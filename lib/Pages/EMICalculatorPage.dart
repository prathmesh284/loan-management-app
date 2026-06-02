import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loan_management_app/Pages/NewLoanPage.dart';
import 'package:loan_management_app/Service/GoldPriceService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmiCalculatorPage extends StatefulWidget {
  final int branchId;
  const EmiCalculatorPage({super.key, required this.branchId});

  @override
  State<EmiCalculatorPage> createState() => _EmiCalculatorPageState();
}

class _EmiCalculatorPageState extends State<EmiCalculatorPage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController goldPriceController = TextEditingController();
  final TextEditingController requestedLoanController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();
  final TextEditingController ltvController = TextEditingController();

  String goldPurity = "22K";  // Gold purity: 22K, 23K, 24K
  String goldItemType = "Ring";  // Gold item type: Ring, Necklace, etc.
  String priceUnit = "per gram"; // "per gram" or "per kg"
  double maxLoanAmount = 0.0;
  double loanAmount = 0.0;
  double monthlyEmi = 0.0;
  double totalInterest = 0.0;
  double totalAmount = 0.0;
  bool _isFetchingPrice = false;

  Future<void> fetchGoldPrice() async {
    setState(() => _isFetchingPrice = true);

    try {
      final service = GoldPriceService();
      double price;

      if (priceUnit == "per gram") {
        price = await service.getGoldPricePerGram(forceFresh: true);
      } else {
        price = await service.getGoldPricePerKg(forceFresh: true);
      }

      if (mounted) {
        setState(() {
          goldPriceController.text = price.toStringAsFixed(2);
          _isFetchingPrice = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Gold price fetched: ₹${price.toStringAsFixed(2)}/$priceUnit",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingPrice = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ Failed to fetch gold price: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void calculateGoldLoan() {
    final double weight = double.tryParse(weightController.text) ?? 0;
    final double goldPrice = double.tryParse(goldPriceController.text) ?? 0;
    final double rate = (double.tryParse(interestController.text) ?? 0) / 12 / 100;
    final int months = int.tryParse(tenureController.text) ?? 0;
    final double ltv = double.tryParse(ltvController.text) ?? 75; // Default 75%

    if (weight > 0 && goldPrice > 0 && rate > 0 && months > 0) {
      // Normalize goldPrice to per gram
      // weight is in grams, so if price is per kg, convert to per gram
      final double pricePerGram = priceUnit == "per kg" ? goldPrice / 1000 : goldPrice;
      final double eligibleLoan = weight * pricePerGram * (ltv / 100);
      final double requestedLoan = double.tryParse(requestedLoanController.text) ?? eligibleLoan;

      if (requestedLoan <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Requested loan amount must be greater than zero."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (requestedLoan > eligibleLoan) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Requested loan amount cannot exceed eligible maximum of ₹${eligibleLoan.toStringAsFixed(2)}.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final double loanPrincipal = requestedLoan;
      final double emi = (loanPrincipal * rate * pow(1 + rate, months)) /
          (pow(1 + rate, months) - 1);
      final double totalPayment = emi * months;
      final double interest = totalPayment - loanPrincipal;

      setState(() {
        maxLoanAmount = eligibleLoan;
        loanAmount = loanPrincipal;
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
            fontSize: 18,
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
                  goldPurity: goldPurity,
                  goldItemType: goldItemType,
                  weight: weightController.text,
                  goldPrice: goldPriceController.text,
                  ltv: ltvController.text,
                  interestRate: interestController.text,
                  tenure: tenureController.text,
                  maxEligibleLoan: maxLoanAmount,
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
                // Gold Purity Selection
                DropdownButtonFormField<String>(
                  value: goldPurity,
                  decoration: buildDropdownDecoration(primary),
                  items: const [
                    DropdownMenuItem(value: "22K", child: Text("22K (91.6% Pure)")),
                    DropdownMenuItem(value: "23K", child: Text("23K (95.8% Pure)")),
                    DropdownMenuItem(value: "24K", child: Text("24K (99.9% Pure)")),
                  ],
                  onChanged: (val) => setState(() => goldPurity = val!),
                ),
                const SizedBox(height: 10),
                
                // Gold Item Type Selection
                DropdownButtonFormField<String>(
                  value: goldItemType,
                  decoration: buildDropdownDecoration(primary),
                  items: const [
                    DropdownMenuItem(value: "Ring", child: Text("Ring")),
                    DropdownMenuItem(value: "Necklace", child: Text("Necklace")),
                    DropdownMenuItem(value: "Bracelet", child: Text("Bracelet")),
                    DropdownMenuItem(value: "Earrings", child: Text("Earrings")),
                    DropdownMenuItem(value: "Chain", child: Text("Chain")),
                    DropdownMenuItem(value: "Coin", child: Text("Coin")),
                    DropdownMenuItem(value: "Bar", child: Text("Bar")),
                    DropdownMenuItem(value: "Pendant", child: Text("Pendant")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (val) => setState(() => goldItemType = val!),
                ),
                const SizedBox(height: 10),
                buildTextField(weightController, "Gold Weight (grams)", type: TextInputType.number),
                const SizedBox(height: 10),
                // Price Unit Selection
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(label: Text("Per Gram"), value: "per gram"),
                          ButtonSegment(label: Text("Per KG"), value: "per kg"),
                        ],
                        selected: {priceUnit},
                        onSelectionChanged: (value) {
                          setState(() {
                            priceUnit = value.first;
                            goldPriceController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        goldPriceController,
                        "Gold Price ($priceUnit) (₹)",
                        type: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isFetchingPrice ? null : fetchGoldPrice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: _isFetchingPrice
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Get Price"),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            buildSectionCard(
              title: "Loan Details",
              children: [
                buildTextField(requestedLoanController, "Requested Loan Amount (₹)",
                    type: TextInputType.number),
                const SizedBox(height: 10),
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
                  buildResultRow("Gold Item Type", goldItemType),
                  buildResultRow("Gold Purity", goldPurity),
                  buildResultRow("Max Eligible Loan", "₹ ${maxLoanAmount.toStringAsFixed(2)}"),
                  buildResultRow("Requested Loan Amount", "₹ ${loanAmount.toStringAsFixed(2)}"),
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
