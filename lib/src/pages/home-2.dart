import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/utils/index.dart';

// import 'package:shared_preferences/shared_preferences.dart';

class HomePage2 extends StatefulWidget {
  static const routeName = '/';
  const HomePage2({Key? key}) : super(key: key);

  @override
  HomePage2State createState() => HomePage2State();
}

class HomePage2State extends State<HomePage2> with PageStorageCache<HomePage2> {
  Future<List<Movie>> _getLatestMovie() async {
    final repo = context.read<MoviesClient>();
    final response = await repo.getMovieList();
    return response.data.movies ?? [];
  }

  Future<List<Movie>> _getHDMovie() async {
    final repo = context.read<MoviesClient>();
    final response = await repo.getMovieList(quality: Quality.$2160);
    return response.data.movies ?? [];
  }

  Future<List<Movie>> _getRatedMovie() async {
    final repo = context.read<MoviesClient>();
    final response = await repo.getMovieList(minimumRating: 5);
    return response.data.movies ?? [];
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
                    //   await showSearch(
                    //     context: context,
                    //     delegate: MovieSearchDelegate(repo),
                    //   );
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
                  future: _getLatestMovie(),
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () {
                    context.goNamed("latest");
                  },
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('4k-movies-intro'),
                  title: const Text('4K Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                  future: _getHDMovie(),
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () {
                    context.goNamed("4k");
                  },
                ),
                _space,
                IntroItem(
                  key: const PageStorageKey('rated-movies-intro'),
                  title: const Text('Highly Rated Movies'),
                  titleTextStyle: Theme.of(context).textTheme.headlineSmall,
                  future: _getRatedMovie(),
                  itemBuilder: (context, movie, i) {
                    return _image(movie);
                  },
                  onAction: () {
                    context.goNamed("rated");
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
          context.goNamed(
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
