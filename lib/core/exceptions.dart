/// Custom exceptions for better error handling

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class AuthException extends AppException {
  AuthException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class PermissionException extends AppException {
  PermissionException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class ValidationException extends AppException {
  ValidationException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class ServiceException extends AppException {
  ServiceException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

/// Result class for handling success/failure operations
class Result<T> {
  final T? _value;
  final AppException? _error;

  Result.success(T value) : _value = value, _error = null;
  Result.failure(AppException error) : _value = null, _error = error;

  bool get isSuccess => _error == null;
  bool get isFailure => _error != null;

  T get requireValue => _value!;
  AppException get requireError => _error!;

  T? get value => _value;
  AppException? get error => _error;
}
