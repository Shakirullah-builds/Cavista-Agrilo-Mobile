import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/features/home/homepage_provider.dart';
import 'package:impulse_mobile/main.dart';
import 'package:impulse_mobile/shared/custom/analyzing_wave.dart';
import 'package:impulse_mobile/shared/custom/bottom_navbar.dart';
import 'package:impulse_mobile/shared/custom_text.dart';

// This provider holds the name of the disease (or "Healthy") after the scan.
// It starts as null because nothing is yet to be scanned by default.

final scanResultProvider = StateProvider<String?>((ref) => null);

class PlantScannerScreen extends ConsumerStatefulWidget {
  const PlantScannerScreen({super.key});

  @override
  ConsumerState<PlantScannerScreen> createState() => _PlantScannerScreenState();
}

class _PlantScannerScreenState extends ConsumerState<PlantScannerScreen> {
  late CameraController _controller;

  bool _isCameraInitialized = false;

  bool _isAnalyzing = false; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    _initCamera();
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
      });
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      await Future.delayed(Duration(seconds: 2));
      final fakeAiResults = 'Powdery Mildew detected';

      // Saving the result to Riverpod
      ref.read(scanResultProvider.notifier).state = fakeAiResults;

      if (mounted) {
        ref.read(bottomNavBarIndexProvider.notifier).state = 2;
        context.go('/recommendation');
        debugPrint('Scan complete! Saved to Riverpod. Ready to navigate.');
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

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          'Plant Scanner',
          style: Theme.of(context).appBarTheme.titleTextStyle,
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
            const Center(
              child: CupertinoActivityIndicator(color: AppColors.lightGreen, radius: 15,)
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
        style: AppTextStyles.bodyStyle.copyWith(color: AppColors.textWhite),
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
            border: Border.all(color: AppColors.background.withValues(alpha: 0.75), width: 5.w),
            color: _isAnalyzing
                ? AppColors.textGrey.withValues(alpha: 0.7)
                : AppColors.textWhite,
          ),
         child: _isAnalyzing
            ? const AnalyzingWave(
                color: AppColors.neonYellow,
                size: 40,
              )
              : Container(),
        ),
      ),
    );
  }
}
