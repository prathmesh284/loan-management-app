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
        seedColor: const Color(0xFFFBBF24),
        brightness: Brightness.light,
        primary: const Color(0xFFFBBF24),
        onPrimary: Colors.black,
        secondary: const Color(0xFF0E4C92),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: const Color(0xFF0F172A),
        tertiary: const Color(0xFF0E4C92),
        error: const Color(0xFFB91C1C),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: const Color(0xFF0F172A),
        displayColor: const Color(0xFF0F172A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F172A),
        selectedItemColor: Color(0xFFFBBF24),
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        showUnselectedLabels: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xA6000000)),
        labelStyle: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0E4C92), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFBBF24),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          side: const BorderSide(color: Color(0xFF0F172A), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
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
