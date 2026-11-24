import 'package:parcial_2/helpers/json_parse.dart';

/// Categorías de residuos que maneja EcoTrack.
abstract final class WasteCategory {
  static const String recyclable = 'aprovechable';
  static const String organic = 'organico_aprovechable';
  static const String nonRecyclable = 'no_aprovechable';

  static const List<String> all = [recyclable, organic, nonRecyclable];
}

/// Estados de llenado de un contenedor.
abstract final class FillStatus {
  static const String normal = 'normal';
  static const String attention = 'atencion';
  static const String full = 'lleno';

  static const List<String> all = [normal, attention, full];
}

/// Contenedor con su llenado ya calculado (schema `ContainerState`).
class ContainerModel {
  const ContainerModel({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.categoryLabel,
    required this.locationId,
    required this.locationName,
    required this.capacityUnits,
    required this.fillThreshold,
    required this.usesGlobalThreshold,
    required this.currentCount,
    required this.fillPercentage,
    required this.rawPercentage,
    required this.status,
    required this.statusLabel,
    required this.isActive,
    this.lastCollectedAt,
    this.updatedAt,
  });

  final int id;
  final String code;
  final String name;
  final String category;
  final String categoryLabel;
  final int locationId;
  final String locationName;
  final int capacityUnits;
  final double fillThreshold;
  final bool usesGlobalThreshold;
  final int currentCount;

  /// Porcentaje de llenado 
  final double fillPercentage;

  /// Porcentaje sin límite 
  final double rawPercentage;

  /// normal | atencion | lleno
  final String status;
  final String statusLabel;
  final bool isActive;
  final DateTime? lastCollectedAt;
  final DateTime? updatedAt;

  bool get needsCollection =>
      status == FillStatus.attention || status == FillStatus.full;

  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      id: JsonParse.toInt(json['id']),
      code: JsonParse.text(json['code']),
      name: JsonParse.text(json['name']),
      category: JsonParse.text(json['category']),
      categoryLabel: JsonParse.text(json['category_label']),
      locationId: JsonParse.toInt(json['location_id']),
      locationName: JsonParse.text(json['location_name']),
      capacityUnits: JsonParse.toInt(json['capacity_units']),
      fillThreshold: JsonParse.toDouble(json['fill_threshold']),
      usesGlobalThreshold: JsonParse.toBool(
        json['uses_global_threshold'],
        true,
      ),
      currentCount: JsonParse.toInt(json['current_count']),
      fillPercentage: JsonParse.toDouble(json['fill_percentage']),
      rawPercentage: JsonParse.toDouble(json['raw_percentage']),
      status: JsonParse.text(json['status'], FillStatus.normal),
      statusLabel: JsonParse.text(json['status_label']),
      isActive: JsonParse.toBool(json['is_active'], true),
      lastCollectedAt: JsonParse.date(json['last_collected_at']),
      updatedAt: JsonParse.date(json['updated_at']),
    );
  }

  /// Datos de ejemplo que se dibujan como esqueleto mientras carga la lista.
  factory ContainerModel.placeholder([int index = 0]) {
    return ContainerModel(
      id: -1 - index,
      code: 'C-00',
      name: 'Contenedor de ejemplo',
      category: WasteCategory.all[index % 3],
      categoryLabel: 'Aprovechable',
      locationId: 0,
      locationName: 'Bloque administrativo',
      capacityUnits: 50,
      fillThreshold: 80,
      usesGlobalThreshold: true,
      currentCount: 25,
      fillPercentage: 50,
      rawPercentage: 50,
      status: FillStatus.normal,
      statusLabel: 'Normal',
      isActive: true,
    );
  }

  /// Modelo → JSON (con los mismos nombres de la API). Se usa para guardar
  /// la ruta del recolector en SQLite y leerla después con [fromJson].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      'category_label': categoryLabel,
      'location_id': locationId,
      'location_name': locationName,
      'capacity_units': capacityUnits,
      'fill_threshold': fillThreshold,
      'uses_global_threshold': usesGlobalThreshold,
      'current_count': currentCount,
      'fill_percentage': fillPercentage,
      'raw_percentage': rawPercentage,
      'status': status,
      'status_label': statusLabel,
      'is_active': isActive,
      'last_collected_at': lastCollectedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
