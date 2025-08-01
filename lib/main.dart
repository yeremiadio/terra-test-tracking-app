import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Tracking Terra',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MetricsDashboard(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MetricsDashboard extends StatefulWidget {
  @override
  _MetricsDashboardState createState() => _MetricsDashboardState();
}

class _MetricsDashboardState extends State<MetricsDashboard> {
  final Dio _dio = Dio();
  Map<String, dynamic>? metrics;
  bool isLoading = true;

  // Google Maps controller
  GoogleMapController? mapController;

  // Initial camera position (example: Jakarta)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-6.2088, 106.8456),
    zoom: 11.0,
  );

  @override
  void initState() {
    super.initState();
    fetchMetrics();
  }

  Future<void> fetchMetrics() async {
    try {
      final response = await _dio.get(
        'https://solid-audre-yeremiadio1-dfd9dd52.koyeb.app/gps/metrics',
      );
      setState(() {
        metrics = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching metrics: $e');
    }
  }

  Widget buildGsmSignalDistribution(Map<String, dynamic> gsmSignal) {
    List<Widget> lines = gsmSignal.entries.map((entry) {
      return Text('Signal Level ${entry.key}: ${entry.value} times');
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('GPS Metrics Dashboard')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (metrics == null) {
      return Scaffold(
        appBar: AppBar(title: Text('GPS Metrics Dashboard')),
        body: Center(child: Text('No metrics data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('GPS Metrics Dashboard')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Total Odometer Sum'),
                      subtitle: Text(
                        '${metrics!['totalOdometerSum']['value']} ${metrics!['totalOdometerSum']['unit']}',
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Average Battery Voltage'),
                      subtitle: Text(
                        '${metrics!['averageBatteryVoltage']['value'].toStringAsFixed(2)} ${metrics!['averageBatteryVoltage']['unit']}',
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('GNSS Fix Counts'),
                      subtitle: Text(
                        'Good: ${metrics!['gnssFix']['good']}, Bad: ${metrics!['gnssFix']['bad']}',
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Total Records Processed'),
                      subtitle: Text('${metrics!['totalRecordsProcessed']}'),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GSM Signal Distribution',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          buildGsmSignalDistribution(
                            Map<String, dynamic>.from(
                              metrics!['gsmSignalDistribution'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}
