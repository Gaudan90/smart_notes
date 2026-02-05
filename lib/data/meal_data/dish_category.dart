import 'package:easy_localization/easy_localization.dart';

enum DishCategory {
  breakfast,
  first,
  second,
  side,
  pizza,
  dessert;

  String get label {
    switch (this) {
      case DishCategory.breakfast:
        return 'dish_cat_breakfast'.tr();
      case DishCategory.first:
        return 'dish_cat_first'.tr();
      case DishCategory.second:
        return 'dish_cat_second'.tr();
      case DishCategory.side:
        return 'dish_cat_side'.tr();
      case DishCategory.pizza:
        return 'dish_cat_pizza'.tr();
      case DishCategory.dessert:
        return 'dish_cat_dessert'.tr();
    }
  }

  String get emoji {
    switch (this) {
      case DishCategory.breakfast:
        return '🥐';
      case DishCategory.first:
        return '🍝';
      case DishCategory.second:
        return '🍖';
      case DishCategory.side:
        return '🥗';
      case DishCategory.pizza:
        return '🍕';
      case DishCategory.dessert:
        return '🍰';
    }
  }
}