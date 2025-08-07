import '../../domain/entities/metrics_summary.dart';

class MetricsSummaryModel extends MetricsSummary {
  MetricsSummaryModel({
    required super.totalDistance,
    required super.totalDuration,
    required super.averageSpeed,
    required super.maxSpeed,
    required super.minSpeed,
    required super.movementStats,
  });

  factory MetricsSummaryModel.fromJson(Map<String, dynamic> json) {
    return MetricsSummaryModel(
      totalDistance: json['totalDistance'].toDouble(),
      totalDuration: json['totalDuration'],
      averageSpeed: json['averageSpeed'].toDouble(),
      maxSpeed: json['maxSpeed'].toDouble(),
      minSpeed: json['minSpeed'].toDouble(),
      movementStats: MovementStats(
        totalMovingTime: json['movementStats']['totalMovingTime'],
        totalStoppedTime: json['movementStats']['totalStoppedTime'],
        totalIdlingTime: json['movementStats']['totalIdlingTime'],
      ),
    );
  }
}
