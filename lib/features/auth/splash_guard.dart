import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashGuard extends ConsumerStatefulWidget {
  const SplashGuard({super.key});

  @override
  ConsumerState<SplashGuard> createState() => _SplashGuardState();
}

class _SplashGuardState extends ConsumerState<SplashGuard> {
  @override
  void initState() {
    super.initState();
    _checkRouting();
  }

  void _checkRouting() async {
    final prefs = await SharedPreferences.getInstance();

    final bool hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;

    final userName = prefs.getString('userName');

    await Future.delayed(Duration(milliseconds: 800));

    if (!mounted) return;

    if (!hasCompletedOnboarding) {
      context.go('/onboarding');
    } else if (userName == null || userName.isEmpty) {
      context.go('/setup_profile');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CupertinoActivityIndicator(
          color: AppColors.primaryColor, // Your Tech Leaf green
          radius: 15.r,
        ),
      ),
    );
  }
}
