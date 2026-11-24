import 'package:parcial_2/helpers/json_parse.dart';
import 'package:parcial_2/model/admin/classification_model.dart';
import 'package:parcial_2/model/admin/collection_model.dart';
import 'package:parcial_2/model/admin/container_model.dart';

/// Detalle de un contenedor (schema `ContainerDetail`).
/// El recolector recibe una vista resumida: sin clasificaciones recientes.
class ContainerDetailModel {
  const ContainerDetailModel({
    required this.container,
    required this.totalClassifications,
    required this.classificationsSinceCollection,
    required this.lowConfidenceCount,
    required this.collections,
    required this.recentClassifications,
    required this.isSummary,
    this.locationDescription,
  });

  final ContainerModel container;
  final String? locationDescription;
  final int totalClassifications;
  final int classificationsSinceCollection;
  final int lowConfidenceCount;
  final List<CollectionModel> collections;
  final List<ClassificationModel> recentClassifications;
  final bool isSummary;

  factory ContainerDetailModel.fromJson(Map<String, dynamic> json) {
    return ContainerDetailModel(
      container: ContainerModel.fromJson(
        json['container'] as Map<String, dynamic>? ?? const {},
      ),
      locationDescription: JsonParse.textOrNull(json['location_description']),
      totalClassifications: JsonParse.toInt(json['total_classifications']),
      classificationsSinceCollection: JsonParse.toInt(
        json['classifications_since_collection'],
      ),
      lowConfidenceCount: JsonParse.toInt(json['low_confidence_count']),
      collections: JsonParse.list(json['collections'])
          .map(CollectionModel.fromJson)
          .toList(),
      recentClassifications: JsonParse.list(json['recent_classifications'])
          .map(ClassificationModel.fromJson)
          .toList(),
      isSummary: JsonParse.toBool(json['is_summary']),
    );
  }

  factory ContainerDetailModel.placeholder() {
    return ContainerDetailModel(
      container: ContainerModel.placeholder(),
      locationDescription: 'Descripción del punto ecológico',
      totalClassifications: 120,
      classificationsSinceCollection: 25,
      lowConfidenceCount: 3,
      collections: [
        CollectionModel.placeholder(0),
        CollectionModel.placeholder(1),
      ],
      recentClassifications: const [],
      isSummary: true,
    );
  }
}

/// Punto de la gráfica de llenado (schema `FillPoint`).
class FillPointModel {
  const FillPointModel({
    required this.time,
    required this.count,
    required this.percentage,
    required this.event,
  });

  final DateTime time;
  final int count;
  final double percentage;

  /// inicio | clasificacion | recoleccion | actual
  final String event;

  factory FillPointModel.fromJson(Map<String, dynamic> json) {
    return FillPointModel(
      time: JsonParse.date(json['t']) ?? DateTime.now(),
      count: JsonParse.toInt(json['count']),
      percentage: JsonParse.toDouble(json['percentage']),
      event: JsonParse.text(json['event']),
    );
  }
}

/// Evolución del llenado (schema `FillHistory`).
class FillHistoryModel {
  const FillHistoryModel({
    required this.container,
    required this.points,
    required this.threshold,
    required this.capacityUnits,
  });

  final ContainerModel container;
  final List<FillPointModel> points;
  final double threshold;
  final int capacityUnits;

  factory FillHistoryModel.fromJson(Map<String, dynamic> json) {
    return FillHistoryModel(
      container: ContainerModel.fromJson(
        json['container'] as Map<String, dynamic>? ?? const {},
      ),
      points: JsonParse.list(json['points'])
          .map(FillPointModel.fromJson)
          .toList(),
      threshold: JsonParse.toDouble(json['threshold'], 80),
      capacityUnits: JsonParse.toInt(json['capacity_units']),
    );
  }

  factory FillHistoryModel.placeholder() {
    final now = DateTime.now();
    return FillHistoryModel(
      container: ContainerModel.placeholder(),
      points: [
        for (var i = 0; i < 8; i++)
          FillPointModel(
            time: now.subtract(Duration(hours: 8 - i)),
            count: i * 5,
            percentage: i * 10.0,
            event: 'clasificacion',
          ),
      ],
      threshold: 80,
      capacityUnits: 50,
    );
  }
}
