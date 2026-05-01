import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_management_app/Pages/PayEmiPage.dart';
import 'package:loan_management_app/Service/api_service.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String customerId;
  final String name;
  final String imageUrl;

  const CustomerDetailsPage({
    super.key,
    required this.customerId,
    required this.name,
    required this.imageUrl,
  });

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  bool isLoading = true;
  bool isError = false;

  final apiService = Get.find<ApiService>();

  Map<String, dynamic>? activeLoan;
  Map<String, dynamic>? emiData;

  @override
  void initState() {
    super.initState();
    fetchCustomerLoan();
  }

  // ✅ SAFE DOUBLE PARSER
  double toDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  Future<void> fetchCustomerLoan() async {
    try {
      final response = await apiService.getRequest(
        "/api/loans/customer/${widget.customerId}",
      );

      if (response.statusCode == 200) {
        List loans = jsonDecode(response.body);

        if (loans.isNotEmpty) {
          final matchingLoan = loans.cast<dynamic>().firstWhere(
            (loan) => loan is Map<String, dynamic> && loan['status'] == 'ACTIVE',
            orElse: () => loans.first,
          );
          activeLoan = Map<String, dynamic>.from(matchingLoan as Map);

          // ✅ FETCH EMI DATA
          final emiRes = await apiService.getRequest(
            "/api/emis/${activeLoan!['id']}",
          );

          if (emiRes.statusCode == 200) {
            final data = jsonDecode(emiRes.body);

            if (data is List) {
              int total = data.length;

              int paid = data.where((e) {
                final status = e['status']?.toString().toLowerCase();
                return status == 'paid';
              }).length;

              emiData = {
                "totalEmis": total,
                "paidEmis": paid,
              };
            } else if (data is Map<String, dynamic>) {
              emiData = data;
            }
          }
        }

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");

      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text("Failed to load loan details"))
              : buildCustomerUI(),
    );
  }

  Widget buildCustomerUI() {
    final avatarName = widget.name.trim().isEmpty ? widget.customerId : widget.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFFFAF6E8),
                child: Text(
                  avatarName.isNotEmpty ? avatarName[0].toUpperCase() : "?",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Customer ID",
                      style: TextStyle(color: Colors.grey)),
                  Text(
                    widget.customerId,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (activeLoan == null) ...[
            const Center(
              child: Text("No active loans for this customer."),
            ),
          ] else ...[
            buildLoanSummary(activeLoan!),
            const SizedBox(height: 20),
            buildPaymentProgress(activeLoan!),
            const SizedBox(height: 20),
            buildNextPayment(activeLoan!),
          ],
        ],
      ),
    );
  }

  Widget buildLoanSummary(Map<String, dynamic> loan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          summaryRow("Loan Amount", "₹${toDouble(loan['loanAmount'])}"),
          summaryRow("Interest Rate", "${loan['interestRate'] ?? 0}%"),
          summaryRow("Tenure", "${loan['tenure'] ?? 0} months"),
          summaryRow("Total Payable", "₹${toDouble(loan['totalAmount'])}"),
        ],
      ),
    );
  }

  Widget summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget buildPaymentProgress(Map<String, dynamic> loan) {
    double total = toDouble(
      emiData?['totalEmis'] ?? loan['totalEmis'] ?? loan['tenure'],
    );
    double paid = toDouble(emiData?['paidEmis'] ?? loan['paidEmis']);

    if (total <= 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Payment Progress",
              style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text("No EMI records yet", style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    double progress = (paid / total).clamp(0, 1);
    
    // 💰 Payment amounts
    double totalAmount = toDouble(loan['totalAmount']);
    double paidAmount = toDouble(loan['paidAmount']);
    double remainingAmount = toDouble(loan['remainingAmount']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Payment Progress",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        // 📊 Progress Bar
        LinearProgressIndicator(
          value: progress,
          color: const Color(0xFFecb613),
          backgroundColor: Colors.grey.shade300,
          minHeight: 8,
        ),

        const SizedBox(height: 12),

        // 📈 EMI Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${paid.toInt()} of ${total.toInt()} months completed",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("${(progress * 100).toStringAsFixed(1)}%",
                style: const TextStyle(
                    color: Color(0xFFecb613), fontWeight: FontWeight.w600)),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 💳 Amount Paid
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Amount Paid",
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  Text("₹${paidAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Remaining Amount",
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  Text("₹${remainingAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  Text("₹${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontSize: 13)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "EMI progress: ${paid.toInt()}/${total.toInt()} paid, ${(total - paid).toInt()} remaining",
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget buildNextPayment(Map<String, dynamic> loan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(loan["nextEmiDate"] ?? "N/A"),

          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PayEmiPage(
                    loanId: activeLoan?['id']?.toString() ?? "",
                    customerId: widget.customerId,
                    totalLoanAmount: toDouble(activeLoan?['totalAmount']),
                    totalEmis: toDouble(
                      emiData?['totalEmis'] ??
                          activeLoan?['totalEmis'] ??
                          activeLoan?['tenure'],
                    ).toInt(),
                    paidEmis: toDouble(
                      emiData?['paidEmis'] ?? activeLoan?['paidEmis'],
                    ).toInt(),
                    nextEmiDate: activeLoan?['nextEmiDate'],
                  ),
                ),
              );

              if (result != null && result is Map && result["success"] == true) {
                // 🔄 Refresh loan details after successful payment
                await Future.delayed(const Duration(milliseconds: 500));
                await fetchCustomerLoan();
              }
            },
            child: const Text("Pay EMI"),
          ),
        ],
      ),
    );
  }
}
