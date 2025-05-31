import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import 'welcome_screen.dart';
import 'gender_screen.dart';
import 'age_screen.dart';
import 'health_screen.dart';
import 'diet_screen.dart';
import 'referral_code_screen.dart';
import 'congratulations_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/rendering.dart';

// Model for a wizard step
class WizardStep {
  final Widget Function(
    BuildContext context,
    VoidCallback onNext,
    VoidCallback? onBack,
  ) builder;
  final String? title;

  WizardStep({required this.builder, this.title});
}

class WizardHeading extends StatelessWidget {
  final String text;

  const WizardHeading({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          text.tr(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// Simplified wizard flow
final List<WizardStep> wizardFlow = [
  WizardStep(
    builder: (context, onNext, _) =>
        WelcomeContentScreen(onNext: onNext),
    title: 'Welcome',
  ),
  WizardStep(
    builder: (context, onNext, onBack) =>
        GenderScreen(
          onNext: onNext,
          onBack: onBack!,
        ),
    title: 'Gender',
  ),
  WizardStep(
    builder: (context, onNext, onBack) =>
        AgeScreen(
          onNext: onNext,
          onBack: onBack!,
        ),
    title: 'Age',
  ),
  WizardStep(
    builder: (context, onNext, onBack) =>
        HealthScreen(
          onNext: onNext,
          onBack: onBack!,
        ),
    title: 'Health',
  ),
  WizardStep(
    builder: (context, onNext, onBack) =>
        DietScreen(
          onNext: onNext,
          onBack: onBack!,
        ),
    title: 'Diet',
  ),
  WizardStep(
    builder: (context, onNext, onBack) =>
        CongratulationsScreen(
          onNext: onNext,
          onBack: onBack!,
        ),
    title: 'Complete',
  ),
  WizardStep(
    builder: (context, onNext, onBack) =>
        ReferralCodeScreen(
          onNext: onNext,
          onBack: onBack!,
        ),
    title: 'Referral',
  ),
];

// Pagination widget
class WizardPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const WizardPagination({
    required this.currentPage,
    required this.totalPages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage 
              ? (isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary)
              : Theme.of(context).colorScheme.secondary,
          ),
        );
      }),
    );
  }
}

// Language selector widget
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      case 'he':
        return '🇮🇱';
      default:
        return '🇺🇸';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      offset: const Offset(0, 56),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlagEmoji(context.locale.languageCode),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.white,
            ),
          ],
        ),
      ),
      onSelected: (String languageCode) async {
        await context.setLocale(Locale(languageCode));
        // Save selected language
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_language', languageCode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text(
                _getFlagEmoji('en'),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'language.english'.tr(),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'ru',
          child: Row(
            children: [
              Text(
                _getFlagEmoji('ru'),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'language.russian'.tr(),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'he',
          child: Row(
            children: [
              Text(
                _getFlagEmoji('he'),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'language.hebrew'.tr(),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Wizard controller widget
class WizardController extends StatefulWidget {
  const WizardController({Key? key}) : super(key: key);

  @override
  State<WizardController> createState() => _WizardControllerState();
}

class _WizardControllerState extends State<WizardController> {
  int currentStep = 0;
  late List<WizardStep> wizardFlow;

  @override
  void initState() {
    super.initState();
    _initializeWizardFlow();
  }

  void _initializeWizardFlow() {
    wizardFlow = [
      WizardStep(
        builder: (context, onNext, _) =>
            WelcomeContentScreen(onNext: onNext),
        title: 'Welcome',
      ),
      WizardStep(
        builder: (context, onNext, onBack) =>
            GenderScreen(
              onNext: onNext,
              onBack: onBack!,
            ),
        title: 'Gender',
      ),
      WizardStep(
        builder: (context, onNext, onBack) =>
            AgeScreen(
              onNext: onNext,
              onBack: onBack!,
            ),
        title: 'Age',
      ),
      WizardStep(
        builder: (context, onNext, onBack) =>
            HealthScreen(
              onNext: onNext,
              onBack: onBack!,
            ),
        title: 'Health',
      ),
      WizardStep(
        builder: (context, onNext, onBack) =>
            DietScreen(
              onNext: onNext,
              onBack: onBack!,
            ),
        title: 'Diet',
      ),
      WizardStep(
        builder: (context, onNext, onBack) =>
            CongratulationsScreen(
              onNext: onNext,
              onBack: onBack!,
            ),
        title: 'Complete',
      ),
      WizardStep(
        builder: (context, onNext, onBack) =>
            ReferralCodeScreen(
              onNext: onNext,
              onBack: onBack!,
            ),
        title: 'Referral',
      ),
    ];
  }

  Future<void> nextStep() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 30);
    }
    if (currentStep < wizardFlow.length - 1) {
      setState(() => currentStep++);
    } else {
      // Navigate to main app
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = wizardFlow[currentStep];
    final isLastStep = currentStep == wizardFlow.length - 1;
    final isWelcomeStep = currentStep == 0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full screen image with overlay for dark mode
        if (!isLastStep) // Don't show background image on completion screen
          Stack(
            children: [
              Image.asset(
                'images/main.jpg',
                fit: BoxFit.cover,
              ),
            ],
          ),
        // Back button and language selector
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isWelcomeStep && !isLastStep)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: isDarkMode ? Colors.white : Colors.white,
                      ),
                      onPressed: previousStep,
                    )
                  else
                    const SizedBox(width: 48), // Placeholder for alignment
                  if (!isLastStep) const LanguageSelector(),
                ],
              ),
            ),
          ),
        ),
        // Wizard content in bottom half
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: isLastStep ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.6,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: isLastStep ? null : const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                if (!isLastStep)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      // Step content
                      Expanded(
                        child: step.builder(
                          context,
                          nextStep,
                          currentStep == 0 ? null : previousStep,
                        ),
                      ),
                      // Navigation area
                      if (!isLastStep && currentStep != wizardFlow.length - 2)  // Don't show navigation on last and congratulations screens
                        SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Next/Get Started button
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: nextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                    child: Text(
                                      'wizard.next'.tr(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Dot navigation
                              WizardPagination(
                                currentPage: currentStep,
                                totalPages: wizardFlow.length - 1, // Don't count completion screen in dots
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

