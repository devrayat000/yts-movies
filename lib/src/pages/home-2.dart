import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/router/state.dart';
import 'package:ytsmovies/src/utils/enums.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:ytsmovies/src/utils/error_handler.dart';
import 'package:ytsmovies/src/utils/repository.dart';
import '../mock/movie.dart';
import 'index.dart';
import '../utils/mixins.dart';
import '../widgets/search/search_delegate.dart';
import '../widgets/cards/intro_item.dart';
import '../widgets/image.dart';
import '../widgets/appbars/home_appbar.dart';
import '../widgets/cards/search_card.dart';

class HomePage2 extends StatefulWidget {
  static const routeName = '/';
  const HomePage2({Key? key}) : super(key: key);

  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2>
    with PageStorageCache<HomePage2> {
  late http.Client _client;

  late Future<List<Movie>> _latestFuture;
  late Future<List<Movie>> _hdFuture;
  late Future<List<Movie>> _ratedFuture;

  // static const _historyKey = 'search-history';

  Future<List<List<Movie>>> get _fetcher async {
    try {
      final repo = context.read<MovieRepository>();
      final f = await repo.homePageMovies();

      return f.values.map((e) => e.movies!).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    _client = http.Client();

    final a = _fetcher.catchError((e, s) {
      print(e);
      print(s);
    });

    _latestFuture =
        a.then<List<Movie>>((value) => value[0]).onError(errorHandler);
    _hdFuture = a.then<List<Movie>>((value) => value[1]).onError(errorHandler);
    _ratedFuture =
        a.then<List<Movie>>((value) => value[2]).onError(errorHandler);

    super.initState();
  }

  void _routeHandler<T>(PageRoute<T> Function(BuildContext) handler) async {
    try {
      await Navigator.of(context).push(handler(context));
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MovieRepository>();

    return Scaffold(
      appBar: const HomeAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ScrollConfiguration(
          behavior: MaterialScrollBehavior(),
          child: HeroMode(
            enabled: false,
            child: ListView(
              children: [
                InkWell(
                  onTap: () async {
                    try {
                      await showSearch(
                        context: context,
                        delegate: MovieSearchDelegate(repo),
                      );
                    } catch (e, s) {
                      print(e);
                      print(s);
                    }
                  },
                  child: const SearchTile(),
                  splashFactory: NoSplash.splashFactory,
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('latest-movies-intro'),
                  title: Text('Latest Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headline5,
                  future: _latestFuture,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () {
                    RootRouteScope.of(context).push(StaticPage.LATEST);
                    // _routeHandler(Routes.hd);
                  },
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('4k-movies-intro'),
                  title: Text('4K Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headline5,
                  future: _hdFuture,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () {
                    RootRouteScope.of(context).push(StaticPage.HD);
                    // _routeHandler(Routes.hd);
                  },
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('rated-movies-intro'),
                  title: Text('Highly Rated Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headline5,
                  future: _ratedFuture,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () {
                    RootRouteScope.of(context).push(StaticPage.RATED);
                    // _routeHandler(Routes.hd);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _space => SizedBox(height: 8);

  Widget _image(Movie movie) => InkWell(
        onTap: () async {
          try {
            await Navigator.of(context).push(Routes.details(
              context,
              argument: MovieArg(movie),
            ));
          } catch (e, s) {
            print(e);
            print(s);
          }
        },
        enableFeedback: false,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              MovieImage(
                src: movie.mediumCoverImage,
                id: movie.id.toString(),
                label: movie.imdbCode,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              Container(
                height: 30,
                width: double.infinity,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 1.5, left: 4, right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                ),
                child: Text(
                  movie.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.grey.shade900,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
