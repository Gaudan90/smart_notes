import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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

  Future<void> _initializeNotifications() async {
    final notificationService = NotificationService();

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
        title: Text('gantt_title'.tr()),
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
        label: Text('new_task'.tr()),
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
            label: 'gantt_stat_total'.tr(),
            value: _presenter.totalTasks.toString(),
            color: Colors.blue,
          ),
          _buildStatCard(
            icon: Icons.play_circle_outline,
            label: 'stat_active'.tr(),
            value: _presenter.activeTasks.toString(),
            color: Colors.orange,
          ),
          _buildStatCard(
            icon: Icons.check_circle,
            label: 'stat_completed'.tr(),
            value: _presenter.completedTasks.toString(),
            color: Colors.green,
          ),
          _buildStatCard(
            icon: Icons.warning_amber,
            label: 'stat_overdue'.tr(),
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
    String messageKey;
    IconData icon;

    switch (_presenter.currentFilter) {
      case TaskFilter.all:
        messageKey = 'empty_all';
        icon = Icons.assignment_outlined;
        break;
      case TaskFilter.active:
        messageKey = 'empty_active';
        icon = Icons.check_circle_outline;
        break;
      case TaskFilter.overdue:
        messageKey = 'empty_overdue';
        icon = Icons.celebration;
        break;
      case TaskFilter.completed:
        messageKey = 'empty_completed';
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
            messageKey.tr(),
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

  Future<void> _toggleNotifications(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    await _presenter.toggleTaskNotifications(id);
    setState(() {});

    final task = _presenter.getTaskById(id);
    if (task != null && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            task.notificationsEnabled
                ? 'notifications_enabled'.tr(namedArgs: {'name': task.name})
                : 'notifications_disabled'.tr(namedArgs: {'name': task.name}),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteTask(GanttTaskModel task) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_task_title'.tr()),
        content: Text('delete_task_confirm'.tr(namedArgs: {'name': task.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      await _presenter.deleteTask(task.id);
      setState(() {});

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('task_deleted'.tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}