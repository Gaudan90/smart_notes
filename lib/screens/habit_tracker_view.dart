import 'package:flutter/material.dart';
import '../controllers/habit_tracker_presenter.dart';
import '../states/habit_model.dart';
import 'habit_detail_view.dart';

class HabitTrackerView extends StatefulWidget {
  const HabitTrackerView({super.key});

  @override
  State<HabitTrackerView> createState() => _HabitTrackerViewState();
}

class _HabitTrackerViewState extends State<HabitTrackerView>
    with SingleTickerProviderStateMixin {
  final _presenter = HabitTrackerPresenter();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  late TabController _tabController;
  Color _selectedColor = HabitTrackerPresenter.defaultColors[0];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    await _presenter.loadHabits();
    setState(() {
      _isLoading = false;
    });
  }

  void _showAddHabitDialog() {
    _nameController.clear();
    _descriptionController.clear();
    _selectedColor = HabitTrackerPresenter.defaultColors[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Nuova Abitudine'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome abitudine',
                      hintText: 'Es: Allenamento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione (opzionale)',
                      hintText: 'Obiettivo o note',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Colore:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: HabitTrackerPresenter.defaultColors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
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
                  if (_nameController.text.isNotEmpty) {
                    await _presenter.addHabit(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      color: _selectedColor,
                    );
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: const Text('Crea'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHabitDetails(HabitModel habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HabitDetailView(
          habit: habit,
          presenter: _presenter,
          onUpdate: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Abitudini'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Abitudini', icon: Icon(Icons.list)),
            Tab(text: 'Panoramica', icon: Icon(Icons.dashboard)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildHabitsTab(),
          _buildOverviewTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHabitDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuova Abitudine'),
      ),
    );
  }

  Widget _buildHabitsTab() {
    if (_presenter.habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nessuna abitudine',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea la tua prima abitudine da tracciare',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _presenter.habits.length,
      itemBuilder: (context, index) {
        final habit = _presenter.habits[index];
        final stats = _presenter.calculateMonthStats(
          habit,
          DateTime.now().year,
          DateTime.now().month,
        );
        final isTodayCompleted = _presenter.isTodayCompleted(habit.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: habit.color,
              child: Icon(
                isTodayCompleted ? Icons.check : Icons.fitness_center,
                color: Colors.white,
              ),
            ),
            title: Text(
              habit.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stats.completionText),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stats.completionPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stats.percentageText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: habit.color,
                    fontSize: 16,
                  ),
                ),
                if (stats.currentStreak > 0)
                  Text(
                    '🔥 ${stats.currentStreak}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            onTap: () => _showHabitDetails(habit),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    final globalStats = _presenter.getGlobalStats();
    final topHabits = _presenter.getTopHabitsThisMonth();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiche Globali',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Abitudini',
                  '${globalStats['totalHabits']}',
                  Icons.list,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Giorni Totali',
                  '${globalStats['totalCompletedDays']}',
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Top Abitudini (Questo Mese)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (topHabits.isEmpty)
            const Center(
              child: Text(
                'Inizia a tracciare le tue abitudini!',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...topHabits.take(5).map((entry) {
              final habit = entry.key;
              final percentage = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: habit.color,
                    child: const Icon(Icons.star, color: Colors.white),
                  ),
                  title: Text(habit.name),
                  trailing: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: habit.color,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}