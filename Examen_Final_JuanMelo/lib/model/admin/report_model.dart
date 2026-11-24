import 'package:parcial_2/helpers/json_parse.dart';
import 'package:parcial_2/model/admin/container_model.dart';

/// Cantidad por categoría (schema `CategoryCount`).
class CategoryCountModel {
  const CategoryCountModel({
    required this.category,
    required this.label,
    required this.count,
    required this.percentage,
  });

  final String category;
  final String label;
  final int count;
  final double percentage;

  factory CategoryCountModel.fromJson(Map<String, dynamic> json) {
    return CategoryCountModel(
      category: JsonParse.text(json['category']),
      label: JsonParse.text(json['label']),
      count: JsonParse.toInt(json['count']),
      percentage: JsonParse.toDouble(json['percentage']),
    );
  }
}

/// Total de un día (schema `DailyPoint`).
class DailyPointModel {
  const DailyPointModel({
    required this.date,
    required this.total,
    required this.byCategory,
  });

  final DateTime date;
  final int total;
  final Map<String, int> byCategory;

  factory DailyPointModel.fromJson(Map<String, dynamic> json) {
    return DailyPointModel(
      date: JsonParse.date(json['date']) ?? DateTime.now(),
      total: JsonParse.toInt(json['total']),
      byCategory: JsonParse.intMap(json['by_category']),
    );
  }
}

/// Total por ubicación (schema `LocationCount`).
class LocationCountModel {
  const LocationCountModel({
    required this.locationId,
    required this.locationName,
    required this.total,
  });

  final int locationId;
  final String locationName;
  final int total;

  factory LocationCountModel.fromJson(Map<String, dynamic> json) {
    return LocationCountModel(
      locationId: JsonParse.toInt(json['location_id']),
      locationName: JsonParse.text(json['location_name']),
      total: JsonParse.toInt(json['total']),
    );
  }
}

/// Uso por hora del día (schema `HourCount`).
class HourCountModel {
  const HourCountModel({required this.hour, required this.count});

  final int hour;
  final int count;

  factory HourCountModel.fromJson(Map<String, dynamic> json) {
    return HourCountModel(
      hour: JsonParse.toInt(json['hour']),
      count: JsonParse.toInt(json['count']),
    );
  }
}

/// Contenedor con más residuos (schema `ContainerCount`).
class ContainerCountModel {
  const ContainerCountModel({
    required this.containerId,
    required this.code,
    required this.name,
    required this.locationName,
    required this.category,
    required this.count,
  });

  final int containerId;
  final String code;
  final String name;
  final String locationName;
  final String category;
  final int count;

  factory ContainerCountModel.fromJson(Map<String, dynamic> json) {
    return ContainerCountModel(
      containerId: JsonParse.toInt(json['container_id']),
      code: JsonParse.text(json['code']),
      name: JsonParse.text(json['name']),
      locationName: JsonParse.text(json['location_name']),
      category: JsonParse.text(json['category']),
      count: JsonParse.toInt(json['count']),
    );
  }
}

/// Indicadores del panel del administrador (schema `OverviewKpis`).
class OverviewKpisModel {
  const OverviewKpisModel({
    required this.totalClassifications,
    required this.classificationsToday,
    required this.activeContainers,
    required this.attentionCount,
    required this.fullCount,
    required this.averageFill,
    required this.pendingReview,
    required this.collectionsToday,
  });

  final int totalClassifications;
  final int classificationsToday;
  final int activeContainers;
  final int attentionCount;
  final int fullCount;
  final double averageFill;
  final int pendingReview;
  final int collectionsToday;

  factory OverviewKpisModel.fromJson(Map<String, dynamic> json) {
    return OverviewKpisModel(
      totalClassifications: JsonParse.toInt(json['total_classifications']),
      classificationsToday: JsonParse.toInt(json['classifications_today']),
      activeContainers: JsonParse.toInt(json['active_containers']),
      attentionCount: JsonParse.toInt(json['attention_count']),
      fullCount: JsonParse.toInt(json['full_count']),
      averageFill: JsonParse.toDouble(json['average_fill']),
      pendingReview: JsonParse.toInt(json['pending_review']),
      collectionsToday: JsonParse.toInt(json['collections_today']),
    );
  }
}

/// Panel general del administrador (schema `Overview`).
class OverviewModel {
  const OverviewModel({
    required this.kpis,
    required this.byCategory30d,
    required this.alerts,
  });

  final OverviewKpisModel kpis;
  final List<CategoryCountModel> byCategory30d;
  final List<ContainerModel> alerts;

  factory OverviewModel.fromJson(Map<String, dynamic> json) {
    return OverviewModel(
      kpis: OverviewKpisModel.fromJson(
        json['kpis'] as Map<String, dynamic>? ?? const {},
      ),
      byCategory30d: JsonParse.list(json['by_category_30d'])
          .map(CategoryCountModel.fromJson)
          .toList(),
      alerts: JsonParse.list(json['alerts'])
          .map(ContainerModel.fromJson)
          .toList(),
    );
  }

