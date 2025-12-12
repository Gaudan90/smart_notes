import 'package:flutter/material.dart';
import 'package:smart_notes/data/gantt/task_filter_extension.dart';
import '../controllers/gantt_planner_presenter.dart';
import '../data/gantt/task_filter_enum.dart';
import '../data/notification_service.dart';
import '../states/gantt_task_model.dart';
import '../widget/task_gantt/task_add_edit_dialog.dart';
import '../widget/task_gantt/task_timeline_card.dart';

class GanttPlannerView extends StatefulWidget {
  const GanttPlannerView({super.key});

  @override
  State<GanttPlannerView> createState() => _GanttPlannerViewState();
}

class _GanttPlannerViewState extends State<GanttPlannerView> {
  final _presenter = GanttPlannerPresenter();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadData();
  }

  // ← SEMPLIFICATO: Usa NotificationService esistente
  Future<void> _initializeNotifications() async {
    final notificationService = NotificationService();

    // Inizializza service nel presenter (già configurato!)
    await _presenter.initializeNotifications(
      notificationService.flutterLocalNotificationsPlugin,
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _presenter.loadTasks();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Planner'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            _buildStatsHeader(),

            _buildFilters(),

            Expanded(
              child: _buildTaskList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Task'),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            icon: Icons.assignment,
            label: 'Totali',
            value: _presenter.totalTasks.toString(),
            color: Colors.blue,
          ),
          _buildStatCard(
            icon: Icons.play_circle_outline,
            label: 'Attivi',
            value: _presenter.activeTasks.toString(),
            color: Colors.orange,
          ),
          _buildStatCard(
            icon: Icons.check_circle,
            label: 'Completati',
            value: _presenter.completedTasks.toString(),
            color: Colors.green,
          ),
          _buildStatCard(
            icon: Icons.warning_amber,
            label: 'Scaduti',
            value: _presenter.overdueTasks.toString(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TaskFilter.values.map((filter) {
            final isSelected = _presenter.currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.label,
                  style: TextStyle(
                    color: isSelected ? Colors.grey.shade700 : Colors.black,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _presenter.setFilter(filter);
                    });
                  }
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = _presenter.tasks;

    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTimelineCard(
          task: task,
          onTap: () => _showEditTaskDialog(task),
          onToggle: () => _toggleTask(task.id),
          onDelete: () => _deleteTask(task),
          onToggleNotifications: () => _toggleNotifications(task.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_presenter.currentFilter) {
      case TaskFilter.all:
        message = 'Nessun task creato.\nPremi + per iniziare!';
        icon = Icons.assignment_outlined;
        break;
      case TaskFilter.active:
        message = 'Nessun task attivo';
        icon = Icons.check_circle_outline;
        break;
      case TaskFilter.overdue:
        message = 'Nessun task scaduto.\nBravo!';
        icon = Icons.celebration;
        break;
      case TaskFilter.completed:
        message = 'Nessun task completato';
        icon = Icons.pending_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => TaskAddEditDialog(
        presenter: _presenter,
        onSaved: () => setState(() {}),
      ),
    );
  }

  void _showEditTaskDialog(GanttTaskModel task) {
    showDialog(
      context: context,
      builder: (context) => TaskAddEditDialog(
        task: task,
        presenter: _presenter,
        onSaved: () => setState(() {}),
      ),
    );
  }

  Future<void> _toggleTask(String id) async {
    await _presenter.toggleTaskCompletion(id);
    setState(() {});
  }

  // Toggle notifiche task
  Future<void> _toggleNotifications(String id) async {
    await _presenter.toggleTaskNotifications(id);
    setState(() {});

    // Feedback visivo
    final task = _presenter.getTaskById(id);
    if (task != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task.notificationsEnabled
                ? 'Notifiche attivate per "${task.name}"'
                : 'Notifiche disattivate per "${task.name}"',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteTask(GanttTaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Vuoi eliminare il task "${task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _presenter.deleteTask(task.id);
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Task eliminato'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}