// import 'package:flutter/material.dart';

// class NewLoanPage extends StatelessWidget {
//   const NewLoanPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final darkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       // backgroundColor: darkMode ? const Color(0xFF221d10) : const Color(0xFFF8F8F6),
//       backgroundColor: const Color(0xFFF8F8F6),
//       appBar: AppBar(
//         // backgroundColor:
//             // darkMode ? const Color(0xFF221d10) : const Color(0xFFF8F8F6),       
//         backgroundColor: const Color(0xFFF8F8F6),
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           "New Loan",
//           style: TextStyle(
//             color: darkMode ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back,
//               color: darkMode ? Colors.white : Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             _inputField("Customer Name", "Enter customer's full name", darkMode),
//             _inputField("Loan Amount", "0.00", darkMode, prefix: "₹"),
//             _inputField("Gold Weight (grams)", "Enter weight in grams", darkMode),
//             Row(
//               children: [
//                 Expanded(
//                     child: _inputField("Interest Rate", "12", darkMode, suffix: "%")),
//                 const SizedBox(width: 16),
//                 Expanded(
//                     child: _inputField("Tenure (months)", "Enter months", darkMode)),
//               ],
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFecb613),
//                 foregroundColor: const Color(0xFF221d10),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//               child: const Text(
//                 "Approve & Send OTP",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _inputField(String label, String hint, bool darkMode,
//       {String? prefix, String? suffix}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color:
//                       darkMode ? Colors.grey.shade400 : Colors.grey.shade600)),
//           const SizedBox(height: 6),
//           TextField(
//             style: TextStyle(
//                 color: darkMode ? Colors.white : Colors.black87, fontSize: 15),
//             decoration: InputDecoration(
//               prefixText: prefix,
//               suffixText: suffix,
//               hintText: hint,
//               filled: true,
//               fillColor:
//                   darkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
//               hintStyle: TextStyle(
//                   color:
//                       darkMode ? Colors.grey.shade500 : Colors.grey.shade400),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                     color: darkMode ? Colors.grey.shade700 : Colors.grey.shade300),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(color: Color(0xFFecb613)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewLoanPage extends StatefulWidget {
  final String? goldType;
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
    this.goldType,
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
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill date with today's date
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
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
                buildTextField(nameController, "Full Name"),
                const SizedBox(height: 10),
                buildTextField(idController, "Customer ID"),
                const SizedBox(height: 10),
                buildTextField(phoneController, "Phone Number",
                    type: TextInputType.phone),
                const SizedBox(height: 10),
                buildTextField(addressController, "Address"),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            buildSectionCard(
              title: "Gold & Loan Details",
              children: [
                buildReadonlyRow("Gold Type", widget.goldType),
                buildReadonlyRow("Gold Weight (g)", widget.weight),
                buildReadonlyRow("Gold Price (₹/g)", widget.goldPrice),
                buildReadonlyRow("LTV (%)", widget.ltv),
                buildReadonlyRow("Interest Rate (%)", widget.interestRate),
                buildReadonlyRow("Tenure (months)", widget.tenure),
                buildReadonlyRow("Eligible Loan (₹)", widget.loanAmount?.toStringAsFixed(2)),
                buildReadonlyRow("Monthly EMI (₹)", widget.emi?.toStringAsFixed(2)),
                buildReadonlyRow("Total Interest (₹)", widget.totalInterest?.toStringAsFixed(2)),
                buildReadonlyRow("Total Payable (₹)", widget.totalAmount?.toStringAsFixed(2)),
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Submit Handler ----
  void submitLoan() {
    if (nameController.text.isEmpty ||
        idController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all customer details."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Construct loan object
    final loanData = {
      "customerName": nameController.text,
      "customerId": idController.text,
      "phone": phoneController.text,
      "address": addressController.text,
      "loanDate": dateController.text,
      "goldType": widget.goldType ?? "N/A",
      "weight": widget.weight ?? "N/A",
      "goldPrice": widget.goldPrice ?? "N/A",
      "ltv": widget.ltv ?? "N/A",
      "interestRate": widget.interestRate ?? "N/A",
      "tenure": widget.tenure ?? "N/A",
      "loanAmount": widget.loanAmount ?? 0,
      "emi": widget.emi ?? 0,
      "totalInterest": widget.totalInterest ?? 0,
      "totalAmount": widget.totalAmount ?? 0,
    };

    // TODO: integrate with Firebase or API
    print("✅ Loan Created: $loanData");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Loan created successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  // ---- UI Helpers ----
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

  Widget buildReadonlyRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              )),
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
