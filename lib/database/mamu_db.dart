import 'package:flutter/foundation.dart' show compute;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

import '../utils/exceptions.dart';
import '../utils/constants.dart' show Col;
import '../models/movie.dart';

class MamuDB {
  late Database _database;
  late String _path;
  static const _dbname = 'yts.db';
  static const _movieTable = 'favmovies';
  static const _torrentTable = 'torrents';
  static const _genreTable = 'genres';
  static const _movieId = 'movieId';
  static const _dateInserted = 'dateInserted';

  MamuDB() {
    open();
  }

  Future<void> open() async {
    try {
      final dbpath = await getDatabasesPath();
      _path = join(dbpath, _dbname);
      _database = await openDatabase(
        _path,
        version: 1,
        onCreate: (Database db, int version) async {
          final batch = db.batch();
          batch.execute('''
              create table $_movieTable ( 
                ${Col.id} text primary key, 
                ${Col.title} text not null, 
                ${Col.year} text not null, 
                ${Col.rating} text not null, 
                ${Col.dateUploaded} text, 
                ${Col.url} text not null, 
                ${Col.imdbCode} text not null, 
                ${Col.language} text not null, 
                ${Col.mpaRating} text not null, 
                ${Col.descriptionFull} text not null, 
                ${Col.synopsis} text not null, 
                ${Col.trailer} text not null, 
                ${Col.runtime} integer not null, 
                ${Col.backgroundImage} text not null, 
                ${Col.smallImage} text not null, 
                ${Col.mediumImage} text not null, 
                ${Col.largeImage} text, 
                $_dateInserted text not null
              )
              ''');

          batch.execute('''
              create table $_torrentTable (
                _id integer primary key autoincrement, 
                $_movieId text not null, 
                ${Col.url} text not null, 
                ${Col.hash} text not null, 
                ${Col.quality} text not null, 
                ${Col.type} text, 
                ${Col.seeds} integer not null, 
                ${Col.peers} integer not null, 
                ${Col.size} text not null, 
                ${Col.dateUploaded} text not null
              )
              ''');

          batch.execute('''
              create table $_genreTable (
                _id integer primary key autoincrement, 
                $_movieId text not null, 
                genre text not null
              )
              ''');

          try {
            await batch.commit(noResult: true);
          } catch (e) {
            throw e;
          }
        },
      );
    } catch (e) {
      throw e;
    }
  }

  // Public methods
  Future<void> insert(Movie movie) async {
    try {
      final batch = _database.batch();
      final _movie = movie.toJSON();
      // print('79: $_movie');
      batch.insert(
        _movieTable,
        _movie
          ..addAll({
            _dateInserted: DateTime.now().toString(),
          }),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      movie.torrents.forEach((torrent) {
        final _torrent = torrent.toJSON()..addAll({_movieId: movie.id});
        // print('83: $_torrent');
        batch.insert(
          _torrentTable,
          _torrent,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      movie.genres.forEach((genre) {
        batch.insert(
          _genreTable,
          {
            _movieId: movie.id,
            'genre': genre,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      await batch.commit(noResult: true);
    } catch (e) {
      throw e;
    }
  }

  Future<void> delete(String id) async {
    final batch = _database.batch();
    batch.delete(_movieTable, where: '${Col.id} = ?', whereArgs: [id]);
    batch.delete(_torrentTable, where: '$_movieId = ?', whereArgs: [id]);
    batch.delete(_genreTable, where: '$_movieId = ?', whereArgs: [id]);
    try {
      await batch.commit(noResult: true);
    } catch (e) {
      throw e;
    }
  }

  Future<void> close() async {
    await _database.close();
  }

  Future<void> deleteDB() async {
    final dbpath = await getDatabasesPath();
    var path = join(dbpath, _dbname);
    await deleteDatabase(path);
  }

  // Public getters
  Database get instance => _database;

  Future<List<String>> get getMovieIds async {
    try {
      final ids = await _database.query(
        _movieTable,
        columns: ['id'],
      );
      return ids.map((e) => e['id'].toString()).toList();
    } catch (e) {
      throw e;
    }
  }

  Future<List<Movie>> get getAll async {
    print(_database);
    final batch = _database.batch();
    batch.query(_movieTable, orderBy: _dateInserted);
    batch.query(_torrentTable);
    batch.query(_genreTable);
    try {
      final data = await batch.commit();

      if (data.length == 0) {
        throw NotFoundException('No movies were found');
      }

      // await this.close();
      return compute(_parseMovies, {
        'movies': data[0] as List? ?? [],
        'torrents': data[1] as List? ?? [],
        'genres': data[2] as List? ?? [],
      });
      // return newMovies;
    } catch (e) {
      throw e;
    }
  }

  static Future<List<Movie>> _parseMovies(Map<String, dynamic> data) async {
    final movies = data['movies'] as List;
    final torrents = data['torrents'] as List;
    final genres = data['genres'] as List;

    // movies.sort((a, b) {
    //   final dateA = DateTime.parse(a[_dateInserted]);
    //   final dateB = DateTime.parse(b[_dateInserted]);
    //   return dateA.compareTo(dateB);
    // });

    return movies.map((movie) {
      var newMovie = {}..addAll(movie);
      newMovie['torrents'] =
          torrents.where((t) => t[_movieId] == newMovie['id']).toList();
      newMovie['genres'] = genres
          .where((g) => g[_movieId] == newMovie['id'])
          .map((g) => g['genre'])
          .toList();
      return Movie.fromJSON(newMovie);
    }).toList();
  }
}
