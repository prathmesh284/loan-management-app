import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:loan_management_app/Components/OtpVerificationDialog.dart';
import 'package:loan_management_app/Service/api_service.dart';
import 'package:loan_management_app/Validators/form_validators.dart';

class NewLoanPage extends StatefulWidget {
  final String? goldPurity;  // Purity: 22K, 23K, 24K
  final String? goldItemType;  // Item type: Ring, Necklace, etc.
  final String? weight;
  final String? goldPrice;
  final String? ltv;
  final String? interestRate;
  final String? tenure;
  final double? loanAmount;
  final double? emi;
  final double? totalInterest;
  final double? totalAmount;

  const NewLoanPage({
    super.key,
    this.goldPurity,
    this.goldItemType,
    this.weight,
    this.goldPrice,
    this.ltv,
    this.interestRate,
    this.tenure,
    this.loanAmount,
    this.emi,
    this.totalInterest,
    this.totalAmount,
  });

  @override
  State<NewLoanPage> createState() => _NewLoanPageState();
}

class _NewLoanPageState extends State<NewLoanPage> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final ApiService apiService;
  bool isLoadingCustomer = false;
  String? customerError;
  bool _isPopulatingCustomer = false;
  bool _customerPhoneVerified = false;

  @override
  void initState() {
    super.initState();
    apiService = Get.find<ApiService>();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Customer ID is the phone number in this app, so fetch from this field.
    idController.addListener(_onCustomerIdChanged);
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    addressController.dispose();
    dateController.dispose();
    super.dispose();
  }

  // Fetch customer details when customer ID is entered.
  Future<void> _onCustomerIdChanged() async {
    if (_isPopulatingCustomer) {
      return;
    }

    final customerId = idController.text.trim();

    if (customerId.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(customerId)) {
      debugPrint('📱 [CUSTOMER] Fetching customer details for customerId: $customerId');
      
      setState(() {
        isLoadingCustomer = true;
        customerError = null;
      });

      try {
        final response = await apiService.getRequest('/api/customers/by-id/$customerId');
        
        if (response.statusCode == 200) {
          final customerData = jsonDecode(response.body);
          debugPrint('✅ [CUSTOMER] Customer found: ${customerData['name']}');

          _isPopulatingCustomer = true;
          setState(() {
            idController.text = customerData['customerId'] ?? '';
            nameController.text = customerData['name'] ?? '';
            addressController.text = customerData['address'] ?? '';
            _customerPhoneVerified = customerData['isPhoneVerified'] == true;
            isLoadingCustomer = false;
          });
          _isPopulatingCustomer = false;
        } else {
          debugPrint('⚠️ [CUSTOMER] Customer not found for customerId: $customerId');
          setState(() {
            customerError = 'Customer not found for this Customer ID.';
            nameController.clear();
            addressController.clear();
            _customerPhoneVerified = false;
            isLoadingCustomer = false;
          });
        }
      } catch (e, stackTrace) {
        debugPrint('❌ [CUSTOMER] Error fetching customer: $e');
        debugPrint(stackTrace.toString());
        
        setState(() {
          customerError = 'Error fetching customer details';
          nameController.clear();
          addressController.clear();
          _customerPhoneVerified = false;
          isLoadingCustomer = false;
        });
      }
    } else if (customerId.isNotEmpty) {
      setState(() {
        customerError = null;
        nameController.clear();
        addressController.clear();
        _customerPhoneVerified = false;
      });
    } else {
      setState(() {
        customerError = null;
        nameController.clear();
        addressController.clear();
        _customerPhoneVerified = false;
      });
    }
  }

  Future<void> _fetchCustomerById() async {
    await _onCustomerIdChanged();
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFECB613);
    const Color backgroundLight = Color(0xFFF8F8F6);
    const Color backgroundDark = Color(0xFF221D10);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'New Loan Entry',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSectionCard(
              title: "Customer Information",
              children: [
                // Customer ID / Phone Number (Primary field)
                buildTextField(
                  idController,
                  "Customer ID *",
                  type: TextInputType.phone,
                  onSubmitted: (_) => _fetchCustomerById(),
                  suffixIcon: isLoadingCustomer
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _fetchCustomerById,
                          icon: const Icon(Icons.search),
                          tooltip: "Fetch customer",
                        ),
                ),
                const SizedBox(height: 10),
                
                // Error message
                if (customerError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                          child: Text(
                              customerError!,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (nameController.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _customerPhoneVerified
                          ? Colors.green.withOpacity(0.12)
                          : Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _customerPhoneVerified ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Text(
                      _customerPhoneVerified
                          ? "Customer phone is verified and ready for loan creation."
                          : "Customer phone is not verified. OTP confirmation will be required.",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _customerPhoneVerified ? Colors.green.shade800 : Colors.orange.shade900,
                      ),
                    ),
                  ),
                
                // Customer Name (auto-filled)
                buildTextField(
                  nameController,
                  "Full Name *",
                  enabled: false,
                ),
                const SizedBox(height: 10),

                buildTextField(
                  addressController,
                  "Address *",
                  enabled: false,
                ),
                const SizedBox(height: 10),
                
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Date of Loan",
                    filled: true,
                    fillColor: primary.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: const Icon(Icons.calendar_today_rounded),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (pickedDate != null) {
                      // Format as ISO date (YYYY-MM-DD) for backend compatibility
                      dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            buildSectionCard(
              title: "Gold & Loan Details",
              children: [
                buildReadonlyRow("Gold Purity", widget.goldPurity),
                buildReadonlyRow("Gold Item Type", widget.goldItemType),
                buildReadonlyRow("Gold Weight (g)", widget.weight),
                buildReadonlyRow("Gold Price (₹/g)", widget.goldPrice),
                buildReadonlyRow("LTV (%)", widget.ltv),
                buildReadonlyRow("Interest Rate (%)", widget.interestRate),
                buildReadonlyRow("Tenure (months)", widget.tenure),
                buildReadonlyRow(
                  "Eligible Loan (₹)",
                  widget.loanAmount?.toStringAsFixed(2)
                ),
                buildReadonlyRow(
                  "Monthly EMI (₹)",
                  widget.emi?.toStringAsFixed(2),
                ),
                buildReadonlyRow(
                  "Total Interest (₹)",
                  widget.totalInterest?.toStringAsFixed(2),
                ),
                buildReadonlyRow(
                  "Total Payable (₹)",
                  widget.totalAmount?.toStringAsFixed(2),
                ),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              onPressed: submitLoan,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: backgroundDark,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              label: const Text(
                'Submit Loan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Submit Handler ----
  void submitLoan() async {
    if (nameController.text.isEmpty ||
        idController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all customer details."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Normalize and validate goldPurity format (must be 22K, 23K, or 24K)
    final rawGoldPurity = (widget.goldPurity ?? '').trim().toUpperCase();
    if (!RegExp(r'^(22K|23K|24K)$').hasMatch(rawGoldPurity)) {
      debugPrint('❌ [LOAN] Invalid gold purity: "$rawGoldPurity" (from: "${widget.goldPurity}")');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid gold purity: \"$rawGoldPurity\". Must be 22K, 23K, or 24K."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final goldItemType = (widget.goldItemType ?? '').trim();
    if (goldItemType.isEmpty) {
      debugPrint('❌ [LOAN] Gold item type is required');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gold item type is required."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final loanData = {
      "customerId": idController.text.trim(),
      "customerName": nameController.text.trim(),
      "address": addressController.text.trim(),
      "loanDate": dateController.text.trim(),
      "goldPurity": rawGoldPurity,
      "purity": rawGoldPurity,
      "goldItemType": goldItemType,
      "goldType": goldItemType,
      "weight": double.tryParse(widget.weight ?? '0') ?? 0.0,
      "goldPrice": double.tryParse(widget.goldPrice ?? '0') ?? 0.0,
      "ltv": double.tryParse(widget.ltv ?? '0') ?? 0.0,
      "interestRate": double.tryParse(widget.interestRate ?? '0') ?? 0.0,
      "tenure": int.tryParse(widget.tenure ?? '0') ?? 0,
      "loanAmount": widget.loanAmount ?? 0.0,
      "emi": widget.emi ?? 0.0,
      "totalInterest": widget.totalInterest ?? 0.0,
      "totalAmount": widget.totalAmount ?? 0.0,
    };

    debugPrint('📤 [LOAN] Submitting loan data: $loanData');

    try {
      final apiService = Get.find<ApiService>();
      if (!_customerPhoneVerified) {
        final verified = await OtpVerificationDialog.show(
          context,
          title: "Verify Before Loan",
          subtitle: "Approve this loan only after the borrower confirms OTP on their phone.",
          phoneNumber: idController.text.trim(),
          onVerify: (otpCode) => apiService.postRequest(
            "/api/customers/verify-otp",
            {
              "customerId": idController.text.trim(),
              "otpCode": otpCode,
            },
          ),
          onResend: () => apiService.postRequest(
            "/api/customers/resend-otp",
            {
              "customerId": idController.text.trim(),
            },
          ),
        );

        if (!verified) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Loan creation stopped because OTP verification is pending."),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        setState(() => _customerPhoneVerified = true);
      }

      final response = await apiService.postRequest("/api/loans/add", loanData);
      
      debugPrint('📥 [LOAN] Response status: ${response.statusCode}');
      debugPrint('📥 [LOAN] Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [LOAN] Loan created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Loan created successfully. Customer notified by SMS."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        debugPrint('❌ [LOAN] Failed to create loan: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed! ${response.statusCode}\n${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [LOAN] Error: $e');
      debugPrint(stackTrace.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---- UI Helpers ----
  Widget buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType type = TextInputType.text,
    bool enabled = true,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
  }) {
    const Color primary = Color(0xFFECB613);
    return TextField(
      controller: controller,
      keyboardType: type,
      enabled: enabled,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled 
          ? primary.withOpacity(0.2)
          : Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget buildReadonlyRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          Text(
            value == null || value.isEmpty ? "—" : value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    const Color primary = Color(0xFFECB613);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
