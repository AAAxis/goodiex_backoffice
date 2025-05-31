import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'wizard_flow.dart';

class GenderScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GenderScreen({Key? key, required this.onNext, required this.onBack})
    : super(key: key);

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _loadGender();
  }

  Future<void> _loadGender() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gender = prefs.getString('gender');
      if (gender != null) {
        setState(() {
          selectedGender = gender;
        });
      } else {
        const defaultGender = 'wizard.gender_male';
        setState(() {
          selectedGender = defaultGender;
        });
        await prefs.setString('gender', defaultGender);
      }
    } catch (e) {
      print('Error loading gender: $e');
    }
  }

  Future<void> _saveGender(String gender) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gender', gender);
    } catch (e) {
      print('Error saving gender: $e');
      showError('Error saving gender');
    }
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildGenderButton(String genderKey, String assetPath) {
    final isSelected = selectedGender == genderKey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await _saveGender(genderKey);
              setState(() {
                selectedGender = genderKey;
              });
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Theme.of(context).cardColor : const Color(0xFFF8F7FC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected 
                    ? (isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary)
                    : Colors.transparent,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    genderKey == 'wizard.gender_male' ? Icons.male :
                    genderKey == 'wizard.gender_female' ? Icons.female :
                    Icons.person_outline,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    genderKey.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNextPressed() {
    if (selectedGender == null || selectedGender!.isEmpty) {
      showError('Please select a gender');
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const WizardHeading(
            text: 'wizard.select_gender',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGenderButton('wizard.gender_male', 'images/male.png'),
                  _buildGenderButton('wizard.gender_female', 'images/female.png'),
                  _buildGenderButton('wizard.gender_other', 'images/other.png'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
