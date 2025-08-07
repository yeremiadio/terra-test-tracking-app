import 'package:terra_test_app/features/detail_gps/domain/repositories/gps_detail_repository.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

class GetDetailGps {
  final GpsDetailRepository repository;

  GetDetailGps(this.repository);

  Future<GpsLatestForAll> call(String imei) {
    return repository.getDetailGpsByImei(imei);
  }
}
