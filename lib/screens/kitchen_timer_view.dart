import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../controllers/kitchen_timer_presenter.dart';
import '../data/notification_service.dart';
import '../states/kitchen_timer_model.dart';
import '../states/kitchen_timer_preset_model.dart';
import '../widget/kitchen_timer/timer_card.dart';
import '../widget/kitchen_timer/timer_presets_grid.dart';
import '../widget/kitchen_timer/timer_history_tab.dart';

class KitchenTimerView extends StatefulWidget {
  const KitchenTimerView({super.key});

  @override
  State<KitchenTimerView> createState() => _KitchenTimerViewState();
}

class _KitchenTimerViewState extends State<KitchenTimerView>
    with SingleTickerProviderStateMixin {
  final _presenter = KitchenTimerPresenter();
  final _notificationService = NotificationService();
  final Set<String> _notifiedTimers = {}; // Per evitare notifiche duplicate
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  void _onTabChanged() {
    // Aggiorna la UI quando cambia tab (per mostrare/nascondere FAB)
    if (_tabController.indexIsChanging == false) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    await _presenter.loadActiveTimers();
    await _presenter.loadHistory();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _presenter.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateTimerDialog({TimerPreset? preset}) {
    final nameController = TextEditingController(
      text: preset?.name ?? '',
    );
    final minutesController = TextEditingController(
      text: preset?.minutes.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('new_timer'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'timer_name'.tr(),
                  hintText: 'timer_name_hint'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minutesController,
                decoration: InputDecoration(
                  labelText: 'timer_minutes'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
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
              final name = nameController.text.trim();
              final minutes = int.tryParse(minutesController.text);

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('enter_name'.tr()),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (minutes == null || minutes <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('enter_valid_minutes'.tr()),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              await _presenter.createTimer(name: name, minutes: minutes);
              setState(() {});

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('timer_created'.tr(namedArgs: {'name': name})),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('create'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('timer_title'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'tab_timer'.tr(), icon: const Icon(Icons.timer, size: 20)),
            Tab(text: 'tab_history'.tr(), icon: const Icon(Icons.history, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildTimersTab(),
          TimerHistoryTab(
            history: _presenter.history,
            onClearHistory: () async {
              await _presenter.clearHistory();
              setState(() {});
            },
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
        onPressed: () => _showCreateTimerDialog(),
        icon: const Icon(Icons.add),
        label: Text('custom_timer'.tr()),
      )
          : null,
    );
  }

  Widget _buildTimersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_presets'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TimerPresetsGrid(
            onPresetSelected: (preset) => _showCreateTimerDialog(preset: preset),
          ),

          const SizedBox(height: 24),

          if (_presenter.activeTimers.isEmpty) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.timer_off,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_active_timers'.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'create_timer_to_start'.tr(),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'active_timers'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(_presenter.activeTimers.length.toString()),
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._presenter.activeTimers.map((timer) {
              return StreamBuilder<KitchenTimerModel>(
                stream: _presenter.timerStream(timer.id),
                initialData: timer,
                builder: (context, snapshot) {
                  final currentTimer = snapshot.data ?? timer;

                  // Invia notifica quando il timer si completa
                  if (currentTimer.state == TimerState.completed &&
                      !_notifiedTimers.contains(currentTimer.id)) {
                    _notifiedTimers.add(currentTimer.id);
                    _notificationService.showInstantNotification(
                      title: 'timer_title'.tr(),
                      body: '${currentTimer.name} - ${'timer_completed'.tr()}',
                    );
                  }

                  return TimerCard(
                    timer: currentTimer,
                    onStart: () {
                      _presenter.startTimer(currentTimer.id);
                      setState(() {});
                    },
                    onPause: () {
                      _presenter.pauseTimer(currentTimer.id);
                      setState(() {});
                    },
                    onReset: () {
                      _notifiedTimers.remove(currentTimer.id);
                      _presenter.resetTimer(currentTimer.id);
                      setState(() {});
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('delete_timer'.tr()),
                          content: Text(
                            'delete_timer_confirm'.tr(namedArgs: {'name': currentTimer.name}),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('cancel'.tr()),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text('delete'.tr()),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        _notifiedTimers.remove(currentTimer.id);
                        await _presenter.deleteTimer(currentTimer.id);
                        setState(() {});
                      }
                    },
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}