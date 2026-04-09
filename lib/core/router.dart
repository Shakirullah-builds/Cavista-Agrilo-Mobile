import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/features/home/homepage.dart';
import 'package:impulse_mobile/features/recommendation/rec.dart';
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
      path: '/recommendation',
      builder: (context, state) => const RecommendationScreen(),
    ),
  ],
);
