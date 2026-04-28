import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:impulse_mobile/core/constants/typography.dart';

class AppTheme {
  // ==========================================
  // 1. DARK THEME
  // ==========================================
  static final darkTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.background, // Dark background
    useMaterial3: true,
    cardColor: AppColors.cardDark,
    iconTheme: IconThemeData(color: AppColors.textWhite, size: 24.spMin),
    
    // 🚨 The Magic Trick: Force all text to be White!
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      AppTextStyles.getTextTheme().apply(
        bodyColor: AppColors.textWhite,
        displayColor: AppColors.textWhite,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textWhite,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textWhite, size: 24.spMin),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
    ),
  );

  // ==========================================
  // 2. LIGHT THEME
  // ==========================================
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.textWhite, // Bright white background
    useMaterial3: true,
    cardColor: AppColors.background.withValues(alpha: 0.09),
    iconTheme: IconThemeData(color: AppColors.background, size: 24.spMin),
    
    // 🚨 The Magic Trick: Force all text to be Dark!
    // (Assuming AppColors.background is your dark slate/black color)
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      AppTextStyles.getTextTheme().apply(
        bodyColor: AppColors.background, 
        displayColor: AppColors.background, 
      ),
    ),

    // Add the AppBar for the light theme so it doesn't look broken
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.textWhite,
      foregroundColor: AppColors.background, // Dark text/icons on white app bar
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.background, size: 24.spMin),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
    ),
  );
}