import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/helpers/token.dart';


class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenStorage, this.onUnauthorized});

  final TokenStorage tokenStorage;
  final void Function()? onUnauthorized;

  bool _isPublic(String path) => ApiConfig.publicPaths.contains(path);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';

    if (!_isPublic(options.path)) {
      final token = await tokenStorage.readToken();
      if (token == null || token.isEmpty) {
        // Ruta protegida sin token (se borró o se modificó): la petición no
        // se envía, se cierra la sesión y la app vuelve al login.
        onUnauthorized?.call();
        return handler.reject(
          DioException(
            requestOptions: options,
            error: const ApiException(ApiErrorType.unauthorized),
          ),
        );
      }
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = ApiException.fromDio(err);

    // Solo en modo debug: el detalle técnico va a la consola, no al usuario.
    if (kDebugMode) {
      debugPrint(
        '[API] ${err.requestOptions.method} ${err.requestOptions.uri} → '
        '$apiError ${apiError.debugDetail ?? ''}',
      );
    }

    if (apiError.type == ApiErrorType.unauthorized &&
        !_isPublic(err.requestOptions.path)) {
      onUnauthorized?.call();
    }

    handler.next(err.copyWith(error: apiError));
  }
}
