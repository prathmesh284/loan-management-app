import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_management_app/Pages/GoldLoanLandingPage.dart';
import 'package:loan_management_app/Auth/LoginPage.dart';
import 'package:loan_management_app/Components/NavigationBarPage.dart';
import 'package:loan_management_app/Service/api_service.dart';
import 'package:loan_management_app/Service/locale_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() async => ApiService());
  
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("jwt_token");
  int branchId = prefs.getInt("branch_id") ?? 1;
  bool isLoggedIn = token != null && token.isNotEmpty;

  if (isLoggedIn) {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.getRequest('/api/branches/details?branchId=$branchId');
      if (response.statusCode == 404 || response.statusCode == 401) {
        debugPrint('⚠️ [STARTUP] Stored branchId $branchId is invalid or auth token expired; clearing stored login state');
        await prefs.remove("jwt_token");
        await prefs.remove("token_expiry_time");
        await prefs.remove("branch_id");
        token = null;
        branchId = 1;
        isLoggedIn = false;
      }
    } catch (e) {
      debugPrint('❌ [STARTUP] Failed to validate stored branchId: $e');
    }
  }

  final initialLocale = await TranslationService.loadSavedLocale();

  runApp(GoldLoanApp(
    isLoggedIn: isLoggedIn,
    branchId: branchId,
    initialLocale: initialLocale,
  ));
}

class GoldLoanApp extends StatelessWidget {
  final bool isLoggedIn;
  final int branchId;
  final Locale initialLocale;
  
  const GoldLoanApp({
    super.key,
    required this.isLoggedIn,
    required this.branchId,
    required this.initialLocale,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFF2B90D),
        brightness: Brightness.light,
        primary: const Color(0xFFF2B90D),
        surface: const Color(0xFFFFFCF4),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F8F5),
      textTheme: GoogleFonts.manropeTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F8F5),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );

    return GetMaterialApp(
      title: 'Gold Loan Management',
      translations: TranslationService(),
      locale: initialLocale,
      fallbackLocale: TranslationService.fallbackLocale,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: baseTheme,
      darkTheme: baseTheme,
      home: isLoggedIn ? NavigationBarPage(branchId: branchId) : const GoldLoanLandingPage(),
      
      // Define named routes for navigation
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final branchId = args?['branchId'] ?? 1;
          return NavigationBarPage(initialIndex: 0, branchId: branchId);
        },
      },
    );
  }
}
