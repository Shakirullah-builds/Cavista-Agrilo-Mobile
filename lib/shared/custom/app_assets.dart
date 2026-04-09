import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppAssets extends StatelessWidget {
  final String assetPath;
  final Color color;
  final double? width;
  final double? height;
  const AppAssets({
    super.key,
    required this.assetPath,
    required this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn, ),
      width: width ?? 26.w,
      height: height ?? 26.h,
      fit: BoxFit.contain,
    );
  }
}
