import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_management_app/Pages/GoldLoanLandingPage.dart';
import 'package:loan_management_app/Auth/LoginPage.dart';
import 'package:loan_management_app/Components/NavigationBarPage.dart';
import 'package:loan_management_app/Service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() async => ApiService());
  
  // Check if user is authenticated
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("jwt_token");
  final branchId = prefs.getInt("branch_id") ?? 1;
  
  runApp(GoldLoanApp(
    isLoggedIn: token != null && token.isNotEmpty,
    branchId: branchId,
  ));
}

class GoldLoanApp extends StatelessWidget {
  final bool isLoggedIn;
  final int branchId;
  
  const GoldLoanApp({
    super.key,
    required this.isLoggedIn,
    required this.branchId,
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
