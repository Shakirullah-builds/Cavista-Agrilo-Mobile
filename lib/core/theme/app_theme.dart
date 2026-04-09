import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:impulse_mobile/core/constants/typography.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    primaryColor: AppColors.neonYellow,
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      AppTextStyles.getTextTheme(),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textWhite,
      centerTitle: true,
      elevation: 0,
      // titleTextStyle: TextStyle(
      //   fontSize: 20.spMin,
      //   fontWeight: AppTextStyles.fontWeightBold,
      //   color: AppColors.textWhite,
      // ),
      iconTheme: IconThemeData(color: AppColors.textWhite, size: 24.spMin),
    ),
    // Add input decoration theme here so all textfields look the same
  );
}
