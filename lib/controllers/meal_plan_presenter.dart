import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/meal_data/dish_category.dart';
import '../data/meal_data/meal_components.dart';
import '../data/meal_data/meal_plan_config.dart';
import '../data/meal_data/meal_type.dart';
import '../states/dish_model.dart';
import '../states/meal_model.dart';
import '../states/meal_plan_model.dart';

class MealPlanPresenter {
  static const String _dishesKey = 'meal_plan_dishes';
  static const String _currentPlanKey = 'meal_plan_current';

  final Random _random = Random();
  List<DishModel> _dishes = [];
  MealPlanModel? _currentPlan;

  List<DishModel> get dishes => List.unmodifiable(_dishes);
  MealPlanModel? get currentPlan => _currentPlan;
  bool get hasPlan => _currentPlan != null;

  // Carica piatti salvati
  Future<void> loadDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishesJson = prefs.getString(_dishesKey);

      if (dishesJson != null) {
        final List<dynamic> dishesList = json.decode(dishesJson);
        _dishes = dishesList.map((d) => DishModel.fromJson(d)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore caricamento piatti: $e');
      }
      _dishes = [];
    }
  }

  // Salva piatti
  Future<void> _saveDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishesJson = json.encode(_dishes.map((d) => d.toJson()).toList());
      await prefs.setString(_dishesKey, dishesJson);
    } catch (e) {
      if (kDebugMode) {
        print('Errore salvataggio piatti: $e');
      }
    }
  }

  // Aggiungi piatto
  Future<void> addDish(String name, DishCategory category) async {
    if (name.trim().isEmpty) return;

    final dish = DishModel(name: name.trim(), category: category);
    _dishes.add(dish);
    await _saveDishes();
  }

  // Rimuovi piatto
  Future<void> removeDish(DishModel dish) async {
    _dishes.remove(dish);
    await _saveDishes();
  }

  // Aggiorna piatto
  Future<void> updateDish(int index, String newName, DishCategory newCategory) async {
    if (index >= 0 && index < _dishes.length && newName.trim().isNotEmpty) {
      _dishes[index] = DishModel(name: newName.trim(), category: newCategory);
      await _saveDishes();
    }
  }

  // Cancella tutti i piatti
  Future<void> clearDishes() async {
    _dishes.clear();
    await _saveDishes();
  }

  // Genera piano pasti settimanale con regole
  Future<MealPlanModel> generateMealPlan(MealPlanConfig config) async {
    if (!config.isValid) {
      throw Exception('Configurazione non valida');
    }

    final meals = <MealModel>[];
    final startDate = DateTime.now();

    // Traccia quando inserire pizza e dolce
    final pizzaDay = _random.nextInt(7);
    final dessertDay = _random.nextInt(7);

    for (int day = 0; day < config.days; day++) {
      final currentDate = startDate.add(Duration(days: day));

      // COLAZIONE
      if (config.includeBreakfast) {
        final breakfast = _generateBreakfast(config);
        meals.add(MealModel(
          date: currentDate,
          type: MealType.breakfast,
          components: breakfast,
        ));
      }

      // PRANZO
      if (config.includeLunch) {
        final isLunchPizzaDay = (day == pizzaDay);
        final isLunchDessertDay = (day == dessertDay && !isLunchPizzaDay);

        final lunch = _generateMeal(config, isLunchPizzaDay, isLunchDessertDay);
        meals.add(MealModel(
          date: currentDate,
          type: MealType.lunch,
          components: lunch,
        ));
      }

      // CENA
      if (config.includeDinner) {
        // Se pizza/dolce già assegnati al pranzo, non li assegno alla cena
        final isDinnerPizzaDay = (day == pizzaDay && !config.includeLunch);
        final isDinnerDessertDay = (day == dessertDay
            && !config.includeLunch && !isDinnerPizzaDay);

        final dinner = _generateMeal(config, isDinnerPizzaDay, isDinnerDessertDay);
        meals.add(MealModel(
          date: currentDate,
          type: MealType.dinner,
          components: dinner,
        ));
      }
    }

    _currentPlan = MealPlanModel(
      startDate: startDate,
      meals: meals,
      includeBreakfast: config.includeBreakfast,
      includeLunch: config.includeLunch,
      includeDinner: config.includeDinner,
    );

    await _savePlan();
    return _currentPlan!;
  }

  // Genera componenti colazione
  MealComponents _generateBreakfast(MealPlanConfig config) {
    final breakfastDishes = config.dishesFor(DishCategory.breakfast);

    if (breakfastDishes.isEmpty) {
      return MealComponents(breakfast: 'N/A');
    }

    final randomDish = breakfastDishes[_random.nextInt(breakfastDishes.length)];
    return MealComponents(breakfast: randomDish.name);
  }


  MealComponents _generateMeal(MealPlanConfig config, bool isPizzaDay, bool isDessertDay) {
    // GIORNO PIZZA: solo pizza, niente altro
    if (isPizzaDay) {
      final pizzas = config.dishesFor(DishCategory.pizza);
      if (pizzas.isEmpty) {
        // Fallback se non ci sono pizze
        return _generateNormalMeal(config, false);
      }

      final pizza = pizzas[_random.nextInt(pizzas.length)];
      return MealComponents(pizza: pizza.name);
    }

    return _generateNormalMeal(config, isDessertDay);
  }

  // Genera pasto: (Primo O Secondo) + Contorno + eventuale Dolce
  MealComponents _generateNormalMeal(MealPlanConfig config, bool addDessert) {
    final firsts = config.dishesFor(DishCategory.first);
    final seconds = config.dishesFor(DishCategory.second);
    final sides = config.dishesFor(DishCategory.side);
    final desserts = config.dishesFor(DishCategory.dessert);

    String? firstCourse;
    String? secondCourse;
    String? side;
    String? dessert;

    // Scegli Primo O Secondo (50% chance per ognuno se entrambi disponibili)
    if (firsts.isNotEmpty && seconds.isNotEmpty) {
      if (_random.nextBool()) {
        firstCourse = firsts[_random.nextInt(firsts.length)].name;
      } else {
        secondCourse = seconds[_random.nextInt(seconds.length)].name;
      }
    } else if (firsts.isNotEmpty) {
      firstCourse = firsts[_random.nextInt(firsts.length)].name;
    } else if (seconds.isNotEmpty) {
      secondCourse = seconds[_random.nextInt(seconds.length)].name;
    }

    // Aggiungi Contorno (sempre, se disponibile)
    if (sides.isNotEmpty) {
      side = sides[_random.nextInt(sides.length)].name;
    }

    // Aggiungi Dolce (se è il giorno designato)
    if (addDessert && desserts.isNotEmpty) {
      dessert = desserts[_random.nextInt(desserts.length)].name;
    }

    return MealComponents(
      first: firstCourse,
      second: secondCourse,
      side: side,
      dessert: dessert,
    );
  }

  // Carica piano salvato
  Future<void> loadPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planJson = prefs.getString(_currentPlanKey);

      if (planJson != null) {
        final Map<String, dynamic> planMap = json.decode(planJson);
        _currentPlan = MealPlanModel.fromJson(planMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore caricamento piano: $e');
      }
      _currentPlan = null;
    }
  }

  // Salva piano
  Future<void> _savePlan() async {
    if (_currentPlan == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final planJson = json.encode(_currentPlan!.toJson());
      await prefs.setString(_currentPlanKey, planJson);
    } catch (e) {
      if (kDebugMode) {
        print('Errore salvataggio piano: $e');
      }
    }
  }

  // Cancella piano
  Future<void> clearPlan() async {
    _currentPlan = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentPlanKey);
  }

  // Esporta piano come testo
  String exportPlan() {
    if (_currentPlan == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('📅 PIANO PASTI SETTIMANALE\n');

    final mealsByDay = _currentPlan!.mealsByDay;
    final sortedDates = mealsByDay.keys.toList()..sort();

    for (var date in sortedDates) {
      final meals = mealsByDay[date]!..sort((a, b)
      => a.type.index.compareTo(b.type.index));

      // Header giorno
      final weekdays = ['Lunedì', 'Martedì', 'Mercoledì',
        'Giovedì', 'Venerdì', 'Sabato', 'Domenica'];
      final weekday = weekdays[date.weekday - 1];
      buffer.writeln('=== $weekday ${date.day}/${date.month} ===');

      // Pasti del giorno
      for (var meal in meals) {
        buffer.writeln('${meal.type.emoji} ${meal.type.label}:');
        final items = meal.components.toDisplayList();
        for (var item in items) {
          buffer.writeln('  • $item');
        }
      }
      buffer.writeln();
    }

    buffer.writeln('============================');
    buffer.writeln('📊 Totale pasti: ${_currentPlan!.totalMeals}');

    return buffer.toString();
  }

  // Statistiche piano
  Map<String, dynamic> getPlanStats() {
    if (_currentPlan == null) return {};

    return {
      'totalMeals': _currentPlan!.totalMeals,
    };
  }
}