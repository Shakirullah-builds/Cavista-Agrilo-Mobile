import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/features/home/homepage_provider.dart';
import 'package:impulse_mobile/shared/custom/app_assets.dart';
import 'package:impulse_mobile/shared/custom/bottom_navbar.dart';
import 'package:impulse_mobile/shared/custom_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ScanResult extends ConsumerWidget {
  const ScanResult({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavBarCurrentIndex = ref.watch(bottomNavBarIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          'Scan Results',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 22.spMin),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultCard(),
                    30.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildStatChart(
                            label: 'AI Confidence',
                            value: 94,
                          ),
                        ),
                        15.horizontalSpace,
                        Expanded(
                          child: _buildStatChart(
                            label: 'Severity Level',
                            value: 60,
                          ),
                        ),
                      ],
                    ),
                    30.verticalSpace,
                    _buildRecommendedAction(),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildRecommendedAction() {
    return _buildResultCard(
      horizontalPadding: 20.w,
      verticalPadding: 20.h,
      color: AppColors.textGrey.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'Recommended Actions',
                style: AppTextStyles.titleStyle.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: AppTextStyles.fontWeightBold,
                ),
              ),
              AppAssets(
                assetPath: AssetPath.recActionIcon,
                color: AppColors.neonYellow,
              ),
            ],
          ),
          20.verticalSpace,
          _buildActionItem(
            text:
                'Remove affected leaves and dispose of them to prevent spread.',
          ),
          15.verticalSpace,
          _buildActionItem(
            text:
                'Improve air circulation around the plant by pruning or spacing.',
          ),
          15.verticalSpace,
          _buildActionItem(
            text:
                'Apply a suitable fungicide spray as per product instructions.',
          ),
          15.verticalSpace,
          _buildActionItem(
            text: 'Water at the base of the plant to keep leaves dry.',
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.lightGreen.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 13.spMin,
              color: AppColors.background,
            ),
          ),
        ),
        10.horizontalSpace,
        Flexible(
          child: CustomText(
            overflow: TextOverflow.visible,
            maxLines: 3,
            text,
            style: AppTextStyles.bodyStyle.copyWith(
              color: AppColors.textGrey,
              fontSize: 15.spMin,
              fontWeight: AppTextStyles.fontWeightMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChart({required String label, required double value}) {
    return _buildResultCard(
      horizontalPadding: 8.w,
      verticalPadding: 8.h,
      borderRadius: BorderRadius.circular(40.r),
      color: AppColors.textGrey.withValues(alpha: 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 55.0,
            lineWidth: 8.0,
            percent: value / 100,
            animation: true,
            animationDuration: 1200,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: AppColors.textGrey.withValues(alpha: 0.15),
            progressColor: AppColors.neonYellow,
            center: CustomText(
              letterSpacing: 2,
              '${value.toInt()}%',
              style: AppTextStyles.titleStyle.copyWith(
                color: AppColors.textWhite,
                fontWeight: AppTextStyles.fontWeightBold,
              ),
            ),
          ),
          15.verticalSpace,
          CustomText(
            letterSpacing: 2,
            label.toUpperCase(),
            style: AppTextStyles.bodyStyle.copyWith(
              color: AppColors.textGrey,
              fontSize: 14.5.spMin,
              fontWeight: AppTextStyles.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    Color? color,
    Widget? child,
    double? verticalPadding,
    double? horizontalPadding,
    BorderRadiusGeometry? borderRadius,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? 30.h,
        horizontal: horizontalPadding ?? 0.w,
      ),
      decoration: BoxDecoration(
        color: color ?? AppColors.textGrey.withValues(alpha: 0.25),
        borderRadius: borderRadius ?? BorderRadius.circular(35.r),
      ),
      child:
          child ??
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfectionResult(),
                15.verticalSpace,
                CustomText(
                  'Powdery Mildew',
                  style: AppTextStyles.headlineStyle.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: AppTextStyles.fontWeightBold,
                  ),
                ),
                15.verticalSpace,
                CustomText(
                  //letterSpacing: 1.0,
                  maxLines: 5,
                  'It is a very common fungal disease that affects plants. It shows up as a white or gray powdery coating on leaves, stems, and sometimes flowers.',
                  style: AppTextStyles.bodyStyle.copyWith(
                    color: AppColors.textGrey,
                    fontSize: 16.spMin,
                    overflow: TextOverflow.visible,
                    fontWeight: AppTextStyles.fontWeightMedium,
                  ),
                ),
                20.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(vertical: 100.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.r),
                    image: DecorationImage(
                      image: AssetImage(AssetPath.powderyMildewImg),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfectionResult() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 7.w),
          decoration: BoxDecoration(
            color: AppColors.errorRed.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        5.horizontalSpace,
        CustomText(
          'Pathogen Detected'.toUpperCase(),
          letterSpacing: 3,
          style: AppTextStyles.bodyStyle.copyWith(
            color: AppColors.textGrey,
            fontWeight: AppTextStyles.fontWeightBold,
          ),
        ),
      ],
    );
  }
}
