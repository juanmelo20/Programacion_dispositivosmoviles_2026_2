import 'package:dio/dio.dart';

import 'package:parcial_2/helpers/api_exception.dart';

/// Ejecuta una petición HTTP dentro de un try/catch y convierte la respuesta.
///
/// 1. Hace la petición.
/// 2. Revisa el estatus (solo 2xx es éxito).
/// 3. Mapea la respuesta con [parse].
/// Si algo falla (red, servidor o un JSON inesperado), lanza una
/// [ApiException] controlada para que la app no se caiga.
Future<T> safeRequest<T>(
  Future<Response<dynamic>> Function() send,
  T Function(dynamic data) parse,
) async {
  try {
    final response = await send();
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw ApiException(
        ApiException.typeForStatus(status),
        statusCode: status,
      );
    }
    return parse(response.data);
  } on ApiException {
    rethrow;
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  } catch (e) {
    throw ApiException(ApiErrorType.unknown, debugDetail: e.toString());
  }
}

/// Convierte una respuesta JSON en lista de modelos.
List<T> parseList<T>(
  dynamic data,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (data is! List) {
    throw const FormatException('Se esperaba una lista en la respuesta');
  }
  return data.whereType<Map<String, dynamic>>().map(fromJson).toList();
}

/// Verifica que la respuesta sea un objeto JSON.
Map<String, dynamic> asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  throw const FormatException('Se esperaba un objeto en la respuesta');
}

/// Quita los parámetros vacíos antes de enviarlos en la URL.
Map<String, dynamic> cleanQuery(Map<String, dynamic> params) {
  return {
    for (final entry in params.entries)
      if (entry.value != null && entry.value.toString().trim().isNotEmpty)
        entry.key: entry.value,
  };
}
