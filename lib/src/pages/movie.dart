import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart'
    show BreadCrumb, BreadCrumbItem;

import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';
import 'package:ytsmovies/src/utils/index.dart';

class MoviePage extends StatelessWidget {
  static const routeName = '/details';

  final Movie? _movie;
  final int id;
  const MoviePage({super.key, required this.id}) : _movie = null;

  MoviePage.withMovie({
    super.key,
    required Movie item,
  })  : _movie = item,
        id = item.id;

  @override
  Widget build(BuildContext context) {
    if (_movie != null) {
      return MovieDetails(movie: _movie!);
    }
    return FutureBuilder(
      future: context.read<MoviesClient>().getMovieByid(id.toString()),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Center(
              child: Text('Could not load data!'),
            );
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              return const Center(
                child: Text('Something went wrong!'),
              );
            } else if (snapshot.hasData) {
              return MovieDetails(movie: snapshot.data!.data.movie);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        }
      },
    );
  }
}

class MovieDetails extends StatefulWidget {
  final Movie _movie;

  const MovieDetails({super.key, required Movie movie}) : _movie = movie;

  @override
  MovieDetailsState createState() => MovieDetailsState();
}

class MovieDetailsState extends State<MovieDetails> with RouteAware {
  YoutubePlayerController? _controller;
  late PlayerState playerState;
  late YoutubeMetaData videoMetaData;
  String language = '';

  int volume = 100;
  bool _isPlayerReady = false;
  bool _wasPlaying = false;

  final _muted = ValueNotifier(false);

  @override
  void initState() {
    final code = YoutubePlayer.convertUrlToId(widget._movie.trailer!);

    if (code != null) {
      _controller = YoutubePlayerController(
        initialVideoId: code,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
          controlsVisibleAtStart: true,
        ),
      )
        ..unMute()
        ..setVolume(volume)
        ..addListener(_listener);
    }

    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller?.pause();
    super.deactivate();
  }

  @override
  void reassemble() {
    _controller?.pause();
    super.reassemble();
  }

  @override
  void didPushNext() {
    if (_controller != null && _controller!.value.isPlaying) {
      _wasPlaying = true;
      _controller?.pause();
    }
    debugPrint('pushed next');
    super.didPushNext();
  }

  @override
  void didPopNext() {
    if (_wasPlaying) {
      _controller?.play();
    }
    debugPrint('popped next');
    super.didPopNext();
  }

  @override
  void dispose() {
    _controller?.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller!.value.isFullScreen) {
      setState(() {
        playerState = _controller!.value.playerState;
        videoMetaData = _controller!.metadata;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      return YoutubePlayerBuilder(
        onExitFullScreen: () {
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        },
        player: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
          onReady: () {
            _isPlayerReady = true;
          },
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _controller!.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 25.0,
              ),
              onPressed: () {
                log('Settings Tapped!');
              },
            ),
          ],
          bottomActions: [
            const SizedBox(width: 8.0),
            IconButton(
              onPressed: () {
                if (_muted.value) {
                  _controller?.unMute();
                  _muted.value = false;
                } else {
                  _controller?.mute();
                  _muted.value = true;
                }
              },
              icon: ValueListenableBuilder<bool>(
                valueListenable: _muted,
                builder: (context, isMuted, child) {
                  return Icon(isMuted ? Icons.volume_mute : Icons.volume_up);
                },
              ),
            ),
            const SizedBox(width: 14.0),
            const CurrentPosition(),
            const SizedBox(width: 8.0),
            const ProgressBar(
              isExpanded: true,
              colors: ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
            ),
            const RemainingDuration(),
            const PlaybackSpeedButton(),
            const FullScreenButton(),
          ],
        ),
        builder: (context, player) => _Screen(
          movie: widget._movie,
          player: player,
        ),
      );
    }
    return _Screen(movie: widget._movie);
  }
}

class _Screen extends StatelessWidget {
  final Movie _movie;
  final Widget? player;
  const _Screen({required Movie movie, this.player}) : _movie = movie;

