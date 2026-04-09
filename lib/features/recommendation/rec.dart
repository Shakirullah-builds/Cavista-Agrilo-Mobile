import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulse_mobile/features/home/homepage_provider.dart';
import 'package:impulse_mobile/shared/custom/bottom_navbar.dart';
import 'package:impulse_mobile/shared/custom_text.dart';

class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavBarCurrentIndex = ref.watch(bottomNavBarIndexProvider);
    return Scaffold(
      appBar: AppBar(title: CustomText('Recommendation', style: Theme.of(context).appBarTheme.titleTextStyle,)),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: bottomNavBarCurrentIndex,
        onTap: (index) {
          ref.read(bottomNavBarIndexProvider.notifier).state = index;
          ref.read(navigateToProvider)(context);
        },
      ),
    );
  }
}
