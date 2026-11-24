import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_request.dart';
import 'package:parcial_2/model/admin/location_model.dart';

/// Puntos ecológicos (ubicaciones).
class LocationService {
  LocationService(this._dio);

  final Dio _dio;

  /// GET /locations
  Future<List<LocationModel>> list({bool includeInactive = false}) {
    return safeRequest(
      () => _dio.get(
        ApiConfig.locations,
        queryParameters: cleanQuery({
          'include_inactive': includeInactive ? 'true' : null,
        }),
      ),
      (data) => parseList(data, LocationModel.fromJson),
    );
  }

  /// POST /locations (administrador)
  Future<LocationModel> create({
    required String name,
    String? description,
    String? buildingZone,
  }) {
    return safeRequest(
      () => _dio.post(
        ApiConfig.locations,
        data: {
          'name': name,
          'description': _orNull(description),
          'building_zone': _orNull(buildingZone),
        },
      ),
      (data) => LocationModel.fromJson(asJsonMap(data)),
    );
  }

  /// PUT /locations/{id} (administrador)
  Future<LocationModel> update(int id, Map<String, dynamic> changes) {
    return safeRequest(
      () => _dio.put(ApiConfig.location(id), data: changes),
      (data) => LocationModel.fromJson(asJsonMap(data)),
    );
  }

  /// DELETE /locations/{id} (administrador)
  Future<void> delete(int id) {
    return safeRequest(() => _dio.delete(ApiConfig.location(id)), (_) {});
  }

  static String? _orNull(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
