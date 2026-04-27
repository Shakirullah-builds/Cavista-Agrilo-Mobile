import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/core/models/model.dart';
import 'package:impulse_mobile/shared/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Spot Pathogens Instantly',
      subtitle: 'AI-powered disease detection right in your pocket.',
      placeholderIcon: Icons.document_scanner_rounded,
    ),
    OnboardingContent(
      title: 'Track Crop Vitality With Ease',
      subtitle:
          'Build a complete history of your scans to prevent future outbreaks.',
      placeholderIcon: Icons.auto_graph_rounded,
    ),
    OnboardingContent(
      title: 'Take Actions With Confidence',
      subtitle:
          'Get targeted treatment recommendations to protect your harvest.',
      placeholderIcon: Icons.shield_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPersonalization() async {
    // Saving that user finished onboarding!
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);

    if (mounted) {
      context.go('/setup_profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    'AGRILO',
                    style: AppTextStyles.bodyStyle.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: AppTextStyles.fontWeightBold,
                    ),
                  ),
                  TextButton(
                    onPressed: _goToPersonalization,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: CustomText(
                      'Skip',
                      style: AppTextStyles.bodyStyle.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 16.spMin,
                        fontWeight: AppTextStyles.fontWeightBold,
                      ),
                    ),
                  ),
                ],
              ),

              30.verticalSpace,

              // --- The PageView Carousel ---
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _contents.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // The Premium Placeholder Card
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Container(
                            height: 350.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(
                                color: AppColors.textGrey.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(30.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 50.r,
                                      spreadRadius: 10.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _contents[index].placeholderIcon,
                                  size: 80.spMin,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        40.verticalSpace,
                        // Title
                        CustomText(
                          _contents[index].title,
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMediumStyle.copyWith(
                            color: AppColors.textWhite,
                            fontSize: 32.spMin,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        20.verticalSpace,

                        // Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: CustomText(
                            overflow: TextOverflow.visible,
                            maxLines: 3,
                            _contents[index].subtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyStyle.copyWith(
                              color: AppColors.textWhite,
                              fontSize: 16.spMin,
                              height: 1.5,
                              fontWeight: AppTextStyles.fontWeightRegular,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // --- Footer ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Dot Indicators
                  Row(
                    children: List.generate(
                      _contents.length,
                      (index) => _buildDot(index: index),
                    ),
                  ),

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      if (_currentIndex == _contents.length - 1) {
                        _goToPersonalization();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 15.r,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        _currentIndex == _contents.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: AppColors.background,
                        size: 28.spMin,
                      ),
                    ),
                  ),
                ],
              ),

              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the dot indicators
  Widget _buildDot({required int index}) {
    bool isActive = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(right: 8.w),
      height: 8.h,
      width: isActive ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryColor
            : AppColors.textGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
