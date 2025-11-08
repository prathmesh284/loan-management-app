import 'package:flutter/material.dart';
import 'package:loan_management_app/Pages/NewLoanPage.dart';

class LoanManagementPage extends StatefulWidget {
  const LoanManagementPage({super.key});

  @override
  State<LoanManagementPage> createState() => _LoanManagementPageState();
}

class _LoanManagementPageState extends State<LoanManagementPage> {
  bool isNewLoan = true;

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: darkMode ? const Color(0xFF221d10) : const Color(0xFFF8F8F6),
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        // backgroundColor:
        //     darkMode ? const Color(0xFF221d10) : const Color(0xFFF8F8F6),
        backgroundColor: const Color(0xFFF8F8F6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Loan Management",
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back,
              color: darkMode ? Colors.white : Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                // color: darkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
                color : const Color(0xFFecb613).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isNewLoan = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !isNewLoan
                              ? const Color(0xFFecb613).withOpacity(0.2)
                              : const Color(0xFFecb613),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Approve New Loan",
                          style: TextStyle(
                            fontWeight: isNewLoan ? FontWeight.bold : FontWeight.w500,
                            // color: isNewLoan
                            //     ? const Color(0xFF221d10)
                            //     : (darkMode
                            //         ? Colors.grey.shade400
                            //         : Colors.grey.shade600),
                            color: const Color(0xFF221d10),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isNewLoan = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !isNewLoan
                              ? const Color(0xFFecb613)
                              : const Color(0xFFecb613).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Payment History",
                          style: TextStyle(
                            fontWeight: !isNewLoan ? FontWeight.bold : FontWeight.w500,
                            // color: !isNewLoan
                            //     ? const Color(0xFF221d10)
                            //     : (darkMode
                            //         ? Colors.grey.shade400
                            //         : Colors.grey.shade600),
                            color: const Color(0xFF221d10),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isNewLoan ? _buildNewLoanSection() : _buildHistorySection(darkMode),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFecb613),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewLoanPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      // bottomNavigationBar: _buildBottomNavBar(darkMode),
    );
  }

  Widget _buildNewLoanSection() {
    return Column(
      children: [
        const Spacer(),
        Text(
          "Approve & Send OTP",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildHistorySection(bool darkMode) {
    // final textColor = darkMode ? Colors.white : Colors.black87;
    const textColor = Colors.black87;
    final items = [
      {"name": "Priya Sharma", "amount": "₹75,000", "id": "CUST-00123"},
      {"name": "Ravi Kumar", "amount": "₹50,000", "id": "CUST-84392"},
      {"name": "Anjali Singh", "amount": "₹1,20,000", "id": "CUST-00456"},
      {"name": "Sameer Patel", "amount": "₹30,000", "id": "CUST-00789"},
      {"name": "Mohan Gupta", "amount": "₹95,000", "id": "CUST-01011"},
    ];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            // color: darkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
            color: const Color(0xFFecb613).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(item["name"]!, style: TextStyle(color: textColor)),
            subtitle: Text(item["id"]!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            trailing: Text(
              "- ${item["amount"]}",
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
