class GpsLatestForAll {
  final int id;
  final String imei;
  final String location;
  final double lng;
  final double lat;
  final DateTime date;
  final int altitude;
  final int speed;
  final int angle;
  final String statusMesin;
  final Map<String, dynamic> iodata;
  final DateTime logTimestamp;

  GpsLatestForAll({
    required this.id,
    required this.imei,
    required this.location,
    required this.lng,
    required this.lat,
    required this.date,
    required this.altitude,
    required this.speed,
    required this.angle,
    required this.statusMesin,
    required this.iodata,
    required this.logTimestamp,
  });
}
