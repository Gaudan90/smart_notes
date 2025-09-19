import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/expense_model.dart';
import '../states/expense_stats.dart';

class ExpensePresenter {
  static const String _expensesKey = 'expenses_list';
  final List<ExpenseModel> _expenses = [];

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);

  static const List<String> categories = [
    'Spesa',
    'Trasporti',
    'Svago',
    'Bollette',
    'Salute',
    'Abbigliamento',
    'Ristorante',
    'Altro',
  ];

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? expensesJson = prefs.getString(_expensesKey);

    if (expensesJson != null) {
      final List<dynamic> decodedList = json.decode(expensesJson);
      _expenses.clear();
      _expenses.addAll(
        decodedList.map((item) => ExpenseModel.fromJson(item)).toList(),
      );
      _expenses.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _expenses.map((expense) => expense.toJson()).toList(),
    );
    await prefs.setString(_expensesKey, encodedList);
  }

  Future<void> addExpense({
    required String name,
    required double amount,
    required DateTime date,
    required String category,
  }) async {
    if (name.trim().isEmpty || amount <= 0) return;

    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      amount: amount,
      date: date,
      category: category,
    );

    // CORREZIONE: usa _expenses invece di expenses
    _expenses.add(expense);
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    await _saveExpenses();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    await _saveExpenses();
  }

  ExpenseStats calculateStats({DateTime? startDate, DateTime? endDate}) {
    List<ExpenseModel> filteredExpenses = _expenses;

    if (startDate != null && endDate != null) {
      filteredExpenses = [];
      for (int i = 0; i < _expenses.length; i++) {
        if (_expenses[i].date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            _expenses[i].date.isBefore(endDate.add(const Duration(days: 1)))) {
          filteredExpenses.add(_expenses[i]);
        }
      }
    }

    if (filteredExpenses.isEmpty) {
      return ExpenseStats(
        total: 0,
        average: 0,
        categoryTotals: {},
      );
    }
    double total = 0;
    for (int i = 0; i < filteredExpenses.length; i++) {
      total += filteredExpenses[i].amount;
    }

    double average = total / filteredExpenses.length;

    ExpenseModel? highest = filteredExpenses[0];
    ExpenseModel? lowest = filteredExpenses[0];

    for (int i = 1; i < filteredExpenses.length; i++) {
      if (filteredExpenses[i].amount > highest!.amount) {
        highest = filteredExpenses[i];
      }
      if (filteredExpenses[i].amount < lowest!.amount) {
        lowest = filteredExpenses[i];
      }
    }

    Map<String, double> categoryTotals = {};
    for (int i = 0; i < filteredExpenses.length; i++) {
      String category = filteredExpenses[i].category;
      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + filteredExpenses[i].amount;
      } else {
        categoryTotals[category] = filteredExpenses[i].amount;
      }
    }

    return ExpenseStats(
      total: total,
      average: average,
      highest: highest,
      lowest: lowest,
      categoryTotals: categoryTotals,
    );
  }

  List<ExpenseModel> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    List<ExpenseModel> monthExpenses = [];
    for (var expense in _expenses) {
      if (expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        monthExpenses.add(expense);
      }
    }
    return monthExpenses;
  }

  List<ExpenseModel> getCurrentWeekExpenses() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    List<ExpenseModel> weekExpenses = [];
    for (var expense in _expenses) {
      if (expense.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        weekExpenses.add(expense);
      }
    }
    return weekExpenses;
  }
}