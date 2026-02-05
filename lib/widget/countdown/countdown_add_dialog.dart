import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/countdown_presenter.dart';
import 'emoji_icons.dart';

class CountdownAddDialog extends StatefulWidget {
  final CountdownPresenter presenter;
  final VoidCallback onCountdownAdded;

  const CountdownAddDialog({
    super.key,
    required this.presenter,
    required this.onCountdownAdded,
  });

  @override
  State<CountdownAddDialog> createState() => _CountdownAddDialogState();
}

class _CountdownAddDialogState extends State<CountdownAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  int? _selectedEmojiIndex;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveCountdown() async {
    if (!_formKey.currentState!.validate()) return;

    String? emojiCodePoint;
    if (_selectedEmojiIndex != null) {
      emojiCodePoint = EmojiIcons.commonIcons[_selectedEmojiIndex!]
          .codePoint
          .toString();
    }

    await widget.presenter.addCountdown(
      title: _titleController.text,
      targetDate: _selectedDate,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      emoji: emojiCodePoint,
    );

    widget.onCountdownAdded();

    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('countdown_created'.tr()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('new_countdown'.tr()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'title_required'.tr(),
                  hintText: 'title_hint'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'enter_title'.tr();
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'description_optional'.tr(),
                  hintText: 'add_details'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('date'.tr()),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: TextButton(
                    onPressed: _selectDate,
                    child: Text('change'.tr()),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('time'.tr()),
                  subtitle: Text(_formatTime(_selectedTime)),
                  trailing: TextButton(
                    onPressed: _selectTime,
                    child: Text('change'.tr()),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'icon_optional'.tr(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: List.generate(EmojiIcons.commonIcons.length, (index) {
                      final isSelected = _selectedEmojiIndex == index;
                      return SizedBox(
                        width: 40,
                        height: 40,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedEmojiIndex = isSelected ? null : index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                                  : null,
                            ),
                            child: Center(
                              child: Icon(
                                EmojiIcons.commonIcons[index],
                                size: 28,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: _saveCountdown,
          child: Text('create'.tr()),
        ),
      ],
    );
  }
}