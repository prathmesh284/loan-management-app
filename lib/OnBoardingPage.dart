import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:loan_management_app/GoldLoanLandingPage.dart';

class OnBoardingPage extends StatelessWidget {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GoldLoanLandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(221, 3, 3, 3),
      ),
      bodyTextStyle: TextStyle(fontSize: 16.0, color: Colors.black54, height: 1.5),
      imagePadding: EdgeInsets.only(top: 80),
      bodyPadding: EdgeInsets.symmetric(horizontal: 24.0),
      pageColor: Color(0xFFF8FAFF), // light modern background
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: const Color(0xFFF8FAFF),
      pages: [
        PageViewModel(
          title: "Welcome to LoanWise",
          body:
              "Manage your loans effortlessly and stay on top of your EMIs with LoanWise.",
          image: Image.asset('assets/intro1.png', height: 250.0),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Manage Your Loans Effortlessly",
          body:
              "Keep track of all your loans in one place, from personal loans to auto loans, with easy EMI tracking.",
          image: Image.asset('assets/intro2.png', height: 250.0),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Stay Updated & Secure",
          body:
              "Get timely reminders, detailed analytics, and secure loan management — all in one app.",
          image: Image.asset('assets/intro3.png', height: 250.0),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Skip", style: TextStyle(fontSize: 16, color: Colors.black54)),
      next: const Text("Next",
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
      done: const Text("Get Started",
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
      nextFlex: 0,
      dotsFlex: 1,
      nextStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Color(0xFF1976D2)),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      doneStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Color(0xFF1976D2)),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: Size(24.0, 10.0),
        activeColor: Color(0xFF1976D2),
        spacing: EdgeInsets.symmetric(horizontal: 4.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      showNextButton: true,
      showDoneButton: true,
      curve: Curves.fastLinearToSlowEaseIn,
      controlsPosition: const Position(bottom: 40, left: 16, right: 16),
    );
  }
}
