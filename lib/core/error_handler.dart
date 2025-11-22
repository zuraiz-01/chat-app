import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exceptions.dart';

/// Global error handler for consistent error management
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Handle and display errors consistently
  void handleError(
    dynamic error, {
    String? customMessage,
    BuildContext? context,
  }) {
    AppException appException;

    if (error is AppException) {
      appException = error;
    } else if (error is Exception) {
      // Convert common exceptions to AppException
      appException = _convertToAppException(error);
    } else {
      appException = ServiceException('An unexpected error occurred: $error');
    }

    // Log error for debugging
    _logError(appException);

    // Show user-friendly message
    _showErrorMessage(appException, customMessage, context);
  }

  /// Handle async operations with error handling
  Future<Result<T>> handleAsync<T>(
    Future<T> Function() operation, {
    String? customMessage,
    BuildContext? context,
  }) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (e) {
      final appException = e is AppException
          ? e
          : _convertToAppException(e as Exception);
      handleError(appException, customMessage: customMessage, context: context);
      return Result.failure(appException);
    }
  }

  /// Handle Result objects
  void handleResult<T>(
    Result<T> result, {
    String? customMessage,
    BuildContext? context,
  }) {
    if (result.isFailure) {
      handleError(
        result.requireError,
        customMessage: customMessage,
        context: context,
      );
    }
  }

  AppException _convertToAppException(Exception error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return NetworkException(
        'Network error occurred. Please check your connection.',
      );
    } else if (errorString.contains('auth') ||
        errorString.contains('unauthorized')) {
      return AuthException('Authentication failed. Please sign in again.');
    } else if (errorString.contains('permission') ||
        errorString.contains('denied')) {
      return PermissionException(
        'Permission denied. Please check your app permissions.',
      );
    } else if (errorString.contains('validation') ||
        errorString.contains('invalid')) {
      return ValidationException('Invalid input. Please check your data.');
    } else {
      return ServiceException('Service error occurred. Please try again.');
    }
  }

  void _logError(AppException error) {
    // In production, send to logging service
    debugPrint('🚨 App Error: ${error.message}');
    if (error.code != null) {
      debugPrint('   Code: ${error.code}');
    }
    if (error.originalError != null) {
      debugPrint('   Original: ${error.originalError}');
    }
  }

  void _showErrorMessage(
    AppException error,
    String? customMessage,
    BuildContext? context,
  ) {
    final message = customMessage ?? error.message;

    // Use GetX snackbar for consistent UI
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Validate input and throw ValidationException if invalid
  void validateInput(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null || value.trim().isEmpty) {
      throw ValidationException('$fieldName cannot be empty');
    }

    if (minLength != null && value.length < minLength) {
      throw ValidationException(
        '$fieldName must be at least $minLength characters',
      );
    }

    if (maxLength != null && value.length > maxLength) {
      throw ValidationException(
        '$fieldName cannot exceed $maxLength characters',
      );
    }
  }

  /// Check network connectivity
  Future<bool> isNetworkAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }
}
