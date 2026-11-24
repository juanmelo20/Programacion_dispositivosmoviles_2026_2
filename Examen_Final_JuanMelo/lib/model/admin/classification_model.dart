import 'package:parcial_2/helpers/json_parse.dart';

/// Residuo clasificado por la IA (schema `ClassificationItem`, campos que
/// usa la app).
class ClassificationModel {
  const ClassificationModel({
    required this.id,
    required this.createdAt,
    required this.label,
    required this.predictedCategory,
    required this.predictedCategoryLabel,
    required this.confidence,
    required this.status,
    required this.statusLabel,
    this.containerCode,
    this.locationName,
    this.imageUrl,
  });

  final int id;
  final DateTime createdAt;

  /// Objeto detectado (ej. "botella plástica").
  final String label;
  final String predictedCategory;
  final String predictedCategoryLabel;

  /// Confianza del modelo entre 0 y 1.
  final double confidence;
  final String status;
  final String statusLabel;
  final String? containerCode;
  final String? locationName;

  /// Ruta relativa de la imagen (/media/...), si se guardó.
  final String? imageUrl;

  factory ClassificationModel.fromJson(Map<String, dynamic> json) {
    return ClassificationModel(
      id: JsonParse.toInt(json['id']),
      createdAt: JsonParse.date(json['created_at']) ?? DateTime.now(),
      label: JsonParse.text(json['label']),
      predictedCategory: JsonParse.text(json['predicted_category']),
      predictedCategoryLabel: JsonParse.text(json['predicted_category_label']),
      confidence: JsonParse.toDouble(json['confidence']),
      status: JsonParse.text(json['status']),
      statusLabel: JsonParse.text(json['status_label']),
      containerCode: JsonParse.textOrNull(json['container_code']),
      locationName: JsonParse.textOrNull(json['location_name']),
      imageUrl: JsonParse.textOrNull(json['image_url']),
    );
  }
}
