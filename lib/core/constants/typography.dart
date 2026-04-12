import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/colors.dart';

class AppTextStyles {
  AppTextStyles._();
  //static final AppTextStyles instance = AppTextStyles._();

  static const double headline = 36.0;
  static const double headlineMedium = 30.0;
  static const double headlineSmall = 24.0;
  static const double title = 20.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double body = 14.0;
  static const double bodyMedium = 13.0;
  static const double caption = 12.0;

  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightBold = FontWeight.w700;

  static TextStyle get headlineStyle => TextStyle(
    fontSize: headline.spMin,
    fontWeight: fontWeightRegular,
    color: AppColors.textWhite,
  );

  static TextStyle get headlineMediumStyle => TextStyle(
    fontSize: headlineMedium.spMin,
    fontWeight: fontWeightRegular,
    color: AppColors.textWhite,
  );

  static TextStyle get headlineSmallStyle => TextStyle(
    fontSize: headlineSmall.spMin,
    fontWeight: fontWeightRegular,
    color: AppColors.textWhite,
  );

  static TextStyle get titleStyle => TextStyle(
    fontSize: title.spMin,
    fontWeight: fontWeightMedium,
    color: AppColors.textWhite,
  );

  static TextStyle get titleMediumStyle => TextStyle(
    fontSize: titleMedium.spMin,
    fontWeight: fontWeightMedium,
    color: AppColors.textWhite,
  );

  static TextStyle get titleSmallStyle => TextStyle(
    fontSize: titleSmall.spMin,
    fontWeight: fontWeightMedium,
    color: AppColors.textWhite,
  );

  static TextStyle get bodyStyle => TextStyle(
    fontSize: body.spMin,
    fontWeight: fontWeightRegular,
    color: AppColors.textWhite,
  );

  static TextStyle get bodyMediumStyle => TextStyle(
    fontSize: bodyMedium.spMin,
    fontWeight: fontWeightRegular,
    color: AppColors.textWhite,
  );

  static TextStyle get captionStyle => TextStyle(
    fontSize: caption.spMin,
    fontWeight: fontWeightRegular,
    color: AppColors.textGrey,
  );

  static TextTheme getTextTheme() {
    return TextTheme(
      headlineSmall: headlineSmallStyle,
      headlineMedium: headlineMediumStyle,
      headlineLarge: headlineStyle,
      titleLarge: titleStyle,
      titleMedium: titleMediumStyle,
      titleSmall: titleSmallStyle,
      bodyLarge: bodyStyle,
      bodyMedium: bodyMediumStyle,
      bodySmall: captionStyle,
    );
  }
}
