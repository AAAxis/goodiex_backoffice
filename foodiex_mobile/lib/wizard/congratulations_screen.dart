import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'wizard_flow.dart';

class CongratulationsScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const CongratulationsScreen({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  Map<String, dynamic> _userData = {};
  Map<String, double> _nutritionGoals = {
    'calories': 2289.0,
    'protein': 172.0,
    'carbs': 245.0,
    'fats': 89.0,
  };

  @override
  void initState() {
    super.initState();
    _calculateInBackground();
  }

  double _calculateBMR(String gender, int age, double weight, double height) {
    // Mifflin-St Jeor Equation
    if (gender.toLowerCase().contains('male') && !gender.toLowerCase().contains('female')) {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  Future<void> _calculateInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load all collected data
      _userData = {
        'gender': prefs.getString('gender') ?? 'wizard.gender_male',
        'age': prefs.getInt('age') ?? 25,
        'steps': prefs.getString('steps') ?? '5000',
        'sleep_hours': prefs.getDouble('sleep_hours') ?? 8.0,
        'height_health': prefs.getDouble('height_health') ?? 170.0,
        'weight_health': prefs.getDouble('weight_health') ?? 70.0,
        'dietType': prefs.getString('dietType') ?? 'wizard.diet_classic',
      };

      // Calculate BMR and nutrition goals
      final bmr = _calculateBMR(
        _userData['gender'],
        _userData['age'],
        _userData['weight_health'],
        _userData['height_health'],
      );

      // Calculate daily calorie needs (using moderate activity multiplier 1.55)
      final dailyCalories = bmr * 1.55;

      // Calculate macros based on diet type
      double proteinRatio = 0.3; // 30% of calories from protein
      double carbsRatio = 0.4;   // 40% of calories from carbs
      double fatsRatio = 0.3;    // 30% of calories from fats

      // Adjust ratios based on diet type
      if (_userData['dietType'] == 'wizard.diet_keto') {
        carbsRatio = 0.05;    // 5% carbs
        proteinRatio = 0.35;  // 35% protein
        fatsRatio = 0.60;     // 60% fats
      }

      final newNutritionGoals = {
        'calories': dailyCalories,
        'protein': (dailyCalories * proteinRatio) / 4, // 4 calories per gram of protein
        'carbs': (dailyCalories * carbsRatio) / 4,     // 4 calories per gram of carbs
        'fats': (dailyCalories * fatsRatio) / 9,       // 9 calories per gram of fat
      };

      // Save nutrition goals
      await prefs.setDouble('daily_calories', newNutritionGoals['calories']!);
      await prefs.setDouble('daily_protein', newNutritionGoals['protein']!);
      await prefs.setDouble('daily_carbs', newNutritionGoals['carbs']!);
      await prefs.setDouble('daily_fats', newNutritionGoals['fats']!);

      // Update state if widget is still mounted
      if (mounted) {
        setState(() {
          _nutritionGoals = newNutritionGoals;
        });
      }
    } catch (e) {
      print('Error calculating nutrition goals: $e');
      // Keep default values if calculation fails
    }
  }

  Widget _buildNutritionCard(String label, String value, Widget icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 16),
          Text(
            'common.$label'.tr().toLowerCase(),
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: value.split(' ').map((part) => 
              Text(
                part,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  decoration: TextDecoration.none,
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image with dark overlay for dark mode
        Stack(
          children: [
            Image.asset(
              'images/main.jpg',
              fit: BoxFit.cover,
            ),
            if (isDarkMode)
              Container(
                color: Colors.black.withOpacity(0.5),
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
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: widget.onBack,
                  ),
                  const LanguageSelector(),
                ],
              ),
            ),
          ),
        ),
        // Bottom sheet content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'wizard.setup_complete'.tr(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 180,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                _buildNutritionCard(
                                  'calories',
                                  '${_nutritionGoals['calories']?.round() ?? 0} kcal',
                                  Icon(
                                    Icons.local_fire_department,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    size: 28,
                                  ),
                                ),
                                _buildNutritionCard(
                                  'protein',
                                  '${_nutritionGoals['protein']?.round() ?? 0}g',
                                  Icon(
                                    Icons.fitness_center,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                ),
                                _buildNutritionCard(
                                  'carbs',
                                  '${_nutritionGoals['carbs']?.round() ?? 0}g',
                                  Icon(
                                    Icons.grain,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                ),
                                _buildNutritionCard(
                                  'fats',
                                  '${_nutritionGoals['fats']?.round() ?? 0}g',
                                  Icon(
                                    Icons.water_drop,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      'wizard.next'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
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