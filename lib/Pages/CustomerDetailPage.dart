// import 'package:flutter/material.dart';

// class CustomerDetailsPage extends StatelessWidget {
//   final String name;
//   final String imageUrl;

//   const CustomerDetailsPage({
//     super.key,
//     required this.name,
//     required this.imageUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.2,
//         title: Text(
//           name,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black87),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile Section
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 32,
//                   backgroundImage: NetworkImage(imageUrl),
//                 ),
//                 const SizedBox(width: 16),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       "Active Loan",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       "Gold Loan #12345",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Loan Summary Card
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFAF6E8),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: const Color(0xFFecb613), width: 0.4),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: const [
//                       Icon(Icons.account_balance_wallet,
//                           color: Color(0xFFecb613), size: 22),
//                       SizedBox(width: 8),
//                       Text(
//                         "Loan Summary",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: const [
//                       Text("Loan Amount",
//                           style: TextStyle(fontSize: 12, color: Colors.grey)),
//                       Text("₹1,50,000",
//                           style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                               fontSize: 13)),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: const [
//                       Text("Interest Rate",
//                           style: TextStyle(fontSize: 12, color: Colors.grey)),
//                       Text("8.5%",
//                           style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                               fontSize: 13)),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: const [
//                       Text("Due Date",
//                           style: TextStyle(fontSize: 12, color: Colors.grey)),
//                       Text("25 Oct 2025",
//                           style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                               fontSize: 13)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Payment Progress
//             const Text(
//               "Payment Progress",
//               style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             LinearProgressIndicator(
//               value: 0.6,
//               color: const Color(0xFFecb613),
//               backgroundColor: Colors.grey.shade300,
//               minHeight: 6,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "60% of the total amount has been paid.",
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),

//             const SizedBox(height: 20),

//             // Upcoming Payment Section
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300, width: 0.6),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const [
//                         Text(
//                           "Next Payment",
//                           style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87),
//                         ),
//                         SizedBox(height: 4),
//                         Text("Due on 25 Nov 2025",
//                             style: TextStyle(fontSize: 12, color: Colors.grey)),
//                       ]),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFecb613),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 18, vertical: 10),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                     onPressed: () {},
//                     child: const Text(
//                       "Pay Now",
//                       style: TextStyle(
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Transaction History
//             const Text(
//               "Recent Transactions",
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87),
//             ),
//             const SizedBox(height: 10),

//             ...[
//               {"date": "25 Sep 2025", "amount": "₹15,000", "status": "Paid"},
//               {"date": "25 Aug 2025", "amount": "₹15,000", "status": "Paid"},
//               {"date": "25 Jul 2025", "amount": "₹15,000", "status": "Paid"},
//             ].map((txn) => Container(
//                   margin: const EdgeInsets.symmetric(vertical: 6),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(10),
//                     border:
//                         Border.all(color: Colors.grey.shade300, width: 0.6),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(txn['date']!,
//                                 style: const TextStyle(
//                                     fontSize: 12, color: Colors.grey)),
//                             Text(txn['amount']!,
//                                 style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.black87)),
//                           ]),
//                       Row(
//                         children: [
//                           const Icon(Icons.check_circle,
//                               color: Colors.green, size: 16),
//                           const SizedBox(width: 4),
//                           Text(txn['status']!,
//                               style: const TextStyle(
//                                   fontSize: 12, color: Colors.green)),
//                         ],
//                       )
//                     ],
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loan_management_app/Pages/PayEmiPage.dart';

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

  Map<String, dynamic>? activeLoan;

  @override
  void initState() {
    super.initState();
    fetchCustomerLoan();
  }

  Future<void> fetchCustomerLoan() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8080/api/loans/customer/${widget.customerId}"),
      );

      if (response.statusCode == 200) {
        List loans = jsonDecode(response.body);

        setState(() {
          isLoading = false;
          isError = false;

          activeLoan = loans.isNotEmpty ? loans.first : null;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
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
          // Header
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
                  const Text("Customer ID", style: TextStyle(color: Colors.grey)),
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

          // No Loan ?
          if (activeLoan == null) ...[
            const Center(
              child: Text(
                "No active loans for this customer.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          ] else ...[
            // Loan Summary
            buildLoanSummary(activeLoan!),

            const SizedBox(height: 20),

            // Payment Progress
            buildPaymentProgress(activeLoan!),

            const SizedBox(height: 20),

            // Next EMI
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
        border: Border.all(color: const Color(0xFFecb613), width: 0.4),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_wallet,
                  color: Color(0xFFecb613), size: 22),
              SizedBox(width: 8),
              Text(
                "Loan Summary",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          summaryRow("Loan Amount", "₹${loan['loanAmount']}"),
          summaryRow("Interest Rate", "${loan['interestRate']}%"),
          summaryRow("Tenure", "${loan['tenure']} months"),
          summaryRow("Gold Type", loan['goldType']),
          summaryRow("Weight", "${loan['weight']}g"),
          summaryRow("Total Payable", "₹${loan['totalAmount']}"),
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
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentProgress(Map<String, dynamic> loan) {
    double total = loan['totalEmis'] * 1.0;
    double paid = loan['paidEmis'] * 1.0;
    double progress = total == 0 ? 0 : (paid / total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Progress",
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          color: const Color(0xFFecb613),
          backgroundColor: Colors.grey.shade300,
          minHeight: 6,
        ),
        const SizedBox(height: 8),
        Text(
          "${(progress * 100).toStringAsFixed(0)}% Paid",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildNextPayment(Map<String, dynamic> loan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Next EMI Date",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                loan["nextEmiDate"] ?? "N/A",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFecb613),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>PayEmiPage(emiAmount: 10000))),
            child: const Text(
              "Pay EMI",
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
