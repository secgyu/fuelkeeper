import 'package:dio/dio.dart';

enum AppErrorKind {
  network,
  server,
  auth,
  badRequest,
  data,
  permission,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.kind,
    required this.userMessage,
    this.statusCode,
    this.cause,
    this.stackTrace,
  });

  final AppErrorKind kind;
  final String userMessage;
  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  bool get isRetryable =>
      kind == AppErrorKind.network || kind == AppErrorKind.server;

  @override
  String toString() =>
      'AppException(kind: $kind, status: $statusCode, msg: "$userMessage")';

  static AppException fromDio(DioException e) {
    final status = e.response?.statusCode;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          kind: AppErrorKind.network,
          userMessage: '응답이 지연되고 있어요. 잠시 후 다시 시도해주세요.',
          cause: e,
          stackTrace: e.stackTrace,
        );
      case DioExceptionType.connectionError:
        return AppException(
          kind: AppErrorKind.network,
          userMessage: '인터넷 연결을 확인해주세요.',
          cause: e,
          stackTrace: e.stackTrace,
        );
      case DioExceptionType.cancel:
        return AppException(
          kind: AppErrorKind.unknown,
          userMessage: '요청이 취소되었어요.',
          cause: e,
          stackTrace: e.stackTrace,
        );
      case DioExceptionType.badCertificate:
        return AppException(
          kind: AppErrorKind.network,
          userMessage: '보안 인증서 오류가 발생했어요.',
          cause: e,
          stackTrace: e.stackTrace,
        );
      case DioExceptionType.badResponse:
        if (status == 401 || status == 403) {
          return AppException(
            kind: AppErrorKind.auth,
            userMessage: '데이터 제공처 인증에 실패했어요. 잠시 후 다시 시도해주세요.',
            statusCode: status,
            cause: e,
            stackTrace: e.stackTrace,
          );
        }
        if (status != null && status >= 500) {
          return AppException(
            kind: AppErrorKind.server,
            userMessage: '데이터 서버에 일시적인 문제가 있어요. 잠시 후 다시 시도해주세요.',
            statusCode: status,
            cause: e,
            stackTrace: e.stackTrace,
          );
        }
        return AppException(
          kind: AppErrorKind.badRequest,
          userMessage: '요청을 처리하지 못했어요.',
          statusCode: status,
          cause: e,
          stackTrace: e.stackTrace,
        );
      case DioExceptionType.unknown:
        return AppException(
          kind: AppErrorKind.unknown,
          userMessage: '알 수 없는 오류가 발생했어요.',
          cause: e,
          stackTrace: e.stackTrace,
        );
    }
  }

  static AppException from(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    if (error is DioException) return fromDio(error);
    return AppException(
      kind: AppErrorKind.unknown,
      userMessage: '알 수 없는 오류가 발생했어요.',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
