import 'package:flutter/material.dart';
import '../controllers/event_calendar_presenter.dart';
import '../states/event_model.dart';
import '../states/event_occurrence_model.dart';

class EventCalendarView extends StatefulWidget {
  const EventCalendarView({super.key});

  @override
  State<EventCalendarView> createState() => _EventCalendarViewState();
}

class _EventCalendarViewState extends State<EventCalendarView>
    with SingleTickerProviderStateMixin {
  final _presenter = EventCalendarPresenter();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  late TabController _tabController;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  RecurrenceType _recurrenceType = RecurrenceType.weekly;
  int _interval = 1;
  List<int> _selectedWeekDays = [];
  int? _occurrences;

  final List<String> _weekDayNames = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await _presenter.loadEvents();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showAddEventDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 30));
    _recurrenceType = RecurrenceType.weekly;
    _interval = 1;
    _selectedWeekDays = [DateTime.now().weekday];
    _occurrences = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Nuovo Evento'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titolo evento',
                      hintText: 'Es: Corso di inglese',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrizione
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione (opzionale)',
                      hintText: 'Dettagli evento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Date
                  ListTile(
                    title: const Text('Data inizio'),
                    subtitle: Text(_formatDate(_startDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      await _selectDate(context, true);
                      setDialogState(() {});
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ListTile(
                    title: const Text('Data fine'),
                    subtitle: Text(_formatDate(_endDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      await _selectDate(context, false);
                      setDialogState(() {});
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tipo di ricorrenza
                  DropdownButtonFormField<RecurrenceType>(
                    value: _recurrenceType,
                    decoration: const InputDecoration(
                      labelText: 'Frequenza',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    items: RecurrenceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _recurrenceType = value!;
                        if (_recurrenceType == RecurrenceType.weekly &&
                            _selectedWeekDays.isEmpty) {
                          _selectedWeekDays = [DateTime.now().weekday];
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Intervallo (per giornaliero e mensile)
                  if (_recurrenceType == RecurrenceType.daily ||
                      _recurrenceType == RecurrenceType.monthly)
                    TextField(
                      decoration: InputDecoration(
                        labelText: _recurrenceType == RecurrenceType.daily
                            ? 'Ogni quanti giorni?'
                            : 'Ogni quanti mesi?',
                        hintText: '1',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _interval = int.tryParse(value) ?? 1;
                      },
                    ),

                  if (_recurrenceType == RecurrenceType.weekly) ...[
                    const Text(
                      'Giorni della settimana:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final dayNumber = index + 1;
                        return FilterChip(
                          label: Text(_weekDayNames[index]),
                          selected: _selectedWeekDays.contains(dayNumber),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                _selectedWeekDays.add(dayNumber);
                              } else {
                                _selectedWeekDays.remove(dayNumber);
                              }
                              _selectedWeekDays.sort();
                            });
                          },
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 16),

                  if (_recurrenceType != RecurrenceType.once)
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Numero ripetizioni (opzionale)',
                        hintText: 'Es: 8 settimane',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat_one),
                        helperText: 'Lascia vuoto per usare la data fine',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _occurrences = value.isEmpty ? null : int.tryParse(value);
                      },
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
                    if (_recurrenceType == RecurrenceType.weekly &&
                        _selectedWeekDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Seleziona almeno un giorno della settimana'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    await _presenter.addEvent(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      startDate: _startDate,
                      endDate: _endDate,
                      recurrenceType: _recurrenceType,
                      interval: _interval,
                      weekDays: _selectedWeekDays,
                      occurrences: _occurrences,
                    );

                    setState(() {});
                    Navigator.pop(context);

                    // Mostra quante date sono state generate
                    final event = _presenter.events.last;
                    final occurrences = _presenter.generateOccurrences(event);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✓ Evento creato con ${occurrences.length} date generate',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Crea Evento'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEventDetails(EventModel event) {
    final occurrences = _presenter.generateOccurrences(event);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.description.isNotEmpty) ...[
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ],

              _buildInfoRow(
                Icons.event,
                'Tipo',
                event.recurrenceType.displayName,
              ),

              _buildInfoRow(
                Icons.calendar_today,
                'Periodo',
                '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
              ),

              _buildInfoRow(
                Icons.repeat,
                'Ripetizioni generate',
                '${occurrences.length} date',
              ),

              if (occurrences.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Prime date:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: occurrences.length > 10 ? 10 : occurrences.length,
                    itemBuilder: (context, index) {
                      final occ = occurrences[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          child: Text(
                            '${occ.occurrenceNumber}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        title: Text(occ.formattedDate),
                      );
                    },
                  ),
                ),
                if (occurrences.length > 10)
                  Text(
                    '... e altre ${occurrences.length - 10} date',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _presenter.deleteEvent(event.id);
              setState(() {});
            },
            child: const Text(
              'Elimina',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario Eventi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'I Miei Eventi', icon: Icon(Icons.event_note)),
            Tab(text: 'Date Future', icon: Icon(Icons.calendar_month)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(),
          _buildUpcomingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Evento'),
      ),
    );
  }

  Widget _buildEventsTab() {
    if (_presenter.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nessun evento creato',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aggiungi un evento ricorrente',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _presenter.events.length,
      itemBuilder: (context, index) {
        final event = _presenter.events[index];
        final totalOccurrences = _presenter.getTotalOccurrencesForEvent(event.id);
        final nextOccurrence = _presenter.getNextOccurrence(event.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                _getRecurrenceIcon(event.recurrenceType),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.recurrenceType.displayName),
                const SizedBox(height: 4),
                Text(
                  '$totalOccurrences date generate',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (nextOccurrence != null)
                  Text(
                    'Prossima: ${nextOccurrence.formattedDate}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showEventDetails(event),
            ),
            onTap: () => _showEventDetails(event),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTab() {
    final upcomingOccurrences = _presenter.getAllUpcomingOccurrences();

    if (upcomingOccurrences.isEmpty) {
      return const Center(
        child: Text('Nessuna data futura disponibile'),
      );
    }

    // Raggruppa per mese
    final Map<String, List<EventOccurrence>> groupedByMonth = {};
    for (var occ in upcomingOccurrences) {
      final monthKey = '${_getMonthName(occ.date.month)} ${occ.date.year}';
      groupedByMonth[monthKey] = groupedByMonth[monthKey] ?? [];
      groupedByMonth[monthKey]!.add(occ);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedByMonth.length,
      itemBuilder: (context, index) {
        final monthKey = groupedByMonth.keys.elementAt(index);
        final occurrences = groupedByMonth[monthKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                monthKey,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ...occurrences.map((occ) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${occ.date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        _weekDayNames[occ.date.weekday - 1],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                title: Text(occ.eventTitle),
                subtitle: Text(
                  'Occorrenza #${occ.occurrenceNumber}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  IconData _getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.once:
        return Icons.event;
      case RecurrenceType.daily:
        return Icons.today;
      case RecurrenceType.weekly:
        return Icons.date_range;
      case RecurrenceType.monthly:
        return Icons.calendar_today;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}