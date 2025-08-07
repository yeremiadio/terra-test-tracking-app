import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terra_test_app/features/detail_gps/domain/usecases/get_detail_gps.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

part 'gps_detail_state.dart';

class GpsDetailCubit extends Cubit<GpsDetailState> {
  final GetDetailGps getDetailGps;

  GpsDetailCubit(this.getDetailGps) : super(GpsDetailInitial());

  Future<void> loadDetail(String imei) async {
    emit(GpsDetailLoading());

    try {
      final data = await getDetailGps(imei);
      emit(GpsDetailLoaded(data));
    } catch (e) {
      emit(GpsDetailError(e.toString()));
    }
  }
}
