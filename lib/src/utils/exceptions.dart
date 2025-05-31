import 'package:freezed_annotation/freezed_annotation.dart';

part 'exceptions.freezed.dart';

@Freezed(equal: true, toStringOverride: false, copyWith: false)
sealed class CustomException with _$CustomException implements Exception {
  const factory CustomException(String message, [StackTrace? stackTrace]) =
      _CustomException;

  @override
  String toString() {
    return '$runtimeType: $message,\n $stackTrace';
  }

  static String getCustomError(Object error) {
    return error is CustomException ? error.message : error.toString();
  }
}

class TorrentClientException implements Exception {
  final String message;
  final Uri? uri;

  const TorrentClientException(this.message, {this.uri});

  @override
  String toString() {
    var b = StringBuffer()
      ..write('TorrentClientException: ')
      ..write(message);
    if (uri != null) {
      b.write(', uri = $uri');
    }
    return b.toString();
  }
}
