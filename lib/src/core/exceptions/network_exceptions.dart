class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, {required this.statusCode});

  @override
  String toString() => 'HttpException [$statusCode]: $message';
}
