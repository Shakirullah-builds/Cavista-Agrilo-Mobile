import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/services/ai_service.dart';
import 'package:impulse_mobile/main.dart';
import 'package:impulse_mobile/shared/custom/analyzing_wave.dart';
import 'package:impulse_mobile/shared/custom/bottom_navbar.dart';
import 'package:impulse_mobile/shared/custom_text.dart';
import 'package:impulse_mobile/shared/empty_state.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/home_page_provider.dart';

// This provider holds the AI analysis result (map with label and confidence) after the scan.
// It starts as null because nothing is yet to be scanned by default.

final scanResultProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class PlantScannerScreen extends ConsumerStatefulWidget {
  const PlantScannerScreen({super.key});

  @override
  ConsumerState<PlantScannerScreen> createState() => _PlantScannerScreenState();
}

class _PlantScannerScreenState extends ConsumerState<PlantScannerScreen>
    with WidgetsBindingObserver {
  late CameraController _controller;

  bool _isCameraInitialized = false;

  bool _isPermissionDenied = false;

  bool _isAnalyzing = false; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    // 1. Tell Flutter to start watching the app's lifecycle
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    // 2. Stop watching when we leave the screen to save memory
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // 3. The Magic Lifecycle trigger
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the app just came back to the foreground AND they were previously blocked...
    if (state == AppLifecycleState.resumed && _isPermissionDenied) {
      // Put the UI back into a loading state
      setState(() {
        _isCameraInitialized = false;
      });
      // Try to initialize the camera again!
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _isPermissionDenied = false;
      });
    } on CameraException catch (e) {
      // Catch the exact moment they deny access
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessRestricted') {
        if (mounted) {
          setState(() {
            _isPermissionDenied = true;
          });
        }
      }
      debugPrint('Camera Error: ${e.code} - ${e.description}');
    } catch (e) {
      // Fallback for any other weird errors
      debugPrint('Unknown Error: $e');
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (!_isCameraInitialized || _isAnalyzing) return;

    // Update UI to show thinking
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Take Picture
      final XFile imageFile = await _controller.takePicture();

      // Running the TFlite model here in the future
      // final result = await MyAiService.analyzeImage(imageFile.path);

      // This causes Delay
      //await Future.delayed(Duration(seconds: 2));
      final aiResult = await AiService.analyzeImage(imageFile.path);
      // Saving the result to Riverpod
      ref.read(scanResultProvider.notifier).state = aiResult;

      if (aiResult != null && mounted) {
        ref.read(bottomNavBarIndexProvider.notifier).state = 2;

        context.push(
          '/scanresult',
          extra: {
            'aiLabel': aiResult['label'], // Extracts the string
            'confidence': aiResult['confidence'], // Extracts the double
            'imagePath': imageFile.path,
          },
        );

        debugPrint('Scan complete! AI Says ${aiResult['label']}');
      } else {
        debugPrint("AI returned null.");
      }
    } catch (e) {
      debugPrint('Error taking pictures: $e');
    } finally {
      // Reset the UI
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarCurrentIndex = ref.watch(bottomNavBarIndexProvider);
    // Defense 1: Did they deny permission?
    if (_isPermissionDenied) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: CustomText(
            'Camera Access',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 22.spMin),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 40.w, right: 40.w),
            child: EmptyStateScreen(
              assetPath: AssetPath.cameraOffIcon,
              title: "Camera Access Required",
              subtitle:
                  "Agrilo needs your camera to scan crops for diseases. Please enable it in your phone settings.",
              emptyStateButtonText: "Open Settings",
              icon: Icons.settings,
              onTap: () async {
                // Open the app settings
                await openAppSettings();
                // When they come back, if the lifecycle observer missed it,
                // this will force a re-check anyway!
                if (mounted && _isPermissionDenied) {
                  setState(() {
                    _isCameraInitialized = false;
                  });
                  _initCamera();
                }
              },
            ),
          ),
        ),
      );
    }
    // Defence 2: Is it still loading?
    if (!_isCameraInitialized) {
      return Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            radius: 15.r,
          ),
        ),
      );
    }

    // Defense 3: We have permission and it's loaded!
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: CustomText(
          'Plant Scanner',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 22.spMin),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview (Base layer)
          if (_isCameraInitialized)
            ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: CameraPreview(_controller),
            )
          else
            Center(
              child: CupertinoActivityIndicator(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                radius: 15.r,
              ),
            ),

          // 2. Top Overlay (Optional info)
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            child: _buildInfoOverlay(),
          ),

          // 3. Bottom Overlay (Capture button)
          Positioned(
            bottom: 40.h, // Above bottom nav
            left: 0,
            right: 0,
            child: _buildCaptureButton(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: bottomNavBarCurrentIndex,
        onTap: (index) {
          ref.read(bottomNavBarIndexProvider.notifier).state = index;
          ref.read(navigateToProvider)(context);
        },
      ),
    );
  }

  // Top info overlay
  Widget _buildInfoOverlay() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: CustomText(
        'Position the plant in the frame',
        style: Theme.of(context).textTheme.bodyLarge,
        // style: AppTextStyles.bodyStyle.copyWith(color: AppColors.textWhite),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Capture button
  Widget _buildCaptureButton() {
    return Center(
      child: GestureDetector(
        onTap: _isAnalyzing ? null : _captureAndAnalyze,
        child: Container(
          padding: EdgeInsets.all(47.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.background.withValues(alpha: 0.75),
              width: 5.w,
            ),
            color: _isAnalyzing
                ? AppColors.textGrey.withValues(alpha: 0.7)
                : AppColors.textWhite,
          ),
          child: _isAnalyzing
              ? const AnalyzingWave(color: AppColors.primaryColor, size: 40)
              : Container(),
        ),
      ),
    );
  }
}
