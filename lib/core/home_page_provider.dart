import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

// =========== State Providers ===========

/// Current page index for the swipeable card (0 = Plant Overview, 1 = Scan Overview)

final currentPageProvider = StateProvider<int>((ref) => 0);

final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

/// Manages the selected bottom nav index

final bottomNavBarIndexProvider = StateProvider<int>((ref) => 0);

/// Controller for the PageView in the home page

//final pageControllerProvider = Provider<PageController>((ref) => PageController());

final animatedPagesProvider = StateProvider<Set<int>>((ref) => {});

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
        context.go('/scanresult');
        break;
    }
  };
});

/// List of quick stats cards

final quickStatsProvider = Provider<List<String>>((ref) {
  return [
    'Health Overview',
    'Scan Overview',
  ];
});