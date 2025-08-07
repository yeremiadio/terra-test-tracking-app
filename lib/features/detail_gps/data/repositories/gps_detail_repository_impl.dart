import 'package:terra_test_app/features/detail_gps/domain/repositories/gps_detail_repository.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

import '../datasources/gps_detail_remote_datasource.dart';

class GpsDetailRepositoryImpl implements GpsDetailRepository {
  final GpsDetailRemoteDatasource remoteDataSource;

  GpsDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<GpsLatestForAll> getDetailGpsByImei(String imei) async {
    final model = await remoteDataSource.fetchLatestByImei(imei);
    return model;
  }
}


//GpsDetailRepositoryImpl