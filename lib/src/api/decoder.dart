import 'dart:async';
import 'dart:convert' show json;

import 'package:squadron/squadron.dart';
import 'package:squadron/squadron_annotations.dart';

import 'decoder.activator.g.dart';
part 'decoder.worker.g.dart';

@SquadronService()
class JsonDecodeService extends WorkerService
    with $JsonDecodeServiceOperations {
  @SquadronMethod()
  Future<dynamic> jsonDecode(String source) async => json.decode(source);
}
