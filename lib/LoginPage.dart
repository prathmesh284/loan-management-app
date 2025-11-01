import 'package:flutter/material.dart';
import 'package:loan_management_app/DashboardPage.dart';
import 'package:loan_management_app/SignupPage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // pure white background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title and subtitle
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 26, // 2 less than before
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Sign in to continue your journey.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),

              // Email Input
              TextField(
                decoration: InputDecoration(
                  hintText: "Email or Phone",
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFF2B90D), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Password Input
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.lock_outline_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFF2B90D), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF2B90D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 46, // slightly smaller
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2B90D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage())),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Divider with "Or continue with"
              const Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.black26, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Or continue with",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.black26, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Google & Facebook Buttons (smaller)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                        width: 16,
                        height: 16,
                      ),
                      label: const Text(
                        "Google",
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side:
                            const BorderSide(color: Colors.black26, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/5968/5968764.png',
                        width: 16,
                        height: 16,
                      ),
                      label: const Text(
                        "Facebook",
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side:
                            const BorderSide(color: Colors.black26, width: 1),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Footer Sign Up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUpPage())),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF2B90D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
