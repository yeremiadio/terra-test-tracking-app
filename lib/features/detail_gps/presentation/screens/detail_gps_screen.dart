import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terra_test_app/features/detail_gps/domain/repositories/gps_detail_repository.dart';
import 'package:terra_test_app/features/detail_gps/presentation/widgets/io_data_panel.dart';
import 'package:terra_test_app/features/gps_dashboard/constants/io_data_unit.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';
import 'package:terra_test_app/injection.dart';
import 'package:terra_test_app/features/detail_gps/presentation/widgets/detail_fleet_widget.dart';

class DetailGpsScreen extends StatefulWidget {
  final String imei;

  const DetailGpsScreen({super.key, required this.imei});

  @override
  State<DetailGpsScreen> createState() => _DetailGpsScreenState();
}

class _DetailGpsScreenState extends State<DetailGpsScreen> {
  late final String imeiState;
  bool isLoading = true;
  GpsLatestForAll? detailGps;
  @override
  void initState() {
    super.initState();
    imeiState = widget.imei;
    fetchDetail(widget.imei);
  }

  Future<void> fetchDetail(String selectedImei) async {
    try {
      final gpsRepository = sl<GpsDetailRepository>();
      final latestGpsData = await gpsRepository.getDetailGpsByImei(
        selectedImei,
      );
      print("Test: ${latestGpsData.altitude}");
      setState(() {
        detailGps = latestGpsData;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        automaticallyImplyLeading:
            true, // This line is optional; it's true by default
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/map/${widget.imei}'),
        ),
        title: const Text(
          "Detail Fleet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fleet Detail Card
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fleet Detail",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                              ).fontFamily,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DetailFleet(
                            location: detailGps?.location,
                            lat: detailGps?.lat,
                            lng: detailGps?.lng,
                            date: detailGps?.date.toIso8601String(),
                            altitude: detailGps?.altitude?.toDouble(),
                            speed: detailGps?.speed?.toDouble(),
                            angle: detailGps?.angle?.toDouble(),
                            statusMesin: detailGps?.statusMesin,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // I/O Data Panel Card
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: IoDataPanel(
                        ioData: detailGps?.iodata,
                        ioDataUnitMap: ioDataUnitMap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
