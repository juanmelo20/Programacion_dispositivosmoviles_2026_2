import 'package:parcial_2/helpers/json_parse.dart';
import 'package:parcial_2/model/admin/container_model.dart';

/// Recolección registrada.
class CollectionModel {
  const CollectionModel({
    required this.id,
    required this.containerId,
    required this.containerCode,
    required this.containerName,
    required this.category,
    required this.categoryLabel,
    required this.locationName,
    required this.unitsCollected,
    required this.fillPercentage,
    required this.createdAt,
    this.collectorName,
    this.notes,
  });

  final int id;
  final int containerId;
  final String containerCode;
  final String containerName;
  final String category;
  final String categoryLabel;
  final String locationName;

  /// Quién recolectó.
  final String? collectorName;
  final int unitsCollected;
  final double fillPercentage;
  final String? notes;
  final DateTime createdAt;

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: JsonParse.toInt(json['id']),
      containerId: JsonParse.toInt(json['container_id']),
      containerCode: JsonParse.text(json['container_code']),
      containerName: JsonParse.text(json['container_name']),
      category: JsonParse.text(json['category']),
      categoryLabel: JsonParse.text(json['category_label']),
      locationName: JsonParse.text(json['location_name']),
      collectorName: JsonParse.textOrNull(json['collector_name']),
      unitsCollected: JsonParse.toInt(json['units_collected']),
      fillPercentage: JsonParse.toDouble(json['fill_percentage']),
      notes: JsonParse.textOrNull(json['notes']),
      createdAt: JsonParse.date(json['created_at']) ?? DateTime.now(),
    );
  }

  factory CollectionModel.placeholder([int index = 0]) {
    return CollectionModel(
      id: -1 - index,
      containerId: 0,
      containerCode: 'C-00',
      containerName: 'Contenedor de ejemplo',
      category: WasteCategory.all[index % 3],
      categoryLabel: 'Aprovechable',
      locationName: 'Bloque administrativo',
      collectorName: 'Recolector de ejemplo',
      unitsCollected: 40,
      fillPercentage: 80,
      createdAt: DateTime.now(),
    );
  }
}

/// Respuesta al registrar una recolección (schema `CollectionResult`).
class CollectionResultModel {
  const CollectionResultModel({
    required this.collection,
    required this.container,
    required this.message,
  });

  final CollectionModel collection;
  final ContainerModel container;
  final String message;

  factory CollectionResultModel.fromJson(Map<String, dynamic> json) {
    return CollectionResultModel(
      collection: CollectionModel.fromJson(
        json['collection'] as Map<String, dynamic>? ?? const {},
      ),
      container: ContainerModel.fromJson(
        json['container'] as Map<String, dynamic>? ?? const {},
      ),
      message: JsonParse.text(json['message']),
    );
  }
}
