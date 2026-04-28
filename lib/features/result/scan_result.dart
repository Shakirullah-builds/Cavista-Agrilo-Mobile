import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/core/services/supabase_service.dart';
import 'package:impulse_mobile/shared/custom/app_assets.dart';
import 'package:impulse_mobile/shared/custom/bottom_navbar.dart';
import 'package:impulse_mobile/shared/custom_text.dart';
import 'package:impulse_mobile/shared/empty_state.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/home_page_provider.dart';

class ScanResult extends ConsumerWidget {
  final supabaseService = SupabaseService();
  final String aiLabel;
  final double confidence;
  final String imagePath;
  ScanResult({
    super.key,
    required this.aiLabel,
    required this.confidence,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavBarCurrentIndex = ref.watch(bottomNavBarIndexProvider);

    if (aiLabel == "No Scan Data" || aiLabel.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: CustomText(
            'Scan Results',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 22.spMin),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 40.w, right: 40.w),
            child: EmptyStateScreen(
              subtitle:
                  "Navigate to the scanner and snap a picture of a leaf to receive a real-time AI health analysis.",
              emptyStateButtonText: 'Open Scanner',
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: bottomNavBarCurrentIndex,
          onTap: (index) {
            if (index == 0) {
              ref.read(dashboardRefreshProvider.notifier).state++;
            }
            ref.read(bottomNavBarIndexProvider.notifier).state = index;
            ref.read(navigateToProvider)(context);
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: CustomText(
          'Scan Results',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 22.spMin),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: supabaseService.fetchDiseaseDetails(aiLabel, imagePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CupertinoActivityIndicator(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  radius: 15.r,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  'Ooops Error!: ${snapshot.error}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: AppTextStyles.fontWeightMedium,
                  ),
                  // style: AppTextStyles.titleStyle.copyWith(
                  //   color: AppColors.textWhite,
                  //   fontWeight: AppTextStyles.fontWeightMedium,
                  // ),
                ),
              );
            }
            // Data state

            final Map<String, dynamic> data = snapshot.data!;
            final String diseaseName = data["disease_name"] ?? "Unknown";
            final String description = data["description"] ?? "No description";
            final int severityLevel = data["severity_level"] ?? 0;

            // parse the JSONB array from Supabase into a Dart List of Strings
            final List<dynamic> rawActions = data["recommended_actions"] ?? [];
            final List<String> recommendedActions = rawActions
                .map((e) => e.toString())
                .toList();

            return SingleChildScrollView(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 10.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultCard(
                          diseaseName: diseaseName,
                          description: description,
                          severityLevel: severityLevel,
                          imagePath: imagePath,
                          context: context,
                        ),
                        30.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildStatChart(
                                label: 'AI Confidence',
                                value: confidence,
                                context: context,
                              ),
                            ),
                            15.horizontalSpace,
                            Expanded(
                              child: _buildStatChart(
                                label: 'Severity Level',
                                value: severityLevel.toDouble(),
                                context: context,
                              ),
                            ),
                          ],
                        ),
                        30.verticalSpace,
                        _buildRecommendedAction(
                          recommendedActions,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: bottomNavBarCurrentIndex,
        onTap: (index) {
          if (index == 0) {
            ref.read(dashboardRefreshProvider.notifier).state++;
          }
          ref.read(bottomNavBarIndexProvider.notifier).state = index;
          ref.read(navigateToProvider)(context);
        },
      ),
    );
  }

  Widget _buildRecommendedAction(
    List<String> actions, {
    required BuildContext context,
  }) {
    return _buildResultCard(
      context: context,
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: AppTextStyles.fontWeightBold,
                ),
                // style: AppTextStyles.titleStyle.copyWith(
                //   color: AppColors.textWhite,
                //   fontWeight: AppTextStyles.fontWeightBold,
                // ),
              ),
              AppAssets(
                assetPath: AssetPath.recActionIcon,
                color: AppColors.primaryColor,
              ),
            ],
          ),
          20.verticalSpace,
          ...actions.map(
            (actionText) => Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: _buildActionItem(text: actionText, context: context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({required String text, required BuildContext context}) {
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: AppTextStyles.fontWeightMedium,
              color: AppColors.textGrey,
              fontSize: 15.spMin,
            ),
            // style: AppTextStyles.bodyStyle.copyWith(
            //   color: AppColors.textGrey,
            //   fontSize: 15.spMin,
            //   fontWeight: AppTextStyles.fontWeightMedium,
            // ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChart({
    required String label,
    required double value,
    required BuildContext context,
  }) {
    return _buildResultCard(
      context: context,
      horizontalPadding: 8.w,
      verticalPadding: 15.h,
      borderRadius: BorderRadius.circular(40.r),
      color: AppColors.textGrey.withValues(alpha: 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 8.0,
            percent: value / 100,
            animation: true,
            animationDuration: 1200,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: AppColors.textGrey.withValues(alpha: 0.15),
            progressColor: AppColors.lightGreen,
            center: CustomText(
              '${value.toInt()}%',
              letterSpacing: 2,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: AppTextStyles.fontWeightBold,
              ),
              // style: AppTextStyles.titleStyle.copyWith(
              //   color: AppColors.textWhite,
              //   fontWeight: AppTextStyles.fontWeightBold,
              // ),
            ),
          ),
          15.verticalSpace,
          CustomText(
            letterSpacing: 2,
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: AppTextStyles.fontWeightBold,
              color: AppColors.textGrey,
              fontSize: 14.spMin,
            ),
            // style: AppTextStyles.bodyStyle.copyWith(
            //   color: AppColors.textGrey,
            //   fontSize: 14.spMin,
            //   fontWeight: AppTextStyles.fontWeightBold,
            // ),
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
    String? diseaseName,
    String? description,
    int? severityLevel,
    String? imagePath,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? 10.h,
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
                _buildInfectionResult(
                  severityLevel: severityLevel ?? 0,
                  diseaseName: diseaseName ?? "",
                  context: context,
                ),
                10.verticalSpace,
                CustomText(
                  diseaseName ?? "No Result",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: AppTextStyles.fontWeightBold,
                  ),
                  // style: AppTextStyles.headlineSmallStyle.copyWith(
                  //   color: AppColors.textWhite,
                  //   fontWeight: AppTextStyles.fontWeightBold,
                  // ),
                ),
                10.verticalSpace,
                CustomText(
                  description ??
                      "Description not available because of no result",
                  maxLines: 5,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.fontWeightMedium,
                    color: AppColors.textGrey,
                    fontSize: 15.spMin,
                    overflow: TextOverflow.visible,
                  ),
                  // style: AppTextStyles.bodyStyle.copyWith(
                  //   color: AppColors.textGrey,
                  //   fontSize: 15.spMin,
                  //   overflow: TextOverflow.visible,
                  //   fontWeight: AppTextStyles.fontWeightMedium,
                  // ),
                ),
                20.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(vertical: 100.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.r),
                    image: DecorationImage(
                      image: imagePath != null && imagePath.isNotEmpty
                          ? FileImage(File(imagePath)) as ImageProvider
                          : AssetImage(AssetPath.powderyMildewImg),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfectionResult({
    required int severityLevel,
    required String diseaseName,
    required BuildContext context,
  }) {
    Color statusColor;
    String statusText;

    if (severityLevel > 0) {
      statusColor = AppColors.errorRed;
      statusText = "Pathogen Detected";
    } else if (diseaseName.toLowerCase().contains("healthy")) {
      statusColor = AppColors.lightGreen;
      statusText = "Plant Healthy";
    } else {
      statusColor = AppColors.orangeAccent; // Use an orange/warning color here
      statusText = 'Analysis Failed';
    }
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        5.horizontalSpace,
        CustomText(
          statusText.toUpperCase(),
          letterSpacing: 3,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: AppTextStyles.fontWeightBold,
            color: AppColors.textGrey,
            fontSize: 12.spMin,
          ),
          // style: AppTextStyles.bodyStyle.copyWith(
          //   color: AppColors.textGrey,
          //   fontSize: 12.spMin,
          //   fontWeight: AppTextStyles.fontWeightBold,
          // ),
        ),
      ],
    );
  }
}
