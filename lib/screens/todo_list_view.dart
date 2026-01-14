import 'package:flutter/material.dart';
import '../controllers/todo_presenter.dart';
import '../theme/theme_config.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final _controller = TextEditingController();
  final _presenter = TodoPresenter();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    await _presenter.loadTodos();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addTodo() async {
    await _presenter.addTodo(_controller.text);
    _controller.clear();
    setState(() {});
  }

  Future<void> _toggleTodo(String id) async {
    await _presenter.toggleTodo(id);
    setState(() {});
  }

  Future<void> _deleteTodo(String id) async {
    await _presenter.deleteTodo(id);
    setState(() {});
  }

  Future<bool> _showDeleteConfirmDialog(String todoText) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Vuoi eliminare "$todoText"?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.defaultColors['red']!,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista To-Do'),
        actions: [
          if (_presenter.todos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Conferma'),
                    content: const Text('Vuoi eliminare tutte le attività?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annulla'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.defaultColors['red']!,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Elimina tutto'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _presenter.clearAll();
                  setState(() {});
                }
              },
              tooltip: 'Elimina tutto',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Aggiungi attività...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: _presenter.todos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessuna attività',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _presenter.todos.length,
              itemBuilder: (context, index) {
                final todo = _presenter.todos[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Dismissible(
                    key: Key(todo.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.defaultColors['red']!,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteConfirmDialog(todo.text);
                    },
                    onDismissed: (direction) {
                      _deleteTodo(todo.id);
                    },
                    child: Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: todo.isCompleted,
                          activeColor: Theme.of(context)
                              .colorScheme
                              .primary,
                          onChanged: (_) => _toggleTodo(todo.id),
                        ),
                        title: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted
                                ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5)
                                : Theme.of(context)
                                .colorScheme
                                .onSurface,
                          ),
                          child: Text(todo.text),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: AppTheme.defaultColors['red']!,
                          ),
                          onPressed: () async {
                            final confirmed =
                            await _showDeleteConfirmDialog(todo.text);
                            if (confirmed) {
                              _deleteTodo(todo.id);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
