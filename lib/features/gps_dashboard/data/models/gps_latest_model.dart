import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';

class GpsLatestModel extends GpsLatestForAll {
  GpsLatestModel({
    required super.id,
    required super.imei,
    required super.location,
    required super.lng,
    required super.lat,
    required super.date,
    required super.altitude,
    required super.speed,
    required super.angle,
    required super.statusMesin,
    required super.iodata,
    required super.logTimestamp,
  });
  factory GpsLatestModel.fromJson(Map<String, dynamic> json) {
    return GpsLatestModel(
      id: json['id'] as int,
      imei: json['imei'] as String,
      location: json['location'] as String,
      lng: (json['lng'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      altitude: json['altitude'] as int,
      speed: json['speed'] as int,
      angle: json['angle'] as int,
      statusMesin: json['status_mesin'] as String,
      iodata: Map<String, dynamic>.from(json['iodata']),
      logTimestamp: DateTime.parse(json['logTimestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imei': imei,
      'location': location,
      'lng': lng,
      'lat': lat,
      'date': date.toIso8601String(),
      'altitude': altitude,
      'speed': speed,
      'angle': angle,
      'status_mesin': statusMesin,
      'iodata': iodata,
      'logTimestamp': logTimestamp.toIso8601String(),
    };
  }
}
