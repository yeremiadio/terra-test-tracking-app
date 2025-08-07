import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:terra_test_app/router/app_router.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // 👈 Load env first
  await init(); // 👈 Then init DI
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.grey.shade100,
        textTheme: GoogleFonts.interTextTheme(),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Main App',
  // theme: ThemeData(
  //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  // ),
  //     home: MetricsDashboard(),
  //   );
  // }
}
