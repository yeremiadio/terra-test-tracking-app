import 'metrics_summary.dart';

class TotalOdometer {
  final double value;
  final String unit;

  TotalOdometer({required this.value, required this.unit});
}

class BatteryVoltage {
  final double value;
  final String unit;

  BatteryVoltage({required this.value, required this.unit});
}

class GnssFix {
  final int good;
  final int bad;

  GnssFix({required this.good, required this.bad});
}

class TotalOdometerByImei {
  final String imei;
  final double avgOdometer;

  TotalOdometerByImei({required this.imei, required this.avgOdometer});
}

class GpsDashboardMetrics {
  final TotalOdometer totalOdometerSum;
  final BatteryVoltage averageBatteryVoltage;
  final Map<String, int> gsmSignalDistribution;
  final GnssFix gnssFix;
  final MetricsSummary baseMetrics;
  final int totalRecordsProcessed;

  GpsDashboardMetrics({
    required this.totalOdometerSum,
    required this.averageBatteryVoltage,
    required this.gsmSignalDistribution,
    required this.gnssFix,
    required this.baseMetrics,
    required this.totalRecordsProcessed,
  });
}

class GpsDashboardMetricsParams {
  final String imei;
  final DateTime? startDate;
  final DateTime? endDate;

  GpsDashboardMetricsParams({required this.imei, this.startDate, this.endDate});
}
