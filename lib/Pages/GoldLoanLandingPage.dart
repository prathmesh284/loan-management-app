import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_management_app/Auth/LoginPage.dart';
import 'package:loan_management_app/Auth/SignupPage.dart';

class GoldLoanLandingPage extends StatelessWidget {
  const GoldLoanLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDPFSJLWwXTRJwmfg4oK4j885c1wHCwtg-j-04Qiq6uNKdjlSWuPLqKeTrD7S1wzZY-JRP7VUquPFeL3bT6BoB9_jFn53COXgjrCUTdhEmmUge3LHwYeIaX9WZuYQ2hfllDqZyKY-52om6rW0X-9r5j7dn_1ZpOvLI5JR2luBRgJv5IPqHFG4lxjTnFKfVHBA1VVIxY93FYv6uylZfRVHr5K9dMoJs7BTxiBa6aSp0AVplWtiYiFmoSULnm1e4sZ4WrkqoVqhVmPA',
              fit: BoxFit.cover,
            ),
          ),

          // Gold-gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.05, 0.35, 0.7, 1],
                  colors: isDark
                      ? [
                          const Color(0xFF221E10),
                          const Color(0xFF3A300E).withOpacity(0.9),
                          const Color(0xFFD4AF37).withOpacity(0.25),
                          Colors.transparent,
                        ]
                      : [
                          const Color(0xFFF8F8F5),
                          const Color(0xFFF6E8B1).withOpacity(0.7),
                          const Color(0xFFFFD700).withOpacity(0.2),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Small gold icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2B90D).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.info_outline,
                          size: 32,
                          color: Color(0xFFF2B90D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Title
                    Text(
                      "Manage Your Gold Loans Effortlessly",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: isDark
                            ? const Color(0xFFF8F8F5)
                            : const Color(0xFF221E10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      "Track EMIs, get payment reminders, and pay securely with our app.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        height: 1.5,
                        color: (isDark
                                ? const Color(0xFFF8F8F5)
                                : const Color(0xFF221E10))
                            .withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Get Started button (smaller height)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B90D),
                          foregroundColor: const Color(0xFF221E10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor:
                              const Color(0xFFF2B90D).withOpacity(0.25),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUpPage()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Get Started",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 12,
                            color: (isDark
                                    ? const Color(0xFFF8F8F5)
                                    : const Color(0xFF221E10))
                                .withOpacity(0.55),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginPage()));
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: Color(0xFFF2B90D),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
