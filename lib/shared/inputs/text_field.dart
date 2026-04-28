import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;

  const CustomTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: AppColors.primaryColor),
        );
    return TextField(
      maxLength: 15,
      maxLines: 1,
      keyboardType: TextInputType.name,
      cursorColor: AppColors.primaryColor.withValues(alpha: 0.5),
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge,
      // style: AppTextStyles.bodyStyle.copyWith(color: AppColors.textGrey),
      decoration: InputDecoration(
        counterText: '',
        hintText: 'e.g., Farmer John',
        hintStyle: AppTextStyles.bodyStyle.copyWith(
          color: AppColors.textGrey.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.textGrey.withValues(alpha: 0.1),
        border: inputBorder,
        contentPadding: EdgeInsets.all(20.r),
        enabledBorder: inputBorder,
        focusedBorder: inputBorder,
      ),
    );
  }
}
