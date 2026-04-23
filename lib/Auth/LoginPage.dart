import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loan_management_app/Auth/SignupPage.dart';
import 'package:loan_management_app/Service/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  int? branchId;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2B90D).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.attach_money_rounded,
                    size: 40,
                    color: Color(0xFFF2B90D),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to your account',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),

              // Username/Email Input
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Email or Username',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
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
                    borderSide: const BorderSide(
                      color: Color(0xFFF2B90D),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
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
                    borderSide: const BorderSide(
                      color: Color(0xFFF2B90D),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password Link
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
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF2B90D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2B90D),
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // Divider
              const Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.black26, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.black26, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Social Login Buttons
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
                        'Google',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(
                          color: Colors.black26,
                          width: 1,
                        ),
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
                        'Facebook',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(
                          color: Colors.black26,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
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

  Future<void> _loginUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    debugPrint('🔐 [LOGIN] Starting login attempt for user: $username');

    if (username.isEmpty || password.isEmpty) {
      debugPrint('❌ [LOGIN] Validation failed: username or password empty');
      setState(
        () =>
            _errorMessage =
            'Please enter both username and password.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔍 [LOGIN] Getting ApiService instance');
      final apiService = Get.find<ApiService>();
      
      debugPrint('📤 [LOGIN] Sending login request for user: $username');
      // Use public POST request (no token required for login)
      final response = await apiService.publicPostRequest(
        '/api/auth/login',
        {
          'username': username,
          'password': password,
        },
      );

      debugPrint('📥 [LOGIN] Received response with status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ [LOGIN] Response status 200 - Success');
        try {
          final data = jsonDecode(response.body);
          debugPrint('📦 [LOGIN] Decoded response body');
          final token = data['token'] ?? data['data']?['token'] ?? '';
          final expiresIn = data['expiresIn'] ?? data['data']?['expiresIn'] ?? 3600;
          branchId = data['branchId'] ?? data['data']?['branchId'] ?? 1;

          debugPrint('🔑 [LOGIN] Token length: ${token.length} | Expires in: $expiresIn | Branch ID: $branchId');

          if (token.isNotEmpty) {
            debugPrint('💾 [LOGIN] Storing token and branch data');
            // Store token with expiry information
            await apiService.storeTokenData(token, expirySeconds: expiresIn);
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('branch_id', branchId!);
            debugPrint('✅ [LOGIN] Token and branch data stored successfully');

            if (mounted) {
              debugPrint('🎯 [LOGIN] Navigating to dashboard');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Login successful!'),
                  backgroundColor: Colors.green,
                ),
              );
              Get.offAllNamed('/dashboard', arguments: {'branchId': branchId});
            }
          } else {
            debugPrint('❌ [LOGIN] Token is empty in response');
            setState(() => _errorMessage = 'Invalid response format.');
          }
        } catch (parseError) {
          debugPrint('❌ [LOGIN] JSON parsing error: $parseError');
          setState(() => _errorMessage = 'Error parsing login response: $parseError');
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ [LOGIN] Response status 401 - Invalid credentials');
        setState(() => _errorMessage = 'Invalid username or password.');
      } else if (response.statusCode == 503 &&
          response.body.contains('Failed to fetch')) {
        debugPrint('❌ [LOGIN] Browser/network access issue while calling login API');
        setState(
          () => _errorMessage =
              'Unable to reach the login API from Chrome. This is usually a CORS or API Gateway/network issue, not invalid credentials.',
        );
      } else {
        debugPrint('❌ [LOGIN] Response status ${response.statusCode} - Login failed');
        debugPrint('⚠️ [LOGIN] Response body: ${response.body}');
        setState(
          () =>
              _errorMessage =
              'Login failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [LOGIN] Exception: $e');
      debugPrint('📍 [LOGIN] Stacktrace: $stackTrace');
      setState(() => _errorMessage = 'Connection error: $e');
    } finally {
      if (mounted) {
        debugPrint('🔄 [LOGIN] Finalizing - setting isLoading to false');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
