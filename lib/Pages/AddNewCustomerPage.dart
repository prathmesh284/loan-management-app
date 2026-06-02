import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:loan_management_app/Components/OtpVerificationDialog.dart';
import 'package:loan_management_app/Service/api_service.dart';
import 'package:loan_management_app/Validators/form_validators.dart';

class AddNewCustomerPage extends StatefulWidget {
  final int branchId;

  const AddNewCustomerPage({super.key, required this.branchId});

  @override
  State<AddNewCustomerPage> createState() => _AddNewCustomerPageState();
}

class _AddNewCustomerPageState extends State<AddNewCustomerPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController adharController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final apiService = Get.find<ApiService>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    adharController.dispose();
    panController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ==================== VALIDATION & API CALL ====================
  Future<void> saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix the errors in the form"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> customerData = {
      "customerId": phoneController.text.trim(),
      "branchId": widget.branchId,
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "aadharNumber": adharController.text.trim(),
      "panNumber": panController.text.trim(),
      "address": addressController.text.trim(),
    };

    setState(() => isLoading = true);

    try {
      final response = await apiService.postRequest("/api/customers/add", customerData);
      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> payload = _decodeMap(response.body);

        if (payload["success"] != true) {
          final errorMessage = payload["message"]?.toString() ??
              payload["otp"]?["message"]?.toString() ??
              "Customer created, but OTP could not be sent.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        if (payload["otp"] is Map<String, dynamic> &&
            payload["otp"]["success"] != true) {
          final otpError = payload["otp"]["message"]?.toString() ??
              "OTP could not be sent. Please try again.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(otpError),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final verified = await OtpVerificationDialog.show(
          context,
          title: "Verify New Customer",
          subtitle: "Confirm the borrower phone number before proceeding in the system.",
          phoneNumber: phoneController.text.trim(),
          onVerify: (otpCode) => apiService.postRequest(
            "/api/customers/verify-otp",
            {
              "customerId": phoneController.text.trim(),
              "otpCode": otpCode,
            },
          ),
          onResend: () => apiService.postRequest(
            "/api/customers/resend-otp",
            {
              "customerId": phoneController.text.trim(),
            },
          ),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verified
                  ? "Customer added and verified successfully!"
                  : (payload["message"]?.toString() ??
                      "Customer added. OTP verification is pending."),
            ),
            backgroundColor: verified ? Colors.green : Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final payload = _decodeMap(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(payload["message"]?.toString() ?? "Failed: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _decodeMap(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
    } catch (_) {}
    return {"message": body};
  }

  // ---------------- BUILD UI -----------------
  @override
  Widget build(BuildContext context) {
    const Color gold = Color(0xFFecb613);
    const Color bg = Color(0xFFF8F8F6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Add Customer",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // ---------------- PROFILE ICON ----------------
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 55, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- FORM CARD ----------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Personal Details"),
                    buildValidatedField(nameController, "Full Name *", validator: FormValidators.validateName),
                    buildValidatedField(phoneController, "Phone Number (ID) *", keyboardType: TextInputType.phone, validator: FormValidators.validatePhone),

                    sectionTitle("Additional Information"),
                    buildValidatedField(emailController, "Email *", keyboardType: TextInputType.emailAddress, validator: FormValidators.validateEmail),
                    buildValidatedField(adharController, "Aadhar Number *", keyboardType: TextInputType.number, validator: FormValidators.validateAadhar),
                    buildValidatedField(panController, "PAN Number *", validator: FormValidators.validatePAN),
                    buildValidatedField(addressController, "Address *", validator: FormValidators.validateAddress),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ---------------- SAVE BUTTON ----------------
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : saveCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 2)
                    : const Text(
                        "Save Customer",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================== FORM COMPONENTS ====================

  /// Builds a validated TextFormField with integrated validation
  Widget buildValidatedField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: const Color(0xFFecb613).withOpacity(0.08),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFecb613), width: 1.7), borderRadius: BorderRadius.circular(12)),
          errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 1.5), borderRadius: BorderRadius.circular(12)),
          focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red, width: 1.7), borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
