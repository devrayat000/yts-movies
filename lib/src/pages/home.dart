import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';
import 'package:ytsmovies/src/services/error_notification_service.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final Future<MovieListResponse> _latestMovies;
  late final Future<MovieListResponse> _hdMovies;
  late final Future<MovieListResponse> _ratedMovies;
  @override
  void initState() {
    super.initState();
    final repo = context.read<MoviesClient>();

    // Initialize futures with error handling
    _latestMovies = _initializeMoviesFuture(() => repo.getMovieList());
    _hdMovies = _initializeMoviesFuture(
        () => repo.getMovieList(quality: Quality.$2160));
    _ratedMovies =
        _initializeMoviesFuture(() => repo.getMovieList(minimumRating: 5));
  }

  /// Wrapper to handle errors and provide consistent error handling
  Future<MovieListResponse> _initializeMoviesFuture(
      Future<MovieListResponse> Function() futureCallback) async {
    try {
      return await futureCallback();
    } catch (error, stackTrace) {
      // Log error for debugging
      log('Movie list fetch error: $error',
          error: error, stackTrace: stackTrace);

      // Re-throw to be handled by FutureBuilder
      rethrow;
    }
  }

  void _handleSearchTap() async {
    try {
      await showSearch(
        context: context,
        delegate: MovieSearchDelegate(
          repo: context.read<MoviesClient>(),
        ),
      );
    } catch (error) {
      if (mounted) {
        context.showError(error, customMessage: 'Failed to open search');
      }
    }
  }

  void _handleNavigation(String routeName) {
    try {
      context.pushNamed(routeName);
    } catch (error) {
      if (mounted) {
        context.showError(error, customMessage: 'Navigation failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior(),
          child: HeroMode(
            enabled: false,
            child: ListView(
              children: [
                InkWell(
                  onTap: _handleSearchTap,
                  splashFactory: NoSplash.splashFactory,
                  child: const SearchTile(),
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('latest-movies-intro'),
                  title: const Text('Latest Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                  future: _latestMovies,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () => _handleNavigation("latest"),
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('4k-movies-intro'),
                  title: const Text('4K Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                  future: _hdMovies,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () => _handleNavigation("4k"),
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('rated-movies-intro'),
                  title: const Text('Top Rated Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                  future: _ratedMovies,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () => _handleNavigation("rated"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _space => const SizedBox(height: 8);
  Widget _image(Movie movie) {
    return MoviePoster(
      movie: movie,
      showFavoriteButton: false,
      onTap: () {
        HapticFeedback.lightImpact();
        context.pushNamed(
          "details",
          pathParameters: {"id": movie.id.toString()},
          extra: movie,
        );
      },
    );
  }
}
