import 'dart:async';
import 'package:flutter/material.dart';
import '../data/alarm_manager.dart';
import '../states/alarm_model.dart';
import '../widget/alarm_overlay.dart';

class AlarmView extends StatefulWidget {
  const AlarmView({super.key});

  @override
  State<AlarmView> createState() => _AlarmViewState();
}

class _AlarmViewState extends State<AlarmView> {
  final AlarmManager _alarmManager = AlarmManager();
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  Timer? _checkTimer;
  bool _isLoading = true;
  OverlayEntry? _alarmOverlay;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _startChecking();
  }

  Future<void> _loadAlarms() async {
    await _alarmManager.loadAlarms();
    setState(() {
      _isLoading = false;
    });
  }

  void _startChecking() {
    // Controlla ogni secondo se ci sono sveglie da far suonare
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkForAlarms();
    });
  }

  void _checkForAlarms() {
    final alarmsToTrigger = _alarmManager.getAlarmsToTrigger();

    if (alarmsToTrigger.isNotEmpty && _alarmOverlay == null) {
      // Suona la prima sveglia della lista
      _triggerAlarm(alarmsToTrigger.first);
    }
  }

  void _triggerAlarm(AlarmModel alarm) {
    print('Triggering alarm: ${alarm.title}');

    _alarmOverlay = OverlayEntry(
      builder: (context) => AlarmOverlay(
        alarm: alarm,
        onDismiss: () async {
          _alarmOverlay?.remove();
          _alarmOverlay = null;

          // Disattiva la sveglia dopo che è suonata
          await _alarmManager.toggleAlarm(alarm.id);
          setState(() {});
        },
      ),
    );

    Overlay.of(context).insert(_alarmOverlay!);
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _showAddAlarmDialog() {
    _titleController.clear();
    _selectedDateTime = DateTime.now().add(const Duration(minutes: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final smartTime = _alarmManager.getSmartAlarmTime(_selectedDateTime);
          final isNextDay = smartTime.day != _selectedDateTime.day;

          return AlertDialog(
            title: const Text('Nuova Sveglia'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nome sveglia',
                      hintText: 'Es: Sveglia mattina',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    title: const Text('Data e Ora'),
                    subtitle: Text(
                      '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} '
                          '${_selectedDateTime.hour.toString().padLeft(2, '0')}:'
                          '${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      await _selectDateTime();
                      setDialogState(() {});
                    },
                  ),

                  if (isNextDay)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'L\'orario è già passato oggi.\nLa sveglia suonerà domani '
                                  '${smartTime.day}/${smartTime.month} alle '
                                  '${smartTime.hour.toString().padLeft(2, '0')}:'
                                  '${smartTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.isNotEmpty) {
                    await _alarmManager.addAlarm(
                      title: _titleController.text,
                      dateTime: _selectedDateTime,
                    );
                    setState(() {});
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Imposta'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatAlarmTime(AlarmModel alarm) {
    final now = DateTime.now();
    final isToday = alarm.dateTime.day == now.day &&
        alarm.dateTime.month == now.month &&
        alarm.dateTime.year == now.year;
    final isTomorrow = alarm.dateTime.day == now.add(const Duration(days: 1)).day &&
        alarm.dateTime.month == now.add(const Duration(days: 1)).month;

    String dayText = '';
    if (isToday) {
      dayText = 'Oggi';
    } else if (isTomorrow) {
      dayText = 'Domani';
    } else {
      dayText = '${alarm.dateTime.day}/${alarm.dateTime.month}';
    }

    return '$dayText alle ${alarm.dateTime.hour.toString().padLeft(2, '0')}:'
        '${alarm.dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final nextAlarm = _alarmManager.getNextActiveAlarm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sveglia Intelligente'),
        actions: [
          // Pulsante test veloce
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final now = DateTime.now();
              await _alarmManager.addAlarm(
                title: 'Test 10 secondi',
                dateTime: now.add(const Duration(seconds: 10)),
              );
              setState(() {});
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sveglia test impostata per tra 10 secondi'),
                ),
              );
              }
            },
            tooltip: 'Test veloce (10 sec)',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (nextAlarm != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.alarm,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prossima sveglia',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          nextAlarm.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatAlarmTime(nextAlarm),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Lista sveglie
          Expanded(
            child: _alarmManager.alarms.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nessuna sveglia impostata',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _alarmManager.alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarmManager.alarms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.alarm,
                      color: alarm.isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    title: Text(
                      alarm.title,
                      style: TextStyle(
                        decoration: alarm.isActive
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(_formatAlarmTime(alarm)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: alarm.isActive,
                          onChanged: (_) async {
                            await _alarmManager.toggleAlarm(alarm.id);
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () async {
                            await _alarmManager.deleteAlarm(alarm.id);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlarmDialog,
        child: const Icon(Icons.add_alarm),
      ),
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _alarmOverlay?.remove();
    _titleController.dispose();
    super.dispose();
  }
}