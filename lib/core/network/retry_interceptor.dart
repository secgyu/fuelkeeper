import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 400),
    Random? random,
  }) : _random = random ?? Random();

  final int maxRetries;
  final Duration baseDelay;
  final Random _random;

  static const _attemptKey = '_retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final method = err.requestOptions.method.toUpperCase();
    if (method != 'GET' && method != 'HEAD') {
      return handler.next(err);
    }
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;
    if (attempt >= maxRetries) {
      return handler.next(err);
    }

    final delay = _backoffDelay(attempt);
    if (kDebugMode) {
      debugPrint(
        '[retry] ${err.requestOptions.uri} attempt=${attempt + 1}/$maxRetries '
        'in ${delay.inMilliseconds}ms (${err.type}/${err.response?.statusCode})',
      );
    }
    await Future<void>.delayed(delay);

    try {
      final newOptions = err.requestOptions.copyWith(
        extra: {...err.requestOptions.extra, _attemptKey: attempt + 1},
      );
      final dio = Dio(
        BaseOptions(
          baseUrl: err.requestOptions.baseUrl,
          connectTimeout: err.requestOptions.connectTimeout,
          receiveTimeout: err.requestOptions.receiveTimeout,
          sendTimeout: err.requestOptions.sendTimeout,
          queryParameters: err.requestOptions.queryParameters,
          headers: err.requestOptions.headers,
        ),
      );
      final response = await dio.fetch<dynamic>(newOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        return status >= 500 && status < 600;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  Duration _backoffDelay(int attempt) {
    final base = baseDelay.inMilliseconds * (1 << attempt);
    final jitter = _random.nextInt((baseDelay.inMilliseconds ~/ 2) + 1);
    return Duration(milliseconds: base + jitter);
  }
}