  factory OverviewModel.placeholder() {
    return OverviewModel(
      kpis: const OverviewKpisModel(
        totalClassifications: 1000,
        classificationsToday: 40,
        activeContainers: 12,
        attentionCount: 3,
        fullCount: 1,
        averageFill: 45,
        pendingReview: 2,
        collectionsToday: 4,
      ),
      byCategory30d: const [],
      alerts: [ContainerModel.placeholder(0), ContainerModel.placeholder(1)],
    );
  }
}

/// Totales del informe (schema `AnalyticsTotals`).
class AnalyticsTotalsModel {
  const AnalyticsTotalsModel({
    required this.classifications,
    required this.valid,
    required this.lowConfidence,
    required this.rejected,
    required this.averageConfidence,
    required this.collections,
    required this.unitsCollected,
    required this.dailyAverage,
  });

  final int classifications;
  final int valid;
  final int lowConfidence;
  final int rejected;

  /// Entre 0 y 1.
  final double averageConfidence;
  final int collections;
  final int unitsCollected;
  final double dailyAverage;

  factory AnalyticsTotalsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsTotalsModel(
      classifications: JsonParse.toInt(json['classifications']),
      valid: JsonParse.toInt(json['valid']),
      lowConfidence: JsonParse.toInt(json['low_confidence']),
      rejected: JsonParse.toInt(json['rejected']),
      averageConfidence: JsonParse.toDouble(json['average_confidence']),
      collections: JsonParse.toInt(json['collections']),
      unitsCollected: JsonParse.toInt(json['units_collected']),
      dailyAverage: JsonParse.toDouble(json['daily_average']),
    );
  }
}

/// Informe analítico por periodo (schema `Analytics`).
class AnalyticsModel {
  const AnalyticsModel({
    required this.start,
    required this.end,
    required this.days,
    required this.totals,
    required this.byCategory,
    required this.daily,
    required this.byLocation,
    required this.byHour,
    required this.topContainers,
  });

  final DateTime start;
  final DateTime end;
  final int days;
  final AnalyticsTotalsModel totals;
  final List<CategoryCountModel> byCategory;
  final List<DailyPointModel> daily;
  final List<LocationCountModel> byLocation;
  final List<HourCountModel> byHour;
  final List<ContainerCountModel> topContainers;

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      start: JsonParse.date(json['start']) ?? DateTime.now(),
      end: JsonParse.date(json['end']) ?? DateTime.now(),
      days: JsonParse.toInt(json['days']),
      totals: AnalyticsTotalsModel.fromJson(
        json['totals'] as Map<String, dynamic>? ?? const {},
      ),
      byCategory: JsonParse.list(json['by_category'])
          .map(CategoryCountModel.fromJson)
          .toList(),
      daily: JsonParse.list(json['daily'])
          .map(DailyPointModel.fromJson)
          .toList(),
      byLocation: JsonParse.list(json['by_location'])
          .map(LocationCountModel.fromJson)
          .toList(),
      byHour: JsonParse.list(json['by_hour'])
          .map(HourCountModel.fromJson)
          .toList(),
      topContainers: JsonParse.list(json['top_containers'])
          .map(ContainerCountModel.fromJson)
          .toList(),
    );
  }

  factory AnalyticsModel.placeholder() {
    final now = DateTime.now();
    return AnalyticsModel(
      start: now.subtract(const Duration(days: 29)),
      end: now,
      days: 30,
      totals: const AnalyticsTotalsModel(
        classifications: 1200,
        valid: 1100,
        lowConfidence: 60,
        rejected: 40,
        averageConfidence: 0.85,
        collections: 30,
        unitsCollected: 900,
        dailyAverage: 40,
      ),
      byCategory: const [
        CategoryCountModel(
          category: WasteCategory.recyclable,
          label: 'Aprovechable',
          count: 500,
          percentage: 45,
        ),
        CategoryCountModel(
          category: WasteCategory.organic,
          label: 'Orgánico',
          count: 400,
          percentage: 35,
        ),
        CategoryCountModel(
          category: WasteCategory.nonRecyclable,
          label: 'No aprovechable',
          count: 200,
          percentage: 20,
        ),
      ],
      daily: [
        for (var i = 0; i < 14; i++)
          DailyPointModel(
            date: now.subtract(Duration(days: 13 - i)),
            total: 20 + (i * 7) % 30,
            byCategory: const {},
          ),
      ],
      byLocation: const [
        LocationCountModel(locationId: 1, locationName: 'Punto A', total: 400),
        LocationCountModel(locationId: 2, locationName: 'Punto B', total: 300),
      ],
      byHour: [
        for (var h = 6; h < 20; h++)
          HourCountModel(hour: h, count: (h * 3) % 17),
      ],
      topContainers: const [],
    );
  }
}
