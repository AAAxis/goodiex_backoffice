import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomeContentScreen extends StatefulWidget {
  final VoidCallback onNext;

  const WelcomeContentScreen({Key? key, required this.onNext})
    : super(key: key);

  @override
  State<WelcomeContentScreen> createState() => _WelcomeContentScreenState();
}

class _WelcomeContentScreenState extends State<WelcomeContentScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 48.0, bottom: 16.0),
            child: Text(
              'wizard.welcome_title'.tr(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle without animation
          Text(
            'wizard.welcome_subtitle'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
