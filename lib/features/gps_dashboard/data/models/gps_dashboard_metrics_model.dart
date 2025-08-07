import '../../domain/entities/gps_dashboard_metrics.dart';
import 'metrics_summary_model.dart';

class GpsDashboardMetricsModel extends GpsDashboardMetrics {
  GpsDashboardMetricsModel({
    required super.totalOdometerSum,
    required super.averageBatteryVoltage,
    required super.gsmSignalDistribution,
    required super.gnssFix,
    required super.baseMetrics,
    required super.totalRecordsProcessed,
  });

  factory GpsDashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    return GpsDashboardMetricsModel(
      totalOdometerSum: TotalOdometer(
        value: json['totalOdometerSum']['value'].toDouble(),
        unit: json['totalOdometerSum']['unit'],
      ),
      averageBatteryVoltage: BatteryVoltage(
        value: json['averageBatteryVoltage']['value'].toDouble(),
        unit: json['averageBatteryVoltage']['unit'],
      ),
      gsmSignalDistribution: Map<String, int>.from(
        json['gsmSignalDistribution'],
      ),
      gnssFix: GnssFix(
        good: json['gnssFix']['good'],
        bad: json['gnssFix']['bad'],
      ),
      baseMetrics: MetricsSummaryModel.fromJson(json['baseMetrics']),
      totalRecordsProcessed: json['totalRecordsProcessed'],
    );
  }
}
