import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impulse_mobile/core/constants/typography.dart';

class CustomText extends StatelessWidget {
  final String text;
  // final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool? softWrap;
  final TextStyle? style;
  final double? letterSpacing;
  final double? wordSpacing;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.softWrap,
    this.letterSpacing,
    this.wordSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? AppTextStyles.bodyStyle;

    final finalStyle = baseStyle.copyWith(
      color: color,
      fontSize: fontSize?.spMin,
      fontWeight: fontWeight,
      decoration: decoration,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      
    );
    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines ?? 1.spMin.toInt(),
      overflow: overflow ?? TextOverflow.ellipsis,
      softWrap: softWrap ?? true,
    );
  }
}
