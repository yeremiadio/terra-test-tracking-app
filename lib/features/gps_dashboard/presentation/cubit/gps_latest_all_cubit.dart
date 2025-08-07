import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_coordinate.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/usecases/get_latest_for_all.dart';

part 'gps_latest_state.dart';

class GpsLatestAllCubit extends Cubit<GpsLatestState> {
  final GetLatestForAll getLatestForAll;

  GpsLatestAllCubit(this.getLatestForAll) : super(GpsLatestAllInitial());

  Future<void> loadCoordinates(String imei) async {
    emit(GpsLatestAllLoading());

    try {
      final data = await getLatestForAll(GpsCoordinateParams(imei: imei));
      emit(GpsLatestAllLoaded(data));
    } catch (e) {
      emit(GpsLatestAllError(e.toString()));
    }
  }
}
