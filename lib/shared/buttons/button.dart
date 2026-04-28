import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/shared/custom_text.dart';

import '../../core/home_page_provider.dart';

class CustomButton extends ConsumerWidget {
  final VoidCallback? onTap;
  final String? buttonText;
  final IconData? icon;
  final Color? buttonColor;
  final double? width;
  final EdgeInsetsGeometry? verticalPadding;
  final List<BoxShadow>? boxShadow;
  final Widget? child;
  const CustomButton({
    super.key,
    this.onTap,
    this.buttonText,
    this.icon,
    this.buttonColor,
    this.width,
    this.verticalPadding,
    this.boxShadow,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            ref.read(bottomNavBarIndexProvider.notifier).state = 1;
            context.push('/scanner');
          },
      child: Container(
        width: width ?? 0.5.sw,
        alignment: Alignment.center,
        padding: verticalPadding ?? EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          boxShadow: boxShadow,
          borderRadius: BorderRadius.circular(35.r),
          color: buttonColor ?? AppColors.primaryColor,
        ),
        child: child ?? Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.camera_alt_outlined,
              size: 18,
              color: AppColors.background,
            ),
            10.horizontalSpace,
            CustomText(
              buttonText ?? "Open Scanner".toUpperCase(),
              style: AppTextStyles.bodyStyle.copyWith(
                color: AppColors.background,
                fontWeight: AppTextStyles.fontWeightBold,
              ),
              // style: AppTextStyles.bodyStyle.copyWith(
              //   color: AppColors.background,
              //   fontWeight: AppTextStyles.fontWeightBold,
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
