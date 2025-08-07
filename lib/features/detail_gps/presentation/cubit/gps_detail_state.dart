part of 'gps_detail_cubit.dart';

abstract class GpsDetailState {}

class GpsDetailInitial extends GpsDetailState {}

class GpsDetailLoading extends GpsDetailState {}

class GpsDetailLoaded extends GpsDetailState {
  final GpsLatestForAll data;

  GpsDetailLoaded(this.data);
}

class GpsDetailError extends GpsDetailState {
  final String message;

  GpsDetailError(this.message);
}
