import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'welcome_section.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../meal_analysis.dart';
import '../settings.dart';
import '../auth/login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'upload_history.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications_screen.dart';
import 'shared_app_bar.dart';
import '../services/paywall_service.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAnalyzing;
  DashboardScreen({Key? key, this.isAnalyzing = false}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  // Placeholder user and meal data
  final String profileImage = 'images/profile.jpg'; // Replace with actual image path
  final bool isPremium = true;
  final List<DateTime> days = List.generate(7, (i) => DateTime.now().subtract(Duration(days: 6 - i)));
  DateTime? _selectedDay = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingProfile = false;

  int _selectedIndex = 0;

  List<Meal> _meals = [];
  bool _isMealsLoading = false;
  bool _isRefreshing = false;

  // Nutrition goals loaded from SharedPreferences
  double _caloriesGoal = 2000;
  double _proteinGoal = 150;
  double _carbsGoal = 300;
  double _fatsGoal = 65;

  Future<void> _loadNutritionGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _caloriesGoal = prefs.getDouble('daily_calories') ?? 2000;
      _proteinGoal = prefs.getDouble('daily_protein') ?? 150;
      _carbsGoal = prefs.getDouble('daily_carbs') ?? 300;
      _fatsGoal = prefs.getDouble('daily_fats') ?? 65;
    });
  }

  List<Meal> get _filteredMeals {
    if (_selectedDay == null) return _meals;
    return _meals.where((meal) {
      final mealDate = meal.timestamp;
      return mealDate.year == _selectedDay!.year &&
             mealDate.month == _selectedDay!.month &&
             mealDate.day == _selectedDay!.day;
    }).toList();
  }

  Future<void> _onProfileTap() async {
    if (!_isUserAuthenticated()) {
      // Navigate directly to login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Additional safety check
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        setState(() { _isUploadingProfile = true; });
        final url = await ImageService.uploadProfileImage(File(image.path), user.uid);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profileImage': url,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error uploading profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile image')),
        );
      } finally {
        setState(() { _isUploadingProfile = false; });
      }
    }
  }

  Future<void> _showCameraOrGalleryDialog(BuildContext context) async {
    // Check subscription before allowing camera access
    try {
      final hasActiveSubscription = await PaywallService.hasActiveSubscription();
      if (!hasActiveSubscription) {
        // Check if user has used their free scan
        final hasUsedFreeScan = await _checkIfUserHasUsedFreeScan();
        if (hasUsedFreeScan) {
          print('🔒 No active subscription and free scan already used, showing paywall...');
          
          // Check if user has used a referral code for metadata tracking
          final prefs = await SharedPreferences.getInstance();
          final hasUsedReferralCode = prefs.getBool('has_used_referral_code') ?? false;
          final referralCode = prefs.getString('referral_code') ?? 'none';
          
          // Always show the same paywall flow regardless of referral code
          // First try the default "Sale" offering
          final purchased = await PaywallService.showPaywall(
            context, 
            forceCloseOnRestore: true,
            metadata: {
              'referral_code_used': hasUsedReferralCode ? referralCode : 'none',
              'source': 'camera_access_paywall',
            },
          );
          if (!purchased) {
            // User cancelled the Sale paywall, show Offer paywall as fallback
            print('💡 User closed Sale paywall, showing Offer paywall as fallback...');
            await PaywallService.showPaywall(
              context, 
              offeringId: 'Offer',
              forceCloseOnRestore: true,
              metadata: {
                'referral_code_used': hasUsedReferralCode ? referralCode : 'none',
                'source': 'fallback_after_sale_paywall',
              },
            );
          }
          return;
        } else {
          print('✅ No subscription but free scan available, allowing camera access...');
        }
      }
    } catch (e) {
      print('❌ Error checking subscription status: $e');
      // If there's an error checking subscription, still allow camera access
    }

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('camera_scan.select_image_source'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'camera_scan.choose_gallery'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'camera_scan.take_photo'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      // Check if this is a free scan usage (for restore purchases flow)
      final hasActiveSubscription = await PaywallService.hasActiveSubscription();
      if (!hasActiveSubscription) {
        // Free scan will be marked as used when meal is saved
        print('📱 Free scan will be marked as used when meal is saved');
      }

      // Trigger analyzing animation
      setAnalyzingState(true);
      
      if (source == ImageSource.camera) {
        await pickAndAnalyzeImageFromCamera(
          picker: _picker,
          meals: _meals,
          updateMeals: updateMeals,
          context: context,
        );
      } else {
        await pickAndAnalyzeImageFromGallery(
          picker: _picker,
          meals: _meals,
          updateMeals: updateMeals,
          context: context,
        );
      }
      
      // Reset analyzing animation
      setAnalyzingState(false);
      
      // Refresh dashboard after adding meal
      await refreshDashboard();
    }
  }

  // Check if user has used their free scan by looking in Firebase or local storage
  Future<bool> _checkIfUserHasUsedFreeScan() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has referral free scans available
      final hasUsedReferralCode = prefs.getBool('has_used_referral_code') ?? false;
      if (hasUsedReferralCode) {
        final referralFreeScans = prefs.getInt('referral_free_scans') ?? 0;
        final usedReferralScans = prefs.getInt('used_referral_scans') ?? 0;
        
        if (usedReferralScans < referralFreeScans) {
          print('🎁 User has ${referralFreeScans - usedReferralScans} referral free scans remaining');
          return false; // Still has referral free scans available
        }
      }
      
      if (user == null) {
        // If user is not logged in, check local storage for any meals
        final localMeals = await Meal.loadFromLocalStorage();
        final hasUsedFreeScan = localMeals.isNotEmpty;
        print('🔍 Free scan check for non-authenticated user: hasUsed=$hasUsedFreeScan (${localMeals.length} local meals)');
        return hasUsedFreeScan;
      }

      // Check Firebase for logged-in users
      final snapshot = await FirebaseFirestore.instance
          .collection('analyzed_meals')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      final hasUsedFreeScan = snapshot.docs.isNotEmpty;
      print('🔍 Free scan check for user ${user.uid}: hasUsed=$hasUsedFreeScan');
      return hasUsedFreeScan;
    } catch (e) {
      print('❌ Error checking free scan usage: $e');
      // If there's an error, assume they haven't used it to be generous
      return false;
    }
  }

  Future<void> _showAuthDialog(String contextKey) async {
    String title = 'login.signin_required'.tr();
    String content;
    switch (contextKey) {
      case 'camera':
        content = 'login.signin_to_access_camera'.tr();
        break;
      case 'profile':
        content = 'Sign in to upload and manage your profile photo';
        break;
      case 'settings':
      default:
        content = 'login.signin_to_access_settings'.tr();
        break;
    }
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('login.sign_in'.tr()),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _showCameraOrGalleryDialog(context);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> loadMealsFromFirebase() async {
    setState(() { _isMealsLoading = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      List<Meal> meals = [];
      
      if (user != null) {
        // User is authenticated - load from Firebase ONLY
        print('🔥 Loading meals from Firebase for user: ${user.uid}');
        final snapshot = await FirebaseFirestore.instance
            .collection('analyzed_meals')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();
        meals = snapshot.docs.map((doc) => Meal.fromMap(doc.data(), doc.id)).toList();
        print('✅ Loaded ${meals.length} meals from Firebase');
        
        // Clear local storage meals when user is authenticated to avoid confusion
        await _clearLocalStorageMeals();
      } else {
        // User is not authenticated - load from local storage
        print('📱 Loading meals from local storage for non-authenticated user');
        meals = await Meal.loadFromLocalStorage();
        print('✅ Loaded ${meals.length} meals from local storage');
      }
      
      setState(() {
        _meals = meals;
      });
    } catch (e) {
      print('❌ Error loading meals: $e');
    } finally {
      setState(() { _isMealsLoading = false; });
    }
  }

  // Helper method to clear local storage meals when user signs in
  Future<void> _clearLocalStorageMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_meals');
      print('🧹 Cleared local storage meals for authenticated user');
    } catch (e) {
      print('❌ Error clearing local storage meals: $e');
    }
  }

  // Method to handle authentication state changes
  Future<void> handleAuthStateChange() async {
    final user = FirebaseAuth.instance.currentUser;
    print('🔄 Authentication state changed, reloading meals...');
    print('🔍 Current user: ${user?.uid ?? 'null'}');
    await loadMealsFromFirebase();
  }

  @override
  void initState() {
    super.initState();
    _loadNutritionGoals();
    loadMealsFromFirebase();
  }

  Future<void> refreshDashboard() async {
    if (_isRefreshing) return; // Prevent multiple simultaneous refreshes
    
    setState(() { _isRefreshing = true; });
    
    // Trigger haptic feedback at the start of refresh
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50, amplitude: 100);
    }
    
    try {
      await Future.wait([
        loadMealsFromFirebase(),
        _loadNutritionGoals(),
        // Add a small delay to make the refresh feel more responsive
        Future.delayed(Duration(milliseconds: 500)),
      ]);
      
      // Success vibration - short and light
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 20, amplitude: 80);
      }
    } catch (e) {
      print('❌ Error during refresh: $e');
      // Error vibration - longer and stronger
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100, amplitude: 150);
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Failed to refresh dashboard'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isRefreshing = false; });
      }
    }
  }

  List<Meal> get meals => _meals;
  set meals(List<Meal> value) => setState(() => _meals = value);
  void Function(List<Meal>) get updateMeals => (meals) => setState(() => _meals = meals);

  ImagePicker get picker => _picker;

  // Method to set analyzing state for animations
  void setAnalyzingState(bool isAnalyzing) {
    setState(() {
      // You can add any analyzing state variables here if needed
      // For now, this just triggers a rebuild
    });
  }

  // Helper method to check if user is truly authenticated
  bool _isUserAuthenticated() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return false;
    
    // You could add additional checks here if needed
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white;
    final textColor = Colors.black;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = _isUserAuthenticated();
    final locale = Localizations.localeOf(context).languageCode;

    String getMealName(Meal meal) {
      if (meal.mealNameMap != null) {
        return meal.mealNameMap![locale] ?? meal.mealNameMap!['en'] ?? meal.name;
      }
      return meal.name;
    }
    List<String> getIngredients(Meal meal) {
      if (meal.ingredientsMap != null) {
        return meal.ingredientsMap![locale] ?? meal.ingredientsMap!['en'] ?? [];
      }
      return [];
    }

    // Calculate dailyCalories and macros for the selected day
    final double dailyCalories = _filteredMeals.fold(0.0, (sum, meal) => sum + (meal.calories ?? 0));
    final double protein = _filteredMeals.fold(0.0, (sum, meal) => sum + (meal.macros['proteins'] ?? 0));
    final double carbs = _filteredMeals.fold(0.0, (sum, meal) => sum + (meal.macros['carbs'] ?? 0));
    final double fats = _filteredMeals.fold(0.0, (sum, meal) => sum + (meal.macros['fats'] ?? 0));
    final Map<String, double> macros = {
      'proteins': protein,
      'carbs': carbs,
      'fats': fats,
    };

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: SharedAppBar(
        title: 'navbar.dashboard'.tr(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCameraOrGalleryDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        tooltip: 'Add Meal',
      ),
      body: RefreshIndicator(
        onRefresh: refreshDashboard,
        color: Colors.blue,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        strokeWidth: 3.0,
        displacement: 40.0,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Add padding before WelcomeSection
            SizedBox(height: 16),
            
            // Welcome Section (date picker, macro cards, etc.)
            WelcomeSection(
              userName: 'Explorer',
              currentMealTime: 'breakfast', // Placeholder
              meals: _filteredMeals,
              dailyCalories: dailyCalories,
              caloriesGoal: _caloriesGoal,
              proteinGoal: _proteinGoal,
              carbsGoal: _carbsGoal,
              fatsGoal: _fatsGoal,
              macros: macros,
              onTap: () {},
              days: days,
              selectedDay: _selectedDay,
              onDaySelected: (d) {
                setState(() {
                  _selectedDay = d;
                });
              },
            ),
            // Meal Analysis Section - removed extra padding to align with WelcomeSection
            MealHistory(
                    meals: _filteredMeals,
                    onRefresh: refreshDashboard,
                    onDelete: (mealId) async {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          // User is authenticated - delete from Firebase
                          await FirebaseFirestore.instance
                              .collection('analyzed_meals')
                              .doc(mealId)
                              .delete();
                          print('✅ Deleted meal from Firebase: $mealId');
                        } else {
                          // User is not authenticated - delete from local storage
                          await Meal.deleteFromLocalStorage(mealId);
                          print('✅ Deleted meal from local storage: $mealId');
                          
                          // For testing: Reset free scan availability when last meal is deleted
                          final remainingMeals = await Meal.loadFromLocalStorage();
                          if (remainingMeals.isEmpty) {
                            print('🔄 All meals deleted - free scan is now available again');
                          }
                        }
                        await loadMealsFromFirebase();
                      } catch (e) {
                        print('❌ Error deleting meal: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete meal')),
                        );
                      }
                    },
                    updateMeals: (meals) {
                      setState(() { _meals = meals; });
                    },
                  ),
            // Spacer for bottom nav bar
            SizedBox(height: 80),
          ],
        ),
      ),
    ),
    );
  }
} 