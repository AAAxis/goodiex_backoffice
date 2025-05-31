import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../meal_analysis.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class WelcomeSection extends StatefulWidget {
  final String userName;
  final String currentMealTime;
  final List<Meal> meals;
  final double dailyCalories;
  final double caloriesGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatsGoal;
  final Map<String, double> macros;
  final Function() onTap;
  final List<DateTime> days;
  final DateTime? selectedDay;
  final ValueChanged<DateTime?> onDaySelected;

  const WelcomeSection({
    Key? key,
    required this.userName,
    required this.currentMealTime,
    required this.meals,
    required this.dailyCalories,
    required this.caloriesGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatsGoal,
    required this.macros,
    required this.onTap,
    required this.days,
    required this.selectedDay,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  State<WelcomeSection> createState() => _WelcomeSectionState();
}

class _WelcomeSectionState extends State<WelcomeSection>
    with TickerProviderStateMixin {
  late AnimationController _fireAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _cardTransitionController;
  late Animation<double> _fireScaleAnimation;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _cardTransitionAnimation;

  // Add PageView controller and stats
  PageController _pageController = PageController();
  int _currentCardIndex = 0;
  Timer? _autoScrollTimer;
  bool _autoScrollEnabled = true; // Add flag to control auto-scroll
  late Future<Map<String, dynamic>> _statsFuture;

  // Default stats values
  final Map<String, dynamic> _defaultStats = {
    'steps': 8000,
    'sleep_hours': 7.5,
  };

  @override
  void initState() {
    super.initState();

    // Initialize stats future
    _statsFuture = _fetchStatsFromPrefs();

    // Fire icon animation (pulsing effect)
    _fireAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fireScaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _fireAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Card entrance animation
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Progress animation
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeOutCirc,
      ),
    );

    // Card transition animation for switching between cards
    _cardTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _cardTransitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardTransitionController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _fireAnimationController.repeat(reverse: true);
    _cardAnimationController.forward();
    _progressAnimationController.forward();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _pageController.hasClients && _autoScrollEnabled) {
        final nextIndex = (_currentCardIndex + 1) % 4;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _disableAutoScroll() {
    setState(() {
      _autoScrollEnabled = false;
    });
    // Optional: Re-enable after 10 seconds of inactivity
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _autoScrollEnabled = true;
        });
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentCardIndex = index;
    });
    // Disable auto-scroll when user manually swipes
    _disableAutoScroll();
    // Trigger card transition animation
    _cardTransitionController.forward().then((_) {
      _cardTransitionController.reset();
    });
  }

  @override
  void dispose() {
    _fireAnimationController.dispose();
    _cardAnimationController.dispose();
    _progressAnimationController.dispose();
    _cardTransitionController.dispose();
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchStatsFromPrefs() async {
    try {
      print('Fetching stats from prefs...');
      final prefs = await SharedPreferences.getInstance();
      print('Prefs loaded');

      // Safe parsing with fallbacks
      int steps = _defaultStats['steps'] as int;
      double sleepHours = _defaultStats['sleep_hours'] as double;

      try {
        dynamic stepsValue = prefs.get('steps');
        if (stepsValue is int) {
          steps = stepsValue;
        } else if (stepsValue is String) {
          steps = int.tryParse(stepsValue) ?? _defaultStats['steps'] as int;
        }
      } catch (e) {
        print('Error parsing steps: $e');
      }

      try {
        final sleepValue = prefs.getDouble('sleep_hours');
        if (sleepValue != null) {
          sleepHours = sleepValue;
        }
      } catch (e) {
        print('Error parsing sleep_hours: $e');
      }

      return {'steps': steps, 'sleep_hours': sleepHours};
    } catch (e) {
      print('Error in _fetchStatsFromPrefs: $e');
      // Return default values on any error
      return _defaultStats;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use default values if meals is empty
    final caloriesRemaining = widget.caloriesGoal - widget.dailyCalories;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final surfaceColor = isDark ? Color(0xFF121212) : Color(0xFFF5F5F5);

    // Modern Material Design layout
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker with modern styling
          Container(
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.only(bottom: 24),
            child: DayPicker(
              days: widget.days,
              selectedDay: widget.selectedDay,
              onDaySelected: widget.onDaySelected,
            ),
          ),

          // Main stats card with vertical PageView
          AnimatedBuilder(
            animation: _cardSlideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - _cardSlideAnimation.value)),
                child: Opacity(
                  opacity: _cardSlideAnimation.value,
                  child: Container(
                    height: 168,
                    child: Stack(
                      children: [
                        // Vertical PageView
                        GestureDetector(
                          onTap: _disableAutoScroll,
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _statsFuture,
                            builder: (context, snapshot) {
                              Map<String, dynamic> stats = _defaultStats;

                              if (snapshot.hasData) {
                                stats = snapshot.data!;
                              } else if (snapshot.hasError) {
                                print('Error loading stats: ${snapshot.error}');
                              }

                              return AnimatedBuilder(
                                animation: _cardTransitionAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        1.0 -
                                        (0.05 * _cardTransitionAnimation.value),
                                    child: PageView(
                                      controller: _pageController,
                                      scrollDirection: Axis.vertical,
                                      onPageChanged: _onPageChanged,
                                      children: [
                                        _buildCaloriesCard(
                                          caloriesRemaining,
                                          widget.caloriesGoal,
                                          cardColor,
                                          textColor,
                                          subTextColor,
                                          isDark,
                                        ),
                                        _buildStepsCard(
                                          stats['steps'] as int,
                                          cardColor,
                                          textColor,
                                          subTextColor,
                                          isDark,
                                        ),
                                        _buildSleepCard(
                                          stats['sleep_hours'] as double,
                                          cardColor,
                                          textColor,
                                          subTextColor ??
                                              (isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600]),
                                          isDark,
                                        ),
                                        _buildMacrosCard(
                                          widget.macros,
                                          widget.proteinGoal,
                                          widget.carbsGoal,
                                          widget.fatsGoal,
                                          cardColor,
                                          textColor,
                                          subTextColor,
                                          isDark,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // Page indicators
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                width: 6,
                                height: _currentCardIndex == index ? 20 : 6,
                                decoration: BoxDecoration(
                                  color:
                                      _currentCardIndex == index
                                          ? (isDark
                                              ? Colors.white
                                              : Colors.black)
                                          : (isDark
                                              ? Colors.grey[600]
                                              : Colors.grey[400]),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Removed the old macro cards section - now integrated into PageView above
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(
    double caloriesRemaining,
    double caloriesGoal,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    bool isDark,
  ) {
    return Card(
      elevation: isDark ? 0 : 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isDark
                ? BorderSide(color: Colors.grey[800]!, width: 1)
                : BorderSide.none,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Left side - Calories info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caloriesRemaining >= 0
                        ? 'dashboard.calories_remaining'.tr()
                        : 'dashboard.over_goal'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          subTextColor ??
                          (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0, end: caloriesRemaining.abs()),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Right side - Animated Progress indicator
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        final targetProgress =
                            caloriesGoal > 0
                                ? ((caloriesGoal - caloriesRemaining) /
                                        caloriesGoal)
                                    .clamp(0.0, 1.0)
                                : 0.0;
                        return SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: targetProgress * _progressAnimation.value,
                            strokeWidth: 6,
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              caloriesRemaining >= 0
                                  ? (isDark
                                      ? Colors.green[400]!
                                      : Colors.green[600]!)
                                  : (isDark
                                      ? Colors.orange[400]!
                                      : Colors.orange[600]!),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _fireScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _fireScaleAnimation.value,
                          child: Icon(
                            Icons.local_fire_department,
                            size: 28,
                            color:
                                caloriesRemaining >= 0
                                    ? (isDark
                                        ? Colors.green[400]
                                        : Colors.green[600])
                                    : (isDark
                                        ? Colors.orange[400]
                                        : Colors.orange[600]),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard(
    int steps,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    bool isDark,
  ) {
    const int stepsGoal = 10000;
    final stepsPercent = (steps / stepsGoal).clamp(0.0, 1.0);

    return Card(
      elevation: isDark ? 0 : 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isDark
                ? BorderSide(color: Colors.grey[800]!, width: 1)
                : BorderSide.none,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Left side - Steps info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboard.steps_today'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          subTextColor ??
                          (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<int>(
                    duration: const Duration(milliseconds: 1200),
                    tween: IntTween(begin: 0, end: steps),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Right side - Animated Progress indicator
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: stepsPercent * _progressAnimation.value,
                            strokeWidth: 6,
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              steps >= stepsGoal
                                  ? (isDark
                                      ? Colors.green[400]!
                                      : Colors.green[600]!)
                                  : (isDark
                                      ? Colors.blue[400]!
                                      : Colors.blue[600]!),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _fireScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _fireScaleAnimation.value,
                          child: Icon(
                            Icons.directions_walk,
                            size: 28,
                            color:
                                steps >= stepsGoal
                                    ? (isDark
                                        ? Colors.green[400]
                                        : Colors.green[600])
                                    : (isDark
                                        ? Colors.blue[400]
                                        : Colors.blue[600]),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard(
    double sleepHours,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    bool isDark,
  ) {
    const double sleepGoal = 8.0;
    final sleepPercent = (sleepHours / sleepGoal).clamp(0.0, 1.0);

    return Card(
      elevation: isDark ? 0 : 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isDark
                ? BorderSide(color: Colors.grey[800]!, width: 1)
                : BorderSide.none,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Left side - Sleep info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboard.sleep_last_night'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          subTextColor ??
                          (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1400),
                    tween: Tween(begin: 0.0, end: sleepHours),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '${value.toStringAsFixed(1)}h',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Right side - Animated Progress indicator
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: sleepPercent * _progressAnimation.value,
                            strokeWidth: 6,
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.red[400]! : Colors.red[600]!,
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _fireScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _fireScaleAnimation.value,
                          child: Icon(
                            Icons.bedtime,
                            size: 28,
                            color:
                                isDark
                                    ? Colors.red[400]
                                    : Colors.red[600],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosCard(
    Map<String, double> macros,
    double proteinGoal,
    double carbsGoal,
    double fatsGoal,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    bool isDark,
  ) {
    final protein = macros['proteins'] ?? 0;
    final carbs = macros['carbs'] ?? 0;
    final fats = macros['fats'] ?? 0;

    final proteinRemaining = proteinGoal - protein;
    final carbsRemaining = carbsGoal - carbs;
    final fatsRemaining = fatsGoal - fats;

    final proteinPercent =
        proteinGoal > 0 ? (protein / proteinGoal).clamp(0.0, 1.0) : 0.0;
    final carbsPercent =
        carbsGoal > 0 ? (carbs / carbsGoal).clamp(0.0, 1.0) : 0.0;
    final fatsPercent = fatsGoal > 0 ? (fats / fatsGoal).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: isDark ? 0 : 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isDark
                ? BorderSide(color: Colors.grey[800]!, width: 1)
                : BorderSide.none,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Protein
            _buildMacroLinearProgress(
              label: 'dashboard.protein'.tr(),
              value: protein,
              goal: proteinGoal,
              color: isDark ? Colors.red[400]! : Colors.red[600]!,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            // Carbs
            _buildMacroLinearProgress(
              label: 'dashboard.carbs'.tr(),
              value: carbs,
              goal: carbsGoal,
              color: isDark ? Colors.blue[400]! : Colors.blue[600]!,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            // Fats
            _buildMacroLinearProgress(
              label: 'dashboard.fats'.tr(),
              value: fats,
              goal: fatsGoal,
              color: isDark ? Colors.green[400]! : Colors.green[600]!,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroLinearProgress({
    required String label,
    required double value,
    required double goal,
    required Color color,
    required bool isDark,
  }) {
    final percent = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;
    final percentageText = '${(percent * 100).toStringAsFixed(0)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            Text(
              percentageText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: percent * _progressAnimation.value,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            );
          },
        ),
      ],
    );
  }
}

class DayPicker extends StatelessWidget {
  final List<DateTime> days;
  final DateTime? selectedDay;
  final ValueChanged<DateTime?> onDaySelected;

  const DayPicker({
    Key? key,
    required this.days,
    required this.selectedDay,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBgColor = isDark ? Colors.grey[800] : Colors.grey[300];
    final unselectedBgColor = isDark ? Colors.grey[900] : Colors.white;
    final selectedTextColor = Colors.white;
    final unselectedTextColor = isDark ? Colors.white70 : Colors.black;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          days.map((date) {
            final dayIndex = (date.weekday - 1) % 7; // Safety check
            final dayName = dayNames[dayIndex];
            final isSelected =
                selectedDay != null &&
                date.year == selectedDay!.year &&
                date.month == selectedDay!.month &&
                date.day == selectedDay!.day;
            final firstLetter = dayName.isNotEmpty ? dayName[0] : '';
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2.0,
                ), // Reduced from 4.0 to 2.0
                child: InkWell(
                  onTap: () {
                    onDaySelected(isSelected ? null : date);
                  },
                  borderRadius: BorderRadius.circular(18), // More pill-like
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? selectedBgColor : unselectedBgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.grey[700]!
                                : (isSelected
                                    ? Colors.grey[400]!
                                    : Colors.grey[300]!),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      DateFormat('d').format(date),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isDark
                                ? (isSelected ? Colors.white : Colors.grey[300])
                                : (isSelected ? Colors.white : Colors.black),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
