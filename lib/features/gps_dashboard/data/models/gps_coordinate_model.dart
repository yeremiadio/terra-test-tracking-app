import '../../domain/entities/gps_coordinate.dart';

class GpsCoordinateModel extends GpsCoordinate {
  GpsCoordinateModel({
    required super.lat,
    required super.lng,
    required super.location,
    required super.timestamp,
  });

  factory GpsCoordinateModel.fromJson(Map<String, dynamic> json) {
    return GpsCoordinateModel(
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      location: json['location'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
