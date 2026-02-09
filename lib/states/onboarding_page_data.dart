import 'package:flutter/material.dart';
import 'onboarding_feature_item.dart';

class OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String titleKey;
  final String descriptionKey;
  final List<OnboardingFeatureItem> features;

  const OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.titleKey,
    required this.descriptionKey,
    this.features = const [],
  });
}