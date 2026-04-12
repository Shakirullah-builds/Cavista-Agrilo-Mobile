import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/features/home/homepage.dart';
import 'package:impulse_mobile/features/result/scan_result.dart';
import 'package:impulse_mobile/features/scanner/plant_scanner.dart';

final router = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    return null;
  },
  routes: [
    GoRoute(path: '/home', builder: (context, state) {
      return HomePage();
    }),
    GoRoute(path: '/scanner', builder: (context, state) => const PlantScannerScreen()),
    GoRoute(
      path: '/scanresult',
      builder: (context, state) => const ScanResult(),
    ),
  ],
);
