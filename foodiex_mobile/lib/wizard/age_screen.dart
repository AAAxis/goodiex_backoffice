import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'wizard_flow.dart';

class AgeScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const AgeScreen({Key? key, required this.onNext, required this.onBack}) : super(key: key);

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  int age = 25;
  final int minAge = 10;
  final int maxAge = 100;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAge();
  }

  Future<void> _loadAge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      age = prefs.getInt('age') ?? 25;
      _loading = false;
    });
  }

  Future<void> _saveAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('age', age);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const WizardHeading(
            text: 'wizard.how_old_are_you',
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  age.toString(),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CupertinoPicker(
                    backgroundColor: Colors.transparent,
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: age - minAge,
                    ),
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        age = index + minAge;
                      });
                      _saveAge();
                    },
                    children: List<Widget>.generate(
                      maxAge - minAge + 1,
                      (int index) {
                        return Center(
                          child: Text(
                            (index + minAge).toString(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 