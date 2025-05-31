import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dashboard/dashboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'wizard/wizard_flow.dart';
import 'wizard/welcome_screen.dart';
import 'settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'meal_analysis.dart';
import 'dart:io';
import 'auth/login.dart';
import 'dashboard/upload_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'services/revenue_cat_config.dart';
import 'services/paywall_service.dart';
import 'theme/app_theme.dart';
import 'dashboard/shop_screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<DashboardScreenState> dashboardKey =
    GlobalKey<DashboardScreenState>();

// Global function to trigger camera access from anywhere in the app
Future<void> triggerCameraAccess(BuildContext context) async {
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
        
        // Always navigate to dashboard regardless of purchase result
        // Add a small delay to ensure paywall is fully dismissed
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainTabScreen()),
            (route) => false,
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

  // Ask user to choose source (only if they have subscription or free scan available)
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

    // Get meals and updateMeals from dashboard
    final dashboardState = dashboardKey.currentState;
    if (dashboardState != null) {
      final meals = dashboardState.meals;
      final updateMeals = dashboardState.updateMeals;
      final picker = ImagePicker();
      
      // Trigger analyzing animation on dashboard
      dashboardState.setAnalyzingState(true);
      
      if (source == ImageSource.camera) {
        await pickAndAnalyzeImageFromCamera(
          picker: picker,
          meals: meals,
          updateMeals: updateMeals,
          context: context,
        );
      } else {
        await pickAndAnalyzeImageFromGallery(
          picker: picker,
          meals: meals,
          updateMeals: updateMeals,
          context: context,
        );
      }
      
      // Reset analyzing animation
      dashboardState.setAnalyzingState(false);
    }
    dashboardKey.currentState?.refreshDashboard();
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Initialize Firebase with the generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize RevenueCat
  await _configureRevenueCat();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('he'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'), // Force English as default
      useOnlyLangCode: true,
      assetLoader: const RootBundleAssetLoader(),
      child: const MyApp(),
    ),
  );
}

Future<void> _configureRevenueCat() async {
  // Enable debug logs before calling `configure`.
  await Purchases.setDebugLogsEnabled(true);

  PurchasesConfiguration configuration;
  
  if (Platform.isAndroid) {
    // Check if building for Amazon (use --dart-define=AMAZON=true)
    const buildingForAmazon = bool.fromEnvironment("AMAZON");
    if (buildingForAmazon) {
      configuration = AmazonConfiguration(amazonApiKey);
    } else {
      configuration = PurchasesConfiguration(googleApiKey);
    }
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration(appleApiKey);
  } else {
    throw UnsupportedError('Platform not supported');
  }

  await Purchases.configure(configuration);
  print('✅ RevenueCat configured successfully for ${Platform.isIOS ? 'iOS' : 'Android'}');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final hasSeenWelcome = snapshot.data!.getBool('has_seen_welcome') ?? false;
                return hasSeenWelcome ? MainTabScreen() : const WizardController();
              },
            ),
          );
        },
      ),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;

  // Mark that user has used their free scan
  Future<void> _markFreeScanAsUsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has referral free scans available
      final hasUsedReferralCode = prefs.getBool('has_used_referral_code') ?? false;
      if (hasUsedReferralCode) {
        final referralFreeScans = prefs.getInt('referral_free_scans') ?? 0;
        final usedReferralScans = prefs.getInt('used_referral_scans') ?? 0;
        
        if (usedReferralScans < referralFreeScans) {
          // Consume a referral free scan
          await prefs.setInt('used_referral_scans', usedReferralScans + 1);
          final remaining = referralFreeScans - (usedReferralScans + 1);
          print('🎁 Used referral free scan. ${remaining} scans remaining');
          return; // Don't mark regular free scan as used
        }
      }
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // For non-authenticated users, the scan will be automatically recorded in local storage
        // when they analyze a meal, so no additional marking needed
        print('📱 Free scan will be marked as used when meal is saved to local storage');
      } else {
        // For logged-in users, the scan will be automatically recorded in Firebase
        // when they analyze a meal, so no additional marking needed
        print('👤 Free scan will be marked as used when meal is saved to Firebase');
      }
    } catch (e) {
      print('❌ Error marking free scan as used: $e');
    }
  }

  void _onTabTapped(int index) async {
    // Special handling for settings tab when user is not authenticated
    if (index == 2) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Navigate to login screen with replacement
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return; // Don't update the current index
      }
    }
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_currentIndex == 0) {
      body = DashboardScreen(key: dashboardKey, isAnalyzing: _isAnalyzing);
    } else if (_currentIndex == 1) {
      body = ShopScreen();
    } else if (_currentIndex == 2) {
      body = SettingsScreen();
    } else {
      body = Container(); // Placeholder for other tabs
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.onSurface,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'navbar.dashboard'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shop),
              label: 'navbar.shop'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'navbar.settings'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
