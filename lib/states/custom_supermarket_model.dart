import 'dart:ui';

class CustomSupermarketModel {
  final String id;
  final String name;
  final int colorValue;

  CustomSupermarketModel({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
  };

  factory CustomSupermarketModel.fromJson(Map<String, dynamic> json) {
    return CustomSupermarketModel(
      id: json['id'],
      name: json['name'],
      colorValue: json['colorValue'],
    );
  }
}