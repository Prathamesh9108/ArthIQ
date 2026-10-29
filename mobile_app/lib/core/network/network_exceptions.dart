class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  NetworkException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException({super.message = 'Session expired, please login again'})
      : super(statusCode: 401);
}

class NotFoundException extends NetworkException {
  NotFoundException({super.message = 'Resource not found'})
      : super(statusCode: 404);
}

class ServerErrorException extends NetworkException {
  ServerErrorException({super.message = 'Internal server error. Please try again later.'})
      : super(statusCode: 500);
}

class NoInternetException extends NetworkException {
  NoInternetException({super.message = 'No internet connection detected'})
      : super(statusCode: 0);
}
