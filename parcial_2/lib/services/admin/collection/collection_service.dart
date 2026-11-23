import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_request.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/model/admin/collection_model.dart';

/// Historial de recolecciones.
class CollectionService {
  CollectionService(this._dio);

  final Dio _dio;

  /// GET /collections — de los últimos [days] días.
  Future<List<CollectionModel>> list({
    required int days,
    String? category,
    int? containerId,
    int limit = 200,
  }) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    return safeRequest(
      () => _dio.get(
        ApiConfig.collections,
        queryParameters: cleanQuery({
          'start': Formatters.apiDate(start),
          'end': Formatters.apiDate(end),
          'category': category,
          'container_id': containerId,
          'limit': limit,
        }),
      ),
      (data) => parseList(data, CollectionModel.fromJson),
    );
  }
}
