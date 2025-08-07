import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';

class DetailFleet extends StatelessWidget {
  final String? location;
  final double? lat;
  final double? lng;
  final String? date;
  final double? altitude;
  final double? speed;
  final double? angle;
  final String? statusMesin;

  const DetailFleet({
    Key? key,
    required this.location,
    required this.lat,
    required this.lng,
    required this.date,
    required this.altitude,
    required this.speed,
    required this.angle,
    required this.statusMesin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField("Location", location),
            _buildField("Coordinate", _formatCoordinate(lat, lng)),
            _buildField("Last Update", _formatDate(date)),
          ],
        ),

        // Right Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField("Altitude", "${altitude ?? '-'} m"),
            _buildField("Speed", "${speed ?? '-'} km/h"),
            _buildField("Angle", "${angle ?? '-'}°"),
            _buildField("Status Mesin", statusMesin),
            const SizedBox(height: 0),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, String? value) {
    final textWidget = Text(
      value ?? "-",
      style: TextStyle(
        fontSize: 14,
        fontFamily: GoogleFonts.inter(fontWeight: FontWeight.w700).fontFamily,
      ),
      softWrap: true,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          SizedBox(
            width: 150, // Or any constraint you want
            child: textWidget,
          ),
        ],
      ),
    );
  }

  String _formatCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return "-";
    return "${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}";
  }

  String _formatDate(String? dateUtc) {
    if (dateUtc == null) return "-";
    try {
      final date = DateTime.parse(dateUtc).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return "-";
    }
  }
}
