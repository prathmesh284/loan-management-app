// import 'dart:math';
// import 'package:flutter/material.dart';

// class EmiCalculatorPage extends StatefulWidget {
//   const EmiCalculatorPage({super.key});

//   @override
//   State<EmiCalculatorPage> createState() => _EmiCalculatorPageState();
// }

// class _EmiCalculatorPageState extends State<EmiCalculatorPage> {
//   final TextEditingController loanController = TextEditingController();
//   final TextEditingController interestController = TextEditingController();
//   final TextEditingController tenureController = TextEditingController();

//   double monthlyEmi = 0.0;
//   double totalInterest = 0.0;
//   double totalAmount = 0.0;

//   void calculateEmi() {
//     final double principal = double.tryParse(loanController.text) ?? 0;
//     final double rate = (double.tryParse(interestController.text) ?? 0) / 12 / 100;
//     final int months = int.tryParse(tenureController.text) ?? 0;

//     if (principal > 0 && rate > 0 && months > 0) {
//       final double emi = (principal * rate * (pow(1 + rate, months))) /
//           (pow(1 + rate, months) - 1);
//       final double totalPayment = emi * months;
//       final double interest = totalPayment - principal;

//       setState(() {
//         monthlyEmi = emi;
//         totalInterest = interest;
//         totalAmount = totalPayment;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const Color primary = Color(0xFFECB613);
//     const Color backgroundLight = Color(0xFFF8F8F6);
//     const Color backgroundDark = Color(0xFF221D10);

