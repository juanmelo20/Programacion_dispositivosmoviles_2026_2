import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_request.dart';
import 'package:parcial_2/model/admin/event_model.dart';

/// Bitácora de eventos (solo administrador).
class EventService {
  EventService(this._dio);

  final Dio _dio;

  /// GET /events — paginada.
  Future<PageModel<EventModel>> list({
    int page = 1,
    int pageSize = 25,
    String? level,
    String? query,
  }) {
    return safeRequest(
      () => _dio.get(
        ApiConfig.events,
        queryParameters: cleanQuery({
          'page': page,
          'page_size': pageSize,
          'level': level,
          'q': query,
        }),
      ),
      (data) => PageModel.fromJson(asJsonMap(data), EventModel.fromJson),
    );
  }

  /// GET /events/types — nombres legibles de cada tipo de evento.
  Future<Map<String, String>> types() {
    return safeRequest(
      () => _dio.get(ApiConfig.eventTypes),
      (data) => {
        for (final entry in asJsonMap(data).entries)
          entry.key: entry.value.toString(),
      },
    );
  }
}
