import 'package:flutter/material.dart';

class NewLoanPage extends StatelessWidget {
  const NewLoanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: darkMode ? const Color(0xFF221d10) : const Color(0xFFF8F8F6),
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        // backgroundColor:
            // darkMode ? const Color(0xFF221d10) : const Color(0xFFF8F8F6),       
        backgroundColor: const Color(0xFFF8F8F6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "New Loan",
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: darkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _inputField("Customer Name", "Enter customer's full name", darkMode),
            _inputField("Loan Amount", "0.00", darkMode, prefix: "₹"),
            _inputField("Gold Weight (grams)", "Enter weight in grams", darkMode),
            Row(
              children: [
                Expanded(
                    child: _inputField("Interest Rate", "12", darkMode, suffix: "%")),
                const SizedBox(width: 16),
                Expanded(
                    child: _inputField("Tenure (months)", "Enter months", darkMode)),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFecb613),
                foregroundColor: const Color(0xFF221d10),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Approve & Send OTP",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, bool darkMode,
      {String? prefix, String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color:
                      darkMode ? Colors.grey.shade400 : Colors.grey.shade600)),
          const SizedBox(height: 6),
          TextField(
            style: TextStyle(
                color: darkMode ? Colors.white : Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              prefixText: prefix,
              suffixText: suffix,
              hintText: hint,
              filled: true,
              fillColor:
                  darkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
              hintStyle: TextStyle(
                  color:
                      darkMode ? Colors.grey.shade500 : Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: darkMode ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFecb613)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
