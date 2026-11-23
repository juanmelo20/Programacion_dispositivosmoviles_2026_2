import 'package:parcial_2/helpers/json_parse.dart';

/// Niveles de la bitácora (valores del backend).
abstract final class EventLevel {
  static const String info = 'INFO';
  static const String warning = 'ADVERTENCIA';
  static const String error = 'ERROR';

  static const List<String> all = [info, warning, error];
}

/// Evento de la bitácora .
class EventModel {
  const EventModel({
    required this.id,
    required this.createdAt,
    required this.level,
    required this.eventType,
    required this.description,
    this.userName,
    this.containerCode,
  });

  final int id;
  final DateTime createdAt;
  final String level;
  final String eventType;
  final String description;
  final String? userName;
  final String? containerCode;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: JsonParse.toInt(json['id']),
      createdAt: JsonParse.date(json['created_at']) ?? DateTime.now(),
      level: JsonParse.text(json['level'], EventLevel.info),
      eventType: JsonParse.text(json['event_type']),
      description: JsonParse.text(json['description']),
      userName: JsonParse.textOrNull(json['user_name']),
      containerCode: JsonParse.textOrNull(json['container_code']),
    );
  }

  factory EventModel.placeholder([int index = 0]) {
    return EventModel(
      id: -1 - index,
      createdAt: DateTime.now(),
      level: EventLevel.info,
      eventType: 'INICIO_SESION',
      description: 'Descripción de ejemplo del evento registrado',
      userName: 'admin',
    );
  }
}

/// Respuesta paginada.
class PageModel<T> {
  const PageModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < total;

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    return PageModel<T>(
      items: JsonParse.list(json['items']).map(fromItem).toList(),
      total: JsonParse.toInt(json['total']),
      page: JsonParse.toInt(json['page'], 1),
      pageSize: JsonParse.toInt(json['page_size'], 25),
    );
  }
}
