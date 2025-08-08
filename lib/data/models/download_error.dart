import 'package:equatable/equatable.dart';

/// Comprehensive download error types with user-friendly messages
class DownloadError extends Equatable implements Exception {
  const DownloadError({
    required this.type,
    required this.url,
    required this.message,
    required this.userMessage,
    this.statusCode,
    this.retryable = false,
  });

  /// Network connection error
  factory DownloadError.networkError(String url, String message) {
    return DownloadError(
      type: DownloadErrorType.network,
      url: url,
      message: message,
      userMessage:
          'Unable to connect to the internet. Please check your connection and try again.',
      retryable: true,
    );
  }

  /// HTTP error with status code
  factory DownloadError.httpError(String url, int statusCode, String message) {
    String userMessage;
    var retryable = false;

    switch (statusCode) {
      case 404:
        userMessage =
            'The requested content was not found. It may have been moved or deleted.';
      case 429:
        userMessage = 'Too many requests. Please wait a moment and try again.';
        retryable = true;
      case 500:
      case 502:
      case 503:
      case 504:
        userMessage =
            'Server is temporarily unavailable. Please try again later.';
        retryable = true;
      default:
        userMessage =
            'Download failed with error $statusCode. Please try again.';
        retryable = statusCode >= 500;
    }

    return DownloadError(
      type: DownloadErrorType.http,
      url: url,
      message: message,
      userMessage: userMessage,
      statusCode: statusCode,
      retryable: retryable,
    );
  }

  /// Request timeout error
  factory DownloadError.timeout(String url, String message) {
    return DownloadError(
      type: DownloadErrorType.timeout,
      url: url,
      message: message,
      userMessage:
          'Download timed out. Please check your connection and try again.',
      retryable: true,
    );
  }

  /// Invalid JSON format error
  factory DownloadError.invalidJson(String url, String message) {
    return DownloadError(
      type: DownloadErrorType.invalidJson,
      url: url,
      message: message,
      userMessage: 'Downloaded content is corrupted. Please try again.',
      retryable: true,
    );
  }

  /// File corruption error
  factory DownloadError.corruption(String url, String message) {
    return DownloadError(
      type: DownloadErrorType.corruption,
      url: url,
      message: message,
      userMessage: 'Downloaded file is corrupted. Please try again.',
      retryable: true,
    );
  }

  /// Storage space error
  factory DownloadError.storageSpace(String url, String message) {
    return DownloadError(
      type: DownloadErrorType.storageSpace,
      url: url,
      message: message,
      userMessage:
          'Not enough storage space. Please free up some space and try again.',
    );
  }

  /// File system error
  factory DownloadError.fileSystem(String url, String message) {
    return DownloadError(
      type: DownloadErrorType.fileSystem,
      url: url,
      message: message,
      userMessage:
          'Unable to save file. Please check permissions and try again.',
      retryable: true,
    );
  }

  /// Cancelled by user
  factory DownloadError.cancelled(String url) {
    return DownloadError(
      type: DownloadErrorType.cancelled,
      url: url,
      message: 'Download cancelled by user',
      userMessage: 'Download was cancelled.',
    );
  }

  /// Unknown error
  factory DownloadError.unknown(String url, String message) {
    return DownloadError(
      type: DownloadErrorType.unknown,
      url: url,
      message: message,
      userMessage: 'An unexpected error occurred. Please try again.',
      retryable: true,
    );
  }

