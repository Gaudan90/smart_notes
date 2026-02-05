import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/gantt_planner_presenter.dart';
import '../../states/gantt_task_model.dart';

class TaskAddEditDialog extends StatefulWidget {
  final GanttTaskModel? task;
  final GanttPlannerPresenter presenter;
  final VoidCallback onSaved;

  const TaskAddEditDialog({
    super.key,
    this.task,
    required this.presenter,
    required this.onSaved,
  });

  @override
  State<TaskAddEditDialog> createState() => _TaskAddEditDialogState();
}

class _TaskAddEditDialogState extends State<TaskAddEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _assignedToController = TextEditingController();

  late DateTime _startDate;
  late DateTime _endDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.text = widget.task!.name;
      _startDate = widget.task!.startDate;
      _endDate = widget.task!.endDate;
      _assignedToController.text = widget.task!.assignedTo ?? '';
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'edit_task'.tr() : 'new_task'.tr()),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nome task
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'task_name_label'.tr(),
                  hintText: 'task_name_hint'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.assignment),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'task_name_required'.tr();
                  }
                  return null;
                },
                autofocus: !_isEditing,
              ),

              const SizedBox(height: 16),

              ListTile(
                title: Text('start_date_label'.tr()),
                subtitle: Text(_formatDate(_startDate)),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectStartDate(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),

              const SizedBox(height: 12),

              ListTile(
                title: Text('due_date_label'.tr()),
                subtitle: Text(_formatDate(_endDate)),
                leading: const Icon(Icons.event),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectEndDate(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),

              const SizedBox(height: 16),

              Autocomplete<String>(
                initialValue: TextEditingValue
                  (text: _assignedToController.text),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return widget.presenter.assignedPeople.where((person) {
                    return person
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _assignedToController.text = selection;
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  _assignedToController.text = controller.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'assigned_to_label'.tr(),
                      hintText: 'assigned_to_hint'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                  );
                },
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
          onPressed: _saveTask,
          child: Text(_isEditing ? 'save'.tr() : 'add'.tr()),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'select_start_date'.tr(),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
      helpText: 'select_due_date'.tr(),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }


  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      _showError('due_date_after_start'.tr());
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_isEditing) {
        await widget.presenter.updateTask(
          id: widget.task!.id,
          name: _nameController.text,
          startDate: _startDate,
          endDate: _endDate,
          assignedTo: _assignedToController.text.trim().isEmpty
              ? null
              : _assignedToController.text.trim(),
        );
      } else {
        await widget.presenter.addTask(
          name: _nameController.text,
          startDate: _startDate,
          endDate: _endDate,
          assignedTo: _assignedToController.text.trim().isEmpty
              ? null
              : _assignedToController.text.trim(),
        );
      }

      widget.onSaved();

      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'task_updated'.tr() : 'task_created'.tr(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('error_msg'.tr(namedArgs: {'error': message})),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}