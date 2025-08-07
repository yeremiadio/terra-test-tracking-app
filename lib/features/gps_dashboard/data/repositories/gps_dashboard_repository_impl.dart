import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

import '../../domain/entities/gps_coordinate.dart';
import '../../domain/entities/gps_dashboard_metrics.dart';
import '../../domain/repositories/gps_repository.dart';
import '../datasources/gps_remote_datasource.dart';

class GpsDashboardRepositoryImpl implements GpsRepository {
  final GpsRemoteDataSource remoteDataSource;

  GpsDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<GpsDashboardMetrics> getDashboardMetrics(
    GpsDashboardMetricsParams params,
  ) async {
    final model = await remoteDataSource.fetchDashboardMetrics(params);
    return model; // since model extends GpsDashboardMetrics
  }

  @override
  Future<List<GpsCoordinate>> getCoordinates(GpsCoordinateParams params) async {
    final models = await remoteDataSource.fetchCoordinates(params);
    return models; // model extends GpsCoordinate
  }

  @override
  Future<List<GpsLatestForAll>> getGpsLatestForAll(
    GpsCoordinateParams params,
  ) async {
    final model = await remoteDataSource.fetchLatestForAll(params);
    return model;
  }
}


//GpsDashboardRepositoryImpl