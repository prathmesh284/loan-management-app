import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
  bool isEmailVerified = false;

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
                _buildTextField(_nameController, "Full Name",
                    TextInputType.name, "Enter your full name"),

                // Username
                _buildTextField(_usernameController, "Username",
                    TextInputType.text, "Enter a username"),

                // Aadhaar
                _buildTextField(
                    _aadhaarController, "Aadhaar Number", TextInputType.number,
                    "Enter your Aadhaar number",
                    validatorExtra: (value) {
                  if (value.length != 12) {
                    return 'Aadhaar must be 12 digits';
                  }
                  return null;
                }),

                // Phone
                _buildTextField(_phoneController, "Phone Number",
                    TextInputType.phone, "Enter your phone number",
                    validatorExtra: (value) {
                  if (value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                }),

                // DOB
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: _inputDecoration("Date of Birth"),
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
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
                      _dobController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    }
                  },
                ),
                const SizedBox(height: 10),

                // Gender
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: _inputDecoration("Gender"),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) => setState(() => gender = value),
                  validator: (value) =>
                      value == null ? 'Please select gender' : null,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 10),

                // Email
                _buildTextField(_emailController, "Email Address",
                    TextInputType.emailAddress, "Enter your email address",
                    validatorExtra: (value) {
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                }),

                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => isEmailVerified = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Verification email sent!")),
                      );
                    },
                    child: Text(
                      isEmailVerified ? "Email Verified ✓" : "Verify Email",
                      style: TextStyle(
                        color: isEmailVerified
                            ? Colors.green
                            : Colors.orangeAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Password
                _buildTextField(_passwordController, "Password",
                    TextInputType.visiblePassword, "Enter your password",
                    obscure: true, validatorExtra: (value) {
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                }),

                // Confirm Password
                _buildTextField(_confirmPasswordController, "Confirm Password",
                    TextInputType.visiblePassword, "Confirm your password",
                    obscure: true, validatorExtra: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                }),

                const SizedBox(height: 16),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Account created successfully!")),
                        );
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
                        child:
                            Divider(thickness: 0.8, color: Colors.black26)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(fontSize: 11.5, color: Colors.black54),
                      ),
                    ),
                    Expanded(
                        child:
                            Divider(thickness: 0.8, color: Colors.black26)),
                  ],
                ),
                const SizedBox(height: 14),

                // Google & Facebook Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        // icon: Image.network(
                        //   'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/google/google-original.svg',
                        //   height: 17,
                        //   width: 17,
                        // ),
                        icon: const Icon(Icons.g_mobiledata, color: Colors.red, size:24),
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.facebook,
                            color: Colors.blue[800], size: 17),
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                      onTap: () {},
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
  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType inputType, String emptyMessage,
      {bool obscure = false, String? Function(String)? validatorExtra}) {
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
            fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(
          fontSize: 12.5, color: Colors.black45, fontWeight: FontWeight.w400),
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
    );
  }
}
