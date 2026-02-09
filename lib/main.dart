import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_notes/screens/home_view.dart';
import 'package:smart_notes/screens/onboarding_view.dart';
import 'package:smart_notes/screens/password_generator_view.dart';
import 'package:smart_notes/screens/pin_setup_view.dart';
import 'package:smart_notes/screens/pin_unlock_view.dart';
import 'package:smart_notes/theme/theme_config.dart';
import 'package:smart_notes/theme/theme_provider.dart';
import 'data/alarm_background_service.dart';
import 'data/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';

late final bool onboardingCompleted;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NotificationService().initialize();
  await AlarmBackgroundService.initialize();

  // Leggi lo stato dell'onboarding prima di avviare l'app
  final prefs = await SharedPreferences.getInstance();
  onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  if (kDebugMode) {
    print('✅ AlarmBackgroundService initialized');
    print('📋 Onboarding completed: $onboardingCompleted');
  }
  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en', 'US'),
      Locale('it', 'IT'),
      Locale('zh', 'CN'),
      Locale('tr', 'TR'),
      Locale('ar', 'SA'),
      Locale('fr', 'FR'),
      Locale('de', 'DE'),
      Locale('es', 'ES'),
      Locale('ru', 'RU'),
    ],
    path: 'assets/translations',
    fallbackLocale: const Locale('en', 'US'),
    startLocale: const Locale('en', 'US'),
    saveLocale: true,
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
          child: Builder(
            builder: (context) {
              final filter = _themeProvider.activeColorFilter;
              Widget app = MaterialApp(
                title: 'SmartNotes',
                theme: AppTheme.lightTheme(_themeProvider.primaryColor),
                darkTheme: AppTheme.darkTheme(_themeProvider.primaryColor),
                themeMode: _themeProvider.themeMode,
                home: onboardingCompleted
                    ? HomeView(themeProvider: _themeProvider)
                    : OnboardingView(themeProvider: _themeProvider),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                routes: {
                  '/pin_setup': (context) => const PinSetupView(),
                  '/pin_unlock': (context) => const PinUnlockView(),
                  '/password_generator': (context) => const PasswordGeneratorView(),
                },
              );

              if (filter != null) {
                app = ColorFiltered(
                  colorFilter: filter,
                  child: app,
                );
              }

              return app;
            },
          ),
        );
      },
    );
  }
}