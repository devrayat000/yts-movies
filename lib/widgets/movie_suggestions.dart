// import 'dart:convert' show jsonDecode;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ytsmovies/utils/constants.dart';
import 'package:ytsmovies/utils/exceptions.dart';

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
    _future = _suggestionsFuture;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _future,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('😥');
      case ConnectionState.waiting:
      case ConnectionState.active:
        return _loader;
      case ConnectionState.done:
        if (snapshot.hasError) {
          return SliverList(
            delegate: SliverChildListDelegate([
              Container(
                child: Text(snapshot.error.toString()),
              ),
            ]),
          );
        } else if (snapshot.hasData) {
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
        } else {
          return _loader;
        }
      default:
        return _loader;
    }
  }

  Widget get _loader => SliverList(
        delegate: SliverChildListDelegate(const [
          MyGlobals.kCircularLoading,
        ]),
      );

  Future<List<Movie>> get _suggestionsFuture async {
    try {
      final uri = Uri.https(
        'yts.mx',
        '/api/v2/movie_suggestions.json',
        {'movie_id': widget.id},
      );
      var response = await http.get(uri);
      final movies = await compute(MyGlobals.parseResponseData, response.body);
      if (movies == null) {
        throw CustomException('No movie found! 😥');
      } else {
        return movies;
      }
    } on HttpException catch (e, s) {
      throw CustomException(e.message, s);
    } on SocketException catch (_, s) {
      throw CustomException('No internet connection', s);
    } on TimeoutException catch (_, s) {
      throw CustomException('The request timed out', s);
    } on CustomException {
      rethrow;
    } catch (e, s) {
      print(e);
      print(s);
      throw CustomException('Unknown error occured!', s);
    }
  }
}
