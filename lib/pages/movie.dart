import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart'
    show BreadCrumb, BreadCrumbItem;
// import 'package:provider/provider.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../widgets/image.dart';
import '../widgets/torrent_tab.dart';
import '../widgets/movie_suggestions.dart';
import '../widgets/buttons/download_button.dart' show DownloadButton;
import '../widgets/buttons/favourite_button.dart';
import '../models/movie.dart';

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

class _MoviePageState extends State<MoviePage> {
  late YoutubePlayerController _controller;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  int _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget._movie.trailer)!,
      flags: const YoutubePlayerFlags(
        mute: true,
        autoPlay: true,
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
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
    super.initState();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language =
        LocaleNames.of(context)?.nameOf(widget._movie.language) ?? 'English';

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
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
              _controller.metadata.title,
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
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          title: Text(
            widget._movie.title,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
          centerTitle: true,
          actions: [FavouriteButton(movie: widget._movie)],
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            int sensitivity = 8;
            if (details.delta.dx > sensitivity) {
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      widget._movie.title,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    _space(),
                    Text(
                      widget._movie.year,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    _space(),
                    BreadCrumb.builder(
                      itemCount: widget._movie.genres.length,
                      builder: (i) => BreadCrumbItem(
                        content: Text(
                          widget._movie.genres[i],
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      divider: const Text(
                        '/',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _space(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MovieImage(
                            src: widget._movie.coverImg.medium,
                            color: Colors.white,
                            padding: 4.0,
                            id: widget._movie.id,
                          ),
                        ),
                        _rowSpace(spacing: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language),
                              Text(widget._movie.mpaRating),
                              Chip(
                                avatar: Image.asset(
                                  'images/logo-imdb.png',
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.star),
                                ),
                                label: Text('${widget._movie.rating} / 10'),
                                padding: EdgeInsets.only(left: 16, right: 4),
                                deleteIcon: Icon(Icons.star),
                                deleteIconColor: Colors.green,
                                onDeleted: null,
                              ),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 2.0,
                                children: widget._movie.torrents
                                    .map((t) => DownloadButton(torrent: t))
                                    .toList(),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    final subTitleUri =
                                        'https://yifysubtitles.org/movie-imdb/${widget._movie.imdbCode}';
                                    if (await canLaunch(subTitleUri)) {
                                      launch(subTitleUri);
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                icon: const Icon(Icons.subtitles),
                                label: const Text('Subtitles'),
                              ),
                              widget._movie.runtime != 0
                                  ? TextButton.icon(
                                      onPressed: null,
                                      icon: Icon(Icons.alarm),
                                      label: Text(_runtimeFormat),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _space(),
                    TorrentTab(torrents: widget._movie.torrents),
                    _space(),
                    player,
                    _space(),
                    Text(
                      'Synopsis',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    _space(),
                    Text(
                      widget._movie.synopsis,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    _space(),
                  ]),
                ),
                Suggestions(id: widget._movie.id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _runtimeFormat {
    final _duration = Duration(minutes: widget._movie.runtime);
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