  @override
  Widget build(BuildContext context) {
    final language = allNativeNames[_movie.language] ?? 'English';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          int sensitivity = 8;
          if (details.delta.dx > sensitivity) {
            context.pop();
          }
        },
        child: CustomScrollView(
          slivers: [
            // TODO: Implement flexible image
            SliverAppBar(
              stretch: true,
              pinned: true,
              snap: false,
              floating: false,
              onStretchTrigger: () async {
                // Triggers when stretching
              },
              stretchTriggerOffset: 200.0,
              expandedHeight: 150.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _movie.title,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                centerTitle: true,
                expandedTitleScale: 1.2,
              ),
              actions: [FavouriteButton(movie: _movie)],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Text(
                    _movie.year.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  _space(),
                  BreadCrumb.builder(
                    itemCount: _movie.genres.length,
                    builder: (i) => BreadCrumbItem(
                      content: Text(
                        _movie.genres[i],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    divider: const Text(
                      ' / ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _space(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_movie.backgroundImage),
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(
                          Colors.black54,
                          BlendMode.overlay,
                        ),
                        onError: (e, s) => debugPrint(e.toString()),
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MovieImage(
                            src: _movie.mediumCoverImage,
                            padding: const EdgeInsets.all(4),
                            id: _movie.id.toString(),
                          ),
                        ),
                        _rowSpace(spacing: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language),
                              if (_movie.mpaRating != null)
                                Text(_movie.mpaRating!),
                              Chip(
                                avatar: Image.asset(
                                  'images/logo-imdb.png',
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.star),
                                ),
                                label: Text('${_movie.rating} / 10'),
                                labelStyle: const TextStyle(color: Colors.grey),
                                padding:
                                    const EdgeInsets.only(left: 16, right: 4),
                                deleteIcon: const Icon(Icons.star),
                                deleteIconColor: Colors.green,
                                onDeleted: null,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadiusGeometry.circular(20.0),
                                  side: BorderSide(color: Colors.grey),
                                ),
                              ),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 2.0,
                                children: _movie.torrents
                                    .map((t) => DownloadButton(
                                          torrent: t,
                                          title: _movie.title,
                                        ))
                                    .toList(),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    final subTitleUri = Uri.parse(
                                        'https://yifysubtitles.org/movie-imdb/${_movie.imdbCode}');
                                    if (await canLaunchUrl(subTitleUri)) {
                                      launchUrl(subTitleUri);
                                    }
                                  } on PlatformException catch (e, s) {
                                    debugPrint(e.message);
                                    debugPrint(s.toString());
                                  } catch (e, s) {
                                    debugPrint(e.toString());
                                    debugPrint(s.toString());
                                  }
                                },
                                icon: const Icon(Icons.subtitles),
                                label: const Text('Subtitles'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  side: const BorderSide(color: Colors.grey),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12.0),
                                ),
                              ),
                              if (_movie.runtime != 0)
                                TextButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Icons.alarm),
                                  label: Text(
                                    _runtimeFormat,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _space(),
                  TorrentTab(torrents: _movie.torrents),
                  _space(),
                  if (player != null) ...[
                    Text(
                      'Trailer',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    _space(),
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(8.0),
                      child: player!,
                    ),
                    _space(),
                  ],
                  Text(
                    'Synopsis',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  _space(),
                  SelectableText(
                    _movie.synopsis ??
                        _movie.descriptionIntro ??
                        _movie.descriptionFull,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  _space(),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Text(
                'Suggested movies',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SliverToBoxAdapter(child: _space()),
            Suggestions(id: _movie.id.toString()),
          ],
        ),
      ),
    );
  }

  String get _runtimeFormat {
    final duration = Duration(minutes: _movie.runtime);
    final hour = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    return '$hour h $mins min';
  }

  Widget _space({double spacing = 4.0}) {
    return SizedBox(height: spacing);
  }

  Widget _rowSpace({double spacing = 16.0}) {
    return SizedBox(width: spacing);
  }
}
