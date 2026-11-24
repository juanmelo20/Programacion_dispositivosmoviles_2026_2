import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_request.dart';
import 'package:parcial_2/model/admin/terminal_model.dart';

/// Terminales de los puntos ecológicos (solo administrador).
class TerminalService {
  TerminalService(this._dio);

  final Dio _dio;

  /// GET /terminales — asignadas (por punto) y las que esperan asignación.
  Future<List<TerminalModel>> list() {
    return safeRequest(
      () => _dio.get(ApiConfig.terminals),
      (data) => parseList(data, TerminalModel.fromJson),
    );
  }

  /// GET /terminales/codigo/{code} — busca la terminal que muestra ese
  /// código para confirmar cuál es antes de asignarla.
  Future<TerminalLookupModel> lookup(String code) {
    return safeRequest(
      () => _dio.get(ApiConfig.terminalByCode(code)),
      (data) => TerminalLookupModel.fromJson(asJsonMap(data)),
    );
  }

  /// POST /terminales/asignar — asigna la terminal a un punto que ya existe
  /// ([locationId]) o a uno nuevo ([newPointName]). Con un punto nuevo el
  /// servidor crea también sus tres contenedores.
  Future<TerminalAssignResultModel> assign({
    required String code,
    int? locationId,
    String? newPointName,
    String? newPointZone,
    String? newPointDescription,
  }) {
    final data = <String, dynamic>{'code': code};
    if (locationId != null) {
      data['location_id'] = locationId;
    } else {
      data['new_location'] = {
        'name': newPointName,
        'building_zone': _orNull(newPointZone),
        'description': _orNull(newPointDescription),
      };
    }
    return safeRequest(
      () => _dio.post(ApiConfig.terminalAssign, data: data),
      (data) => TerminalAssignResultModel.fromJson(asJsonMap(data)),
    );
  }

  /// DELETE /terminales/{id} — quita la terminal.
  Future<void> delete(int id) {
    return safeRequest(() => _dio.delete(ApiConfig.terminal(id)), (_) {});
  }

  static String? _orNull(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