//     return Scaffold(
//       backgroundColor: backgroundLight,
//       appBar: AppBar(
//         backgroundColor: backgroundLight.withOpacity(0.9),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: const Text(
//           'EMI Calculator',
//           style: TextStyle(
//             color: Colors.black,
//             fontFamily: 'Manrope',
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             const SizedBox(height: 12),
//             TextField(
//               controller: loanController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: "Loan Amount",
//                 hintStyle: const TextStyle(
//                   color: Colors.black54,
//                   fontSize: 15,
//                 ),
//                 filled: true,
//                 fillColor: primary.withOpacity(0.2),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: interestController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: "Interest Rate (%)",
//                 hintStyle: const TextStyle(
//                   color: Colors.black54,
//                   fontSize: 15,
//                 ),
//                 filled: true,
//                 fillColor: primary.withOpacity(0.2),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: tenureController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: "Loan Tenure (Months)",
//                 hintStyle: const TextStyle(
//                   color: Colors.black54,
//                   fontSize: 15,
//                 ),
//                 filled: true,
//                 fillColor: primary.withOpacity(0.2),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: calculateEmi,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primary,
//                 foregroundColor: backgroundDark,
//                 minimumSize: const Size.fromHeight(48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 'Calculate',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 28),
//             const Text(
//               "EMI Details",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Manrope',
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Container(
//               decoration: BoxDecoration(
//                 color: primary.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   buildRow("Monthly EMI", monthlyEmi),
//                   buildRow("Total Interest Payable", totalInterest),
//                   buildRow("Total Amount Payable", totalAmount),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       // bottomNavigationBar: Container(
//       //   color: backgroundLight.withOpacity(0.9),
//       //   child: BottomNavigationBar(
//       //     type: BottomNavigationBarType.fixed,
//       //     backgroundColor: Colors.transparent,
//       //     selectedItemColor: primary,
//       //     unselectedItemColor: Colors.black54,
//       //     showUnselectedLabels: true,
//       //     currentIndex: 4,
//       //     items: const [
//       //       BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
//       //       BottomNavigationBarItem(icon: Icon(Icons.group), label: "Customers"),
//       //       BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Loans"),
//       //       BottomNavigationBarItem(icon: Icon(Icons.description), label: "Documents"),
//       //       BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
//       //     ],
//       //   ),
//       // ),
//     );
//   }

//   Widget buildRow(String title, double value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black54,
//               )),
//           Text(
//             "₹ ${value.toStringAsFixed(2)}",
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loan_management_app/Pages/NewLoanPage.dart';

class EmiCalculatorPage extends StatefulWidget {
  const EmiCalculatorPage({super.key});

  @override
  State<EmiCalculatorPage> createState() => _EmiCalculatorPageState();
}

class _EmiCalculatorPageState extends State<EmiCalculatorPage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController goldPriceController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();
  final TextEditingController ltvController = TextEditingController();

  String goldType = "Ring";
  double loanAmount = 0.0;
  double monthlyEmi = 0.0;
  double totalInterest = 0.0;
  double totalAmount = 0.0;

  void fetchGoldPrice() {
    setState(() {
      goldPriceController.text = "6250"; // Mock price (per gram)
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Gold price fetched successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void calculateGoldLoan() {
    final double weight = double.tryParse(weightController.text) ?? 0;
    final double goldPrice = double.tryParse(goldPriceController.text) ?? 0;
    final double rate = (double.tryParse(interestController.text) ?? 0) / 12 / 100;
    final int months = int.tryParse(tenureController.text) ?? 0;
    final double ltv = double.tryParse(ltvController.text) ?? 75; // Default 75%

    if (weight > 0 && goldPrice > 0 && rate > 0 && months > 0) {
      final double eligibleLoan = weight * goldPrice * (ltv / 100);
      final double emi = (eligibleLoan * rate * pow(1 + rate, months)) /
          (pow(1 + rate, months) - 1);
      final double totalPayment = emi * months;
      final double interest = totalPayment - eligibleLoan;

      setState(() {
        loanAmount = eligibleLoan;
        monthlyEmi = emi;
        totalInterest = interest;
        totalAmount = totalPayment;
      });
    }
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
          'Gold Loan EMI Calculator',
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

      // Floating Action Button ➕ New Loan
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: backgroundDark,
        icon: const Icon(Icons.add),
        label: const Text("New Loan"),
        onPressed: () {
          if (loanAmount > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewLoanPage(
                  goldType: goldType,
                  weight: weightController.text,
                  goldPrice: goldPriceController.text,
                  ltv: ltvController.text,
                  interestRate: interestController.text,
                  tenure: tenureController.text,
                  loanAmount: loanAmount,
                  emi: monthlyEmi,
                  totalInterest: totalInterest,
                  totalAmount: totalAmount,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please calculate loan before proceeding!"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSectionCard(
              title: "Gold Details",
              children: [
                DropdownButtonFormField<String>(
                  value: goldType,
                  decoration: buildDropdownDecoration(primary),
                  items: const [
                    DropdownMenuItem(value: "Ring", child: Text("Ring")),
                    DropdownMenuItem(value: "Necklace", child: Text("Necklace")),
                    DropdownMenuItem(value: "Bracelet", child: Text("Bracelet")),
                    DropdownMenuItem(value: "Earrings", child: Text("Earrings")),
                    DropdownMenuItem(value: "Chain", child: Text("Chain")),
                    DropdownMenuItem(value: "Coin", child: Text("Coin")),
                    DropdownMenuItem(value: "Bar", child: Text("Bar")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (val) => setState(() => goldType = val!),
                ),
                const SizedBox(height: 10),
                buildTextField(weightController, "Gold Weight (grams)", type: TextInputType.number),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        goldPriceController,
                        "Gold Price per gram (₹)",
                        type: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: fetchGoldPrice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text("Get Price"),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            buildSectionCard(
              title: "Loan Details",
              children: [
                buildTextField(interestController, "Interest Rate (% per annum)",
                    type: TextInputType.number),
                const SizedBox(height: 10),
                buildTextField(tenureController, "Tenure (months)",
                    type: TextInputType.number),
                const SizedBox(height: 10),
                buildTextField(ltvController, "LTV Ratio (%) (default 75%)",
                    type: TextInputType.number),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateGoldLoan,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: backgroundDark,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Calculate Loan & EMI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 28),
            if (loanAmount > 0)
              buildSectionCard(
                title: "Loan Summary",
                children: [
                  buildResultRow("Gold Type", goldType),
                  buildResultRow("Eligible Loan Amount", "₹ ${loanAmount.toStringAsFixed(2)}"),
                  buildResultRow("Monthly EMI", "₹ ${monthlyEmi.toStringAsFixed(2)}"),
                  buildResultRow("Total Interest", "₹ ${totalInterest.toStringAsFixed(2)}"),
                  buildResultRow("Total Payable", "₹ ${totalAmount.toStringAsFixed(2)}"),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // --- Reusable UI Helpers ---
  Widget buildTextField(TextEditingController controller, String hint,
      {TextInputType type = TextInputType.text}) {
    const Color primary = Color(0xFFECB613);
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: primary.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  InputDecoration buildDropdownDecoration(Color primary) => InputDecoration(
        filled: true,
        fillColor: primary.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget buildResultRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({required String title, required List<Widget> children}) {
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
          Text(title,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
