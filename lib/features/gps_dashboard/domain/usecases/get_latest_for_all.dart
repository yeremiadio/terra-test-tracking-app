import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

import '../entities/gps_coordinate.dart';
import '../repositories/gps_repository.dart';

class GetLatestForAll {
  final GpsRepository repository;

  GetLatestForAll(this.repository);

  Future<List<GpsLatestForAll>> call(GpsCoordinateParams params) {
    return repository.getGpsLatestForAll(params);
  }
}
