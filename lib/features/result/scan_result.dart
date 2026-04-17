import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/core/services/supabase_service.dart';
import 'package:impulse_mobile/features/home/homepage_provider.dart';
import 'package:impulse_mobile/shared/custom/app_assets.dart';
import 'package:impulse_mobile/shared/custom/bottom_navbar.dart';
import 'package:impulse_mobile/shared/custom_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
    //final aiResult = ref.watch(scanResultProvider);

    if (aiLabel == "No Scan Data" || aiLabel.isEmpty) {
      return _buildEmptyScanResult(context, ref, bottomNavBarCurrentIndex);
    }
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
        child: FutureBuilder<Map<String, dynamic>>(
          future: supabaseService.fetchDiseaseDetails(aiLabel),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CupertinoActivityIndicator(
                  color: AppColors.textWhite,
                  radius: 20.r,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  'Ooops Error!: ${snapshot.error}',
                  style: AppTextStyles.titleStyle.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: AppTextStyles.fontWeightMedium,
                  ),
                ),
              );
            }
            // Data state
              
            final Map<String, dynamic> data = snapshot.data!;
            final String diseaseName = data["disease_name"] ?? "Unknown";
            final String description =
                data["description"] ?? "No description";
            final int severityLevel = data["severity_level"] ?? 0;
              
            // parse the JSONB array from Supabase into a Dart List of Strings
            final List<dynamic> rawActions =
                data["recommended_actions"] ?? [];
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
                        ),
                        30.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildStatChart(
                                label: 'AI Confidence',
                                value: confidence,
                              ),
                            ),
                            15.horizontalSpace,
                            Expanded(
                              child: _buildStatChart(
                                label: 'Severity Level',
                                value: severityLevel.toDouble(),
                              ),
                            ),
                          ],
                        ),
                        30.verticalSpace,
                        _buildRecommendedAction(recommendedActions),
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
          ref.read(bottomNavBarIndexProvider.notifier).state = index;
          ref.read(navigateToProvider)(context);
        },
      ),
    );
  }

  Widget _buildEmptyScanResult(
    BuildContext context,
    WidgetRef ref,
    int bottomNavBarCurrentIndex,
  ) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
            'Scan Results',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 22.spMin),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AssetPath.emptyStateScannerImg,
                  width: 100.w,
                  height: 100.h,
                  color: AppColors.textGrey,
                  //fit: BoxFit.cover,
              ),
              25.verticalSpace,
              CustomText(
                "No Scan Data".toUpperCase(),
                style: AppTextStyles.headlineSmallStyle.copyWith(
                  color: AppColors.textGrey,
                  fontWeight: AppTextStyles.fontWeightBold,
                  fontSize: 26.spMin,
                ),
              ),
              10.verticalSpace,
              CustomText(
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.visible,
                "Navigate to the scanner and snap a picture of a leaf to receive a real-time AI health analysis.",
                style: AppTextStyles.bodyStyle.copyWith(
                  color: AppColors.textGrey,
                  fontWeight: AppTextStyles.fontWeightRegular,
                ),
              ),
              25.verticalSpace,
              GestureDetector(
                onTap: () {
                  ref.read(bottomNavBarIndexProvider.notifier).state = 1;
                  context.go('/scanner');
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.r),
                    color: AppColors.neonYellow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 18,
                        color: AppColors.background,
                      ),
                      10.horizontalSpace,
                      CustomText(
                        "Open Scanner".toUpperCase(),
                        style: AppTextStyles.bodyStyle.copyWith(
                          color: AppColors.background,
                          fontWeight: AppTextStyles.fontWeightBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: bottomNavBarCurrentIndex,
          onTap: (index) {
            ref.read(bottomNavBarIndexProvider.notifier).state = index;
            ref.read(navigateToProvider)(context);
          },
        ),
      ),
    );
  }

  Widget _buildRecommendedAction(List<String> actions) {
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
          ...actions.map(
            (actionText) => Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: _buildActionItem(text: actionText),
            ),
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
    String? diseaseName,
    String? description,
    int? severityLevel,
    String? imagePath,
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
                _buildInfectionResult(
                  severityLevel: severityLevel ?? 0,
                  diseaseName: diseaseName ?? "",
                ),
                15.verticalSpace,
                CustomText(
                  diseaseName ?? "No Result",
                  style: AppTextStyles.headlineStyle.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: AppTextStyles.fontWeightBold,
                  ),
                ),
                15.verticalSpace,
                CustomText(
                  description ??
                      "Description not available because of no result",
                  //letterSpacing: 1.0,
                  maxLines: 5,
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
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 7.w),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        5.horizontalSpace,
        CustomText(
          statusText.toUpperCase(),
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
