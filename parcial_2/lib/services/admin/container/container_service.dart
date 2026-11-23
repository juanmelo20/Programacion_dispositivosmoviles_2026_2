import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_request.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/model/admin/collection_model.dart';
import 'package:parcial_2/model/admin/container_detail_model.dart';
import 'package:parcial_2/model/admin/container_model.dart';

/// Contenedores: consultar ("productos"), guardar y registrar recolecciones.
class ContainerService {
  ContainerService(this._dio);

  final Dio _dio;

  /// GET /containers — lista con filtros (todos los perfiles).
  Future<List<ContainerModel>> list({
    String? category,
    String? status,
    String? query,
    int? locationId,
    bool includeInactive = false,
  }) {
    return safeRequest(
      () => _dio.get(
        ApiConfig.containers,
        queryParameters: cleanQuery({
          'category': category,
          'status': status,
          'q': query,
          'location_id': locationId,
          'include_inactive': includeInactive ? 'true' : null,
        }),
      ),
      (data) => parseList(data, ContainerModel.fromJson),
    );
  }

  /// GET /containers/alerts — los que superan el umbral, por prioridad.
  Future<List<ContainerModel>> alerts({int? locationId}) {
    return safeRequest(
      () => _dio.get(
        ApiConfig.alerts,
        queryParameters: cleanQuery({'location_id': locationId}),
      ),
      (data) => parseList(data, ContainerModel.fromJson),
    );
  }

  /// GET /containers/{id} — detalle (administrador y recolector).
  Future<ContainerDetailModel> detail(int id) {
    return safeRequest(
      () => _dio.get(ApiConfig.container(id)),
      (data) => ContainerDetailModel.fromJson(asJsonMap(data)),
    );
  }

  /// GET /containers/{id}/fill-history — evolución del llenado.
  Future<FillHistoryModel> fillHistory(int id, {int days = 14}) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    return safeRequest(
      () => _dio.get(
        ApiConfig.fillHistory(id),
        queryParameters: {
          'start': Formatters.apiDate(start),
          'end': Formatters.apiDate(end),
        },
      ),
      (data) => FillHistoryModel.fromJson(asJsonMap(data)),
    );
  }

  /// POST /containers — crea un contenedor (administrador).
  Future<ContainerModel> create({
    required String name,
    required String category,
    required int locationId,
    String? code,
    int? capacityUnits,
    double? fillThreshold,
  }) {
    return safeRequest(
      () => _dio.post(
        ApiConfig.containers,
        data: {
          'name': name,
          'category': category,
          'location_id': locationId,
          if (code != null && code.trim().isNotEmpty) 'code': code.trim(),
          // El "?" envía la clave solo si el valor no es null.
          'capacity_units': ?capacityUnits,
          'fill_threshold': ?fillThreshold,
        },
      ),
      (data) => ContainerModel.fromJson(asJsonMap(data)),
    );
  }

  /// PUT /containers/{id} — edita, retira o reactiva (administrador).
  Future<ContainerModel> update(int id, Map<String, dynamic> changes) {
    return safeRequest(
      () => _dio.put(ApiConfig.container(id), data: changes),
      (data) => ContainerModel.fromJson(asJsonMap(data)),
    );
  }

  /// POST /containers/{id}/collections — registra la recolección.
  Future<CollectionResultModel> registerCollection(int id, {String? notes}) {
    final text = notes?.trim() ?? '';
    return safeRequest(
      () => _dio.post(
        ApiConfig.containerCollections(id),
        data: {'notes': text.isEmpty ? null : text},
      ),
      (data) => CollectionResultModel.fromJson(asJsonMap(data)),
    );
  }
}
