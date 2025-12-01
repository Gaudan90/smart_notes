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
        return 'Colazione';
      case DishCategory.first:
        return 'Primo';
      case DishCategory.second:
        return 'Secondo';
      case DishCategory.side:
        return 'Contorno';
      case DishCategory.pizza:
        return 'Pizza';
      case DishCategory.dessert:
        return 'Dolce';
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