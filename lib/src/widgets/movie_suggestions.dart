// import 'dart:convert' show jsonDecode;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/exceptions.dart';
import '../utils/repository.dart';
import '../widgets/future_builder.dart';
import './cards/movie_card.dart' show MovieCard;
import '../mock/movie.dart';

class Suggestions extends StatefulWidget {
  final String id;
  const Suggestions({Key? key, required this.id}) : super(key: key);

  @override
  _SuggestionsState createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  late Future<List<Movie>> _future;
  @override
  void initState() {
    _future = context.read<MovieRepository>().movieSuggestions(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyFutureBuilder<List<Movie>>(
      future: _future,
      successBuilder: _builder,
      loadingBuilder: (_) => _loader,
      errorBuilder: (context, error) {
        String message;
        if (error is CustomException) {
          message = error.message;
        } else {
          message = error.toString();
        }
        return SliverToBoxAdapter(
          child: Center(
            child: Text(
              message,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        );
      },
    );
  }

  Widget _builder(BuildContext context, List<Movie>? movies) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) => MovieCard.grid(
          movie: movies![i],
        ),
        childCount: movies!.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 17 / 20,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
    );
  }

  Widget get _loader => SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

  // Future<List<Movie>> get _suggestionsFuture =>
  //     context.read<MovieRepository>().movieSuggestions(widget.id);
}
