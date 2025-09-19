import 'package:flutter/material.dart';
import 'package:smart_notes/screens/reminder_view.dart';
import 'package:smart_notes/screens/sentence_reverse_view.dart';
import 'package:smart_notes/screens/theme_settings_view.dart';
import 'package:smart_notes/screens/todo_list_view.dart';
import 'package:smart_notes/theme/theme_provider.dart';
import '../widget/feature_card.dart';
import 'fizzbuzz_view.dart';
import 'missing_numbers_view.dart';
import 'number_stats_view.dart';

class HomeView extends StatefulWidget {
  final ThemeProvider themeProvider;

  const HomeView({super.key, required this.themeProvider});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animations = List.generate(6, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.1,
          0.5 + index * 0.1,
          curve: Curves.easeOutBack,
        ),
      ));
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final features = [
      FeatureCard(
        title: 'Lista To-Do',
        subtitle: 'Gestisci le tue attività',
        icon: Icons.checklist,
        color: Colors.orange,
        animation: _animations[0],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TodoListView()),
        ),
      ),
      FeatureCard(
        title: 'Routine Planner',
        subtitle: 'Pianifica routine ricorrenti',
        icon: Icons.event_repeat,
        color: Colors.red,
        animation: _animations[1],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FizzBuzzView()),
        ),
      ),
      FeatureCard(
        title: 'Promemoria',
        subtitle: 'Attività ricorrenti giornaliere',
        icon: Icons.notifications_active,
        color: Colors.amber,
        animation: _animations[2],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderView()),
        ),
      ),
      FeatureCard(
        title: 'Statistiche Numeriche',
        subtitle: 'Trova il numero più frequente',
        icon: Icons.analytics_outlined,
        color: Colors.blue,
        animation: _animations[3],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NumberStatsView()),
        ),
      ),
      FeatureCard(
        title: 'Riformulatore Frasi',
        subtitle: 'Inverti le parole della frase',
        icon: Icons.text_rotation_none,
        color: Colors.green,
        animation: _animations[4],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SentenceReverserView()),
        ),
      ),
      FeatureCard(
        title: 'Numeri Mancanti',
        subtitle: 'Trova i numeri saltati',
        icon: Icons.search,
        color: Colors.purple,
        animation: _animations[5],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MissingNumbersView()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartNotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ThemeSettingsView(themeProvider: widget.themeProvider),
              ),
            ),
            tooltip: 'Personalizza Tema',
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: child,
                );
              },
              child: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDarkMode),
              ),
            ),
            onPressed: () => widget.themeProvider.toggleTheme(),
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Blocchetto Intelligente',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Strumenti utili per la vita quotidiana',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme
                      .onBackground.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) => features[index],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}