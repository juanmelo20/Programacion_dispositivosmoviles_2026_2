import 'package:dio/dio.dart';

/// Tipos de error que la app sabe manejar. 
enum ApiErrorType {
  unauthorized,  // 401: token vencido o inválido
  forbidden,     // 403: tu perfil no tiene termisos
  notFound,      // 404: no existe
  validation,    // 400, 409, 422: datos o regla de negocio
  timeout,       // la red tardó demasiado
  noConnection,  // sin internet o servidor apagado
  server,        // 500: falló el servidor
  cancelled,
  unknown,       // cualquier otra cosa
}


class ApiException implements Exception {
  const ApiException(
    this.type, {
    this.statusCode,
    this.debugDetail,
    this.serverMessage,
    this.errorCode,
    this.errorParams = const {},
  });

  final ApiErrorType type;
  final int? statusCode;

  final String? serverMessage;

  final String? errorCode;

  /// Datos del mensaje
  final Map<String, dynamic> errorParams;

  final String? debugDetail;

  /// Error de credenciales o de token (vencido, inválido o sin permisos).
  bool get isAuthError =>
      type == ApiErrorType.unauthorized || type == ApiErrorType.forbidden;

  factory ApiException.fromDio(DioException e) {
    final existing = e.error;
    if (existing is ApiException) return existing;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(ApiErrorType.timeout, debugDetail: e.message);
      case DioExceptionType.connectionError:
        return ApiException(ApiErrorType.noConnection, debugDetail: e.message);
      case DioExceptionType.cancel:
        return const ApiException(ApiErrorType.cancelled);
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final data = e.response?.data;
        final detail = data is Map ? data['detail'] : null;
        if (isGatewayError(e.response)) {
          return ApiException(
            ApiErrorType.noConnection,
            statusCode: code,
            debugDetail: 'Respuesta del túnel o proxy, no del backend: $code',
          );
        }
        final errorCode = data is Map ? data['code'] : null;
        final params = data is Map ? data['params'] : null;
        return ApiException(
          typeForStatus(code),
          statusCode: code,
          debugDetail: data?.toString(),
          serverMessage: detail is String ? detail : null,
          errorCode: errorCode is String ? errorCode : null,
          errorParams: params is Map
              ? Map<String, dynamic>.from(params)
              : const {},
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(
          ApiErrorType.unknown,
          debugDetail: e.message ?? e.error?.toString(),
        );
    }
  }
///Error de gateway (ngrok, Cloudflare, etc.) que no viene del backend.
  static bool isGatewayError(Response<dynamic>? response) {
    if (response == null) return false;
    if (response.headers.value('ngrok-error-code') != null) return true;
    final data = response.data;
    final fromBackend = data is Map && data.containsKey('detail');
    const gatewayCodes = {404, 502, 503, 504, 521, 522, 523, 530};
    return !fromBackend && gatewayCodes.contains(response.statusCode);
  }

  
  static ApiErrorType typeForStatus(int? code) {
    if (code == null) return ApiErrorType.unknown;
    if (code == 401) return ApiErrorType.unauthorized;
    if (code == 403) return ApiErrorType.forbidden;
    if (code == 404) return ApiErrorType.notFound;
    if (code == 400 || code == 409 || code == 422) {
      return ApiErrorType.validation;
    }
    if (code >= 500) return ApiErrorType.server;
    return ApiErrorType.unknown;
  }

  @override
  String toString() =>
      'ApiException(${type.name}${statusCode != null ? ', $statusCode' : ''})';
}
