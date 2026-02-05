import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
        SnackBar(
          content: Text('select_weekday'.tr()),
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
      title: Text('new_event'.tr()),
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
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text('create_event'.tr()),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'event_title'.tr(),
        hintText: 'event_title_hint'.tr(),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.title),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'description_optional'.tr(),
        hintText: 'event_details'.tr(),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 2,
    );
  }

  Widget _buildDateSelectors() {
    return Column(
      children: [
        ListTile(
          title: Text('start_date'.tr()),
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
          title: Text('end_date'.tr()),
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
      decoration: InputDecoration(
        labelText: 'frequency'.tr(),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.repeat),
      ),
      items: RecurrenceType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(EventCalendarHelpers.getRecurrenceDisplayName(type)),
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
              ? 'every_how_many_days'.tr()
              : 'every_how_many_months'.tr(),
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
          Text(
            'weekdays_label'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
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
      decoration: InputDecoration(
        labelText: 'occurrences_optional'.tr(),
        hintText: 'occurrences_hint'.tr(),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.repeat_one),
        helperText: 'occurrences_helper'.tr(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _occurrences = value.isEmpty ? null : int.tryParse(value);
      },
    );
  }
}