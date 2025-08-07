import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:terra_test_app/features/detail_gps/data/datasources/gps_detail_remote_datasource.dart';
import 'package:terra_test_app/features/detail_gps/data/repositories/gps_detail_repository_impl.dart';
import 'package:terra_test_app/features/detail_gps/domain/repositories/gps_detail_repository.dart';
import 'package:terra_test_app/features/detail_gps/domain/usecases/get_detail_gps.dart';
import 'package:terra_test_app/features/detail_gps/presentation/cubit/gps_detail_cubit.dart';

import 'package:terra_test_app/features/gps_dashboard/data/datasources/gps_remote_datasource.dart';
import 'package:terra_test_app/features/gps_dashboard/data/repositories/gps_repository_impl.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/repositories/gps_repository.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/usecases/get_coordinates.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/usecases/get_dashboard_metrics.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/usecases/get_latest_for_all.dart';
import 'package:terra_test_app/features/gps_dashboard/presentation/cubit/gps_coordinates_cubit.dart';
import 'package:terra_test_app/features/gps_dashboard/presentation/cubit/gps_latest_all_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final baseUrl = dotenv.env['BASE_URL'];

  if (baseUrl == null || baseUrl.isEmpty) {
    throw Exception('BASE_URL not found in .env');
  }

  // External
  sl.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: "$baseUrl/gps")),
  );

  // Data layer
  sl.registerLazySingleton<GpsRemoteDataSource>(
    () => GpsRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<GpsDetailRemoteDatasource>(
    () => GpsDetailRemoteDatasourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<GpsRepository>(
    () => GpsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<GpsDetailRepository>(
    () => GpsDetailRepositoryImpl(remoteDataSource: sl()),
  );

  // Domain layer
  sl.registerLazySingleton(() => GetDashboardMetrics(sl()));
  sl.registerLazySingleton(() => GetCoordinates(sl()));
  sl.registerLazySingleton(() => GetLatestForAll(sl()));
  sl.registerLazySingleton(() => GetDetailGps(sl()));

  //Cubit
  sl.registerFactory(() => GpsDetailCubit(sl<GetDetailGps>()));
  sl.registerFactory(() => GpsCoordinatesCubit(sl<GetCoordinates>()));
  sl.registerFactory(() => GpsLatestAllCubit(sl<GetLatestForAll>()));
}
