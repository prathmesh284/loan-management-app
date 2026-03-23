// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:loan_management_app/Pages/PayEmiPage.dart';
// import 'package:loan_management_app/Service/api_service.dart';

// class CustomerDetailsPage extends StatefulWidget {
//   final String customerId;
//   final String name;
//   final String imageUrl;

//   const CustomerDetailsPage({
//     super.key,
//     required this.customerId,
//     required this.name,
//     required this.imageUrl,
//   });

//   @override
//   State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
// }

// class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
//   bool isLoading = true;
//   bool isError = false;
//   final apiService = Get.find<ApiService>();
//   Map<String, dynamic>? activeLoan;
//   Map<String, dynamic>? emiData;
//   @override
//   void initState() {
//     super.initState();
//     fetchCustomerLoan();
//   }

//   double toDouble(dynamic val) {
//     if (val == null) return 0;
//     if (val is num) return val.toDouble();
//     return double.tryParse(val.toString()) ?? 0;
//   }

//   Future<void> fetchCustomerLoan() async {
//     try {
//       final response = await apiService.getRequest(
//         "/api/loans/customer/${widget.customerId}",
//       );

//       print("📡 Status Code: ${response.statusCode}");
//       print("📦 Response Body: ${response.body}");

//       if (response.statusCode == 200) {
//         List loans = jsonDecode(response.body);

//         if (loans.isNotEmpty) {
//           activeLoan = loans.first;

//           // 🔥 FETCH EMI DATA HERE
//           final emiRes = await apiService.getRequest(
//             "/api/emis/${activeLoan!['id']}",
//           );

//           if (emiRes.statusCode == 200) {
//             final data = jsonDecode(emiRes.body);

//             if (data is List) {
//               int total = data.length;
//               int paid = data.where((e) => e['status'] == 'PAID').length;

//               emiData = {"totalEmis": total, "paidEmis": paid};
//             } else if (data is Map<String, dynamic>) {
//               emiData = data;
//             }
//           } else {
//             print("❌ EMI API ERROR: ${emiRes.statusCode}");
//           }
//         }

//         setState(() {
//           isLoading = false;
//           isError = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           isError = true;
//         });
//       }
//     } catch (e) {
//       print("❌ Exception: $e");

//       setState(() {
//         isLoading = false;
//         isError = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.2,
//         title: Text(
//           widget.name,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black87),
//         centerTitle: true,
//       ),

//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : isError
//           ? const Center(child: Text("Failed to load loan details"))
//           : buildCustomerUI(),
//     );
//   }

//   Widget buildCustomerUI() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 32,
//                 backgroundImage: NetworkImage(widget.imageUrl),
//               ),
//               const SizedBox(width: 16),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Customer ID",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   Text(
//                     widget.customerId,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // No Loan ?
//           if (activeLoan == null) ...[
//             const Center(
//               child: Text(
//                 "No active loans for this customer.",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ] else ...[
//             // Loan Summary
//             buildLoanSummary(activeLoan!),

//             const SizedBox(height: 20),

//             // Payment Progress
//             buildPaymentProgress(activeLoan!),

//             const SizedBox(height: 20),

//             // Next EMI
//             buildNextPayment(activeLoan!),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget buildLoanSummary(Map<String, dynamic> loan) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFAF6E8),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFecb613), width: 0.4),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: const [
//               Icon(
//                 Icons.account_balance_wallet,
//                 color: Color(0xFFecb613),
//                 size: 22,
//               ),
//               SizedBox(width: 8),
//               Text(
//                 "Loan Summary",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           summaryRow("Loan Amount", "₹${loan['loanAmount']}"),
//           summaryRow("Interest Rate", "${loan['interestRate']}%"),
//           summaryRow("Tenure", "${loan['tenure']} months"),
//           summaryRow("Gold Type", loan['goldType']),
//           summaryRow("Weight", "${loan['weight']}g"),
//           summaryRow("Total Payable", "₹${loan['totalAmount']}"),
//         ],
//       ),
//     );
//   }

//   Widget summaryRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//               color: Colors.black87,
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildPaymentProgress(Map<String, dynamic> loan) {
//     double total = 0;
//     double paid = 0;

//     // ✅ Case 1: EMI summary exists
//     if (emiData != null &&
//         emiData!.containsKey('totalEmis') &&
//         emiData!.containsKey('paidEmis')) {
//       total = toDouble(emiData!['totalEmis']);
//       paid = toDouble(emiData!['paidEmis']);
//     } else {
//       // ✅ Case 2: fallback to loan data
//       total = toDouble(loan['totalEmis']);
//       paid = toDouble(loan['paidEmis']);
//     }

//     // 🛑 Still no data
//     if (total <= 0) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: const [
//           Text(
//             "Payment Progress",
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           SizedBox(height: 8),
//           Text("No EMI records yet", style: TextStyle(color: Colors.grey)),
//         ],
//       );
//     }

//     double progress = (paid / total).clamp(0, 1);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Payment Progress",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 8),

//         LinearProgressIndicator(
//           value: progress,
//           color: const Color(0xFFecb613),
//           backgroundColor: Colors.grey.shade300,
//           minHeight: 6,
//         ),

//         const SizedBox(height: 8),

//         Text("${paid.toInt()} / ${total.toInt()} EMIs Paid"),

//         const SizedBox(height: 4),

//         Text("Remaining: ${(total - paid).toInt()} EMIs"),
//       ],
//     );
//   }

//   Widget buildNextPayment(Map<String, dynamic> loan) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300, width: 0.6),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Next EMI Date",
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 loan["nextEmiDate"] ?? "N/A",
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFecb613),
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PayEmiPage(
//                     loanId: activeLoan!['id'].toString(),
//                     emiAmount: activeLoan!['emiAmount'] * 1.0,
//                     nextEmiDate: activeLoan!['nextEmiDate'],
//                   ),
//                 ),
//               );

//               // 🔥 REFRESH AFTER PAYMENT
//               if (result == true) {
//                 fetchCustomerLoan();
//               }
//             },
//             child: const Text(
//               "Pay EMI",
//               style: TextStyle(
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


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
          activeLoan = loans.first;

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
      print("❌ Exception: $e");

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
                backgroundImage: NetworkImage(widget.imageUrl),
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
    double total = toDouble(emiData?['totalEmis'] ?? loan['totalEmis']);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Payment Progress",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: progress,
          color: const Color(0xFFecb613),
          backgroundColor: Colors.grey.shade300,
          minHeight: 6,
        ),

        const SizedBox(height: 8),

        Text("${paid.toInt()} / ${total.toInt()} EMIs Paid"),

        const SizedBox(height: 4),

        Text("Remaining: ${(total - paid).toInt()} EMIs"),
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
                    emiAmount: toDouble(activeLoan?['emiAmount']),
                    nextEmiDate: activeLoan?['nextEmiDate'],
                  ),
                ),
              );

              if (result == true) {
                fetchCustomerLoan();
              }
            },
            child: const Text("Pay EMI"),
          ),
        ],
      ),
    );
  }
}