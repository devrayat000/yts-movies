import 'dart:convert' show jsonDecode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './cards/movie_card.dart' show MovieCard;

import '../models/movie.dart';

class Suggestions extends StatelessWidget {
  final String id;
  const Suggestions({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _suggestionsFuture,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
    if (snapshot.hasError) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            child: Text(snapshot.error.toString()),
          ),
        ]),
      );
    } else if (snapshot.hasData) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return _loader;
        case ConnectionState.done:
          final movies = snapshot.data!;
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => MovieCard.grid(
                movie: movies[i],
              ),
              childCount: movies.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 17 / 20,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
          );

        default:
          return _loader;
      }
    } else {
      return _loader;
    }
  }

  Widget get _loader => SliverList(
        delegate: SliverChildListDelegate([
          const Center(
            child: CircularProgressIndicator(),
          )
        ]),
      );

  Future<List<Movie>> get _suggestionsFuture async {
    final uri = Uri.https(
      'yts.mx',
      '/api/v2/movie_suggestions.json',
      {'movie_id': id},
    );
    var response = await http.get(uri);
    return compute(_parseData, response.body);
  }

  static Future<List<Movie>> _parseData(String respBody) async {
    var respData = jsonDecode(respBody);
    var data = respData['data'];

    List movies = data['movies'];
    return movies.map((e) => Movie.fromJSON(e)).toList();
  }
}
