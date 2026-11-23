import 'package:parcial_2/helpers/json_parse.dart';

/// Estados de una terminal (los códigos que envía el backend).
abstract final class TerminalStatus {
  static const String unassigned = 'sin_asignar';
  static const String assigned = 'asignada';
  static const String changeRequested = 'cambio_pedido';
}

/// Terminal del punto ecológico (schema `TerminalItem`).
class TerminalModel {
  const TerminalModel({
    required this.id,
    required this.label,
    required this.status,
    required this.online,
    this.device,
    this.locationId,
    this.locationName,
    this.lastSeenAt,
    this.assignedAt,
  });

  final int id;

  /// Nombre corto, por ejemplo «T-05».
  final String label;
  final String status;

  /// Se comunicó hace poco (la pantalla de la terminal está abierta).
  final bool online;

  /// Navegador y equipo con que se registró.
  final String? device;
  final int? locationId;
  final String? locationName;
  final DateTime? lastSeenAt;
  final DateTime? assignedAt;

  bool get isAssigned => locationId != null;

  factory TerminalModel.fromJson(Map<String, dynamic> json) {
    return TerminalModel(
      id: JsonParse.toInt(json['id']),
      label: JsonParse.text(json['label']),
      status: JsonParse.text(json['status'], TerminalStatus.unassigned),
      online: JsonParse.toBool(json['online']),
      device: JsonParse.textOrNull(json['device']),
      locationId: JsonParse.toIntOrNull(json['location_id']),
      locationName: JsonParse.textOrNull(json['location_name']),
      lastSeenAt: JsonParse.date(json['last_seen_at']),
      assignedAt: JsonParse.date(json['assigned_at']),
    );
  }

  /// Datos de ejemplo para dibujar el esqueleto mientras carga.
  factory TerminalModel.placeholder([int index = 0]) {
    return TerminalModel(
      id: index + 1,
      label: 'T-0${index + 1}',
      status: TerminalStatus.assigned,
      online: true,
      device: 'Chrome en Android',
      locationId: 1,
      locationName: 'Bloque A · Punto ecológico',
      lastSeenAt: DateTime(2026),
    );
  }
}

/// Terminal encontrada con su código, antes de asignarla.
class TerminalLookupModel {
  const TerminalLookupModel({
    required this.terminal,
    required this.isChange,
    required this.codeExpiresIn,
  });

  final TerminalModel terminal;

  /// `true` si ya tenía punto y se pidió cambiarla de lugar.
  final bool isChange;

  /// Segundos que le quedan al código.
  final int codeExpiresIn;

  factory TerminalLookupModel.fromJson(Map<String, dynamic> json) {
    return TerminalLookupModel(
      terminal: TerminalModel.fromJson(json),
      isChange: JsonParse.text(json['purpose']) == 'cambiar',
      codeExpiresIn: JsonParse.toInt(json['code_expires_in']),
    );
  }
}

/// Resultado de asignar una terminal a un punto.
class TerminalAssignResultModel {
  const TerminalAssignResultModel({
    required this.terminal,
    required this.locationName,
    required this.createdLocation,
    required this.containersCreated,
    this.previousLocation,
  });

  final TerminalModel terminal;
  final String locationName;
  final String? previousLocation;

  /// Se creó un punto nuevo al asignar.
  final bool createdLocation;

  /// Códigos de los contenedores que se crearon (C-13, C-14...).
  final List<String> containersCreated;

  factory TerminalAssignResultModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    return TerminalAssignResultModel(
      terminal: TerminalModel.fromJson(
        json['terminal'] is Map<String, dynamic>
            ? json['terminal'] as Map<String, dynamic>
            : const {},
      ),
      locationName: location is Map
          ? JsonParse.text(
              location['display_name'],
              JsonParse.text(location['name']),
            )
          : '',
      previousLocation: JsonParse.textOrNull(json['previous_location']),
      createdLocation: JsonParse.toBool(json['created_location']),
      containersCreated: json['containers_created'] is List
          ? (json['containers_created'] as List)
                .map((code) => code.toString())
                .toList()
          : const [],
    );
  }
}
