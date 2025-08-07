// lib/features/gps_dashboard/presentation/utils/io_data_formatter.dart

Map<String, dynamic> formatIoData(
  Map<String, dynamic> ioData,
  Map<String, String> ioMapping,
) {
  Map<String, dynamic> formatted = {};

  for (final entry in ioData.entries) {
    final keyId = entry.key;
    final value = entry.value;

    if (ioMapping.containsKey(keyId)) {
      final camelCaseKey = ioMapping[keyId]!;
      final readableKey = _camelCaseToReadable(camelCaseKey);
      formatted[readableKey] = value;
    }
  }

  return formatted;
}

String _camelCaseToReadable(String input) {
  final spaced = input.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  return spaced[0].toUpperCase() + spaced.substring(1);
}
