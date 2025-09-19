import '../states/todo_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TodoPresenter {
  static const String _todosKey = 'todos_list';
  final List<TodoModel> _todos = [];

  List<TodoModel> get todos => List.unmodifiable(_todos);

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString(_todosKey);

    if (todosJson != null) {
      final List<dynamic> decodedList = json.decode(todosJson);
      _todos.clear();
      _todos.addAll(
        decodedList.map((item) => TodoModel.fromJson(item)).toList(),
      );
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _todos.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_todosKey, encodedList);
  }

  Future<void> addTodo(String text) async {
    if (text.trim().isEmpty) return;

    _todos.add(TodoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
    ));

    await _saveTodos();
  }

  Future<void> toggleTodo(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    todo.isCompleted = !todo.isCompleted;

    await _saveTodos();
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);

    await _saveTodos();
  }

  Future<void> clearAll() async {
    _todos.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todosKey);
  }
}