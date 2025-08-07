import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_coordinate.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/usecases/get_coordinates.dart';

part 'gps_coordinates_state.dart';

class GpsCoordinatesCubit extends Cubit<GpsCoordinatesState> {
  final GetCoordinates getCoordinates;

  GpsCoordinatesCubit(this.getCoordinates) : super(GpsCoordinatesInitial());

  Future<void> loadCoordinates(String imei) async {
    emit(GpsCoordinatesLoading());

    try {
      final coords = await getCoordinates(GpsCoordinateParams(imei: imei));
      emit(GpsCoordinatesLoaded(coords));
    } catch (e) {
      emit(GpsCoordinatesError(e.toString()));
    }
  }
}
