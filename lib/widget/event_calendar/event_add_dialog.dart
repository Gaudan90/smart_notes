import 'package:flutter/material.dart';
import '../../states/event_model.dart';
import 'event_calendar_helpers.dart';

class EventAddDialog extends StatefulWidget {
  final Future<void> Function({
  required String title,
  required String description,
  required DateTime startDate,
  required DateTime endDate,
  required RecurrenceType recurrenceType,
  required int interval,
  required List<int> weekDays,
  int? occurrences,
  }) onAdd;

  const EventAddDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<EventAddDialog> createState() => _EventAddDialogState();
}

class _EventAddDialogState extends State<EventAddDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  RecurrenceType _recurrenceType = RecurrenceType.weekly;
  int _interval = 1;
  List<int> _selectedWeekDays = [DateTime.now().weekday];
  int? _occurrences;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
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

  Future<void> _handleSubmit() async {
    if (_titleController.text.isEmpty) return;

    if (_recurrenceType == RecurrenceType.weekly && _selectedWeekDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un giorno della settimana'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await widget.onAdd(
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      endDate: _endDate,
      recurrenceType: _recurrenceType,
      interval: _interval,
      weekDays: _selectedWeekDays,
      occurrences: _occurrences,
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuovo Evento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildDateSelectors(),
            const SizedBox(height: 16),
            _buildRecurrenceDropdown(),
            const SizedBox(height: 16),
            _buildIntervalField(),
            _buildWeekDaySelector(),
            _buildOccurrencesField(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Crea Evento'),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Titolo evento',
        hintText: 'Es: Corso di inglese',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descrizione (opzionale)',
        hintText: 'Dettagli evento',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 2,
    );
  }

  Widget _buildDateSelectors() {
    return Column(
      children: [
        ListTile(
          title: const Text('Data inizio'),
          subtitle: Text(EventCalendarHelpers.formatDate(_startDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(true),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Data fine'),
          subtitle: Text(EventCalendarHelpers.formatDate(_endDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(false),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurrenceDropdown() {
    return DropdownButtonFormField<RecurrenceType>(
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
        setState(() {
          _recurrenceType = value!;
          if (_recurrenceType == RecurrenceType.weekly &&
              _selectedWeekDays.isEmpty) {
            _selectedWeekDays = [DateTime.now().weekday];
          }
        });
      },
    );
  }

  Widget _buildIntervalField() {
    if (_recurrenceType != RecurrenceType.daily &&
        _recurrenceType != RecurrenceType.monthly) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
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
    );
  }

  Widget _buildWeekDaySelector() {
    if (_recurrenceType != RecurrenceType.weekly) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                label: Text(EventCalendarHelpers.weekDayNames[index]),
                selected: _selectedWeekDays.contains(dayNumber),
                onSelected: (selected) {
                  setState(() {
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
      ),
    );
  }

  Widget _buildOccurrencesField() {
    if (_recurrenceType == RecurrenceType.once) {
      return const SizedBox.shrink();
    }

    return TextField(
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
    );
  }
}