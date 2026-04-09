import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:impulse_mobile/core/constants/colors.dart';
import 'package:impulse_mobile/core/models/model.dart';
import 'package:impulse_mobile/shared/custom/app_assets.dart';

// =========== State Providers ===========

/// Current page index for the swipeable card (0 = Plant Overview, 1 = Scan Overview)

final currentPageProvider = StateProvider<int>((ref) => 0);

/// Manages the selected bottom nav index

final bottomNavBarIndexProvider = StateProvider<int>((ref) => 0);

/// Controller for the PageView in the home page

final pageControllerProvider = Provider<PageController>((ref) => PageController());

final animatedPagesProvider = StateProvider<Set<int>>((ref) => {});

final plantMetricProvider = Provider<List<PlantMetric>>((ref) {
  return [
    PlantMetric(label: 'Chlorophyll', value: '92', unit: '%'),
    PlantMetric(label: 'Hydration', value: '78', unit: '%'),
    PlantMetric(label: 'Disease Risk', value: '10', unit: '%'),
    PlantMetric(label: 'Pest Stress', value: '7', unit: '%'),
  ];
});

final navigateToProvider = StateProvider<void Function(BuildContext)>((ref) {
  return (BuildContext context) {
    final index = ref.read(bottomNavBarIndexProvider);
    switch(index) {
      case 0:
      context.go('/home');
      break;
      case 1: 
      context.go('/scanner');
      break;
      case 2:
      context.go('/recommendation');
      break;
    }
  };
});

final plantStatsProvider = Provider<List<PlantStats>>((ref) {
  return [
    PlantStats(
      label: 'Total Scans',
      value: '56',
      icon: AppAssets(
        assetPath: AssetPath.apertureIcon,
        color: AppColors.lightGreen,
      ),
      color: AppColors.lightGreen,
    ),
    PlantStats(
      label: 'Avg Health Index',
      value: '85%',
      icon: AppAssets(
        assetPath: AssetPath.smileIcon,
        color: AppColors.neonYellow,
      ),
      color: AppColors.neonYellow,
    ),
  ];
});

/// List of quick stats cards

final quickStatsProvider = Provider<List<String>>((ref) {
  return [
    'Health Overview',
    'Scan Overview',
  ];
});

// /// Plant info rows data
// final plantInfoProvider = Provider<List<Map<String, dynamic>>>((ref) {
//   return [
//     {'icon': AssetPath.calendarIcon, 'label': '3 Days Ago'},
//     {'icon': AssetPath.sproutIcon, 'label': 'Flower Plant'},
//   ];
// });