import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  bool isLoading = false;

  // ---------------- API CALL -----------------
  Future<void> saveCustomer() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name & Phone Number are required."),
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
      final response = await http.post(
        Uri.parse("http://localhost:8080/api/customers/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(customerData),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Customer added successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.statusCode}"),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle("Personal Details"),
                  buildField(nameController, "Full Name *"),
                  buildField(phoneController, "Phone Number (ID) *",
                      keyboardType: TextInputType.phone),

                  sectionTitle("Additional Information"),
                  buildField(emailController, "Email"),
                  buildField(adharController, "Aadhar Number",
                      keyboardType: TextInputType.number),
                  buildField(panController, "PAN Number"),
                  buildField(addressController, "Address"),
                ],
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
          ],
        ),
      ),
    );
  }

  // ---------------- COMPONENTS ----------------
  Widget buildField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: const Color(0xFFecb613).withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color(0xFFecb613), width: 1.7),
            borderRadius: BorderRadius.circular(12),
          ),
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
