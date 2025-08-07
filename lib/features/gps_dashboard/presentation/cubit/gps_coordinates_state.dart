part of 'gps_coordinates_cubit.dart';

abstract class GpsCoordinatesState {}

class GpsCoordinatesInitial extends GpsCoordinatesState {}

class GpsCoordinatesLoading extends GpsCoordinatesState {}

class GpsCoordinatesLoaded extends GpsCoordinatesState {
  final List<GpsCoordinate> coordinates;

  GpsCoordinatesLoaded(this.coordinates);
}

class GpsCoordinatesError extends GpsCoordinatesState {
  final String message;

  GpsCoordinatesError(this.message);
}
