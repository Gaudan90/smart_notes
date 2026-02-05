import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../controllers/reminder_presenter.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  final _presenter = ReminderPresenter();
  final _titleController = TextEditingController();
  final _intervalController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    await _presenter.loadReminders();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Helper per generare titolo notifica tradotto
  String _getNotificationTitle(String title) {
    return 'notif_reminder_title'.tr(namedArgs: {'title': title});
  }

  // Helper per generare body notifica tradotto
  String _getNotificationBody(String title) {
    return 'notif_reminder_body'.tr(namedArgs: {'title': title});
  }

  void _showAddReminderDialog() {
    _titleController.clear();
    _intervalController.clear();
    _selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('new_reminder'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'activity_label'.tr(),
                  hintText: 'activity_hint'.tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _intervalController,
                decoration: InputDecoration(
                  labelText: 'every_how_many_hours'.tr(),
                  hintText: 'every_hours_hint'.tr(),
                  border: const OutlineInputBorder(),
                  suffixText: 'hours_suffix'.tr(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('start_time_label'.tr()),
                subtitle: Text(_formatTimeOfDay(_selectedTime)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              final interval = int.tryParse(_intervalController.text);
              if (_titleController.text.isNotEmpty && interval != null && interval > 0) {
                final title = _titleController.text;
                await _presenter.addReminder(
                  title: title,
                  intervalHours: interval,
                  startTime: _formatTimeOfDay(_selectedTime),
                  notificationTitle: _getNotificationTitle(title),
                  notificationBody: _getNotificationBody(title),
                  channelName: 'notif_reminders'.tr(),
                  channelDescription: 'notif_reminders_desc'.tr(),
                );
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text('add'.tr()),
          ),
        ],
      ),
    );
  }

  void _showScheduledTimes(List<String> times, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('schedule_for'.tr(namedArgs: {'title': title})),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: times.map((time) => ListTile(
              leading: const Icon(Icons.alarm, size: 20),
              title: Text(time),
              dense: true,
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('daily_reminders'.tr()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _presenter.reminders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'no_reminders'.tr(),
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'add_recurring_activities'.tr(),
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _presenter.reminders.length,
        itemBuilder: (context, index) {
          final reminder = _presenter.reminders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: reminder.isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                reminder.title,
                style: TextStyle(
                  decoration: reminder.isActive
                      ? null
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                'every_x_hours_from'.tr(namedArgs: {
                  'hours': '${reminder.intervalHours}',
                  'time': reminder.startTime,
                }),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () => _showScheduledTimes(
                      reminder.scheduledTimes,
                      reminder.title,
                    ),
                    tooltip: 'view_schedule'.tr(),
                  ),
                  Switch(
                    value: reminder.isActive,
                    onChanged: (value) async {
                      await _presenter.toggleReminder(
                        reminder.id,
                        notificationTitle: _getNotificationTitle(reminder.title),
                        notificationBody: _getNotificationBody(reminder.title),
                        channelName: 'notif_reminders'.tr(),
                        channelDescription: 'notif_reminders_desc'.tr(),
                      );
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      await _presenter.deleteReminder(reminder.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _intervalController.dispose();
    super.dispose();
  }
}