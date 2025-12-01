import '../data/meal_data/meal_components.dart';
import '../data/meal_data/meal_type.dart';

class MealModel {
  final DateTime date;
  final MealType type;
  final MealComponents components;

  MealModel({
    required this.date,
    required this.type,
    required this.components,
  });

  String get formattedDate {
    final weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}';
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type.name,
      'breakfast': components.breakfast,
      'first': components.first,
      'second': components.second,
      'side': components.side,
      'pizza': components.pizza,
      'dessert': components.dessert,
    };
  }

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      date: DateTime.parse(json['date']),
      type: MealType.values.firstWhere((e) => e.name == json['type']),
      components: MealComponents(
        breakfast: json['breakfast'],
        first: json['first'],
        second: json['second'],
        side: json['side'],
        pizza: json['pizza'],
        dessert: json['dessert'],
      ),
    );
  }
}