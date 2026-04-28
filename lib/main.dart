import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/router.dart';
import 'package:impulse_mobile/core/services/ai_service.dart';
import 'package:impulse_mobile/core/services/supabase_service.dart';
import 'package:impulse_mobile/core/theme/app_theme.dart';

// Global variable to hold the cameras
late List<CameraDescription> cameras;

// // Route observer to track navigation events
// final RouteObserver<ModalRoute<void>> routeObserver =
//     RouteObserver<ModalRoute<void>>();
Future<void> main() async {
  // 1. Ensure bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // Load the hidden keys
  await dotenv.load(fileName: ".env");

  // Initialize the database
  await SupabaseService.initSupabase();

  // Fetch the available cameras
  cameras = await availableCameras();

  // Load the AI brain

  await AiService.loadModel();

  // 2. Lock the app to Portrait mode (Saves UI work)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // // 3. Make the Status Bar transparent (Looks modern)
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: AppColors.transparent,
  //     statusBarIconBrightness: Brightness.dark,
  //   ),
  // );

  runApp(
    ScreenUtilInit(
      // The design size from the Figma file
      designSize: const Size(390, 884),
      splitScreenMode: true,
      builder: (context, child) {
        return const ProviderScope(child: ImpulseCavista());
      },
    ),
  );
}

class ImpulseCavista extends StatelessWidget {
  const ImpulseCavista({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Impulse Cavista (Agrilo)',
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
