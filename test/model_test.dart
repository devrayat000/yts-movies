import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ytsmovies/src/mock/movie.dart';
import 'package:ytsmovies/src/mock/movie_data.dart';
import 'package:ytsmovies/src/mock/torrent.dart';

class MockMovie extends Mock implements Movie {}

class MockTorrent extends Mock implements Torrent {}

class MockMovieData extends Mock implements MovieData {}

void main() {
  var movieData = MockMovieData();
  var movie = MockMovie();

  final limit = 20;
  final count = math.Random().nextInt(365);
  final last = (count / limit).ceil();

  when(movieData.movies).thenReturn(List.generate(4, (index) => MockMovie()));

  when(movieData.limit).thenReturn(limit);
  when(movieData.movieCount).thenReturn(count);
  when(movieData.lastPage).thenReturn(last);

  group('Model Test', () {
    test('MovieData model length test', () {
      expect(movieData.movies!.length, equals(4));
    });
    test('Movie model type test', () {
      expect(movieData.movies!.first.runtimeType, equals(movie.runtimeType));
    });
    test('MovieData last page', () {
      expect(movieData.lastPage,
          equals((movieData.movieCount / movieData.limit).ceil()));
    });
  });
}
