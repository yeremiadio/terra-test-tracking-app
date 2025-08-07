import '../entities/gps_coordinate.dart';
import '../repositories/gps_repository.dart';

class GetCoordinates {
  final GpsRepository repository;

  GetCoordinates(this.repository);

  Future<List<GpsCoordinate>> call(GpsCoordinateParams params) {
    return repository.getCoordinates(params);
  }
}
