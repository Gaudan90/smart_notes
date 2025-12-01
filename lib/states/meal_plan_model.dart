import 'meal_model.dart';

class MealPlanModel {
  final DateTime startDate;
  final List<MealModel> meals;
  final bool includeBreakfast;
  final bool includeLunch;
  final bool includeDinner;

  MealPlanModel({
    required this.startDate,
    required this.meals,
    required this.includeBreakfast,
    required this.includeLunch,
    required this.includeDinner,
  });

  // Raggruppa pasti per giorno
  Map<DateTime, List<MealModel>> get mealsByDay {
    final grouped = <DateTime, List<MealModel>>{};

    for (var meal in meals) {
      final dateKey = DateTime(meal.date.year, meal.date.month, meal.date.day);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(meal);
    }

    return grouped;
  }

  // Numero totale di pasti
  int get totalMeals => meals.length;

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'includeBreakfast': includeBreakfast,
      'includeLunch': includeLunch,
      'includeDinner': includeDinner,
    };
  }

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      startDate: DateTime.parse(json['startDate']),
      meals: (json['meals'] as List)
          .map((m) => MealModel.fromJson(m))
          .toList(),
      includeBreakfast: json['includeBreakfast'] ?? false,
      includeLunch: json['includeLunch'],
      includeDinner: json['includeDinner'],
    );
  }
}

