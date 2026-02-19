import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/onboarding_feature_item.dart';
import '../states/onboarding_page_data.dart';

/// Presenter per la schermata di onboarding.
/// Gestisce la logica di navigazione tra le pagine,
/// il completamento e la persistenza dello stato.
class OnboardingPresenter {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final PageController pageController = PageController();
  final List<OnboardingPageData> pages = _buildPages();

  int currentPage = 0;

  bool get isFirstPage => currentPage == 0;
  bool get isLastPage => currentPage == pages.length - 1;
  int get totalPages => pages.length;

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    currentPage = index;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  void dispose() {
    pageController.dispose();
  }

  /// Definizione statica di tutte le pagine dell'onboarding.
  static List<OnboardingPageData> _buildPages() {
    return const [
      // 1. Benvenuto
      OnboardingPageData(
        icon: Icons.auto_awesome,
        iconColor: Colors.amber,
        titleKey: 'ob_welcome_title',
        descriptionKey: 'ob_welcome_desc',
      ),

      // 2. Produttività
      OnboardingPageData(
        icon: Icons.task_alt,
        iconColor: Colors.orange,
        titleKey: 'ob_productivity_title',
        descriptionKey: 'ob_productivity_desc',
        features: [
          OnboardingFeatureItem(icon: Icons.checklist, color: Colors.orange, labelKey: 'ob_feat_todo'),
          OnboardingFeatureItem(icon: Icons.track_changes, color: Colors.teal, labelKey: 'ob_feat_habits'),
          OnboardingFeatureItem(icon: Icons.timeline, color: Colors.amber, labelKey: 'ob_feat_planner'),
        ],
      ),

      // 3. Shopping
      OnboardingPageData(
        icon: Icons.shopping_cart,
        iconColor: Colors.lightGreen,
        titleKey: 'ob_shopping_title',
        descriptionKey: 'ob_shopping_desc',
        features: [
          OnboardingFeatureItem(icon: Icons.shopping_cart, color: Colors.lightGreen, labelKey: 'ob_feat_shopping'),
          OnboardingFeatureItem(icon: Icons.account_balance_wallet, color: Colors.indigo, labelKey: 'ob_feat_expenses'),
        ],
      ),

      // 4. Gestione tempo
      OnboardingPageData(
        icon: Icons.schedule,
        iconColor: Colors.cyan,
        titleKey: 'ob_time_title',
        descriptionKey: 'ob_time_desc',
        features: [
          OnboardingFeatureItem(icon: Icons.timer, color: Colors.pink, labelKey: 'ob_feat_countdown'),
          OnboardingFeatureItem(icon: Icons.event_repeat, color: Colors.deepPurple, labelKey: 'ob_feat_calendar'),
          OnboardingFeatureItem(icon: Icons.notifications_active, color: Colors.amber, labelKey: 'ob_feat_reminder'),
        ],
      ),

      // 5. Utilità
      OnboardingPageData(
        icon: Icons.build_circle,
        iconColor: Colors.deepPurple,
        titleKey: 'ob_utilities_title',
        descriptionKey: 'ob_utilities_desc',
        features: [
          OnboardingFeatureItem(icon: Icons.security, color: Colors.deepPurple, labelKey: 'ob_feat_password'),
          OnboardingFeatureItem(icon: Icons.text_snippet, color: Colors.deepOrange, labelKey: 'ob_feat_text'),
          OnboardingFeatureItem(icon: Icons.restaurant_menu, color: Colors.teal, labelKey: 'ob_feat_meal'),
        ],
      ),

      // 6. Extra
      OnboardingPageData(
        icon: Icons.extension,
        iconColor: Colors.green,
        titleKey: 'ob_extras_title',
        descriptionKey: 'ob_extras_desc',
        features: [
          OnboardingFeatureItem(icon: Icons.event_repeat, color: Colors.red, labelKey: 'ob_feat_routine'),
          OnboardingFeatureItem(icon: Icons.analytics_outlined, color: Colors.blue, labelKey: 'ob_feat_numbers'),
          OnboardingFeatureItem(icon: Icons.text_rotation_none, color: Colors.green, labelKey: 'ob_feat_sentence'),
          OnboardingFeatureItem(icon: Icons.search, color: Colors.purple, labelKey: 'ob_feat_missing'),
        ],
      ),

      // 7. Personalizzazione
      OnboardingPageData(
        icon: Icons.palette,
        iconColor: Colors.pink,
        titleKey: 'ob_customize_title',
        descriptionKey: 'ob_customize_desc',
        features: [
          OnboardingFeatureItem(icon: Icons.light_mode, color: Colors.amber, labelKey: 'ob_feat_theme'),
          OnboardingFeatureItem(icon: Icons.translate, color: Colors.blue, labelKey: 'ob_feat_languages'),
          OnboardingFeatureItem(icon: Icons.accessibility_new, color: Colors.teal, labelKey: 'ob_feat_accessibility'),
        ],
      ),

      // 8. Pronti
      OnboardingPageData(
        icon: Icons.rocket_launch,
        iconColor: Colors.deepOrange,
        titleKey: 'ob_ready_title',
        descriptionKey: 'ob_ready_desc',
      ),
    ];
  }
}