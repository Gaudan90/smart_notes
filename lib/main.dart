import 'package:flutter/material.dart';
import 'package:smart_notes/screens/home_view.dart';
import 'package:smart_notes/theme/theme_config.dart';
import 'package:smart_notes/theme/theme_provider.dart';
import 'data/alarm_background_service.dart';
import 'data/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NotificationService().initialize();
  await AlarmBackgroundService.initialize();
  print('✅ AlarmBackgroundService initialized');
  runApp(EasyLocalization(
    supportedLocales: const [Locale('it', 'IT'), Locale('en', 'US')],
    path: 'assets/translations',
    fallbackLocale: const Locale('it', 'IT'),
    child: const MyApp(),
  ),);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  final ThemeProvider _themeProvider = ThemeProvider();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _themeProvider.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    _animationController.forward(from: 0.7);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeProvider,
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: MaterialApp(
            title: 'SmartNotes',
            theme: AppTheme.lightTheme(_themeProvider.primaryColor),
            darkTheme: AppTheme.darkTheme(_themeProvider.primaryColor),
            themeMode: _themeProvider.themeMode,
            home: HomeView(themeProvider: _themeProvider),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          ),
        );
      },
    );
  }
}