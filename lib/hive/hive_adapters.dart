import 'package:hive_ce/hive.dart';
import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/models/torrent.dart';

export 'package:ytsmovies/src/models/movie.dart';
export 'package:ytsmovies/src/models/torrent.dart';

@GenerateAdapters([
  AdapterSpec<Movie>(),
  AdapterSpec<Torrent>(),
])
part 'hive_adapters.g.dart';
