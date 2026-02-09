import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_notes/screens/home_view.dart';
import 'package:smart_notes/theme/theme_provider.dart';
import '../controllers/onboarding_presenter.dart';
import '../widget/onboarding/onboarding_page.dart';

/// Schermata di onboarding mostrata al primo avvio dell'app.
/// Può essere richiamata dalla HomeView con [isRevisit] = true.
class OnboardingView extends StatefulWidget {
  final ThemeProvider themeProvider;

  /// Se true, mostra "Chiudi" anziché "Iniziamo!" e fa pop() alla fine.
  final bool isRevisit;

  const OnboardingView({
    super.key,
    required this.themeProvider,
    this.isRevisit = false,
  });

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final OnboardingPresenter _presenter = OnboardingPresenter();

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!widget.isRevisit) {
      await _presenter.completeOnboarding();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeView(themeProvider: widget.themeProvider),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip (solo al primo avvio)
            if (!widget.isRevisit)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'ob_skip'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 16),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _presenter.pageController,
                itemCount: _presenter.totalPages,
                onPageChanged: (index) {
                  _presenter.onPageChanged(index);
                  setState(() {});
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _presenter.pages[index]);
                },
              ),
            ),

            // Indicatori a pallino
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_presenter.totalPages, (index) {
                  final isActive = index == _presenter.currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? primaryColor
                          : primaryColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Pulsanti navigazione
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  // Indietro
                  if (!_presenter.isFirstPage)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _presenter.previousPage,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text('ob_back'.tr()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),

                  if (!_presenter.isFirstPage) const SizedBox(width: 16),

                  // Avanti / Fine
                  Expanded(
                    flex: _presenter.isFirstPage ? 2 : 1,
                    child: ElevatedButton.icon(
                      onPressed: _presenter.isLastPage
                          ? _completeOnboarding
                          : _presenter.nextPage,
                      icon: Icon(
                        _presenter.isLastPage
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                      label: Text(
                        _presenter.isLastPage
                            ? (widget.isRevisit
                            ? 'ob_close'.tr()
                            : 'ob_finish'.tr())
                            : 'ob_next'.tr(),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}