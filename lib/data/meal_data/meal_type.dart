import 'package:easy_localization/easy_localization.dart';

enum MealType {
  breakfast,
  lunch,
  dinner;

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'meal_type_breakfast'.tr();
      case MealType.lunch:
        return 'meal_type_lunch'.tr();
      case MealType.dinner:
        return 'meal_type_dinner'.tr();
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
    }
  }
}