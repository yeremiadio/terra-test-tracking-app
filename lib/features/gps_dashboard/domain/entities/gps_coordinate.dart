class GpsCoordinate {
  final double lat;
  final double lng;
  final String location;
  final DateTime timestamp;

  GpsCoordinate({
    required this.lat,
    required this.lng,
    required this.location,
    required this.timestamp,
  });
}

class GpsCoordinateParams {
  final String imei;
  final DateTime? startDate;
  final DateTime? endDate;

  GpsCoordinateParams({required this.imei, this.startDate, this.endDate});
}
