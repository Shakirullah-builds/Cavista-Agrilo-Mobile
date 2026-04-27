import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/core/services/supabase_service.dart';
import 'package:impulse_mobile/shared/custom_text.dart';
import 'package:impulse_mobile/shared/empty_state.dart';

class ScanHistoryScreen extends StatelessWidget {
  ScanHistoryScreen({super.key});

  final supabaseService = SupabaseService();

  // The Timezone-safe Date Formatter
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    String rawDate = dateStr;
    if (!rawDate.endsWith('Z') && !rawDate.contains('+')) {
      rawDate = '${rawDate.replaceFirst(' ', 'T')}Z';
    }
    DateTime date = DateTime.parse(rawDate).toLocal();
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

    // Formats like: "Apr 20 • 14:30"
    String time =
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    return "${months[date.month - 1]} ${date.day} • $time";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Ensure your dark background
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          'Scan History',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 22.spMin),
        ),
        leading: InkWell(
          borderRadius: BorderRadius.circular(15.r),
          onTap: () {
            if (context.canPop()) {
              context.pop();
              debugPrint('Can Pop');
            } else {
              context.go('/home');
              debugPrint('To home');
            }
          },
          // onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 15,
            color: AppColors.textWhite,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: supabaseService.fetchScanHistory(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(
                color: AppColors.primaryColor,
                radius: 15.r,
              ),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: CustomText(
                'Failed to load history.',
                style: AppTextStyles.bodyStyle.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            );
          }

          final scans = snapshot.data ?? [];

          // 3. Empty State
          if (scans.isEmpty) {
            return Center(
              child: EmptyStateScreen(
                //title: 'No scans yet',
                subtitle: 'Time to check your plants!',
              ),
            );
          }

          // 4. The Loaded List
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            itemCount: scans.length,
            separatorBuilder: (context, index) => 15.verticalSpace,
            itemBuilder: (context, index) {
              final scan = scans[index];
              final diseaseName = scan['disease_name']?.toString() ?? 'Unknown';
              final severityLevel = scan['severity_level'] as int? ?? 0;
              final formattedDate = _formatDate(scan['created_at']?.toString());

              return _buildHistoryTile(
                diseaseName: diseaseName,
                severityLevel: severityLevel,
                dateStr: formattedDate,
              );
            },
          );
        },
      ),
    );
  }

  // --- The Individual Row UI ---
  Widget _buildHistoryTile({
    required String diseaseName,
    required int severityLevel,
    required String dateStr,
  }) {
    final String lowerName = diseaseName.toLowerCase();
    final bool isInvalid =
        lowerName.contains('no plant') ||
        lowerName.contains('unknown') ||
        lowerName.contains('unrecognized');

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isInvalid) {
      statusColor = AppColors.orangeAccent; // Use your warning color
      statusText = 'Invalid';
      statusIcon = Icons.help_outline_rounded;
    } else if (severityLevel > 0) {
      statusColor = AppColors.errorRed;
      statusText = 'At Risk';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = AppColors.lightGreen;
      statusText = 'Healthy';
      statusIcon = Icons.eco_rounded;
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.textGrey.withValues(
          alpha: 0.1,
        ), // Subtle dark card background
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          // Left Icon Indicator
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24.spMin,
            ),
          ),

          15.horizontalSpace,

          // Middle Content (Name and Date)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  diseaseName,
                  style: AppTextStyles.bodyStyle.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: AppTextStyles.fontWeightBold,
                    fontSize: 16.spMin,
                  ),
                ),
                5.verticalSpace,
                CustomText(
                  dateStr,
                  style: AppTextStyles.bodyStyle.copyWith(
                    color: AppColors.textGrey,
                    fontSize: 13.spMin,
                  ),
                ),
              ],
            ),
          ),

          // Right Severity Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: CustomText(
              statusText,
              style: AppTextStyles.bodyStyle.copyWith(
                color: statusColor,
                fontWeight: AppTextStyles.fontWeightBold,
                fontSize: 12.spMin,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
