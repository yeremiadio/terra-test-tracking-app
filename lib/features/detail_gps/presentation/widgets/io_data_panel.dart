import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terra_test_app/features/detail_gps/presentation/utils/io_data_icons.dart';
import 'package:terra_test_app/features/gps_dashboard/constants/io_data_mapping.dart';
import 'package:terra_test_app/features/gps_dashboard/presentation/utils/io_data_formatter.dart';

class IoDataPanel extends StatelessWidget {
  final Map<String, dynamic>? ioData;
  final Map<String, String> ioDataUnitMap;

  const IoDataPanel({
    Key? key,
    required this.ioData,
    required this.ioDataUnitMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ioData == null || ioData!.isEmpty) {
      return const Center(
        child: Text(
          'No I/O data available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    final readableIoData = formatIoData(ioData!, ioMapping);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "IO Parameters",
          style: TextStyle(
            fontSize: 20,
            fontFamily: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
            ).fontFamily,
          ),
        ),
        ...readableIoData.entries.map((entry) {
          final key = entry.key;
          final value = entry.value;
          final unit = ioDataUnitMap[key] ?? '';

          final icon = ioDataIcons[key] ?? Icons.device_hub;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Icon(icon, color: Colors.green, size: 24),
                ),
                // Label + optional subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (unit.isNotEmpty)
                        Text(
                          'Measured in $unit',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                // Value
                Text(
                  '$value ${unit.isNotEmpty ? unit : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
