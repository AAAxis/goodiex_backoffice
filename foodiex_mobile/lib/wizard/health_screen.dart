import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vibration/vibration.dart';
import 'wizard_flow.dart';

class HealthScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const HealthScreen({Key? key, required this.onNext, required this.onBack}) : super(key: key);

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  // bool _isHealthConnected = false; // Keep if Apple Health sync is still desired
  String _stepsValue = _defaultSteps;
  double _sleepHours = _defaultSleep;
  double _heightValue = _defaultHeight;
  double _weightValue = _defaultWeight;

  static const String _defaultSteps = '5000';
  static const double _defaultSleep = 8.0;
  static const double _defaultHeight = 170.0; // cm
  static const double _defaultWeight = 70.0; // kg

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _stepsValue = prefs.getString('steps') ?? _defaultSteps;
        _sleepHours = prefs.getDouble('sleep_hours') ?? _defaultSleep;
        _heightValue = prefs.getDouble('height_health') ?? _defaultHeight;
        _weightValue = prefs.getDouble('weight_health') ?? _defaultWeight;
      });
      // Save defaults if not set
      if (prefs.getString('steps') == null) {
        await prefs.setString('steps', _defaultSteps);
      }
      if (prefs.getDouble('sleep_hours') == null) {
        await prefs.setDouble('sleep_hours', _defaultSleep);
      }
      if (prefs.getDouble('height_health') == null) {
        await prefs.setDouble('height_health', _defaultHeight);
      }
      if (prefs.getDouble('weight_health') == null) {
        await prefs.setDouble('weight_health', _defaultWeight);
      }
    } catch (e) {
      print('Error loading health data: $e');
      // Show error to user if appropriate
    }
  }

  Future<void> _saveHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('steps', _stepsValue);
      await prefs.setDouble('sleep_hours', _sleepHours);
      await prefs.setDouble('height_health', _heightValue);
      await prefs.setDouble('weight_health', _weightValue);
      print('Successfully saved health data');
      if (mounted) {
        // showSuccess('Health data saved!'); // Optional success message
      }
    } catch (e) {
      print('Error saving health data: $e');
      if (mounted) {
        showError('Error saving health data');
      }
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

  Widget _buildHealthRow(String label, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () => _showEditDialog(label.startsWith('wizard.') ? label : 'wizard.$label'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 16),
                Text(
                  label.tr(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String metric) {
    String tempSteps = _stepsValue;
    double tempSleep = _sleepHours;
    double tempHeight = _heightValue;
    double tempWeight = _weightValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget buildSlider() {
              switch (metric) {
                case 'wizard.steps':
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${double.tryParse(tempSteps)?.round() ?? 0} ${'wizard.steps'.tr()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.green.shade600,
                          inactiveTrackColor: Colors.green.shade200,
                          thumbColor: Colors.green.shade700,
                          overlayColor: Colors.green.withOpacity(0.2),
                          trackHeight: 4.0,
                        ),
                        child: Slider(
                          value: double.tryParse(tempSteps)?.clamp(0, 30000) ?? 0,
                          min: 0,
                          max: 30000,
                          divisions: 300,
                          onChanged: (value) {
                            setState(() {
                              tempSteps = value.round().toString();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                case 'wizard.sleep':
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${tempSleep.toStringAsFixed(1)} ${'wizard.hours'.tr()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.blue.shade600,
                          inactiveTrackColor: Colors.blue.shade200,
                          thumbColor: Colors.blue.shade700,
                          overlayColor: Colors.blue.withOpacity(0.2),
                          trackHeight: 4.0,
                        ),
                        child: Slider(
                          value: tempSleep.clamp(0, 16),
                          min: 0,
                          max: 16,
                          divisions: 160,
                          onChanged: (value) {
                            setState(() {
                              tempSleep = value;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                case 'wizard.height':
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${tempHeight.round()} ${'wizard.cm'.tr()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.orange.shade600,
                          inactiveTrackColor: Colors.orange.shade200,
                          thumbColor: Colors.orange.shade700,
                          overlayColor: Colors.orange.withOpacity(0.2),
                          trackHeight: 4.0,
                        ),
                        child: Slider(
                          value: tempHeight.clamp(100, 250),
                          min: 100,
                          max: 250,
                          divisions: 150,
                          onChanged: (value) {
                            setState(() {
                              tempHeight = value;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                case 'wizard.weight':
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${tempWeight.toStringAsFixed(1)} ${'wizard.kg'.tr()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.red.shade600,
                          inactiveTrackColor: Colors.red.shade200,
                          thumbColor: Colors.red.shade700,
                          overlayColor: Colors.red.withOpacity(0.2),
                          trackHeight: 4.0,
                        ),
                        child: Slider(
                          value: tempWeight.clamp(30, 200),
                          min: 30,
                          max: 200,
                          divisions: 340,
                          onChanged: (value) {
                            setState(() {
                              tempWeight = value;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                default:
                  return const SizedBox.shrink();
              }
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                metric.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: buildSlider(),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'wizard.cancel'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(
                    'wizard.save'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    if (await Vibration.hasVibrator() ?? false) {
                      Vibration.vibrate(duration: 30);
                    }
                    switch (metric) {
                      case 'wizard.steps':
                        _stepsValue = tempSteps;
                        break;
                      case 'wizard.sleep':
                        _sleepHours = tempSleep;
                        break;
                      case 'wizard.height':
                        _heightValue = tempHeight;
                        break;
                      case 'wizard.weight':
                        _weightValue = tempWeight;
                        break;
                    }
                    await _saveHealthData();
                    if (mounted) {
                      setState(() {});
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const WizardHeading(
            text: 'wizard.connect_health',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom - 
                    120, // Approximate height of WizardHeading
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Theme.of(context).cardColor : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHealthRow(
                              'wizard.steps',
                              '$_stepsValue ${'wizard.steps'.tr()}',
                              Icons.directions_walk_rounded,
                              Colors.green.shade600,
                            ),
                            _buildHealthRow(
                              'wizard.sleep',
                              '${_sleepHours.toStringAsFixed(1)} ${'wizard.hours'.tr()}',
                              Icons.bedtime_rounded,
                              Colors.blue.shade600,
                            ),
                            _buildHealthRow(
                              'wizard.height',
                              '${_heightValue.round()} ${'wizard.cm'.tr()}',
                              Icons.height_rounded,
                              Colors.orange.shade600,
                            ),
                            _buildHealthRow(
                              'wizard.weight',
                              '${_weightValue.toStringAsFixed(1)} ${'wizard.kg'.tr()}',
                              Icons.monitor_weight_rounded,
                              Colors.red.shade600,
                            ),
                          ],
                        ),
                      ),
                      if (Platform.isIOS)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.ios_share, color: Colors.black),
                            label: Text(
                              'wizard.connect_apple_health'.tr(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final health = Health();
                                const types = [
                                  HealthDataType.STEPS,
                                  HealthDataType.SLEEP_IN_BED,
                                  HealthDataType.HEIGHT,
                                  HealthDataType.WEIGHT,
                                ];

                                const permissions = [
                                  HealthDataAccess.READ,
                                  HealthDataAccess.READ,
                                  HealthDataAccess.READ,
                                  HealthDataAccess.READ,
                                ];

                                final bool authorized = await health.requestAuthorization(
                                  types,
                                  permissions: permissions,
                                );

                                if (authorized) {
                                  final now = DateTime.now();
                                  // Get steps
                                  final stepsData = await health.getHealthDataFromTypes(
                                    types: [HealthDataType.STEPS],
                                    startTime: now.subtract(const Duration(days: 1)),
                                    endTime: now,
                                  );
                                  double totalSteps = 0;
                                  for (final entry in stepsData) {
                                    final value = entry.value is NumericHealthValue
                                        ? (entry.value as NumericHealthValue).numericValue
                                        : 0.0;
                                    totalSteps += value;
                                  }
                                  if (totalSteps > 0) {
                                    setState(() {
                                      _stepsValue = totalSteps.round().toString();
                                    });
                                  }

                                  // Get sleep
                                  final sleepData = await health.getHealthDataFromTypes(
                                    types: [HealthDataType.SLEEP_IN_BED],
                                    startTime: now.subtract(const Duration(days: 1)),
                                    endTime: now,
                                  );
                                  double totalSleepSeconds = 0;
                                  for (final entry in sleepData) {
                                    final value = entry.value is NumericHealthValue
                                        ? (entry.value as NumericHealthValue).numericValue
                                        : 0.0;
                                    totalSleepSeconds += value;
                                  }
                                  if (totalSleepSeconds > 0) {
                                    setState(() {
                                      _sleepHours = (totalSleepSeconds / 3600).clamp(0, 16).toDouble();
                                    });
                                  }

                                  // Get height
                                  final heightData = await health.getHealthDataFromTypes(
                                    types: [HealthDataType.HEIGHT],
                                    startTime: now.subtract(const Duration(days: 365 * 10)),
                                    endTime: now,
                                  );
                                  if (heightData.isNotEmpty) {
                                    final latestHeight = heightData
                                        .where((d) => d.value is NumericHealthValue)
                                        .lastOrNull
                                        ?.value as NumericHealthValue?;
                                    if (latestHeight != null && latestHeight.numericValue > 0) {
                                      setState(() {
                                        _heightValue = (latestHeight.numericValue * 100).toDouble();
                                      });
                                    }
                                  }

                                  // Get weight
                                  final weightData = await health.getHealthDataFromTypes(
                                    types: [HealthDataType.WEIGHT],
                                    startTime: now.subtract(const Duration(days: 90)),
                                    endTime: now,
                                  );
                                  if (weightData.isNotEmpty) {
                                    final latestWeight = weightData
                                        .where((d) => d.value is NumericHealthValue)
                                        .lastOrNull
                                        ?.value as NumericHealthValue?;
                                    if (latestWeight != null && latestWeight.numericValue > 0) {
                                      setState(() {
                                        _weightValue = latestWeight.numericValue.toDouble();
                                      });
                                    }
                                  }

                                  await _saveHealthData();
                                } else {
                                  showError('wizard.health_permissions_not_granted'.tr());
                                }
                              } catch (e) {
                                print('Error connecting to Apple Health: $e');
                                showError('wizard.health_connect_error'.tr());
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              side: const BorderSide(color: Colors.black, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 