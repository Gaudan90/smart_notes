import 'package:flutter/material.dart';
import '../../controllers/countdown_presenter.dart';
import '../../states/countdown_model.dart';
import 'emoji_icons.dart';

class CountdownEditDialog extends StatefulWidget {
  final CountdownPresenter presenter;
  final CountdownModel countdown;
  final VoidCallback onCountdownUpdated;

  const CountdownEditDialog({
    super.key,
    required this.presenter,
    required this.countdown,
    required this.onCountdownUpdated,
  });

  @override
  State<CountdownEditDialog> createState() => _CountdownEditDialogState();
}

class _CountdownEditDialogState extends State<CountdownEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int? _selectedEmojiIndex;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.countdown.title);
    _descriptionController = TextEditingController(
      text: widget.countdown.description ?? '',
    );
    _selectedDate = widget.countdown.targetDate;
    _selectedTime = TimeOfDay(
      hour: widget.countdown.targetDate.hour,
      minute: widget.countdown.targetDate.minute,
    );

    if (widget.countdown.emoji != null) {
      final codePoint = int.tryParse(widget.countdown.emoji!);
      if (codePoint != null) {
        _selectedEmojiIndex = EmojiIcons.commonIcons.indexWhere(
              (icon) => icon.codePoint == codePoint,
        );
        if (_selectedEmojiIndex == -1) {
          _selectedEmojiIndex = null;
        }
      }
    }
  }

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
      locale: const Locale('it', 'IT'),
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

  Future<void> _updateCountdown() async {
    if (!_formKey.currentState!.validate()) return;

    String? emojiCodePoint;
    if (_selectedEmojiIndex != null) {
      emojiCodePoint = EmojiIcons.commonIcons[_selectedEmojiIndex!]
          .codePoint
          .toString();
    }

    await widget.presenter.updateCountdown(
      id: widget.countdown.id,
      title: _titleController.text,
      targetDate: _selectedDate,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      emoji: emojiCodePoint,
    );

    widget.onCountdownUpdated();

    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Countdown aggiornato con successo'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica Countdown'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titolo
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo *',
                  hintText: 'Es: Esame di matematica',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci un titolo';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione (opzionale)',
                  hintText: 'Aggiungi dettagli...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              // Data
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Data'),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: TextButton(
                    onPressed: _selectDate,
                    child: const Text('Cambia'),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Ora
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Ora'),
                  subtitle: Text(_formatTime(_selectedTime)),
                  trailing: TextButton(
                    onPressed: _selectTime,
                    child: const Text('Cambia'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Icona (opzionale)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
// Sostituisci TUTTO il GridView con questo widget
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
                        width: 40, // Dimensione fissa per ogni icona
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
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _updateCountdown,
          child: const Text('Salva'),
        ),
      ],
    );
  }
}