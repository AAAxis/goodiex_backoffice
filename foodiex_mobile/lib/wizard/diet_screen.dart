import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'wizard_flow.dart';

class DietScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const DietScreen({Key? key, required this.onNext, required this.onBack}) : super(key: key);

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  String? selectedDietType;

  @override
  void initState() {
    super.initState();
    _loadDietType();
  }

  Future<void> _loadDietType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dietType = prefs.getString('dietType');
      if (dietType != null) {
        setState(() {
          selectedDietType = dietType;
        });
      } else {
        const defaultDiet = 'wizard.diet_classic';
        setState(() {
          selectedDietType = defaultDiet;
        });
        // Save the default dietType to shared preferences
        await prefs.setString('dietType', defaultDiet);
      }
    } catch (e) {
      print('Error loading diet type: $e');
    }
  }

  Future<void> _saveDietType(String dietType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('Saving diet type: $dietType');
      await prefs.setString('dietType', dietType);
      print('Diet type saved successfully');
    } catch (e) {
      print('Error saving diet type: $e');
      showError('Error saving diet type');
    }
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDietOption(String dietKey, IconData icon) {
    final isSelected = selectedDietType == dietKey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          await _saveDietType(dietKey);
          if (mounted) {
            setState(() {
              selectedDietType = dietKey;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Theme.of(context).cardColor : const Color(0xFFF8F7FC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected 
                ? (isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary)
                : Colors.transparent,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Text(
                dietKey.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 48.0, bottom: 16.0),
            child: Text(
              'wizard.select_diet'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDietOption('wizard.diet_classic', Icons.restaurant),
                    _buildDietOption('wizard.diet_keto', Icons.local_fire_department),
                    _buildDietOption('wizard.diet_vegan', Icons.eco),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 