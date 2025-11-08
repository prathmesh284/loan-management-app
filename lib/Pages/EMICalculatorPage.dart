import 'dart:math';
import 'package:flutter/material.dart';

class EmiCalculatorPage extends StatefulWidget {
  const EmiCalculatorPage({super.key});

  @override
  State<EmiCalculatorPage> createState() => _EmiCalculatorPageState();
}

class _EmiCalculatorPageState extends State<EmiCalculatorPage> {
  final TextEditingController loanController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();

  double monthlyEmi = 0.0;
  double totalInterest = 0.0;
  double totalAmount = 0.0;

  void calculateEmi() {
    final double principal = double.tryParse(loanController.text) ?? 0;
    final double rate = (double.tryParse(interestController.text) ?? 0) / 12 / 100;
    final int months = int.tryParse(tenureController.text) ?? 0;

    if (principal > 0 && rate > 0 && months > 0) {
      final double emi = (principal * rate * (pow(1 + rate, months))) /
          (pow(1 + rate, months) - 1);
      final double totalPayment = emi * months;
      final double interest = totalPayment - principal;

      setState(() {
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
        backgroundColor: backgroundLight.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'EMI Calculator',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: loanController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Loan Amount",
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: primary.withOpacity(0.2),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: interestController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Interest Rate (%)",
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: primary.withOpacity(0.2),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tenureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Loan Tenure (Months)",
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: primary.withOpacity(0.2),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateEmi,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: backgroundDark,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              "EMI Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildRow("Monthly EMI", monthlyEmi),
                  buildRow("Total Interest Payable", totalInterest),
                  buildRow("Total Amount Payable", totalAmount),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: Container(
      //   color: backgroundLight.withOpacity(0.9),
      //   child: BottomNavigationBar(
      //     type: BottomNavigationBarType.fixed,
      //     backgroundColor: Colors.transparent,
      //     selectedItemColor: primary,
      //     unselectedItemColor: Colors.black54,
      //     showUnselectedLabels: true,
      //     currentIndex: 4,
      //     items: const [
      //       BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      //       BottomNavigationBarItem(icon: Icon(Icons.group), label: "Customers"),
      //       BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Loans"),
      //       BottomNavigationBarItem(icon: Icon(Icons.description), label: "Documents"),
      //       BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
      //     ],
      //   ),
      // ),
    );
  }

  Widget buildRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              )),
          Text(
            "₹ ${value.toStringAsFixed(2)}",
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
}
