import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/alarm_manager.dart';
import '../states/alarm_model.dart';
import '../widget/alarm_overlay.dart';
import '../data/alarm_background_service.dart';

class AlarmView extends StatefulWidget {
  const AlarmView({super.key});

  @override
  State<AlarmView> createState() => _AlarmViewState();
}

class _AlarmViewState extends State<AlarmView> with WidgetsBindingObserver {
  final AlarmManager _alarmManager = AlarmManager();
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = true;
  OverlayEntry? _alarmOverlay;

  // Variabili per ripetizione
  bool _isRepeating = false;
  bool _repeatDaily = false;
  List<int> _selectedDays = [];

  final List<String> _weekDays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAlarms();
    _setupAlarmHandler();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAlarms();
    }
  }

  void _setupAlarmHandler() {
    // Gestisce quando una sveglia viene triggerata dal background
    AlarmTriggerManager.onAlarmTriggered = (String alarmId) async {
      await _alarmManager.loadAlarms();
      final alarm = _alarmManager.getAlarmById(alarmId);

      if (alarm != null && _alarmOverlay == null) {
        _triggerAlarm(alarm);
      }
    };
  }

  Future<void> _loadAlarms() async {
    await _alarmManager.loadAlarms();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      print('📱 Schedule exact alarm permission: $status');

      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Permesso allarmi negato. Vai in Impostazioni → App → '
                      'SmartNotes → Allarmi e promemoria'
              ),
              action: SnackBarAction(
                label: 'Impostazioni',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    }
  }

  void _triggerAlarm(AlarmModel alarm) {
    print('Triggering alarm overlay: ${alarm.title}');

    _alarmOverlay = OverlayEntry(
      builder: (context) => AlarmOverlay(
        alarm: alarm,
        onDismiss: () async {
          _alarmOverlay?.remove();
          _alarmOverlay = null;

          if (alarm.isRepeating) {
            // Rischedula se è ripetuta
            await _alarmManager.rescheduleRepeatingAlarm(alarm.id);
          } else {
            // Disattiva se è singola
            await _alarmManager.toggleAlarm(alarm.id);
          }

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
    _isRepeating = false;
    _repeatDaily = false;
    _selectedDays = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final smartTime = _alarmManager.getSmartAlarmTime(_selectedDateTime);
          final isNextDay = !_isRepeating && smartTime.day != _selectedDateTime.day;

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
                    title: const Text('Ora'),
                    subtitle: Text(
                      '${_selectedDateTime.hour.toString().padLeft(2, '0')}:'
                          '${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      await _selectDateTime();
                      setDialogState(() {});
                    },
                  ),

                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Sveglia ripetuta'),
                    value: _isRepeating,
                    onChanged: (value) {
                      setDialogState(() {
                        _isRepeating = value;
                        if (!value) {
                          _repeatDaily = false;
                          _selectedDays = [];
                        }
                      });
                    },
                  ),

                  if (_isRepeating) ...[
                    RadioListTile<bool>(
                      title: const Text('Tutti i giorni'),
                      value: true,
                      groupValue: _repeatDaily,
                      onChanged: (value) {
                        setDialogState(() {
                          _repeatDaily = value!;
                          if (value) {
                            _selectedDays = [];
                          }
                        });
                      },
                    ),
                    RadioListTile<bool>(
                      title: const Text('Giorni specifici'),
                      value: false,
                      groupValue: _repeatDaily,
                      onChanged: (value) {
                        setDialogState(() {
                          _repeatDaily = value!;
                        });
                      },
                    ),

                    if (!_repeatDaily)
                      Wrap(
                        spacing: 8,
                        children: List.generate(7, (index) {
                          final dayNumber = index + 1;
                          return FilterChip(
                            label: Text(_weekDays[index]),
                            selected: _selectedDays.contains(dayNumber),
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  _selectedDays.add(dayNumber);
                                } else {
                                  _selectedDays.remove(dayNumber);
                                }
                              });
                            },
                          );
                        }),
                      ),
                  ],

                  if (!_isRepeating && isNextDay)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'L\'orario è già passato oggi.\n'
                                  'La sveglia suonerà domani alle '
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
                    if (_isRepeating && !_repeatDaily && _selectedDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Seleziona almeno un giorno'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    await _alarmManager.addAlarm(
                      title: _titleController.text,
                      dateTime: _selectedDateTime,
                      isRepeating: _isRepeating,
                      repeatDays: _selectedDays,
                      repeatDaily: _repeatDaily,
                    );
                    setState(() {});
                    Navigator.pop(context);
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
    if (alarm.isRepeating) {
      String time = '${alarm.dateTime.hour.toString().padLeft(2, '0')}:'
          '${alarm.dateTime.minute.toString().padLeft(2, '0')}';

      if (alarm.repeatDaily) {
        return '$time (Tutti i giorni)';
      } else if (alarm.repeatDays.isNotEmpty) {
        final days = alarm.repeatDays
            .map((d) => _weekDays[d - 1])
            .join(', ');
        return '$time ($days)';
      }
    }

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
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final now = DateTime.now();
              await _alarmManager.addAlarm(
                title: 'Test 10 secondi',
                dateTime: now.add(const Duration(seconds: 10)),
              );
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sveglia test impostata per tra 10 secondi'),
                ),
              );
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
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
                      alarm.isRepeating ? Icons.repeat : Icons.alarm,
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
    WidgetsBinding.instance.removeObserver(this);
    _alarmOverlay?.remove();
    _titleController.dispose();
    super.dispose();
  }
}