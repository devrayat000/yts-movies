import 'package:flutter/cupertino.dart' show CupertinoScrollBehavior;
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart'
    show BreadCrumb, BreadCrumbItem;
import 'package:provider/provider.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/image.dart';
import '../widgets/torrent_tab.dart';
import '../widgets/movie_suggestions.dart';
import '../widgets/buttons/download_button.dart' show DownloadButton;
import '../widgets/buttons/favourite_button.dart';
import '../models/movie.dart';

@immutable
class MoviePage extends StatelessWidget {
  static const routeName = '/details';

  final Movie _movie;
  const MoviePage({Key? key, required Movie item})
      : _movie = item,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final language =
        LocaleNames.of(context)?.nameOf(_movie.language) ?? 'English';

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
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            scrollBehavior: CupertinoScrollBehavior(),
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Text(
                    _movie.title,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  _space(),
                  Text(
                    _movie.year,
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
                          src: _movie.coverImg.medium,
                          color: Colors.white,
                          padding: 4.0,
                          id: _movie.id,
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
                                } catch (e) {
                                  print(e);
                                }
                              },
                              icon: const Icon(Icons.subtitles),
                              label: const Text('Subtitles'),
                            ),
                            _movie.runtime != 0
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
                  TorrentTab(torrents: _movie.torrents),
                  _space(),
                  Text(
                    'Synopsis',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  _space(),
                  Text(
                    _movie.synopsis,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  _space(),
                ]),
              ),
              Suggestions(id: _movie.id),
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
