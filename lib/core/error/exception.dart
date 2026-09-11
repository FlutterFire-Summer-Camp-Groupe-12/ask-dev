class ServerException implements Exception {
  final String? message;

  ServerException({this.message = 'Server error'});

  @override
  String toString() => message ?? 'Server error';
}

class NetworkException implements Exception {
  final String? message;

  NetworkException({this.message = 'Network error'});

  @override
  String toString() => message ?? 'Network error';
}

class CacheException implements Exception {
  final String? message;

  CacheException({this.message = 'Cache error'});

  @override
  String toString() => message ?? 'Cache error';
}

class NotFoundException implements Exception {
  final String? message;

  NotFoundException({this.message = 'Resource not found'});

  @override
  String toString() => message ?? 'Resource not found';
}

class BadRequestException implements Exception {
  final String? message;

  BadRequestException({this.message = 'Bad request'});

  @override
  String toString() => message ?? 'Bad request';
}

class UnauthorizedException implements Exception {
  final String? message;

  UnauthorizedException({this.message = 'Unauthorized'});

  @override
  String toString() => message ?? 'Unauthorized';
}

class ForbiddenException implements Exception {
  final String? message;

  ForbiddenException({this.message = 'Access forbidden'});

  @override
  String toString() => message ?? 'Access forbidden';
}

class TimeoutException implements Exception {
  final String? message;

  TimeoutException({this.message = 'Request timeout'});

  @override
  String toString() => message ?? 'Request timeout';
}

class ConnectionException implements Exception {
  final String? message;

  ConnectionException({this.message = 'Connection failed'});

  @override
  String toString() => message ?? 'Connection failed';
}

class TypeErrorException implements Exception {
  final String? message;

  TypeErrorException({this.message = 'Converting type error'});

  @override
  String toString() => message ?? 'Converting type error';
}

class FormatException implements Exception {
  final String? message;

  FormatException({this.message = 'Invalid format'});

  @override
  String toString() => message ?? 'Invalid format';
}

class ExpiredSessionException implements Exception {
  final String? message;

  ExpiredSessionException({this.message = 'Session expired'});

  @override
  String toString() => message ?? 'Session expired';
}

class ValidationException implements Exception {
  final String? message;

  ValidationException({this.message = 'Validation error'});

  @override
  String toString() => message ?? 'Validation error';
}

class EmptyDataException implements Exception {
  final String? message;

  EmptyDataException({this.message = 'No data found'});

  @override
  String toString() => message ?? 'No data found';
}

class FileException implements Exception {
  final String? message;

  FileException({this.message = 'File error'});

  @override
  String toString() => message ?? 'File error';
}