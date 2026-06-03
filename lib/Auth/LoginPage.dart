import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  int? branchId;
  String? _userFacingError;

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = true,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.75)),
      labelStyle: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
      prefixIcon: Icon(icon, color: const Color(0xFF475569), size: 20),
      suffixIcon: suffixIcon,
      suffix: requiredField
          ? const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                '*',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF0E4C92), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.8),
      ),
      errorStyle: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.w600),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 241, 191, 84), Color.fromARGB(255, 146, 104, 13)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 18,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFBBF24), Color.fromARGB(255, 164, 122, 13)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Sign in to your account and manage loans effortlessly',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        if (_userFacingError != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF2B90D)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Color(0xFF0E4C92)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _userFacingError!,
                                    style: const TextStyle(
                                      color: Color(0xFF0E4C92),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_userFacingError != null) const SizedBox(height: 18),
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: _buildInputDecoration(
                            label: 'Email or Username',
                            hint: 'Enter your email or username',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email or username is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                          decoration: _buildInputDecoration(
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF475569),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Color(0xFF0E4C92), fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2B90D),
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFFCBD5E1), thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Or continue with', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Color(0xFFCBD5E1), thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Image.network(
                                  'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                                  width: 18,
                                  height: 18,
                                ),
                                label: const Text('Google'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0F172A),
                                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.facebook, color: Colors.blueAccent, size: 18),
                                label: const Text('Facebook'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0F172A),
                                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account? ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpPage()),
                              ),
                              child: const Text('Sign Up', style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _userFacingError = 'Please fix the highlighted fields.';
      });
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    debugPrint('🔐 [LOGIN] Starting login attempt for user: $username');
    setState(() {
      _isLoading = true;
      _userFacingError = null;
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

          dynamic rawBranchId = data['branchId'] ?? data['branch_id'] ?? data['data']?['branchId'] ?? data['data']?['branch_id'];
          int? parsedBranchId;
          if (rawBranchId is int) {
            parsedBranchId = rawBranchId;
          } else if (rawBranchId is String) {
            parsedBranchId = int.tryParse(rawBranchId);
          } else if (rawBranchId is num) {
            parsedBranchId = rawBranchId.toInt();
          }

          if (token.isEmpty) {
            debugPrint('❌ [LOGIN] Token is empty in response');
            setState(() => _userFacingError = 'Login cannot be completed right now.');
            return;
          }

          if (parsedBranchId == null || parsedBranchId <= 0) {
            debugPrint('❌ [LOGIN] Invalid or missing branchId in login response: $rawBranchId');
            setState(() => _userFacingError = 'Login cannot be completed right now.');
            return;
          }

          branchId = parsedBranchId;
          debugPrint('🔑 [LOGIN] Token length: ${token.length} | Expires in: $expiresIn | Branch ID: $branchId');

          debugPrint('💾 [LOGIN] Storing token and branch data');
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
        } catch (parseError) {
          debugPrint('❌ [LOGIN] JSON parsing error: $parseError');
          setState(() => _userFacingError = 'Something went wrong. Please try again.');
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ [LOGIN] Response status 401 - Invalid credentials');
        setState(() => _userFacingError = 'Unable to sign in. Check your credentials.');
      } else if (response.statusCode == 503 &&
          response.body.contains('Failed to fetch')) {
        debugPrint('❌ [LOGIN] Browser/network access issue while calling login API');
        setState(
          () => _userFacingError = 'Unable to connect. Try again later.',
        );
      } else {
        debugPrint('❌ [LOGIN] Response status ${response.statusCode} - Login failed');
        debugPrint('⚠️ [LOGIN] Response body: ${response.body}');
        setState(
          () => _userFacingError = 'Login failed. Please retry.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [LOGIN] Exception: $e');
      debugPrint('📍 [LOGIN] Stacktrace: $stackTrace');
      setState(() => _userFacingError = 'Unable to connect right now.');
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
