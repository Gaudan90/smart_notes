import 'package:flutter/material.dart';

class OnboardingFeatureItem {
  final IconData icon;
  final Color color;
  final String labelKey;

  const OnboardingFeatureItem({
    required this.icon,
    required this.color,
    required this.labelKey,
  });
}