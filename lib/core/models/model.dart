import 'package:flutter/material.dart';

// =========== Data Models ===========

class PlantMetric {
final String label;
final String value;
final String? unit;

const PlantMetric({
  required this.label,
  required this.value,
  this.unit,
});
}

class PlantStats {
  final String label;
  final String value;
  final Widget icon;
  final Color color;

  const PlantStats({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class ScanInfo {
final String label;
  final String value;

  const ScanInfo({
    required this.label,
    required this.value,
  });
}