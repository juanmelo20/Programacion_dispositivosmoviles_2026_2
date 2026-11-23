import 'dart:convert';

import 'package:parcial_2/helpers/api_exception.dart';

/// Acciones que se pueden hacer sin conexión.
abstract final class PendingAction {
  static const String create = 'crear';
  static const String update = 'editar';
  static const String delete = 'eliminar';
}


class PendingChangeModel {
  PendingChangeModel({
    this.id,
    required this.ecoPointId,
    required this.action,
    required this.data,
    required this.userId,
    required this.createdAt,
    this.error,
  });

  final int? id;

  /// Id del punto ecológico (negativo si se creó sin conexión).
  final int ecoPointId;

  /// [PendingAction.create], [PendingAction.update] o [PendingAction.delete].
  final String action;

  /// Los datos que se enviarán a la API (nombre, zona, descripción, activo).
  final Map<String, dynamic> data;
  final int userId;
  final DateTime createdAt;

  final ApiException? error;

  factory PendingChangeModel.fromMap(Map<String, dynamic> map) {
    final rawError = map['error'] as String?; 
    return PendingChangeModel(
      id: map['id'] as int?,
      ecoPointId: map['ecopunto_id'] as int,
      action: map['accion'] as String,
      data: Map<String, dynamic>.from(jsonDecode(map['datos'] as String)),
      userId: map['usuario_id'] as int,
      createdAt: DateTime.parse(map['creado'] as String),
      error: rawError == null ? null : errorFromJson(rawError),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ecopunto_id': ecoPointId,
      'accion': action,
      'datos': jsonEncode(data),
      'usuario_id': userId,
      'creado': createdAt.toIso8601String(),
      'error': error == null ? null : errorToJson(error!),
    };
  }

  /// El error se guarda como texto JSON en la columna `error`.
  static String errorToJson(ApiException e) => jsonEncode({
    'type': e.type.name,
    'status': e.statusCode,
    'message': e.serverMessage,
    'code': e.errorCode,
    'params': e.errorParams,
  });

  static ApiException errorFromJson(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return ApiException(
      ApiErrorType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => ApiErrorType.unknown,
      ),
      statusCode: map['status'] as int?,
      serverMessage: map['message'] as String?,
      errorCode: map['code'] as String?,
      errorParams: map['params'] is Map
          ? Map<String, dynamic>.from(map['params'] as Map)
          : const {},
    );
  }
}
