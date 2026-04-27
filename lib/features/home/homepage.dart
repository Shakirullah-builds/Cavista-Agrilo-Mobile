import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/core/models/model.dart';
import 'package:impulse_mobile/shared/custom/app_assets.dart';
import 'package:impulse_mobile/shared/custom/bottom_navbar.dart';
import 'package:impulse_mobile/shared/custom_text.dart';
import 'package:impulse_mobile/shared/empty_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/home_page_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String userName = 'Guest';
  String greeting = 'Welcome!';
  bool hasScans = false;
  int totalScans = 0;
  int riskCount = 0;
  int averageHealth = 100;
  bool isLoadingData = true;
  int healthyRatio = 100;
  String lastScanTime = 'No scans yet';
  String topRisk = "None";
  int scansToday = 0;
  String latestStatus = "None";
  int uniqueThreats = 0;
  String firstScanDate = 'Member since today';
  int cropsTracked = 0;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _fetchUserName();
    _loadDashboardData();

    final savedPage = ref.read(currentPageProvider);
    _pageController = PageController(initialPage: savedPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Dynamic Greeting
  void _setGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      greeting = hour < 12
          ? 'Good Morning'
          : hour < 17
          ? 'Good Afternoon'
          : 'Good Evening';
    });
  }

  Future<void> _fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();

    // Make sure this key matches exactly what you saved in SetupProfileScreen!
    final savedName = prefs.getString('userName');

    // 4. Update the UI safely
    if (savedName != null && savedName.isNotEmpty && mounted) {
      setState(() {
        userName = savedName;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id');

    if (deviceId == null) return;

    try {
      final response = await Supabase.instance.client
          .from("scan_history")
          .select()
          .eq('device_id', deviceId);

      List<dynamic> scans = response;

      if (scans.isNotEmpty) {
        int risks = 0;
        int totalSeverity = 0;
        int perfectlyHealthyScans = 0;
        int todayCount = 0;

        // Keep 'now' as local time so we can compare it properly
        DateTime now = DateTime.now();
        DateTime? latestDate;
        DateTime? oldestDate;
        Map<String, int> diseaseCounts = {};
        Set<String> uniqueCropType = {};

        // --- ONE SINGLE LOOP FOR EVERYTHING ---
        for (var scan in scans) {
          final severity = scan['severity_level'] as int? ?? 0;
          totalSeverity += severity;

          // Grab the full name and split it to get the first word
          final fullName = scan['disease_name']?.toString() ?? 'Unknown';
          final cropName = fullName.split(' ').first;

          // The Non-Crop Bouncer
          // Only add it to the 'Crops Tracked' count if it's an actual plant!
          if (cropName.toLowerCase() != 'unknown' &&
              cropName.toLowerCase() != 'no' &&
              cropName.toLowerCase() != 'unrecognized') {
            uniqueCropType.add(cropName);
          }
          if (severity > 0) {
            risks++;
            // Track diseases
            final dName = scan['disease_name']?.toString() ?? 'Unknown';
            diseaseCounts[dName] = (diseaseCounts[dName] ?? 0) + 1;
          } else {
            perfectlyHealthyScans++;
          }

          // --- THE TRUE TIMEZONE FIX ---
          if (scan['created_at'] != null) {
            String rawDate = scan['created_at'].toString();

            // Force UTC format BEFORE parsing so Dart doesn't get confused
            if (!rawDate.endsWith('Z') && !rawDate.contains('+')) {
              rawDate = '${rawDate.replaceFirst(' ', 'T')}Z';
            }

            // Parse as UTC, then immediately convert to the phone's local time
            DateTime scanDate = DateTime.parse(rawDate).toLocal();

            // Find the most recent date
            if (latestDate == null || scanDate.isAfter(latestDate)) {
              latestDate = scanDate;
              latestStatus = severity == 0 ? "Healthy" : "At Risk";
            }

            // --- Add this right below where you find the latestDate ---
            if (oldestDate == null || scanDate.isBefore(oldestDate)) {
              oldestDate = scanDate;
            }

            // Count if it was today
            if (now.year == scanDate.year &&
                now.month == scanDate.month &&
                now.day == scanDate.day) {
              todayCount++;
            }
          }
        }

        // --- FORMAT LAST SCAN TIME ---
        String timeAgo = 'Just now';
        if (latestDate != null) {
          final diff = now.difference(latestDate);
          if (diff.inDays > 0) {
            timeAgo = '${diff.inDays}day(s) ago';
          } else if (diff.inHours > 0) {
            timeAgo = '${diff.inHours}hr(s) ago';
          } else if (diff.inMinutes > 0) {
            timeAgo = '${diff.inMinutes}min(s) ago';
          }
        }

        // --- FIND TOP RISK ---
        String mostFrequentDisease = 'None';
        int maxCount = 0;
        diseaseCounts.forEach((key, value) {
          if (value > maxCount) {
            maxCount = value;
            mostFrequentDisease = key;
          }
        });

        // --- FORMAT FIRST SCAN DATE ---
        String firstScanStr = 'Member since today';
        if (oldestDate != null) {
          List<String> months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          firstScanStr =
              "Member since ${months[oldestDate.month - 1]} ${oldestDate.day}";
        }

        // --- UI UPDATE ---
        if (!mounted) return;
        setState(() {
          totalScans = scans.length;
          riskCount = risks;
          averageHealth = 100 - (totalSeverity / scans.length).round();
          healthyRatio = ((perfectlyHealthyScans / scans.length) * 100).round();

          lastScanTime = timeAgo;
          topRisk = mostFrequentDisease;
          scansToday = todayCount;
          cropsTracked = uniqueCropType.length;
          uniqueThreats = diseaseCounts.length;
          firstScanDate = firstScanStr;

          hasScans = true;
          isLoadingData = false;
        });
      } else {
        setState(() {
          isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
      setState(() {
        isLoadingData = false;
      });
    }
  }

  String get _healthStatusText {
    if (averageHealth >= 80) {
      return 'Growth on Track';
    } else if (averageHealth >= 50) {
      return 'Needs Attention';
    } else {
      return 'Critical Condition';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarCurrentIndex = ref.watch(
      bottomNavBarIndexProvider,
    ); // Watch the bottom nav bar index
    ref.listen(dashboardRefreshProvider, (previous, next) {
      _loadDashboardData();
    });
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppColors.transparent,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 15.w, top: 15.h, right: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                10.verticalSpace,
                // 2. The Conditional Layout
                if (isLoadingData)
                  Expanded(
                    child: Center(
                      child: CupertinoActivityIndicator(
                        color: AppColors.primaryColor,
                        radius: 15.r,
                      ),
                    ),
                  )
                else if (!hasScans)
                  // EMPTY STATE: Fills the remaining screen and centers perfectly!
                  Expanded(
                    child: EmptyStateScreen(
                      //title: 'No Scans Yet',
                      subtitle:
                          "Your crop health overview will appear here once you make your first scan.",
                      emptyStateButtonText: 'Start first scan',
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      backgroundColor: AppColors.background,
                      color: AppColors.lightGreen,
                      onRefresh: () async {
                        await _loadDashboardData();

                        if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: CustomText(
                              'Dashboard up to date!',
                              style: AppTextStyles.bodyStyle.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: AppColors.orangeAccent,
                            duration: const Duration(seconds: 2),
                            showCloseIcon: true,
                            closeIconColor: AppColors.background,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                        );
                      }
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickStats(ref),
                            10.verticalSpace,
                            _buildSwipeableCard(ref),
                            10.verticalSpace,
                            _buildPlantStats(),
                            20.verticalSpace, // Extra padding for the bottom nav bar
                          ],
                        ),
                      ),
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
            debugPrint('Bottom Nav Index: $index');
          },
        ),
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
          Expanded(child: _plantStats(value: '$totalScans')),
          5.horizontalSpace,
          Expanded(
            child: _plantStats(
              icon: AppAssets(
                assetPath: AssetPath.pieChartIcon,
                color: AppColors.primaryColor,
              ),
              label: 'Healthy Crop Rate',
              value: '$healthyRatio%',
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableCard(WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    //final pageController = ref.watch(pageControllerProvider);
    final animatedPages = ref.watch(animatedPagesProvider);

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 380.h,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                ref.read(currentPageProvider.notifier).state = index;
                debugPrint('Current Page Index: $index');
                ref
                    .read(animatedPagesProvider.notifier)
                    .update((state) => {...state, index});
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: _buildPlantHealthOverview(
                    animate: !animatedPages.contains(0),
                  ),
                ),
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

  // ============== Health Overview ==============
  Widget _buildPlantHealthOverview({bool animate = false}) {
    final content = cardWidget(
      alignment: Alignment.centerLeft,
      color: AppColors.primaryColor,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.only(top: 0.r, left: 15.w, right: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCardHeader(
              subtitle: 'Health Overview',
              icon: AssetPath.activityIcon,
              title: 'Status Report',
            ),
            30.verticalSpace,
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  CustomText(
                    'Overall Crop Vitality',
                    style: AppTextStyles.titleMediumStyle.copyWith(
                      color: AppColors.background,
                      fontSize: 13.spMin,
                      fontWeight: AppTextStyles.fontWeightBold,
                    ),
                  ),
                  CustomText(
                    '$averageHealth%',
                    style: AppTextStyles.titleMediumStyle.copyWith(
                      color: AppColors.background,
                      fontSize: 60.spMin,
                      fontWeight: AppTextStyles.fontWeightBold,
                    ),
                  ),
                  10.verticalSpace,
                  Container(
                    width: 0.45.sw,
                    padding: EdgeInsets.symmetric(
                      vertical: 5.h,
                      horizontal: 10.w,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: averageHealth <= 50
                          ? AppColors.errorRed.withValues(alpha: 0.8)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(35.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppAssets(
                          assetPath: AssetPath.heartPulseIcon,
                          color: averageHealth <= 50
                              ? AppColors.textWhite
                              : AppColors.primaryColor,
                          width: 20.w,
                          height: 20.h,
                        ),
                        5.horizontalSpace,
                        CustomText(
                          _healthStatusText.toUpperCase(),
                          style: AppTextStyles.captionStyle.copyWith(
                            color: averageHealth <= 50
                                ? AppColors.textWhite
                                : AppColors.primaryColor,
                            fontSize: 10.spMin,
                            fontWeight: AppTextStyles.fontWeightBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            const Divider(color: AppColors.textGrey, thickness: 0.3),
            15.verticalSpace,
            _buildReportRowWithDividers([
              _buildhealthInfo(
                label: 'Risk Level',
                value: riskCount > 0 ? 'High' : 'Low',
              ),
              _buildhealthInfo(label: 'Total Risks', value: '$riskCount'),
              _buildhealthInfo(
                label: 'Threats',
                value: '$uniqueThreats Disease(s)',
              ),
            ]),
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

  Widget _buildReportRowWithDividers(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            SizedBox(
              height: 50.h,
              child: VerticalDivider(color: AppColors.textGrey, thickness: 0.3),
            ),
        ],
      ],
    );
  }

  Widget _buildhealthInfo({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label.toUpperCase(),
          style: AppTextStyles.captionStyle.copyWith(
            color: AppColors.background.withValues(alpha: 0.5),
            //fontSize: 16.spMin,
            fontWeight: AppTextStyles.fontWeightBold,
          ),
        ),
        5.verticalSpace,
        CustomText(
          value,
          style: AppTextStyles.titleSmallStyle.copyWith(
            color: AppColors.background,
            //fontSize: 25.spMin,
            fontWeight: AppTextStyles.fontWeightBold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardHeader({
    required String title,
    required String icon,
    required String subtitle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              title.toUpperCase(),
              style: AppTextStyles.captionStyle.copyWith(
                color: AppColors.background.withValues(alpha: 0.5),
                fontWeight: AppTextStyles.fontWeightBold,
                //fontSize: 15.spMin,
              ),
            ),
            3.verticalSpace,
            CustomText(
              subtitle,
              style: AppTextStyles.titleMediumStyle.copyWith(
                color: AppColors.background,
                fontWeight: AppTextStyles.fontWeightBold,
                fontSize: 20.spMin,
              ),
            ),
          ],
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
                ? AppColors.primaryColor
                : AppColors.textGrey.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8.r),
          ),
        );
      }),
    );
  }

  // ========= Scan Overview
  Widget _buildScanOverview({bool animate = false}) {
    final content = cardWidget(
      alignment: Alignment.centerLeft,
      color: AppColors.primaryColor,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.only(top: 10.r, left: 15.w, right: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //10.verticalSpace,
            _buildCardHeader(
              subtitle: 'Scan Overview',
              icon: AssetPath.scanIcon,
              title: 'Diagnostic Log',
            ),
            10.verticalSpace,
            _buildScanInfoRows(),
            10.verticalSpace,
            _buildScanMetrics(),
            15.verticalSpace,
            _buildScanHistoryTile(),
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

  Widget _buildScanHistoryTile() {
    return InkWell(
      onTap: () {
        context.push('/scan_history');
      },
      borderRadius: BorderRadius.circular(15.r),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          width: 0.8.sw,
          padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: AppColors.textGrey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                'View Full History',
                style: AppTextStyles.bodyStyle.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: AppTextStyles.fontWeightBold,
                ),
              ),
              10.horizontalSpace,
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primaryColor,
                size: 16.spMin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanMetrics() {
    final List<PlantMetric> metrics = [
      PlantMetric(
        label: 'CROP TRACKED',
        value: '$cropsTracked',
        unit: 'type(s)',
      ),
      PlantMetric(label: 'TODAY SCANS', value: '$scansToday', unit: ''),
      PlantMetric(label: 'LATEST RESULT', value: latestStatus, unit: ''),
      PlantMetric(label: 'MOST COMMON', value: topRisk, unit: ''),
    ];

    // 2. UI return without needing a Riverpod Consumer!
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

  Widget _buildScanInfoRows() {
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: cardWidget(
              //color: AppColors.textGrey.withValues(alpha: 0.5),
              padding: EdgeInsets.all(7.r),
              alignment: Alignment.centerLeft,
              child: _buildPlantInfoItem(AssetPath.calendarIcon, firstScanDate),
            ),
          ),
          5.horizontalSpace,
          Expanded(
            child: cardWidget(
              padding: EdgeInsets.all(7.r),
              alignment: Alignment.center,
              child: _buildPlantInfoItem(null, lastScanTime),
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
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        debugPrint('Quick Stat Card Tapped: $title (Index: $index)');
      },
      child: cardWidget(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        color: isSelected
            ? AppColors.textWhite
            : AppColors.textGrey.withValues(alpha: 0.1),
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
                'Hello, $userName',
                style: AppTextStyles.bodyMediumStyle.copyWith(
                  color: AppColors.textGrey,
                  fontSize: 17.spMin,
                  fontWeight: AppTextStyles.fontWeightRegular,
                ),
              ),
              CustomText(
                greeting,
                style: AppTextStyles.headlineStyle.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: AppTextStyles.fontWeightBold,
                  overflow: TextOverflow.visible,
                  fontSize: 23.spMin,
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
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.orangeAccent,
            showCloseIcon: true,
            closeIconColor: AppColors.background,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            content: Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.watch_later,
                  color: AppColors.background,
                  size: 17.spMin,
                ),
                10.horizontalSpace,
                CustomText(
                  'This feature is coming soon!',
                  style: AppTextStyles.bodyStyle.copyWith(
                    color: AppColors.background,
                    fontWeight: AppTextStyles.fontWeightBold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: circledCardWidget(
        padding: EdgeInsets.all(20.r),
        child: Badge(
          padding: EdgeInsets.zero,
          offset: const Offset(0, 0),
          backgroundColor: AppColors.primaryColor,
          child: AppAssets(
            width: 20.w,
            height: 20.h,
            assetPath: AssetPath.bellIcon,
            color: AppColors.textWhite,
          ),
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

  Widget _buildPlantInfoItem(String? icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          AppAssets(
            assetPath: icon,
            color: AppColors.background,
            width: 18.w,
            height: 18.h,
          ),
          5.horizontalSpace,
        ],
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

  Widget circledCardWidget({
    Color? color,
    BoxBorder? border,
    Widget? child,
    EdgeInsetsGeometry? padding,
  }) {
    // final;
    return Container(
      padding: padding ?? EdgeInsets.all(10.r),
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
