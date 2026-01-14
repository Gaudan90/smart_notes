import 'package:flutter/material.dart';

import '../controllers/habit_tracker_presenter.dart';
import '../states/habit_model.dart';
import '../states/habit_stats_model.dart';

class HabitDetailView extends StatefulWidget {
  final HabitModel habit;
  final HabitTrackerPresenter presenter;
  final VoidCallback onUpdate;

  const HabitDetailView({
    super.key,
    required this.habit,
    required this.presenter,
    required this.onUpdate,
  });

  @override
  State<HabitDetailView> createState() => _HabitDetailViewState();
}

class _HabitDetailViewState extends State<HabitDetailView> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
        1,
      );
    });
  }

  Future<void> _toggleDay(int day) async {
    await widget.presenter.toggleDay(
      widget.habit.id,
      _selectedMonth.year,
      _selectedMonth.month,
      day,
    );
    setState(() {});
    widget.onUpdate();
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.presenter.calculateMonthStats(
      widget.habit,
      _selectedMonth.year,
      _selectedMonth.month,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        backgroundColor: widget.habit.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Conferma'),
                  content: const Text('Eliminare questa abitudine?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Elimina'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await widget.presenter.deleteHabit(widget.habit.id);
                widget.onUpdate();
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: widget.habit.color.withValues(alpha: 0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      _getMonthName(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Statistiche mensili
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Completati',
                        '${stats.completedCount}', Icons.check_circle),
                    _buildStatColumn('Mancanti',
                        '${stats.missingCount}', Icons.cancel),
                    _buildStatColumn('Streak',
                        '${stats.currentStreak}', Icons.local_fire_department),
                    _buildStatColumn('Record',
                        '${stats.longestStreak}', Icons.emoji_events),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCalendar(stats),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: widget.habit.color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.habit.color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(HabitStats stats) {
    final weekDays = widget.presenter.getWeekdayHeaders();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) => SizedBox(
            width: 40,
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),

        _buildCalendarGrid(stats),
      ],
    );
  }

  Widget _buildCalendarGrid(HabitStats stats) {
    final firstDayOffset = widget.presenter.getFirstDayOffset(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final daysInMonth = stats.totalDaysInMonth;

    final totalCells = firstDayOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;

              if (cellIndex < firstDayOffset) {
                return const SizedBox(width: 40, height: 40);
              }

              final day = cellIndex - firstDayOffset + 1;

              if (day > daysInMonth) {
                return const SizedBox(width: 40, height: 40);
              }

              final isCompleted = stats.completedDays.contains(day);
              final isMissing = stats.missingDays.contains(day);
              final isToday = _selectedMonth.year == DateTime.now().year &&
                  _selectedMonth.month == DateTime.now().month &&
                  day == DateTime.now().day;

              return _buildDayCell(day, isCompleted, isMissing, isToday);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(int day, bool isCompleted, bool isMissing, bool isToday) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    if (isCompleted) {
      backgroundColor = widget.habit.color;
      textColor = Colors.white;
      icon = Icons.check;
    } else if (isMissing) {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey;
    } else {
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.black;
    }

    return GestureDetector(
      onTap: () => _toggleDay(day),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: widget.habit.color, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (icon != null)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  icon,
                  size: 12,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}