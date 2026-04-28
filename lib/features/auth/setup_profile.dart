import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/models/model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🚨 Added
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/constants/typography.dart';
import 'package:impulse_mobile/shared/custom_text.dart';
import 'package:impulse_mobile/shared/inputs/text_field.dart';

class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final TextEditingController controller = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (_errorMessage != null && controller.text.trim().isNotEmpty) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  final List<PersonalizationReason> _reasons = [
    const PersonalizationReason(
      icon: Icons.dashboard_customize_rounded,
      reason: 'Tailored Intelligence Dashboard',
    ),
    const PersonalizationReason(
      icon: Icons.troubleshoot_rounded,
      reason: 'Real-time Crop Health Analysis',
    ),
    const PersonalizationReason(
      icon: Icons.history_rounded,
      reason: 'Personalized Scan History',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: AppColors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded + ScrollView prevents keyboard overflow
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 24.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //20.verticalSpace,
                        CustomText(
                          'Welcome to Agrilo',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 32.spMin,
                                height: 1.2,
                              ),
                          // style: AppTextStyles.bodyMediumStyle.copyWith(
                          //   fontSize: 32.spMin,
                          //   color: AppColors.textWhite,
                          //   fontWeight: FontWeight.w900,
                          //   height: 1.2,
                          // ),
                        ),
                        20.verticalSpace,
                        CustomText(
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          'Let’s personalize your intelligence dashboard. What should we call you?',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 16.spMin,
                                fontWeight: AppTextStyles.fontWeightMedium,
                                height: 1.5,
                              ),
                          // style: AppTextStyles.bodyMediumStyle.copyWith(
                          //   fontSize: 16.spMin,
                          //   color: AppColors.textGrey,
                          //   fontWeight: AppTextStyles.fontWeightMedium,
                          //   height: 1.5,
                          // ),
                        ),
                        40.verticalSpace,
                        CustomTextField(controller: controller),
                        5.verticalSpace,
                        AnimatedSize(
                          duration: const Duration(milliseconds: 100),
                          child: _errorMessage == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.only(
                                    top: 8.h,
                                    left: 12.w,
                                  ),
                                  child: CustomText(
                                    _errorMessage!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 12.spMin,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.errorRed,
                                        ),
                                    // style: AppTextStyles.bodyMediumStyle.copyWith(

                                    //   fontSize: 12.spMin,
                                    //   fontWeight: FontWeight.w500,
                                    // ),
                                  ),
                                ),
                        ),
                        40.verticalSpace,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(_reasons.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 24.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 24.w),
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryColor
                                              .withValues(alpha: 0.15),
                                          blurRadius: 10.r,
                                          spreadRadius: 2.r,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _reasons[index].icon,
                                      size: 22.spMin,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),

                                  Expanded(
                                    child: CustomText(
                                      _reasons[index].reason,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontSize: 16.spMin,
                                            fontWeight:
                                                AppTextStyles.fontWeightMedium,
                                            height: 1.5,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color
                                                ?.withValues(alpha: 0.9),
                                          ),
                                      // style: AppTextStyles.bodyStyle.copyWith(
                                      //   color: AppColors.textWhite.withValues(
                                      //     alpha: 0.9,
                                      //   ),
                                      //   fontSize: 16.spMin,
                                      // fontWeight:
                                      //     AppTextStyles.fontWeightMedium,
                                      // ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
                child: GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () async {
                          if (controller.text.trim().isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                          }
                          if (controller.text.trim().isNotEmpty) {
                            final newName = controller.text.trim();

                            final prefs = await SharedPreferences.getInstance();

                            await Future.delayed(Duration(milliseconds: 600));
                            await prefs.setString('userName', newName);

                            // Generate an ID here so Supabase knows who is scanning!
                            final deviceId = prefs.getString('device_id');
                            if (deviceId == null) {
                              final uniqueId =
                                  'device_${DateTime.now().millisecondsSinceEpoch}';
                              await prefs.setString('device_id', uniqueId);
                              debugPrint("Unique Device ID: $uniqueId");
                            }

                            // Lock onboarding so it doesn't show again
                            await prefs.setBool('hasCompletedOnboarding', true);

                            if (context.mounted) {
                              context.go('/home');
                            }
                          } else {
                            setState(() {
                              _errorMessage =
                                  "Please let us know what to call you!";
                            });
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? AppColors.primaryColor.withValues(alpha: 0.5)
                          : AppColors
                                .primaryColor, // Using your Tech Leaf green
                      borderRadius: BorderRadius.circular(35.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 30.r,
                          spreadRadius: 5.r,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CupertinoActivityIndicator(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                radius: 11.r,
                              ),
                              10.horizontalSpace,
                              CustomText(
                                'Processing...',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 14.spMin,
                                      fontWeight: FontWeight.w700,
                                    ),
                                // style: AppTextStyles.captionStyle.copyWith(
                                //   color: AppColors.background,
                                //   fontWeight: FontWeight.w700,
                                //   fontSize: 14.spMin,
                                // ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                'Enter Dashboard',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontSize: 16.spMin,
                                      fontWeight: FontWeight.w800,
                                    ),
                                // style: AppTextStyles.titleStyle.copyWith(
                                //   color: AppColors.background,
                                //   fontWeight: FontWeight.w800,
                                //   fontSize: 16.spMin,
                                // ),
                              ),
                              8.horizontalSpace,
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 22.spMin,
                                color: AppColors.background,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              10.verticalSpace, // Small cushion for bottom swipe bar on iOS
            ],
          ),
        ),
      ),
    );
  }
}
