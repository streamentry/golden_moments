import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:golden_moments/data/models/download_error.dart';
import 'package:golden_moments/shared/constants/cache_constants.dart';
import 'package:http/http.dart' as http;

/// HTTP client service with retry logic and timeout handling
class HttpClientService {
  factory HttpClientService() => _instance;
  HttpClientService._internal();
  static final HttpClientService _instance = HttpClientService._internal();

  late final http.Client _client;

  /// Initialize the HTTP client
  void initialize() {
    _client = http.Client();
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }

  /// Download JSON data with retry logic
  Future<Map<String, dynamic>> downloadJson(String url) async {
    final response = await _downloadWithRetry(url);

    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return jsonData;
    } catch (e) {
      throw DownloadError.invalidJson(url, e.toString());
    }
  }

  /// Download binary data (images) with progress callback
  Future<Uint8List> downloadBinary(
    String url, {
    void Function(int downloaded, int total)? onProgress,
  }) async {
    int retryCount = 0;

    while (retryCount < CacheConstants.maxRetryAttempts) {
      try {
        final request = http.Request('GET', Uri.parse(url));
        request.headers.addAll(CacheConstants.defaultHeaders);

        final streamedResponse = await _client
            .send(request)
            .timeout(CacheConstants.downloadTimeout);

        if (streamedResponse.statusCode != 200) {
          throw DownloadError.httpError(
            url,
            streamedResponse.statusCode,
            streamedResponse.reasonPhrase ?? 'Unknown error',
          );
        }

        final contentLength = streamedResponse.contentLength ?? 0;
        final bytes = <int>[];
        int downloadedBytes = 0;

        await for (final chunk in streamedResponse.stream) {
          bytes.addAll(chunk);
          downloadedBytes += chunk.length;

          // Report progress if callback provided
          onProgress?.call(downloadedBytes, contentLength);
        }

        return Uint8List.fromList(bytes);
      } on SocketException catch (e) {
        if (retryCount == CacheConstants.maxRetryAttempts - 1) {
          throw DownloadError.networkError(url, e.message);
        }
      } on HttpException catch (e) {
        if (retryCount == CacheConstants.maxRetryAttempts - 1) {
          throw DownloadError.networkError(url, e.message);
        }
      } on TimeoutException catch (e) {
        if (retryCount == CacheConstants.maxRetryAttempts - 1) {
          throw DownloadError.timeout(url, e.message ?? 'Request timeout');
        }
      } catch (e) {
        if (retryCount == CacheConstants.maxRetryAttempts - 1) {
          throw DownloadError.unknown(url, e.toString());
        }
      }

      retryCount++;
      await _waitForRetry(retryCount);
    }

    throw DownloadError.unknown(url, 'Max retries exceeded');
  }

  /// Check if URL is accessible
  Future<bool> checkConnectivity(String url) async {
    try {
      final response = await _client
          .head(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get file size from URL without downloading
  Future<int> getFileSize(String url) async {
    try {
      final response = await _client
          .head(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw DownloadError.httpError(
          url,
          response.statusCode,
          response.reasonPhrase ?? 'Unknown error',
        );
      }

      final contentLength = response.headers['content-length'];
      if (contentLength != null) {
        return int.parse(contentLength);
      }

      return 0;
    } catch (e) {
      if (e is DownloadError) rethrow;
      throw DownloadError.unknown(url, e.toString());
    }
  }

  /// Download with automatic retry logic
  Future<http.Response> _downloadWithRetry(String url) async {
    int retryCount = 0;

    while (retryCount < CacheConstants.maxRetryAttempts) {
      try {
        final response = await _client
            .get(
              Uri.parse(url),
              headers: CacheConstants.defaultHeaders,
            )
            .timeout(CacheConstants.downloadTimeout);

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 429) {
          // Rate limited - wait longer
          await _waitForRetry(retryCount + 2);
        } else if (response.statusCode >= 400 && response.statusCode < 500) {
          // Client error - don't retry
          throw DownloadError.httpError(
            url,
            response.statusCode,
            response.reasonPhrase ?? 'Client error',
          );
        } else {
          // Server error - retry
          throw DownloadError.httpError(
            url,
            response.statusCode,
            response.reasonPhrase ?? 'Server error',
          );
        }
      } on SocketException catch (e) {
        if (retryCount == CacheConstants.maxRetryAttempts - 1) {
          throw DownloadError.networkError(url, e.message);
        }
      } on HttpException catch (e) {
        if (retryCount == CacheConstants.maxRetryAttempts - 1) {
          throw DownloadError.networkError(url, e.message);
        }
      } on TimeoutException catch (e) {
        if (retryCount == CacheConstants.maxRetryAttempts - 1) {
          throw DownloadError.timeout(url, e.message ?? 'Request timeout');
        }
      } catch (e) {
        if (e is DownloadError) rethrow;
        if (retryCount == CacheConstants.maxRetryAttempts - 1) {
          throw DownloadError.unknown(url, e.toString());
        }
      }

      retryCount++;
      await _waitForRetry(retryCount);
    }

    throw DownloadError.unknown(url, 'Max retries exceeded');
  }

  /// Wait with exponential backoff
  Future<void> _waitForRetry(int attemptNumber) async {
    final delay = CacheConstants.getRetryDelay(attemptNumber);
    await Future<void>.delayed(delay);
  }

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get download speed estimate (bytes per second)
  double calculateDownloadSpeed(int bytesDownloaded, Duration elapsed) {
    if (elapsed.inMilliseconds == 0) return 0.0;
    return bytesDownloaded / (elapsed.inMilliseconds / 1000.0);
  }

  /// Calculate ETA based on current speed
  Duration calculateETA(int bytesRemaining, double bytesPerSecond) {
    if (bytesPerSecond <= 0) return Duration.zero;
    final secondsRemaining = bytesRemaining / bytesPerSecond;
    return Duration(seconds: secondsRemaining.round());
  }

  /// Format download speed for display
  String formatDownloadSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  /// Format ETA for display
  String formatETA(Duration eta) {
    if (eta.inHours > 0) {
      return '${eta.inHours}h ${eta.inMinutes % 60}m';
    } else if (eta.inMinutes > 0) {
      return '${eta.inMinutes}m ${eta.inSeconds % 60}s';
    } else {
      return '${eta.inSeconds}s';
    }
  }
}
