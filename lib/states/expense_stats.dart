import 'expense_model.dart';

class ExpenseStats {
  final double total;
  final double average;
  final ExpenseModel? highest;
  final ExpenseModel? lowest;
  final Map<String, double> categoryTotals;

  ExpenseStats({
    required this.total,
    required this.average,
    this.highest,
    this.lowest,
    required this.categoryTotals,
  });
}