class NotFoundException implements Exception {
  final String message;
  final Uri? uri;

  const NotFoundException(this.message, {this.uri});
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
