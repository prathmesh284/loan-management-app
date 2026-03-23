import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_management_app/Service/api_service.dart';

class PayEmiPage extends StatefulWidget {
  final String loanId; // ✅ added
  final double emiAmount;
  final String? nextEmiDate;

  const PayEmiPage({
    super.key,
    required this.loanId, // ✅ added
    required this.emiAmount,
    this.nextEmiDate,
  });

  @override
  State<PayEmiPage> createState() => _PayEmiPageState();
}

class _PayEmiPageState extends State<PayEmiPage> {
  String selectedMethod = "cash";
  final TextEditingController upiController = TextEditingController();
  bool isLoading = false; // ✅ added

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
                          "EMI Amount",
                          "₹${(widget.emiAmount).toStringAsFixed(2)}",
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

    setState(() => isLoading = true);

    try {
      final apiService = Get.find<ApiService>();

      final body = {
        "loanId": widget.loanId,
        "amount": widget.emiAmount,
        "paymentMethod": selectedMethod,
      };

      final response = await apiService.postRequest(
        "/api/emi/pay", // 🔥 your backend endpoint
        body,
      );

      print("📡 EMI STATUS: ${response.statusCode}");
      print("📦 EMI BODY: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Successful"),
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
          content: Text("Payment Failed"),
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
}
