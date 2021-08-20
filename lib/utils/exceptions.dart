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
}

// class NotFoundException implements Exception {
//   final String message;
//   final Uri? uri;

//   const NotFoundException(this.message, {this.uri});

//   @override
//   String toString() => 'NotFoundException: $message for uri $uri';
// }

class TorrentClientException implements Exception {
  final String message;
  final Uri? uri;

  const TorrentClientException(this.message, {this.uri});

  String toString() {
    var b = new StringBuffer()
      ..write('TorrentClientException: ')
      ..write(message);
    if (uri != null) {
      b.write(', uri = $uri');
    }
    return b.toString();
  }
}
