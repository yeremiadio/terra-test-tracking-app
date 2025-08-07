import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_coordinate.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/repositories/gps_repository.dart';
import 'package:terra_test_app/injection.dart';

class FleetListScreen extends StatefulWidget {
  const FleetListScreen({super.key});

  @override
  State<FleetListScreen> createState() => _FleetListScreenState();
}

class _FleetListScreenState extends State<FleetListScreen> {
  List<String> imeis = [];
  List<GpsLatestForAll> latestGps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImeis();
  }

  Future<void> fetchImeis() async {
    try {
      final gpsRepository = sl<GpsRepository>();
      final dashboard = await gpsRepository.getGpsLatestForAll(
        GpsCoordinateParams(imei: '', startDate: null, endDate: null),
      );
      final imeiData = dashboard.map((data) => data.imei).toList();
      setState(() {
        imeis = imeiData;
        latestGps = dashboard;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text(
          "Fleet Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: latestGps.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final data = latestGps[index];
                return ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(
                    data.imei,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.location),
                      Text('Speed: ${data.speed.toStringAsFixed(1)} km/h'),
                      Padding(
                        padding: EdgeInsetsGeometry.only(top: 4),
                        child: Text(
                          'Updated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(data.date.toString()))}',
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.go('/map/${data.imei}'),
                );
              },
            ),
    );
  }
}
