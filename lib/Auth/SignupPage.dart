import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loan_management_app/Auth/LoginPage.dart';
import 'package:loan_management_app/Components/OtpVerificationDialog.dart';
import 'package:loan_management_app/Service/api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? shopName; // Add this to your state variables
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dobController = TextEditingController();

  String? gender;
  String? branch;
  
  List<String> branches = [];
  bool isLoadingBranches = true;
  String? branchError;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    debugPrint('🏢 [BRANCHES] Starting to fetch branches');
    try {
      debugPrint('🔍 [BRANCHES] Getting ApiService instance');
      final apiService = Get.find<ApiService>();
      
      debugPrint('📤 [BRANCHES] Sending request to /api/branches');
      // Use public GET request (no token required)
      final response = await apiService.publicGetRequest('/api/branches');
      
      debugPrint('📥 [BRANCHES] Received response with status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ [BRANCHES] Response status 200 - Success');
        try {
          final List<dynamic> jsonData = jsonDecode(response.body);
          debugPrint('📦 [BRANCHES] Decoded ${jsonData.length} branches');
          setState(() {
            branches = jsonData
                .map((branch) => branch['branchName'].toString())
                .toList();
            isLoadingBranches = false;
            debugPrint('✅ [BRANCHES] Branches list updated: $branches');
          });
        } catch (parseError) {
          debugPrint('❌ [BRANCHES] JSON parsing error: $parseError');
          setState(() {
            branchError = 'Error parsing branches: $parseError';
            isLoadingBranches = false;
          });
        }
      } else {
        debugPrint('❌ [BRANCHES] Response status ${response.statusCode} - Failed to load branches');
        debugPrint('⚠️ [BRANCHES] Response body: ${response.body}');
        setState(() {
          branchError = 'Failed to load branches (Status: ${response.statusCode})';
          isLoadingBranches = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [BRANCHES] Error fetching branches: $e');
      debugPrint('📍 [BRANCHES] Stacktrace: $stackTrace');
      setState(() {
        branchError = 'Error loading branches: $e';
        isLoadingBranches = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _aadhaarController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Get started by filling in your details",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 22),

                // Name
                _buildTextField(
                  _nameController,
                  "Full Name",
                  TextInputType.name,
                  "Enter your full name",
                ),

                // Username
                _buildTextField(
                  _usernameController,
                  "Username",
                  TextInputType.text,
                  "Enter a username",
                ),

                // Aadhaar
                _buildTextField(
                  _aadhaarController,
                  "Aadhaar Number",
                  TextInputType.number,
                  "Enter your Aadhaar number",
                  validatorExtra: (value) {
                    if (value.length != 12) {
                      return 'Aadhaar must be 12 digits';
                    }
                    return null;
                  },
                ),

                // Phone
                _buildTextField(
                  _phoneController,
                  "Phone Number",
                  TextInputType.phone,
                  "Enter your phone number",
                  validatorExtra: (value) {
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),

                // DOB
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: _inputDecoration("Date of Birth"),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Select DOB' : null,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      // ISO format: yyyy-MM-dd
                      _dobController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SizedBox(height: 10),

                // Gender
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: _inputDecoration("Gender"),
                  items: const [
                    DropdownMenuItem(value: "MALE", child: Text("Male")),
                    DropdownMenuItem(value: "FEMALE", child: Text("Female")),
                    DropdownMenuItem(value: "OTHER", child: Text("Other")),
                  ],
                  onChanged: (value) => setState(() => gender = value),
                  validator: (value) =>
                      value == null ? 'Please select gender' : null,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),

                // Jeweller Shop Name (Dynamically Loaded)
                if (isLoadingBranches)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: CircularProgressIndicator(color: Color(0xFFF2B90D)),
                  )
                else if (branchError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Unable to load shop list. Please try again.',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: shopName,
                    decoration: _inputDecorationDropBox(
                      "Select Jeweler Shop Name",
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      backgroundColor: Colors.white,
                    ),
                    items: branches
                        .map((branch) => DropdownMenuItem(
                              value: branch,
                              child: Text(branch),
                            ))
                        .toList(),
                    focusColor: Colors.grey,
                    onChanged: (value) => setState(() => shopName = value),
                    validator: (value) =>
                        value == null ? 'Please select your jeweller shop' : null,
                  ),

                const SizedBox(height: 10),

                // Email
                _buildTextField(
                  _emailController,
                  "Email Address",
                  TextInputType.emailAddress,
                  "Enter your email address",
                  validatorExtra: (value) {
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF4D3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8CB6F)),
                  ),
                  child: const Text(
                    "Phone OTP verification will appear right after signup.",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Password
                _buildTextField(
                  _passwordController,
                  "Password",
                  TextInputType.visiblePassword,
                  "Enter your password",
                  obscure: true,
                  validatorExtra: (value) {
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                // Confirm Password
                _buildTextField(
                  _confirmPasswordController,
                  "Confirm Password",
                  TextInputType.visiblePassword,
                  "Confirm your password",
                  obscure: true,
                  validatorExtra: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _registerUser(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2B90D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Divider
                const Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 0.8, color: Colors.black26),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(fontSize: 11.5, color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 0.8, color: Colors.black26),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Google & Facebook Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.g_mobiledata,
                          color: Colors.red,
                          size: 24,
                        ),
                        label: const Text(
                          "Google",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black12),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.facebook,
                          color: Colors.blue[800],
                          size: 17,
                        ),
                        label: const Text(
                          "Facebook",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black12),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(fontSize: 11.5, color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.offAll(() => const LoginPage());
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFFF2B90D),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
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
    );
  }

  // --- Helper Methods ---
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType inputType,
    String emptyMessage, {
    bool obscure = false,
    String? Function(String)? validatorExtra,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) return emptyMessage;
          if (validatorExtra != null) {
            final extra = validatorExtra(value);
            if (extra != null) return extra;
          }
          return null;
        },
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecorationDropBox(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12.5, color: Colors.black87, fontWeight: FontWeight.w500),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: label,
      hintStyle: const TextStyle(
        fontSize: 12.5,
        color: Colors.black87,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white, // 👈 ensures textfield background is white
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFF2B90D), width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12.5, color: Colors.black87, fontWeight: FontWeight.w500),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: label,
      hintStyle: const TextStyle(
        fontSize: 12.5,
        color: Colors.black87,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFF2B90D), width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
        errorMaxLines: 2,
    );
  }

  Future<void> _registerUser(BuildContext context) async {
    final Map<String, dynamic> userData = {
      "username": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "phoneNumber": _phoneController.text.trim(),
      "adharNumber": _aadhaarController.text.trim(),
      "dob": _dobController.text.trim(),
      "gender": gender,
      "branch": shopName,
    };

    debugPrint('👤 [SIGNUP] Starting signup with username: ${userData["username"]}');
    debugPrint('📦 [SIGNUP] User data: $userData');

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFF2B90D)),
        ),
      );

      debugPrint('🔍 [SIGNUP] Getting ApiService instance');
      // Use public POST request (no token required for signup)
      final apiService = Get.find<ApiService>();
      
      debugPrint('📤 [SIGNUP] Sending signup request');
      final response = await apiService.publicPostRequest(
        '/api/auth/signup',
        userData,
      );

      debugPrint('📥 [SIGNUP] Received response with status: ${response.statusCode}');

      if (!mounted) {
        debugPrint('⚠️ [SIGNUP] Widget unmounted, closing dialog');
        return;
      }
      Navigator.pop(context); // close loader

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [SIGNUP] Signup successful! Status: ${response.statusCode}');
        debugPrint('📦 [SIGNUP] Response: ${response.body}');
        
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final dynamic user = responseData['user'];
          final String phoneNumber =
              user is Map<String, dynamic> ? (user['phoneNumber'] ?? '').toString() : _phoneController.text.trim();

          if (!mounted) {
            debugPrint('⚠️ [SIGNUP] Widget unmounted, cannot continue OTP flow');
            return;
          }

          final verified = await OtpVerificationDialog.show(
            context,
            title: "Verify Team Access",
            subtitle: "Secure this new staff account with one quick OTP check.",
            phoneNumber: phoneNumber,
            onVerify: (otpCode) => apiService.publicPostRequest(
              '/api/auth/verify-otp',
              {
                'phoneNumber': phoneNumber,
                'otpCode': otpCode,
              },
            ),
            onResend: () => apiService.publicPostRequest(
              '/api/auth/resend-otp',
              {
                'phoneNumber': phoneNumber,
              },
            ),
          );

          if (!mounted) return;

          if (verified) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', _usernameController.text.trim());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ Account verified successfully. Please login."),
                backgroundColor: Colors.green,
              ),
            );
            Get.offAll(() => const LoginPage());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account created, but OTP verification is still pending."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (parseError) {
          debugPrint('❌ [SIGNUP] Error parsing signup response: $parseError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("⚠️ Signup completed but response parsing failed: $parseError"),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        debugPrint('❌ [SIGNUP] Signup failed! Status: ${response.statusCode}');
        debugPrint('⚠️ [SIGNUP] Response body: ${response.body}');
        
        if (!mounted) {
          debugPrint('⚠️ [SIGNUP] Widget unmounted, cannot show error message');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ Signup failed: ${response.statusCode} - ${response.body}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [SIGNUP] Exception occurred: $e');
      debugPrint('📍 [SIGNUP] Stacktrace: $stackTrace');
      if (!mounted) {
        debugPrint('⚠️ [SIGNUP] Widget unmounted, skipping error handling');
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
