import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';
import 'index.dart';
import '../utils/api.dart';
import '../utils/constants.dart';
import '../utils/exceptions.dart';
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

  late CancelableOperation<List<Movie>> _latestFuture;
  late CancelableOperation<List<Movie>> _hdFuture;
  late CancelableOperation<List<Movie>> _ratedFuture;

  final _latestCache = AsyncCache<List<Movie>>(Duration(hours: 1));
  final _hdCache = AsyncCache<List<Movie>>(Duration(hours: 1));
  final _ratedCache = AsyncCache<List<Movie>>(Duration(hours: 1));

  static const _historyKey = 'search-history';

  @override
  void initState() {
    _client = http.Client();

    _latestFuture = CancelableOperation<List<Movie>>.fromFuture(
        _fetch(_latestCache, Query.latest));
    _hdFuture = CancelableOperation<List<Movie>>.fromFuture(Future.delayed(
      Duration(seconds: 2),
      () => _fetch(_hdCache, Query.hd),
    ));
    _ratedFuture = CancelableOperation<List<Movie>>.fromFuture(Future.delayed(
      Duration(seconds: 4),
      () => _fetch(_ratedCache, Query.rated),
    ));

    super.initState();
  }

  @override
  void deactivate() {
    _latestFuture.cancel();
    _hdFuture.cancel();
    _ratedFuture.cancel();
    super.deactivate();
  }

  Future<List<Movie>> _fetch(
    AsyncCache<List<Movie>> _cacher, [
    Query query = Query.latest,
  ]) async {
    try {
      final storedMovies = getCache<List<Movie>>(key: '$query');

      if (storedMovies != null) {
        return storedMovies;
      }
      Future<http.Response> _resolver;
      final _limit = 10;

      switch (query) {
        case Query.latest:
          _resolver = Api.latestMovies(1, _limit);
          break;
        case Query.hd:
          _resolver = Api.hd4kMovies(1, _limit);
          break;
        case Query.mostDownloaded:
          _resolver = Api.mostDownloadedMovies(1, _limit);
          break;
        case Query.mostLiked:
          _resolver = Api.mostLikedMovies(1, _limit);
          break;
        case Query.rated:
          _resolver = Api.ratedMovies(1, _limit);
          break;
        default:
          _resolver = Api.latestMovies(1, _limit);
      }

      final movies = await _cacher.fetch(() async {
        try {
          final response = await _resolver;
          final movies =
              await compute(MyGlobals.parseResponseData, response.body);
          if (movies == null) {
            throw NotFoundException('No movie found! 😥');
          } else {
            return movies;
          }
        } catch (e) {
          throw e;
        }
      });
      setCache<List<Movie>>(key: '$query', data: movies);

      return movies;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void _routeHandler<T>(PageRoute<T> Function(BuildContext) handler) async {
    try {
      await Navigator.of(context).push(handler(context));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: MyGlobals.bucket,
      child: Scaffold(
        appBar: const HomeAppbar(),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ScrollConfiguration(
            behavior: MaterialScrollBehavior(),
            child: ListView(
              children: [
                InkWell(
                  onTap: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final _history = prefs.getStringList(_historyKey);

                      showSearch(
                        context: context,
                        delegate: MovieSearchDelegate(history: _history),
                      );
                    } catch (e) {
                      print(e);
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
                  future: _latestFuture.value,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () => _routeHandler(Routes.latest),
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('4k-movies-intro'),
                  title: Text('4K Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headline5,
                  future: _hdFuture.value,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () => _routeHandler(Routes.hd),
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('rated-movies-intro'),
                  title: Text('Highly Rated Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headline5,
                  future: _ratedFuture.value,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () => _routeHandler(Routes.rated),
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
          } catch (e) {
            print(e);
          }
        },
        enableFeedback: false,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              MovieImage(
                src: movie.coverImg.medium,
                id: movie.id,
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
