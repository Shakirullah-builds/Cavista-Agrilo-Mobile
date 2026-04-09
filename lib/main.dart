import 'package:camera/camera.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/router.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/theme/app_theme.dart';

// Global variable to hold the cameras
late List<CameraDescription> cameras;

Future<void> main() async {
  // 1. Ensure bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // Fetch the available cameras
  cameras = await availableCameras();

  // 2. Lock the app to Portrait mode (Saves UI work)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. Make the Status Bar transparent (Looks modern)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ScreenUtilInit(
        // The design size from the Figma file
        designSize: const Size(390, 884),
        splitScreenMode: true,
        builder: (context, child) {
          return const ProviderScope(child: ImpulseCavista());
        },
      ),
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
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      // Theme Setup
      theme: AppTheme.darkTheme,
      // theme: ThemeData(
      //   useMaterial3: true,
      //   // Set the default font for the WHOLE app here
      //   textTheme: GoogleFonts.poppinsTextTheme(), // To be changed to preferred font
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
      // ),

      // Navigation (GoRouter)
      routerConfig: router,
    );
  }
}
