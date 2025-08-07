import 'package:dio/dio.dart';
import 'package:terra_test_app/features/gps_dashboard/data/models/gps_latest_model.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

abstract class GpsDetailRemoteDatasource {
  Future<GpsLatestForAll> fetchLatestByImei(String imei);
}

class GpsDetailRemoteDatasourceImpl implements GpsDetailRemoteDatasource {
  final Dio dio;

  GpsDetailRemoteDatasourceImpl({required this.dio});

  @override
  Future<GpsLatestForAll> fetchLatestByImei(String imei) async {
    final response = await dio.get('/latest/$imei');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      print("Detail Data: ${data}");
      return GpsLatestModel.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to load GPS detail');
    }
  }
}
