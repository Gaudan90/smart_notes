import 'package:flutter/material.dart';

class LanguageOption {
  final Locale locale;
  final String flag;
  final String labelKey;

  const LanguageOption({
    required this.locale,
    required this.flag,
    required this.labelKey,
  });
}