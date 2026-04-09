import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/core/models/model.dart';
import 'package:impulse_mobile/features/home/homepage_provider.dart';
import 'package:impulse_mobile/shared/custom/app_assets.dart';
import 'package:impulse_mobile/shared/custom/bottom_navbar.dart';
import 'package:impulse_mobile/shared/custom_text.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavBarCurrentIndex = ref.watch(
      bottomNavBarIndexProvider,
    ); // Watch the bottom nav bar index
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 15.w, top: 15.h, right: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                30.verticalSpace,
                _buildQuickStats(ref),
                10.verticalSpace,
                _buildSwipeableCard(ref),
                10.verticalSpace,
                _buildPlantStats(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: bottomNavBarCurrentIndex,
        onTap: (index) {
          ref.read(bottomNavBarIndexProvider.notifier).state = index;
          ref.read(navigateToProvider)(context);
          debugPrint('Bottom Nav Index: $index');
        },
      ),
    );
  }

  Widget _buildPlantStats() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _plantStats()),
          5.horizontalSpace,
          Expanded(
            child: _plantStats(
              icon: AppAssets(
                assetPath: AssetPath.pieChartIcon,
                color: AppColors.neonYellow,
              ),
              label: 'Average Health Index',
              value: '85%',
              color: AppColors.neonYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableCard(WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final pageController = ref.watch(pageControllerProvider);
    final animatedPages = ref.watch(animatedPagesProvider);

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 440.h,
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                ref.read(currentPageProvider.notifier).state = index;
                debugPrint('Current Page Index: $index');
                ref
                    .read(animatedPagesProvider.notifier)
                    .update((state) => {...state, index});
              },
              children: [
                _buildPlantHealthOverview(animate: !animatedPages.contains(0)),
                _buildScanOverview(animate: !animatedPages.contains(1)),
              ],
            ),
          ),
          10.verticalSpace,
          _buildPageIndicator(currentPage),
        ],
      ),
    );
  }

  // ============== Scan Overview ==============
  Widget _buildScanOverview({bool animate = false}) {
    final content = cardWidget(
      alignment: Alignment.centerLeft,
      color: AppColors.neonYellow,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.only(top: 0.r, left: 15.w, right: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(title: 'Scan Overview', icon: AssetPath.scanIcon),
            20.verticalSpace,
            CustomText(
              'Overall Crop Vitality',
              style: AppTextStyles.titleMediumStyle.copyWith(
                color: AppColors.textGrey,
                fontSize: 20.spMin,
                fontWeight: AppTextStyles.fontWeightMedium,
              ),
            ),
            CustomText(
              '96%',
              style: AppTextStyles.titleMediumStyle.copyWith(
                color: AppColors.textGrey,
                fontSize: 50.spMin,
                fontWeight: AppTextStyles.fontWeightBold,
              ),
            ),
            Row(
              children: [
                AppAssets(
                  assetPath: AssetPath.heartPulseIcon,
                  color: AppColors.background,
                ),
                5.horizontalSpace,
                CustomText(
                  'Growth on Track',
                  style: AppTextStyles.captionStyle.copyWith(
                    color: AppColors.background,
                    fontSize: 18.spMin,
                    fontWeight: AppTextStyles.fontWeightRegular,
                  ),
                ),
              ],
            ),
            10.verticalSpace,
            const Divider(color: AppColors.textGrey, thickness: 0.2),
            15.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScanInfo(label: 'SCANS', value: '10'),
                _buildScanInfo(label: 'RISKS', value: '2'),
                _buildScanInfo(label: 'LAST SCAN', value: '2Hrs'),
              ],
            ),
          ],
        ),
      ),
    );
    if (animate) {
      return FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: content,
      );
    }
    return content;
  }

  Widget _buildScanInfo({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          style: AppTextStyles.captionStyle.copyWith(
            color: AppColors.background,
            fontSize: 16.spMin,
            fontWeight: AppTextStyles.fontWeightRegular,
          ),
        ),
        5.verticalSpace,
        CustomText(
          value,
          style: AppTextStyles.titleMediumStyle.copyWith(
            color: AppColors.background,
            fontSize: 25.spMin,
            fontWeight: AppTextStyles.fontWeightBold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardHeader({required String title, required String icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          title,
          style: AppTextStyles.titleMediumStyle.copyWith(
            color: AppColors.background,
            fontWeight: AppTextStyles.fontWeightBold,
            fontSize: 18.spMin,
          ),
        ),
        circledCardWidget(
          child: AppAssets(assetPath: icon, color: AppColors.background),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: currentPage == index ? 24.w : 8.w,
          height: 2.5.w,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.neonYellow
                : AppColors.textGrey.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8.r),
          ),
        );
      }),
    );
  }

  Widget _buildPlantHealthOverview({bool animate = false}) {
    final content = cardWidget(
      alignment: Alignment.centerLeft,
      color: AppColors.neonYellow,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.only(top: 0.r, left: 15.w, right: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(
              title: 'Health Overview',
              icon: AssetPath.activityIcon,
            ),
            10.verticalSpace,
            _buildPlantInfoRows(),
            30.verticalSpace,
            _buildPlantMetrics(),
            20.verticalSpace,
          ],
        ),
      ),
    );
    if (animate) {
      return FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: content,
      );
    }
    return content;
  }

  Widget _buildPlantMetrics() {
    return Consumer(
      builder: (context, ref, child) {
        final metrics = ref.watch(plantMetricProvider);
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildMetricTile(metrics[0])),
                15.horizontalSpace,
                Expanded(child: _buildMetricTile(metrics[1])),
              ],
            ),
            15.verticalSpace,
            Row(
              children: [
                Expanded(child: _buildMetricTile(metrics[2])),
                15.horizontalSpace,
                Expanded(child: _buildMetricTile(metrics[3])),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile(PlantMetric metric) {
    return cardWidget(
      padding: EdgeInsets.all(15.r),
      color: AppColors.textGrey.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            metric.label,
            style: AppTextStyles.titleMediumStyle.copyWith(
              color: AppColors.background,
              fontWeight: AppTextStyles.fontWeightMedium,
              fontSize: 14.spMin,
            ),
          ),
          4.verticalSpace,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: metric.value,
                  style: AppTextStyles.headlineStyle.copyWith(
                    color: AppColors.background,
                    fontWeight: AppTextStyles.fontWeightBold,
                    fontSize: 25.spMin,
                  ),
                ),
                if (metric.unit != null)
                  TextSpan(
                    text: metric.unit,
                    style: AppTextStyles.bodyMediumStyle.copyWith(
                      color: AppColors.background,
                      fontSize: 12.spMin,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfoRows() {
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: cardWidget(
              padding: EdgeInsets.all(13.r),
              alignment: Alignment.centerLeft,
              child: _buildPlantInfoItem(AssetPath.calendarIcon, '3 Days Ago'),
            ),
          ),
          5.horizontalSpace,
          Expanded(
            child: cardWidget(
              padding: EdgeInsets.all(13.r),
              alignment: Alignment.centerLeft,
              child: _buildPlantInfoItem(AssetPath.sproutIcon, 'Flower Plant'),
            ),
          ),
        ],
      ),
    );
  }

  // ======== Quick Stats Section ========
  Widget _buildQuickStats(WidgetRef ref) {
    final stats = ref.watch(quickStatsProvider);

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 200),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(title: stats[0], ref: ref, index: 0),
          ),
          5.horizontalSpace,
          Expanded(
            child: _buildStatCard(title: stats[1], ref: ref, index: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required WidgetRef ref,
    required int index,
  }) {
    final currentPage = ref.watch(currentPageProvider);
    final isSelected = currentPage == index;

    return GestureDetector(
      onTap: () {
        ref.read(currentPageProvider.notifier).state = index;
        ref.read(pageControllerProvider).jumpToPage(index);
        debugPrint('Quick Stat Card Tapped: $title (Index: $index)');
      },
      child: cardWidget(
        color: isSelected
            ? AppColors.textWhite
            : AppColors.textGrey.withValues(alpha: 0.05),
        child: CustomText(
          title,
          style: AppTextStyles.titleMediumStyle.copyWith(
            color: isSelected ? AppColors.background : AppColors.textGrey,
            fontWeight: AppTextStyles.fontWeightMedium,
          ),
        ),
      ),
    );
  }

  // ========  Header Section ========
  Widget _buildHeader() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'Hello, Devid!',
                style: AppTextStyles.bodyMediumStyle.copyWith(
                  color: AppColors.textGrey,
                  fontSize: 20.spMin,
                  fontWeight: AppTextStyles.fontWeightRegular,
                ),
              ),
              CustomText(
                'Good Morning!',
                style: AppTextStyles.headlineStyle.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: AppTextStyles.fontWeightBold,
                  overflow: TextOverflow.visible,
                  fontSize: 30.spMin,
                ),
              ),
            ],
          ),
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return circledCardWidget(
      child: Badge(
        padding: EdgeInsets.zero,
        offset: const Offset(0, 0),
        backgroundColor: AppColors.neonYellow,
        child: AppAssets(
          assetPath: AssetPath.bellIcon,
          color: AppColors.textWhite,
        ),
      ),
    );
  }

  Widget _plantStats({
    Widget? icon,
    String label = 'Total Scans',
    String value = '100',
    Color color = AppColors.lightGreen,
  }) {
    icon ??= AppAssets(
      assetPath: AssetPath.apertureIcon,
      color: AppColors.lightGreen,
    );
    return cardWidget(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(15.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: circledCardWidget(
              border: Border.all(color: AppColors.transparent),
              child: icon,
            ),
          ),
          CustomText(
            value,
            style: AppTextStyles.headlineStyle.copyWith(
              color: AppColors.textWhite,
              fontWeight: AppTextStyles.fontWeightMedium,
            ),
          ),
          CustomText(
            maxLines: 2,
            label,
            style: AppTextStyles.bodyStyle.copyWith(
              color: AppColors.textGrey,
              fontWeight: AppTextStyles.fontWeightRegular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfoItem(String icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAssets(
          assetPath: icon,
          color: AppColors.background,
          width: 18.w,
          height: 18.h,
        ),
        5.horizontalSpace,
        Flexible(
          child: CustomText(
            label,
            style: AppTextStyles.captionStyle.copyWith(
              color: AppColors.background,
              fontWeight: AppTextStyles.fontWeightBold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget circledCardWidget({Color? color, BoxBorder? border, Widget? child}) {
    return Container(
      padding: EdgeInsets.all(30.r),
      decoration: BoxDecoration(
        color: color ?? AppColors.textGrey.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border:
            border ??
            Border.all(
              color: AppColors.textWhite.withValues(alpha: 0.25),
              width: 0.2.w,
            ),
      ),
      child: child,
    );
  }

  Widget cardWidget({
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    Color? color,
    Widget? child,
  }) {
    return Container(
      alignment: alignment ?? Alignment.center,
      padding: padding ?? EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        color: color ?? AppColors.textGrey.withValues(alpha: 0.10),
        borderRadius: borderRadius ?? BorderRadius.circular(35.r),
      ),
      child:
          child ??
          CustomText(
            'Health Overview',
            style: AppTextStyles.titleMediumStyle.copyWith(
              color: AppColors.textGrey,
              fontWeight: AppTextStyles.fontWeightMedium,
            ),
          ),
    );
  }
}
