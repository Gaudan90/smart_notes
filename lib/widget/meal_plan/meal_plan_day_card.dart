import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/meal_data/meal_type.dart';
import '../../states/meal_model.dart';

class MealPlanDayCard extends StatelessWidget {
  final DateTime date;
  final List<MealModel> meals;

  const MealPlanDayCard({
    super.key,
    required this.date,
    required this.meals,
  });

  String _getWeekdayName(int weekday) {
    const weekdayKeys = [
      'weekday_monday',
      'weekday_tuesday',
      'weekday_wednesday',
      'weekday_thursday',
      'weekday_friday',
      'weekday_saturday',
      'weekday_sunday',
    ];
    return weekdayKeys[weekday - 1].tr();
  }

  @override
  Widget build(BuildContext context) {
    final weekday = _getWeekdayName(date.weekday);

    // Ordina pasti per tipo
    final sortedMeals = List<MealModel>.from(meals)
      ..sort((a, b) => a.type.index.compareTo(b.type.index));

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header giorno migliorato
              _buildDayHeader(context, weekday),

              const SizedBox(height: 20),

              // Divider decorativo
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lista pasti
              ...sortedMeals.asMap().entries.map((entry) {
                final index = entry.key;
                final meal = entry.value;
                final isLast = index == sortedMeals.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: _buildMealSection(context, meal),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context, String weekday) {
    return Row(
      children: [
        // Icona calendario
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),

        const SizedBox(width: 16),

        // Testo giorno
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weekday,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealSection(BuildContext context, MealModel meal) {
    Color getColorForType(MealType type) {
      switch (type) {
        case MealType.breakfast:
          return Colors.amber;
        case MealType.lunch:
          return Colors.blue;
        case MealType.dinner:
          return Colors.deepPurple;
      }
    }

    final color = getColorForType(meal.type);
    final items = meal.components.toDisplayList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tipo pasto
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    meal.type.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  meal.type.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Componenti del pasto
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: Theme.of(context).colorScheme
                              .onSurface.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}