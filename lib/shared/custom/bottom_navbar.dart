import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/shared/custom/app_assets.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.textGrey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textGrey.withValues(alpha: 0.08),
            blurRadius: 5.r,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(
            index: 0,
            iconWidget: AppAssets(
              assetPath: AssetPath.homeIcon,
              color: currentIndex == 0 ? AppColors.background : AppColors.textGrey
            ),
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            index: 1,
            isLarge: true,
            iconWidget: AppAssets(
              width: 40.w,
              height: 40.h,
              assetPath: AssetPath.scanIcon,
              color: currentIndex == 1 ? AppColors.background : AppColors.textGrey
            ),
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            index: 2,
            iconWidget: AppAssets(
              assetPath: AssetPath.scanResultIcon,
              color: currentIndex == 2 ? AppColors.background : AppColors.textGrey
            ),
            isSelected: currentIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    int index = 0,
    Widget? iconWidget,
    required bool isSelected,
    double horizontalPadding = 25,
    double verticalPadding = 30,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 25 : horizontalPadding.w,
          vertical: isLarge ? 25 : verticalPadding.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonYellow : AppColors.textGrey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(35.r),
        ),
        child: iconWidget,
      ),
    );
  }
}
