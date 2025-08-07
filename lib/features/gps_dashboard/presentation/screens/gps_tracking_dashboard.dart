import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:terra_test_app/features/gps_dashboard/constants/io_data_mapping.dart';
import 'package:terra_test_app/features/gps_dashboard/constants/io_data_unit.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_coordinate.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_dashboard_metrics.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/entities/gps_latest_for_all.dart';
import 'package:terra_test_app/features/gps_dashboard/domain/repositories/gps_repository.dart';
import 'package:terra_test_app/features/gps_dashboard/presentation/utils/io_data_formatter.dart';
import 'package:terra_test_app/injection.dart';

const int maxPointsPerRequest = 100;

class GpsTrackingDashboard extends StatefulWidget {
  final String imei;

  const GpsTrackingDashboard({super.key, required this.imei});

  @override
  _GpsTrackingDashboardState createState() => _GpsTrackingDashboardState();
}

class _GpsTrackingDashboardState extends State<GpsTrackingDashboard> {
  GoogleMapController? mapController;
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-6.2088, 106.8456), // Jakarta
    zoom: 5.0,
  );

  GpsDashboardMetrics? metrics;
  List<GpsCoordinate> coordinates = [];
  List<GpsLatestForAll> latestGps = [];
  List<String> imeis = [];
  List<LatLng> snappedCoordinates = [];
  late final String selectedImei;
  GpsLatestForAll? selectedDeviceGps;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedImei = widget.imei;
    fetchDashboard(widget.imei);
  }

  Future<void> fetchRoad() async {
    try {
      final dio = Dio();
      final points = coordinates;
      final List<LatLng> results = [];

      for (var i = 0; i < points.length; i += maxPointsPerRequest) {
        final batch = points.sublist(
          i,
          (i + maxPointsPerRequest > points.length)
              ? points.length
              : i + maxPointsPerRequest,
        );

        final pathParam = batch.map((p) => '${p.lat},${p.lng}').join('|');

        final url = 'https://roads.googleapis.com/v1/snapToRoads';

        try {
          final response = await dio.get(
            url,
            queryParameters: {
              'path': pathParam,
              'interpolate': true,
              'key': dotenv.env['MAPS_API_KEY'],
            },
          );

          final snappedPoints =
              response.data['snappedPoints'] as List<dynamic>?;

          if (snappedPoints != null) {
            final snappedBatch = snappedPoints.map((p) {
              final loc = p['location'];
              return LatLng(loc['latitude'], loc['longitude']);
            }).toList();

            results.addAll(snappedBatch);
          } else {
            print('❗ No snapped points returned for batch $i');
            results.addAll(batch.map((p) => LatLng(p.lat, p.lng)));
          }
        } catch (e) {
          print('❌ Error calling Snap to Roads API for batch $i: $e');
          results.addAll(batch.map((p) => LatLng(p.lat, p.lng)));
        }
      }
      setState(() {
        snappedCoordinates = results;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchDashboard(String? imei) async {
    try {
      final gpsRepository = sl<GpsRepository>();
      final latestGpsData = await gpsRepository.getGpsLatestForAll(
        GpsCoordinateParams(imei: selectedImei),
      );
      final dashboard = await gpsRepository.getDashboardMetrics(
        GpsDashboardMetricsParams(
          imei: selectedImei,
          startDate: null,
          endDate: null,
        ),
      );

      final coords = await gpsRepository.getCoordinates(
        GpsCoordinateParams(imei: selectedImei),
      );
      print("Dashboard: ${dashboard.averageBatteryVoltage}");
      setState(() {
        metrics = dashboard;
        coordinates = coords;
        selectedDeviceGps = latestGpsData.firstWhere((gps) => gps.imei == imei);
        _initialPosition = CameraPosition(
          target: LatLng(coords.last.lat, coords.last.lng),
          zoom: 24,
        );
        isLoading = false;

        // Move camera
        if (coords.isNotEmpty) {
          mapController?.moveCamera(
            CameraUpdate.newLatLng(LatLng(coords.last.lat, coords.last.lng)),
          );
        }
      });
      await fetchRoad();
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  List<LatLng> get polylinePoints =>
      coordinates.map((coord) => LatLng(coord.lat, coord.lng)).toList();
  List<GpsCoordinate> get sortedCoordinateData {
    final sorted = [...coordinates]; // create a copy
    sorted.sort(
      (a, b) => DateTime.parse(
        b.timestamp.toString(),
      ).compareTo(DateTime.parse(a.timestamp.toString())),
    );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final rawIoData = selectedDeviceGps?.iodata ?? {};
    final readableIoData = formatIoData(rawIoData, ioMapping);
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (controller) => mapController = controller,
              polylines: {
                Polyline(
                  polylineId: PolylineId('snapped_route'),
                  color: const Color.fromARGB(255, 255, 230, 6),
                  width: 8,
                  points: snappedCoordinates,
                ),
              },
              markers: {
                if (coordinates.isNotEmpty)
                  Marker(
                    markerId: const MarkerId("latest"),
                    position: LatLng(
                      coordinates.last.lat,
                      coordinates.last.lng,
                    ),
                    infoWindow: const InfoWindow(title: "Latest Position"),
                  ),
              },
            ),
            DraggableScrollableSheet(
              minChildSize: 0.25,
              initialChildSize: 0.3,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (metrics != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedImei,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                  selectedDeviceGps?.statusMesin ?? "-",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration:
                                      selectedDeviceGps?.statusMesin == 'ON'
                                      ? BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        )
                                      : BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.directional(
                            start: 0,
                            end: 0,
                            top: 4,
                            bottom: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 200,
                                ), // Set your desired max width
                                child: Text(
                                  "${selectedDeviceGps?.lat},${selectedDeviceGps?.lng}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.directional(
                            start: 0,
                            end: 0,
                            top: 4,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 4,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Average Speed",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${metrics!.baseMetrics.averageSpeed.toInt()} km/h",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color.fromARGB(
                                        255,
                                        27,
                                        27,
                                        27,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Max Speed",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${metrics!.baseMetrics.maxSpeed.toInt()} km/h",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color.fromARGB(
                                        255,
                                        27,
                                        27,
                                        27,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Min Speed",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${metrics!.baseMetrics.minSpeed.toInt()} km/h",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color.fromARGB(
                                        255,
                                        27,
                                        27,
                                        27,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Padding(padding: EdgeInsetsGeometry.all(8), child: ),
                        // 🟢 TabBar (only visual)
                        Container(
                          height: 40,
                          // margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.green.shade100,
                          ),
                          child: const TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black54,
                            tabs: [
                              Tab(text: 'Overview'),
                              Tab(text: 'Parameters'),
                              Tab(text: 'Latest History'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🟢 TabBarView must have fixed height
                        SizedBox(
                          height: 360, // Or adjust to your content height
                          child: TabBarView(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 0,
                                ),
                                child: Column(
                                  spacing: 8,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Current speed",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        Text(
                                          "${selectedDeviceGps?.speed ?? ""} km/h",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Location",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 200,
                                          ),
                                          child: Text(
                                            "${selectedDeviceGps?.location ?? "-"}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        spacing: 8,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.drive_eta,
                                                  color: Colors.green,
                                                  size: 36,
                                                  semanticLabel:
                                                      'Total Distance',
                                                ),
                                                Text(
                                                  "${metrics?.baseMetrics.totalDistance.toStringAsFixed(3) ?? 0} m",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text("Distance"),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.timelapse_rounded,
                                                  color: Colors.green,
                                                  size: 36,
                                                  semanticLabel:
                                                      'Total Duration',
                                                ),
                                                Text(
                                                  "${metrics?.baseMetrics.totalDuration.toStringAsFixed(3) ?? 0} m",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text("Duration"),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.add_road,
                                                  color: Colors.green,
                                                  size: 36,
                                                  semanticLabel:
                                                      'Average Battery Voltage',
                                                ),
                                                Text(
                                                  "${metrics?.averageBatteryVoltage.value.toStringAsFixed(3) ?? 0} A",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text("Battery Voltage"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: false,
                                padding: EdgeInsets.only(top: 0),
                                physics:
                                    const NeverScrollableScrollPhysics(), // if inside scrollable parent
                                itemCount: readableIoData.length,
                                itemBuilder: (context, index) {
                                  final key = readableIoData.keys.elementAt(
                                    index,
                                  );
                                  final value = readableIoData[key];
                                  // Format value with precision
                                  String formattedValue;
                                  if (value is num) {
                                    formattedValue = value.toStringAsFixed(
                                      0,
                                    ); // 3 fraction digits
                                  } else {
                                    formattedValue = value.toString();
                                  }

                                  // Append unit if exists
                                  final unit =
                                      ioDataUnitMap[key]; // optional unit lookup
                                  if (unit != null) {
                                    formattedValue += ' $unit';
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(formattedValue),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(top: 0),
                                physics:
                                    const NeverScrollableScrollPhysics(), // if inside scrollable parent
                                itemCount: sortedCoordinateData.length.clamp(
                                  0,
                                  4,
                                ),
                                itemBuilder: (context, index) {
                                  final entry = sortedCoordinateData[index];

                                  final location = entry.location;
                                  final timestamp = entry.timestamp != null
                                      ? DateTime.tryParse(
                                          entry.timestamp.toIso8601String(),
                                        )
                                      : DateTime.now();
                                  final formattedTime = DateFormat(
                                    'dd MMM yyyy – HH:mm',
                                  ).format(timestamp!);

                                  return ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                    ),
                                    title: Text(location),
                                    subtitle: Text(formattedTime),
                                    trailing: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Lat: ${entry.lat}'),
                                        Text('Lng: ${entry.lng}'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          child: Text(
                            "See Detail",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => context.go("/fleet/${selectedImei}"),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith(
                              (_) => Colors.green.withAlpha(50),
                            ),
                            elevation: WidgetStateProperty.resolveWith(
                              (_) => 0,
                            ),
                          ),
                        ),
                      ] else ...[
                        const Text('Metrics not loaded yet'),
                      ],
                    ],
                  ),
                );
              },
            ),
            // Positioned Button in top-right
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                // iconSize: 12,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                ),
                icon: const Icon(Icons.arrow_back, size: 36),
                onPressed: () => context.go("/"),
              ),
            ),
          ],
        ),
      ),
    );
    // return Scaffold(body: Stack(children: [Text("Distance")]));,
  }
}
