import 'package:dio/dio.dart';
import 'package:terra_test_app/features/gps_dashboard/data/models/gps_latest_model.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_dashboard_metrics.dart';
import '../models/gps_dashboard_metrics_model.dart';
import '../models/gps_coordinate_model.dart';
import '../../domain/entities/gps_coordinate.dart';

abstract class GpsRemoteDataSource {
  Future<GpsDashboardMetricsModel> fetchDashboardMetrics(
    GpsDashboardMetricsParams params,
  );
  Future<List<GpsCoordinateModel>> fetchCoordinates(GpsCoordinateParams params);
  Future<List<GpsLatestModel>> fetchLatestForAll(GpsCoordinateParams params);
}

class GpsRemoteDataSourceImpl implements GpsRemoteDataSource {
  final Dio dio;

  GpsRemoteDataSourceImpl({required this.dio});

  @override
  Future<GpsDashboardMetricsModel> fetchDashboardMetrics(
    GpsDashboardMetricsParams params,
  ) async {
    final queryParams = {
      if (params.imei != '') 'imei': params.imei,
      if (params.startDate != null)
        'startDate': params.startDate!.toIso8601String(),
      if (params.endDate != null) 'endDate': params.endDate!.toIso8601String(),
    };
    final response = await dio.get('/metrics', queryParameters: queryParams);
    print('[📡 RemoteDataSource] GET /gps/metrics');
    print('[📥 Response] ${response.statusCode}');
    print('[📥 Query Params] $queryParams');
    print('[📊 Response Data] ${response.data}');
    if (response.statusCode == 200) {
      return GpsDashboardMetricsModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load GPS dashboard metrics');
    }
  }

  @override
  Future<List<GpsCoordinateModel>> fetchCoordinates(
    GpsCoordinateParams params,
  ) async {
    final queryParams = {
      if (params.startDate != null)
        'startDate': params.startDate!.toIso8601String(),
      if (params.endDate != null) 'endDate': params.endDate!.toIso8601String(),
    };

    final response = await dio.get(
      '/coordinates/${params.imei}',
      queryParameters: queryParams,
    );
    final data = response.data['data'];

    if (response.statusCode == 200) {
      return (data as List).map((e) => GpsCoordinateModel.fromJson(e)).toList();
      // return (response.data as List)
      //     .map((json) => GpsCoordinateModel.fromJson(json))
      //     .toList();
    } else {
      throw Exception('Failed to fetch GPS coordinates');
    }
  }

  @override
  Future<List<GpsLatestModel>> fetchLatestForAll(
    GpsCoordinateParams params,
  ) async {
    final queryParams = {
      if (params.startDate != null)
        'startDate': params.startDate!.toIso8601String(),
      if (params.endDate != null) 'endDate': params.endDate!.toIso8601String(),
    };

    final response = await dio.get(
      '/latest-for-all',
      queryParameters: queryParams,
    );
    final data = response.data['data'];

    if (response.statusCode == 200) {
      return (data as List).map((e) => GpsLatestModel.fromJson(e)).toList();
      // return (response.data as List)
      //     .map((json) => GpsCoordinateModel.fromJson(json))
      //     .toList();
    } else {
      throw Exception('Failed to fetch GPS coordinates');
    }
  }
}
