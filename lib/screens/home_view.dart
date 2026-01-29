import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_notes/screens/reminder_view.dart';
import 'package:smart_notes/screens/sentence_reverse_view.dart';
import 'package:smart_notes/screens/shopping_list_view.dart';
import 'package:smart_notes/screens/text_analyzer_view.dart';
import 'package:smart_notes/screens/theme_settings_view.dart';
import 'package:smart_notes/screens/todo_list_view.dart';
import 'package:smart_notes/theme/theme_provider.dart';
import '../widget/feature_card.dart';
import '../widget/password/password_security_gate.dart';
import 'alarm_view.dart';
import 'countdown_view.dart';
import 'expense_view.dart';
import 'fizzbuzz_view.dart';
import 'gantt_planner_view.dart';
import 'kitchen_timer_view.dart';
import 'meal_plan_view.dart';
import 'missing_numbers_view.dart';
import 'number_stats_view.dart';
import 'event_calendar_view.dart';
import 'habit_tracker_view.dart';

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

    _animations = List.generate(17, (index) {
      final double start = index * 0.04;
      final double end = (0.2 + index * 0.04).clamp(0.0, 1.0);

      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          start,
          end,
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

  void _toggleLanguage() {
    final currentLocale = context.locale;
    if (currentLocale.languageCode == 'en') {
      context.setLocale(const Locale('it', 'IT'));
    } else {
      context.setLocale(const Locale('en', 'US'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isItalian = context.locale.languageCode == 'it';

    final features = [
      FeatureCard(
        title: 'todo_list'.tr(),
        subtitle: 'todo_list_subtitle'.tr(),
        icon: Icons.checklist,
        color: Colors.orange,
        animation: _animations[0],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TodoListView()),
        ),
      ),
      FeatureCard(
        title: 'habit_tracker'.tr(),
        subtitle: 'habit_tracker_subtitle'.tr(),
        icon: Icons.track_changes,
        color: Colors.teal,
        animation: _animations[1],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HabitTrackerView()),
        ),
      ),
      FeatureCard(
        title: 'shopping_list'.tr(),
        subtitle: 'shopping_list_subtitle'.tr(),
        icon: Icons.shopping_cart,
        color: Colors.lightGreen,
        animation: _animations[2],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShoppingListView()),
        ),
      ),
      FeatureCard(
        title: 'expense_tracker'.tr(),
        subtitle: 'expense_tracker_subtitle'.tr(),
        icon: Icons.account_balance_wallet,
        color: Colors.indigo,
        animation: _animations[3],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpenseView()),
        ),
      ),
      FeatureCard(
        title: 'countdown'.tr(),
        subtitle: 'countdown_subtitle'.tr(),
        icon: Icons.timer,
        color: Colors.pink,
        animation: _animations[4],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CountdownView()),
        ),
      ),
      FeatureCard(
        title: 'smart_alarm'.tr(),
        subtitle: 'smart_alarm_subtitle'.tr(),
        icon: Icons.alarm,
        color: Colors.cyan,
        animation: _animations[5],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AlarmView()),
        ),
      ),
      FeatureCard(
        title: 'timer'.tr(),
        subtitle: 'timer_subtitle'.tr(),
        icon: Icons.kitchen_outlined,
        color: Colors.redAccent,
        animation: _animations[6],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KitchenTimerView()),
        ),
      ),
      FeatureCard(
        title: 'event_calendar'.tr(),
        subtitle: 'event_calendar_subtitle'.tr(),
        icon: Icons.event_repeat,
        color: Colors.deepPurple,
        animation: _animations[7],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventCalendarView()),
        ),
      ),
      FeatureCard(
        title: 'reminder'.tr(),
        subtitle: 'reminder_subtitle'.tr(),
        icon: Icons.notifications_active,
        color: Colors.amber,
        animation: _animations[8],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReminderView()),
        ),
      ),
      FeatureCard(
        title: 'routine_planner'.tr(),
        subtitle: 'routine_planner_subtitle'.tr(),
        icon: Icons.event_repeat,
        color: Colors.red,
        animation: _animations[9],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FizzBuzzView()),
        ),
      ),
      FeatureCard(
        title: 'password_generator'.tr(),
        subtitle: 'password_generator_subtitle'.tr(),
        icon: Icons.security,
        color: Colors.deepPurple,
        animation: _animations[10],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PasswordSecurityGate()),
        ),
      ),
      FeatureCard(
        title: 'text_analyzer'.tr(),
        subtitle: 'text_analyzer_subtitle'.tr(),
        icon: Icons.text_snippet,
        color: Colors.deepOrange,
        animation: _animations[11],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TextAnalyzerView()),
        ),
      ),
      FeatureCard(
        title: 'meal_plan'.tr(),
        subtitle: 'meal_plan_subtitle'.tr(),
        icon: Icons.restaurant_menu,
        color: Colors.teal,
        animation: _animations[12],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MealPlanView()),
        ),
      ),
      FeatureCard(
        title: 'mini_planner'.tr(),
        subtitle: 'mini_planner_subtitle'.tr(),
        icon: Icons.timeline,
        color: Colors.amberAccent,
        animation: _animations[13],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GanttPlannerView()),
        ),
      ),
      FeatureCard(
        title: 'number_stats'.tr(),
        subtitle: 'number_stats_subtitle'.tr(),
        icon: Icons.analytics_outlined,
        color: Colors.blue,
        animation: _animations[14],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NumberStatsView()),
        ),
      ),
      FeatureCard(
        title: 'sentence_reverser'.tr(),
        subtitle: 'sentence_reverser_subtitle'.tr(),
        icon: Icons.text_rotation_none,
        color: Colors.green,
        animation: _animations[15],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SentenceReverserView()),
        ),
      ),
      FeatureCard(
        title: 'missing_numbers'.tr(),
        subtitle: 'missing_numbers_subtitle'.tr(),
        icon: Icons.search,
        color: Colors.purple,
        animation: _animations[16],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MissingNumbersView()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Text(
            isItalian ? 'IT' : 'EN',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _toggleLanguage,
          tooltip: 'change_language'.tr(),
        ),
        title: Text('app_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ThemeSettingsView(themeProvider: widget.themeProvider),
              ),
            ),
            tooltip: 'customize_theme'.tr(),
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
            tooltip: isDarkMode ? 'light_mode'.tr() : 'dark_mode'.tr(),
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
                'smart_notebook'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'useful_tools'.tr(),
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