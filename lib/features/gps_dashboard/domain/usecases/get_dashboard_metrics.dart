import '../entities/gps_dashboard_metrics.dart';
import '../repositories/gps_repository.dart';

class GetDashboardMetrics {
  final GpsRepository repository;

  GetDashboardMetrics(this.repository);

  Future<GpsDashboardMetrics> call(GpsDashboardMetricsParams params) {
    return repository.getDashboardMetrics(params);
  }
}
