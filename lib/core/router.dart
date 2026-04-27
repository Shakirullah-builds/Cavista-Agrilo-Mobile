import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/features/auth/setup_profile.dart';
import 'package:impulse_mobile/features/auth/splash_guard.dart';
import 'package:impulse_mobile/features/home/homepage.dart';
import 'package:impulse_mobile/features/onboarding/onboarding.dart';
import 'package:impulse_mobile/features/result/scan_result.dart';
import 'package:impulse_mobile/features/scan_history_screen.dart';
import 'package:impulse_mobile/features/scanner/plant_scanner.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashGuard()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) {
        return HomePage();
      },
    ),
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const PlantScannerScreen(),
    ),
    GoRoute(
      path: '/scanresult',
      builder: (context, state) {
        // Extra data from the scan result screen
        final extra = state.extra as Map<String, dynamic>?;

        // Unpack it into typed variables
        final String label = extra?['aiLabel'] as String? ?? 'No Scan Data';
        final double confidence = extra?["confidence"] as double? ?? 0.0;
        final String imagePath = extra?["imagePath"] as String? ?? '';

        // Feed to the screen!
        return ScanResult(
          aiLabel: label,
          confidence: confidence,
          imagePath: imagePath,
        );
      },
    ),
    GoRoute(
      path: '/scan_history',
      builder: (context, state) => ScanHistoryScreen(),
    ),
    GoRoute(
      path: '/setup_profile',
      builder: (context, state) => SetupProfileScreen(),
    ),
  ],
);
