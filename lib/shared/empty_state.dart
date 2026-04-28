import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/shared/buttons/button.dart';
import 'package:impulse_mobile/shared/custom/app_assets.dart';
import 'package:impulse_mobile/shared/custom_text.dart';

class EmptyStateScreen extends ConsumerWidget {
  //final String title;
  final String subtitle;
  final String? emptyStateButtonText;
  final String? assetPath;
  final String? title;
  final IconData? icon;
  final VoidCallback? onTap;
  const EmptyStateScreen({
    super.key,
    this.title,
    required this.subtitle,
    this.emptyStateButtonText,
    this.assetPath,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppAssets(
          assetPath: assetPath ?? AssetPath.scanIcon,
          color:
              Theme.of(context).textTheme.bodyLarge?.color ??
              AppColors.textGrey,
          width: 70.w,
          height: 70.h,
        ),
        25.verticalSpace,

        CustomText(
          title ?? 'No Scans Yet!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: AppTextStyles.fontWeightBold,
            fontSize: 24.spMin,
          ),
          // style: AppTextStyles.headlineStyle.copyWith(
          //   color: AppColors.textWhite,
          //   fontWeight: AppTextStyles.fontWeightBold,
          //   fontSize: 24.spMin,
          // ),
        ),
        10.verticalSpace,
        CustomText(
          maxLines: 3,
          overflow: TextOverflow.visible,
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textGrey,
            fontSize: 16.spMin,
            height: 1.5,
          ),
          // style: AppTextStyles.bodyStyle.copyWith(
          //   color: AppColors.textGrey,
          //   fontSize: 16.spMin,
          //   height: 1.5,
          // ),
        ),
        35.verticalSpace,
        // 3. The Call to Action
        CustomButton(
          buttonText: emptyStateButtonText?.toUpperCase(),
          icon: icon,
          onTap: onTap,
        ),
      ],
    );
  }
}
