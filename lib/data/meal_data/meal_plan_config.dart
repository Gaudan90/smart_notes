import '../../states/dish_model.dart';
import 'dish_category.dart';

class MealPlanConfig {
  final List<DishModel> dishes;
  final bool includeBreakfast;
  final bool includeLunch;
  final bool includeDinner;
  final int days;

  MealPlanConfig({
    required this.dishes,
    required this.includeBreakfast,
    required this.includeLunch,
    required this.includeDinner,
    this.days = 7,
  });

  bool get isValid {
    return dishes.isNotEmpty && (includeBreakfast || includeLunch || includeDinner);
  }

  int get mealsPerDay {
    int count = 0;
    if (includeBreakfast) count++;
    if (includeLunch) count++;
    if (includeDinner) count++;
    return count;
  }

  int get totalMeals => days * mealsPerDay;

  /// Filtra piatti per categoria
  List<DishModel> dishesFor(DishCategory category) {
    return dishes.where((d) => d.category == category).toList();
  }
}