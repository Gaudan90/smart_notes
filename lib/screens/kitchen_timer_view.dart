import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/kitchen_timer_presenter.dart';
import '../states/kitchen_timer_model.dart';
import '../states/kitchen_timer_preset_model.dart';
import '../widget/kitchen_timer/timer_card.dart';
import '../widget/kitchen_timer/timer_presets_grid.dart';
import '../widget/kitchen_timer/timer_history_tab.dart';
import '../widget/kitchen_timer/timer_completed_overlay.dart';

class KitchenTimerView extends StatefulWidget {
  const KitchenTimerView({super.key});

  @override
  State<KitchenTimerView> createState() => _KitchenTimerViewState();
}

class _KitchenTimerViewState extends State<KitchenTimerView>
    with SingleTickerProviderStateMixin {
  final _presenter = KitchenTimerPresenter();
  late TabController _tabController;
  bool _isLoading = true;
  OverlayEntry? _timerOverlay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Imposta il callback per quando un timer completa
    _presenter.onTimerCompleted = _onTimerCompleted;

    _loadData();
  }

  void _onTimerCompleted(KitchenTimerModel timer) {
    if (_timerOverlay != null) return; // Già mostrando un overlay

    _timerOverlay = OverlayEntry(
      builder: (context) => TimerCompletedOverlay(
        timer: timer,
        onDismiss: () {
          _timerOverlay?.remove();
          _timerOverlay = null;
          setState(() {}); // Refresh UI
        },
      ),
    );

    Overlay.of(context).insert(_timerOverlay!);
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
    _timerOverlay?.remove();
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
        title: const Text('Nuovo Timer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'es. Pasta, Studio, Pausa...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minutesController,
                decoration: const InputDecoration(
                  labelText: 'Minuti',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
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
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final minutes = int.tryParse(minutesController.text);

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inserisci un nome'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (minutes == null || minutes <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inserisci minuti validi'),
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
                    content: Text('Timer "$name" creato'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Crea'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timer', icon: Icon(Icons.timer, size: 20)),
            Tab(text: 'Cronologia', icon: Icon(Icons.history, size: 20)),
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
        label: const Text('Timer Custom'),
      )
          : null,
    );
  }

  Widget _buildTimersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preset rapidi
          const Text(
            'Preset Rapidi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TimerPresetsGrid(
            onPresetSelected: (preset) => _showCreateTimerDialog(preset: preset),
          ),

          const SizedBox(height: 24),

          // Timer attivi
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
                  const Text(
                    'Nessun timer attivo',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea un timer per iniziare',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Timer Attivi',
                  style: TextStyle(
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
                      _presenter.resetTimer(currentTimer.id);
                      setState(() {});
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Elimina Timer'),
                          content: Text(
                            'Vuoi eliminare il timer "${currentTimer.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annulla'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Elimina'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
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