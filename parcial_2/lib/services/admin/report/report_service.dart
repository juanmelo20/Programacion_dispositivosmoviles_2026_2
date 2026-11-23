import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_request.dart';
import 'package:parcial_2/helpers/formatters.dart';
import 'package:parcial_2/model/admin/report_model.dart';

/// Informes y panel general.
class ReportService {
  ReportService(this._dio);

  final Dio _dio;

  /// GET /reports/overview — panel del administrador.
  Future<OverviewModel> overview() {
    return safeRequest(
      () => _dio.get(ApiConfig.overview),
      (data) => OverviewModel.fromJson(asJsonMap(data)),
    );
  }

  /// GET /reports/analytics — administrador e interesado.
  Future<AnalyticsModel> analytics({
    required int days,
    String? category,
    int? locationId,
  }) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    return safeRequest(
      () => _dio.get(
        ApiConfig.analytics,
        queryParameters: cleanQuery({
          'start': Formatters.apiDate(start),
          'end': Formatters.apiDate(end),
          'category': category,
          'location_id': locationId,
        }),
      ),
      (data) => AnalyticsModel.fromJson(asJsonMap(data)),
    );
  }
}
