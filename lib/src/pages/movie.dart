import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:ytsmovies/src/services/error_notification_service.dart';

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

    return MyFutureBuilder<MovieResponse>(
      future: context.read<MoviesClient>().getMovieByid(id.toString()),
      errorBuilder: (context, error) {
        return ErrorDisplayWidget(
          error: error!,
          onRetry: () {
            // Trigger a rebuild by setting state
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MoviePage(id: id),
              ),
            );
          },
        );
      },
      successBuilder: (context, response) {
        if (response?.data.movie != null) {
          return MovieDetails(movie: response!.data.movie);
        } else {
          return ErrorDisplayWidget(
            error: CustomException('Movie not found'),
            onRetry: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MoviePage(id: id),
                ),
              );
            },
          );
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
    super.initState();
    _initializeYouTubePlayer();
    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;
  }

  void _initializeYouTubePlayer() {
    try {
      if (widget._movie.trailer == null || widget._movie.trailer!.isEmpty) {
        log('No trailer URL available for movie: ${widget._movie.title}');
        return;
      }

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
        );

        _controller!
          ..unMute()
          ..setVolume(volume)
          ..addListener(_listener);
      } else {
        log('Failed to extract YouTube video ID from URL: ${widget._movie.trailer}');
      }
    } catch (error, stackTrace) {
      log(
        'Error initializing YouTube player: $error',
        error: error,
        stackTrace: stackTrace,
      );
      // Don't show error to user for trailer issues, just log it
    }
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
    final theme = Theme.of(context);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _movie.year.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        language,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
                        image: CachedNetworkImageProvider(
                          _movie.backgroundImage,
                          cacheKey: _movie.backgroundImage,
                        ),
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
                            id: _movie.id.toString(),
                          ),
                        ),
                        _rowSpace(spacing: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_movie.mpaRating != null)
                                Text(
                                  _movie.mpaRating!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                    ],
                                  ),
                                ),
                              Material(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius: BorderRadius.circular(20.0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 6.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'images/logo-imdb.png',
                                        width: 20,
                                        height: 20,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.star, size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_movie.rating} / 10',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _space(spacing: 6.0),
                              Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 12.0,
                                runSpacing: 4.0,
                                children: [
                                  ..._movie.torrents
                                      .map((t) => DownloadButton(
                                            torrent: t,
                                            title: _movie.title,
                                          ))
                                      .toList(),
                                ],
                              ),
                              _space(spacing: 6.0),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16.0),
                                  onTap: () async {
                                    try {
                                      final subTitleUri = Uri.parse(
                                          'https://yifysubtitles.org/movie-imdb/${_movie.imdbCode}');
                                      if (await canLaunchUrl(subTitleUri)) {
                                        await launchUrl(subTitleUri);
                                      } else {
                                        if (context.mounted) {
                                          context.showError(
                                            CustomException(
                                                'Cannot open subtitles link'),
                                            customMessage:
                                                'Unable to open subtitles page',
                                          );
                                        }
                                      }
                                    } on PlatformException catch (e, s) {
                                      log('Platform error opening subtitles: ${e.message}',
                                          error: e, stackTrace: s);
                                      if (context.mounted) {
                                        context.showError(
                                          e,
                                          customMessage:
                                              'Failed to open subtitles',
                                        );
                                      }
                                    } catch (e, s) {
                                      log('Error opening subtitles: $e',
                                          error: e, stackTrace: s);
                                      if (context.mounted) {
                                        context.showError(
                                          e,
                                          customMessage:
                                              'Failed to open subtitles',
                                        );
                                      }
                                    }
                                  },
                                  splashColor: Colors.white.withOpacity(0.1),
                                  highlightColor:
                                      Colors.white.withOpacity(0.05),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.subtitles,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Subtitles',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (_movie.runtime != 0) ...[
                                _space(spacing: 6.0),
                                Material(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 6.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.alarm,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _runtimeFormat,
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]
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
                      borderRadius: BorderRadiusGeometry.circular(16.0),
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
                  Text(
                    'Suggested movies',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  _space(),
                  Suggestions(id: _movie.id.toString()),
                ]),
              ),
            ),
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
