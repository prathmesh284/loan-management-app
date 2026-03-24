import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_management_app/Service/api_service.dart';

class PayEmiPage extends StatefulWidget {
  final String loanId;
  final double totalLoanAmount;
  final int totalEmis;
  final int paidEmis;
  final String? nextEmiDate;

  const PayEmiPage({
    super.key,
    required this.loanId,
    required this.totalLoanAmount,
    required this.totalEmis,
    required this.paidEmis,
    this.nextEmiDate,
  });

  @override
  State<PayEmiPage> createState() => _PayEmiPageState();
}

class _PayEmiPageState extends State<PayEmiPage> {
  String selectedMethod = "cash";
  final TextEditingController upiController = TextEditingController();
  final TextEditingController cashReferenceController = TextEditingController();
  bool isLoading = false;

  // 💰 CALCULATE EMI AMOUNT (Annual payment = Total Loan / Number of EMIs)
  double get emiAmount {
    if (widget.totalEmis <= 0) return 0;
    return widget.totalLoanAmount / widget.totalEmis;
  }

  double get payableAmount {
    return emiAmount;
  }

  double get totalAmount {
    return emiAmount;
  }

  @override
  Widget build(BuildContext context) {
    const Color gold = Color(0xFFecb613);
    const Color bg = Color(0xFFF8F8F6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          "Pay EMI",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: bg,
        elevation: 0.3,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- EMI SUMMARY ----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        rowItem(
                          "Total Loan Amount",
                          "₹${widget.totalLoanAmount.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        rowItem(
                          "EMI Amount",
                          "₹${emiAmount.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        rowItem(
                          "Total Payable",
                          "₹${payableAmount.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        rowItem(
                          "Due Date",
                          widget.nextEmiDate ?? "Not Available",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Select Payment Method",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------- CASH ----------
                  paymentOption(
                    title: "Cash Payment",
                    selected: selectedMethod == "cash",
                    icon: Icons.attach_money_rounded,
                    onTap: () => setState(() => selectedMethod = "cash"),
                  ),

                  const SizedBox(height: 14),

                  // ---------- UPI ----------
                  paymentOption(
                    title: "UPI Payment",
                    selected: selectedMethod == "upi",
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () => setState(() => selectedMethod = "upi"),
                  ),

                  const SizedBox(height: 20),

                  // ---------- CASH PAYMENT SECTION ----------
                  if (selectedMethod == "cash") cashPaymentSection(),

                  // ---------- UPI INPUT ----------
                  if (selectedMethod == "upi") upiSection(),

                  const SizedBox(height: 30),

                  // ---------- PAY BUTTON ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black87,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Pay Now",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- HANDLER ----------------
  void handlePayment() async {
    if (selectedMethod == "upi" && upiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid UPI ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedMethod == "cash" && cashReferenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a reference number or receipt number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🔥 SHOW CONFIRMATION DIALOG FOR CASH
    if (selectedMethod == "cash") {
      showCashPaymentConfirmation();
    } else {
      processPayment();
    }
  }

  // 🎯 CASH PAYMENT CONFIRMATION DIALOG
  void showCashPaymentConfirmation() {
    const Color gold = Color(0xFFecb613);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Cash Payment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Payment Details:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Payable Amount:"),
                  Text(
                    "₹${payableAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Reference #:"),
                  Text(
                    cashReferenceController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Payment Method:"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Cash",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFecb613)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: gold),
              onPressed: () {
                Navigator.pop(context);
                processPayment();
              },
              child: const Text(
                "Confirm Payment",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }

  // 💳 PROCESS PAYMENT
  void processPayment() async {
    setState(() => isLoading = true);

    try {
      final apiService = Get.find<ApiService>();

      final body = {
        "loanId": widget.loanId,
        "amountPaid": emiAmount,
        "paymentMethod": selectedMethod,
      };

      final response = await apiService.postRequest(
        "/api/emis/pay",
        body,
      );

      print("📡 EMI STATUS: ${response.statusCode}");
      print("📦 EMI BODY: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Payment Successful"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, {"success": true, "loanId": widget.loanId});
      } else {
        throw Exception("Payment failed");
      }
    } catch (e) {
      print("❌ ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Payment Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  // ---------------- REUSABLE WIDGETS ----------------

  Widget rowItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget paymentOption({
    required String title,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    const Color gold = Color(0xFFecb613);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? gold : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? gold.withOpacity(0.20) : Colors.white,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: gold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: gold, size: 26),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? gold : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget upiSection() {
    const Color gold = Color(0xFFecb613);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter UPI ID",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: upiController,
          decoration: InputDecoration(
            hintText: "example@upi",
            filled: true,
            fillColor: gold.withOpacity(0.12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // 💰 CASH PAYMENT SECTION
  Widget cashPaymentSection() {
    const Color gold = Color(0xFFecb613);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 💵 CASH DETAILS
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: gold, width: 0.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, color: gold, size: 24),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cash Payment",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Please settle the amount in cash",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Amount to Pay:", style: TextStyle(fontSize: 13)),
                  Text(
                    "₹${payableAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFecb613),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 📝 REFERENCE NUMBER INPUT
        const Text(
          "Receipt / Reference Number",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: cashReferenceController,
          decoration: InputDecoration(
            hintText: "Enter receipt or reference number",
            prefixIcon: const Icon(Icons.receipt, color: gold),
            filled: true,
            fillColor: gold.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
