import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart'
    show BreadCrumb, BreadCrumbItem;
// import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:ytsmovies/src/utils/constants.dart';

import '../utils/locales.dart' show all_native_names;
import '../widgets/image.dart';
import '../widgets/torrent_tab.dart';
import '../widgets/movie_suggestions.dart';
import '../widgets/buttons/download_button.dart' show DownloadButton;
import '../widgets/buttons/favourite_button.dart';
import '../mock/movie.dart';

@immutable
class MoviePage extends StatefulWidget {
  static const routeName = '/details';

  final Movie _movie;
  const MoviePage({Key? key, required Movie item})
      : _movie = item,
        super(key: key);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> with RouteAware {
  YoutubePlayerController? _controller;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  String language = '';

  int _volume = 100;
  bool _isPlayerReady = false;
  bool _wasPlaying = false;

  final _muted = ValueNotifier(false);

  @override
  void initState() {
    final _code = YoutubePlayer.convertUrlToId(widget._movie.trailer!);

    if (_code != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _code,
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
        ..setVolume(_volume)
        ..addListener(_listener);
    }

    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;

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
    print('pushed next');
    super.didPushNext();
  }

  @override
  void didPopNext() {
    if (_wasPlaying) {
      _controller?.play();
    }
    print('popped next');
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
        _playerState = _controller!.value.playerState;
        _videoMetaData = _controller!.metadata;
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
          progressColors: ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
          ),
          onReady: () {
            // _trailerController.addListener(listener);
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
            CurrentPosition(),
            const SizedBox(width: 8.0),
            ProgressBar(
              isExpanded: true,
              colors: ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
            ),
            RemainingDuration(),
            const PlaybackSpeedButton(),
            FullScreenButton(),
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
  const _Screen({Key? key, required Movie movie, this.player})
      : _movie = movie,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = all_native_names[_movie.language] ?? 'English';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _movie.title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        centerTitle: true,
        actions: [FavouriteButton(movie: _movie)],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          int sensitivity = 8;
          if (details.delta.dx > sensitivity) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              // TODO: Implement flexible image
              // SliverAppBar(
              //   collapsedHeight: MediaQuery.of(context).size.width,
              //   expandedHeight: MediaQuery.of(context).size.width / 2 * 3,
              //   flexibleSpace: FlexibleSpaceBar(),
              // ),
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  SelectableText(
                    _movie.title,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  _space(),
                  Text(
                    _movie.year.toString(),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  _space(),
                  BreadCrumb.builder(
                    itemCount: _movie.genres.length,
                    builder: (i) => BreadCrumbItem(
                      content: Text(
                        _movie.genres[i],
                        style: Theme.of(context).textTheme.headline5,
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
                        colorFilter: ColorFilter.mode(
                          Colors.black54,
                          BlendMode.overlay,
                        ),
                        onError: (e, s) => print(e),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MovieImage(
                            src: _movie.mediumCoverImage,
                            padding: const EdgeInsets.all(4),
                            id: _movie.id.toString(),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _rowSpace(spacing: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language),
                              Text(_movie.mpaRating),
                              Chip(
                                avatar: Image.asset(
                                  'images/logo-imdb.png',
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.star),
                                ),
                                label: Text('${_movie.rating} / 10'),
                                padding: EdgeInsets.only(left: 16, right: 4),
                                deleteIcon: Icon(Icons.star),
                                deleteIconColor: Colors.green,
                                onDeleted: null,
                              ),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 2.0,
                                children: _movie.torrents
                                    .map((t) => DownloadButton(torrent: t))
                                    .toList(),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    final subTitleUri =
                                        'https://yifysubtitles.org/movie-imdb/${_movie.imdbCode}';
                                    if (await canLaunch(subTitleUri)) {
                                      launch(subTitleUri);
                                    }
                                  } on PlatformException catch (e, s) {
                                    print(e.message);
                                    print(s);
                                  } catch (e, s) {
                                    print(e);
                                    print(s);
                                  }
                                },
                                icon: const Icon(Icons.subtitles),
                                label: const Text('Subtitles'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                              ),
                              if (_movie.runtime != 0)
                                TextButton.icon(
                                  onPressed: null,
                                  icon: Icon(Icons.alarm),
                                  label: Text(
                                    _runtimeFormat,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
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
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    _space(),
                    player!,
                    _space(),
                  ],
                  Text(
                    'Synopsis',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  _space(),
                  SelectableText(
                    _movie.synopsis,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  _space(),
                ]),
              ),
              Suggestions(id: _movie.id.toString()),
            ],
          ),
        ),
      ),
    );
  }

  String get _runtimeFormat {
    final _duration = Duration(minutes: _movie.runtime);
    final hour = _duration.inHours;
    final mins = _duration.inMinutes.remainder(60);
    return '$hour h $mins min';
  }

  Widget _space({double spacing = 16.0}) {
    return SizedBox(height: spacing);
  }

  Widget _rowSpace({double spacing = 16.0}) {
    return SizedBox(width: spacing);
  }
}
