import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

import '../entities/gps_dashboard_metrics.dart';
import '../entities/gps_coordinate.dart';

abstract class GpsRepository {
  Future<GpsDashboardMetrics> getDashboardMetrics(
    GpsDashboardMetricsParams params,
  );
  Future<List<GpsCoordinate>> getCoordinates(GpsCoordinateParams params);
  Future<List<GpsLatestForAll>> getGpsLatestForAll(GpsCoordinateParams params);
}
