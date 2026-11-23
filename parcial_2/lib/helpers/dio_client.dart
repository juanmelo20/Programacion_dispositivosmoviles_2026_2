import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/interceptor.dart';
import 'package:parcial_2/helpers/token.dart';

/// Crea el cliente HTTP (Dio) que usa toda la app.
class DioClient {
  DioClient._();

  static Dio create({
    required TokenStorage tokenStorage,
    void Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}',
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
        // respuestas del servidor exito
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onUnauthorized: onUnauthorized,
      ),
    );
    return dio;
  }
}
