import '../data/meal_data/dish_category.dart';

class DishModel {
  final String name;
  final DishCategory category;

  DishModel({
    required this.name,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category.name,
  };

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      name: json['name'],
      category: DishCategory.values.firstWhere(
            (e) => e.name == json['category'],
        orElse: () => DishCategory.first,
      ),
    );
  }
}