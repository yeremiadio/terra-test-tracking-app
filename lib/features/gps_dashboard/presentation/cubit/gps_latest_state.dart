part of 'gps_latest_all_cubit.dart';

abstract class GpsLatestState {}

class GpsLatestAllInitial extends GpsLatestState {}

class GpsLatestAllLoading extends GpsLatestState {}

class GpsLatestAllLoaded extends GpsLatestState {
  final List<GpsLatestForAll> data;

  GpsLatestAllLoaded(this.data);
}

class GpsLatestAllError extends GpsLatestState {
  final String message;

  GpsLatestAllError(this.message);
}
