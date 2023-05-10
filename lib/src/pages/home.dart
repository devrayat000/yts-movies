import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/utils/index.dart';

// import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with PageStorageCache<HomePage> {
  late final Future<MovieListResponse> _latestMovies;
  late final Future<MovieListResponse> _hdMovies;
  late final Future<MovieListResponse> _ratedMovies;

  @override
  void initState() {
    super.initState();
    final repo = context.read<MoviesClient>();
    _latestMovies = repo.getMovieList();
    _hdMovies = repo.getMovieList(quality: Quality.$2160);
    _ratedMovies = repo.getMovieList(minimumRating: 5);
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
                  onTap: () async {
                    // try {
                    await showSearch(
                      context: context,
                      delegate: MovieSearchDelegate(
                        repo: context.read<MoviesClient>(),
                      ),
                    );
                    // } catch (e, s) {
                    //   print(e);
                    //   print(s);
                    // }
                  },
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
                  onAction: () {
                    context.pushNamed("latest");
                  },
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
                  onAction: () {
                    context.pushNamed("4k");
                  },
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('rated-movies-intro'),
                  title: const Text('Highly Rated Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                  future: _ratedMovies,
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () {
                    context.pushNamed("rated");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _space => const SizedBox(height: 8);

  Widget _image(Movie movie) => InkWell(
        onTap: () {
          context.pushNamed(
            "details",
            pathParameters: {"id": movie.id.toString()},
            extra: movie,
          );
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
}
