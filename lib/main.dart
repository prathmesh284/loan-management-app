import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:loan_management_app/Pages/DashboardPage.dart';
import 'package:loan_management_app/Pages/GoldLoanLandingPage.dart';
// import 'package:loan_management_app/OnBoardingPage.dart';

void main() {
  runApp(const GoldLoanApp());
}

class GoldLoanApp extends StatelessWidget {
  const GoldLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gold Loan Management',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFF2B90D),
        scaffoldBackgroundColor: const Color(0xFFF8F8F5),
        textTheme: GoogleFonts.manropeTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFF2B90D),
        scaffoldBackgroundColor: const Color(0xFF221E10),
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      // home: const GoldLoanLandingPage(),
      home: GoldLoanLandingPage(),
    );
  }
}