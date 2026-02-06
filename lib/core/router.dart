import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Center(child: Text("Login Placeholder")))), // To be replaced with the actual LoginScreen widget
    GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Center(child: Text("Home Placeholder")))), // To be replaced with the actual HomeScreen widget
  ]
);