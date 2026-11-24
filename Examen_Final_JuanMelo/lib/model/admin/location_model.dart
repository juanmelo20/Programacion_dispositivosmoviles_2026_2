import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/helpers/json_parse.dart';
import 'package:parcial_2/model/local/pending_change_model.dart';

/// Punto ecológico / ubicación (schema `LocationResponse`).
class LocationModel {
  const LocationModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.isActive,
    required this.containerCount,
    required this.activeContainerCount,
    this.description,
    this.buildingZone,
    this.pendingAction,
    this.syncError,
  });

  /// Id de la API. Es negativo si el punto se creó sin conexión y todavía no
  /// existe en el servidor.
  final int id;
  final String name;
  final String? description;
  final String? buildingZone;
  final String displayName;
  final bool isActive;
  final int containerCount;
  final int activeContainerCount;

  /// Cambio hecho sin conexión que falta enviar a la API
  /// (`crear`, `editar` o `eliminar`); null si está al día.
  final String? pendingAction;

  /// Si la API rechazó ese cambio al sincronizar, el motivo.
  final ApiException? syncError;

  /// Creado sin conexión: todavía no existe en el servidor.
  bool get isLocalOnly => id < 0;

  bool get isPending => pendingAction != null;

  /// Eliminado sin conexión: se sigue viendo en la lista (para poder
  /// deshacerlo) hasta que se sincronice.
  bool get isPendingDelete => pendingAction == PendingAction.delete;

  /// Existe en la API y no está por eliminarse: se puede usar en el resto de
  /// la app (asignarle contenedores, filtrar por él).
  bool get isAvailable => !isLocalOnly && !isPendingDelete;

  /// Igual que el backend: «zona · nombre».
  static String displayNameFor(String name, String? zone) {
    final z = zone?.trim() ?? '';
    return z.isEmpty ? name : '$z · $name';
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: JsonParse.toInt(json['id']),
      name: JsonParse.text(json['name']),
      description: JsonParse.textOrNull(json['description']),
      buildingZone: JsonParse.textOrNull(json['building_zone']),
      displayName: JsonParse.text(
        json['display_name'],
        JsonParse.text(json['name']),
      ),
      isActive: JsonParse.toBool(json['is_active'], true),
      containerCount: JsonParse.toInt(json['container_count']),
      activeContainerCount: JsonParse.toInt(json['active_container_count']),
    );
  }

  /// Fila de la tabla `ecopuntos` de SQLite → modelo.
  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] as int,
      name: map['nombre'] as String,
      description: map['descripcion'] as String?,
      buildingZone: map['zona'] as String?,
      displayName: map['nombre_visible'] as String,
      isActive: map['activo'] == 1,
      containerCount: map['contenedores'] as int,
      activeContainerCount: map['contenedores_activos'] as int,
    );
  }

  /// Modelo → fila de la tabla `ecopuntos` de SQLite.
  Map<String, dynamic> toMap({required int position}) {
    return {
      'id': id,
      'posicion': position,
      'nombre': name,
      'descripcion': description,
      'zona': buildingZone,
      'nombre_visible': displayName,
      'activo': isActive ? 1 : 0,
      'contenedores': containerCount,
      'contenedores_activos': activeContainerCount,
    };
  }

  LocationModel copyWith({
    int? id,
    String? name,
    String? description,
    String? buildingZone,
    bool? isActive,
    String? pendingAction,
    ApiException? syncError,
  }) {
    final newName = name ?? this.name;
    final newZone = buildingZone ?? this.buildingZone;
    return LocationModel(
      id: id ?? this.id,
      name: newName,
      description: description ?? this.description,
      buildingZone: newZone,
      displayName: name != null || buildingZone != null
          ? displayNameFor(newName, newZone)
          : displayName,
      isActive: isActive ?? this.isActive,
      containerCount: containerCount,
      activeContainerCount: activeContainerCount,
      pendingAction: pendingAction ?? this.pendingAction,
      syncError: syncError ?? this.syncError,
    );
  }

  factory LocationModel.placeholder([int index = 0]) {
    return LocationModel(
      id: -1 - index,
      name: 'Punto ecológico',
      displayName: 'Punto ecológico de ejemplo',
      description: 'Descripción del punto',
      buildingZone: 'Bloque A',
      isActive: true,
      containerCount: 3,
      activeContainerCount: 3,
    );
  }
}
