import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

abstract class GpsDetailRepository {
  Future<GpsLatestForAll> getDetailGpsByImei(String imei);
}
