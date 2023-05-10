import 'package:equatable/equatable.dart';

class CustomException with EquatableMixin implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const CustomException(this.message, [this.stackTrace]);

  @override
  String toString() {
    return '$runtimeType: $message,\n $stackTrace';
  }

  @override
  List<Object?> get props => [message, stackTrace];

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
