import 'package:go_router/go_router.dart';
import 'package:terra_test_app/features/detail_gps/presentation/screens/detail_gps_screen.dart';
import 'package:terra_test_app/features/fleet/presentation/screens/fleet_list_screen.dart';
import 'package:terra_test_app/features/gps_dashboard/presentation/screens/gps_tracking_dashboard.dart';
import 'package:terra_test_app/features/tracking_history/presentation/screens/detail_tracking_history.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'fleet',
      builder: (context, state) => FleetListScreen(),
    ),
    GoRoute(
      path: '/map/:id',
      name: 'map_tracking',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GpsTrackingDashboard(imei: id);
      },
    ),
    GoRoute(
      path: '/fleet/:id',
      name: 'detail_fleet',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailGpsScreen(imei: id);
      },
    ),
    GoRoute(
      path: '/detail_tracking/:id',
      name: 'detail_tracking',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailTrackingHistory(id: id);
      },
    ),
  ],
);
