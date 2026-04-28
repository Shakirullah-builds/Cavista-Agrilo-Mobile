// import 'package:flutter/cupertino.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:impulse_mobile/core/constants/colors.dart';
// import 'package:impulse_mobile/core/constants/typography.dart';
// import 'package:impulse_mobile/shared/custom_text.dart';
// import 'package:impulse_mobile/shared/inputs/text_field.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NamePromptBottomSheet extends StatefulWidget {
//   final SharedPreferences prefs;
//   final Function(String) onNameSaved;

//   const NamePromptBottomSheet({
//     super.key,
//     required this.prefs,
//     required this.onNameSaved,
//   });

//   @override
//   State<NamePromptBottomSheet> createState() => _NamePromptBottomSheetState();
// }

// class _NamePromptBottomSheetState extends State<NamePromptBottomSheet> {
//   final TextEditingController controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom + 30.h,
//         left: 30.w,
//         right: 0.w,
//         top: 30.h,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CustomText(
//             'Welcome to Agrilo',
//             style: AppTextStyles.headlineStyle.copyWith(
//               color: AppColors.textWhite,
//               fontWeight: AppTextStyles.fontWeightBold,
//               fontSize: 28.spMin,
//             ),
//           ),
//           10.verticalSpace,
//           Padding(
//             padding: EdgeInsets.only(right: 10.w),
//             child: CustomText(
//               maxLines: 4,
//               "Your pocket AI agronomist. Detect diseases early and keep your crops thriving.",
//               style: AppTextStyles.bodyStyle.copyWith(
//                 color: AppColors.textWhite,
//                 fontSize: 16.spMin,
//               ),
//             ),
//           ),
//           30.verticalSpace,
//           CustomText(
//             'What should we call you?',
//             style: AppTextStyles.bodyStyle.copyWith(
//               color: AppColors.textGrey,
//               fontSize: 16.spMin,
//             ),
//           ),
//           10.verticalSpace,
//           Padding(
//             padding: EdgeInsets.only(right: 30.w),
//             child: CustomTextField(controller: controller),
//           ),
//           30.verticalSpace,
//           GestureDetector(
//             onTap: () async {
//               if (controller.text.trim().isNotEmpty) {
//                 final newName = controller.text.trim();
    
//                 await widget.prefs.setString('user_name', newName);
    
//                 widget.onNameSaved(newName);
    
//                 if (context.mounted) Navigator.pop(context);
//               }
//             },
//             child: Padding(
//               padding: EdgeInsets.only(right: 30.w),
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 20.h),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryColor,
//                   borderRadius: BorderRadius.circular(30.r),
//                 ),
//                 alignment: Alignment.center,
//                 child: CustomText(
//                   'Get Started',
//                   style: AppTextStyles.titleStyle.copyWith(
//                     color: AppColors.background,
//                     fontWeight: AppTextStyles.fontWeightBold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }