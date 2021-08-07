class NotFoundException implements Exception {
  final String message;
  final Uri? uri;

  const NotFoundException(this.message, {this.uri});

  @override
  String toString() => 'NotFoundException: $message for uri $uri';
}

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