  /// Create from JSON
  factory DownloadError.fromJson(Map<String, dynamic> json) {
    return DownloadError(
      type: DownloadErrorType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => DownloadErrorType.unknown,
      ),
      url: json['url'] as String,
      message: json['message'] as String,
      userMessage: json['userMessage'] as String,
      statusCode: json['statusCode'] as int?,
      retryable: json['retryable'] as bool? ?? false,
    );
  }

  final DownloadErrorType type;
  final String url;
  final String message;
  final String userMessage;
  final int? statusCode;
  final bool retryable;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'url': url,
      'message': message,
      'userMessage': userMessage,
      if (statusCode != null) 'statusCode': statusCode,
      'retryable': retryable,
    };
  }

  /// Get error icon for UI
  String get icon {
    switch (type) {
      case DownloadErrorType.network:
        return '📡';
      case DownloadErrorType.http:
        return '🌐';
      case DownloadErrorType.timeout:
        return '⏱️';
      case DownloadErrorType.invalidJson:
      case DownloadErrorType.corruption:
        return '🔧';
      case DownloadErrorType.storageSpace:
        return '💾';
      case DownloadErrorType.fileSystem:
        return '📁';
      case DownloadErrorType.cancelled:
        return '❌';
      case DownloadErrorType.unknown:
        return '❓';
    }
  }

  /// Get error color for UI
  String get colorHex {
    switch (type) {
      case DownloadErrorType.network:
      case DownloadErrorType.timeout:
        return '#FF9800'; // Orange
      case DownloadErrorType.http:
        return statusCode != null && statusCode! >= 500
            ? '#FF9800'
            : '#F44336'; // Orange for server, red for client
      case DownloadErrorType.invalidJson:
      case DownloadErrorType.corruption:
        return '#FF5722'; // Deep orange
      case DownloadErrorType.storageSpace:
      case DownloadErrorType.fileSystem:
        return '#9C27B0'; // Purple
      case DownloadErrorType.cancelled:
        return '#607D8B'; // Blue grey
      case DownloadErrorType.unknown:
        return '#F44336'; // Red
    }
  }

  /// Check if error suggests network issues
  bool get isNetworkRelated {
    return type == DownloadErrorType.network ||
        type == DownloadErrorType.timeout ||
        (type == DownloadErrorType.http && (statusCode ?? 0) >= 500);
  }

  /// Check if error is temporary and should be retried
  bool get shouldRetry {
    return retryable &&
        (type == DownloadErrorType.network ||
            type == DownloadErrorType.timeout ||
            type == DownloadErrorType.corruption ||
            (type == DownloadErrorType.http && (statusCode ?? 0) >= 500));
  }

  /// Get suggested retry delay
  Duration get suggestedRetryDelay {
    switch (type) {
      case DownloadErrorType.network:
      case DownloadErrorType.timeout:
        return const Duration(seconds: 5);
      case DownloadErrorType.http:
        if (statusCode == 429) return const Duration(minutes: 1);
        if ((statusCode ?? 0) >= 500) return const Duration(seconds: 10);
        return const Duration(seconds: 5);
      case DownloadErrorType.corruption:
        return const Duration(seconds: 2);
      default:
        return const Duration(seconds: 5);
    }
  }

  @override
  List<Object?> get props => [type, url, message, statusCode, retryable];

  @override
  String toString() {
    return 'DownloadError(type: $type, url: $url, message: $message, statusCode: $statusCode)';
  }
}

/// Types of download errors
enum DownloadErrorType {
  network, // Network connection issues
  http, // HTTP status code errors
  timeout, // Request timeout
  invalidJson, // JSON parsing errors
  corruption, // File corruption
  storageSpace, // Insufficient storage
  fileSystem, // File system errors
  cancelled, // User cancelled
  unknown, // Unknown errors
}

/// Extension for error type display names
extension DownloadErrorTypeExtension on DownloadErrorType {
  String get displayName {
    switch (this) {
      case DownloadErrorType.network:
        return 'Network Error';
      case DownloadErrorType.http:
        return 'Server Error';
      case DownloadErrorType.timeout:
        return 'Timeout';
      case DownloadErrorType.invalidJson:
        return 'Invalid Data';
      case DownloadErrorType.corruption:
        return 'Corrupted File';
      case DownloadErrorType.storageSpace:
        return 'Storage Full';
      case DownloadErrorType.fileSystem:
        return 'File System Error';
      case DownloadErrorType.cancelled:
        return 'Cancelled';
      case DownloadErrorType.unknown:
        return 'Unknown Error';
    }
  }
}
