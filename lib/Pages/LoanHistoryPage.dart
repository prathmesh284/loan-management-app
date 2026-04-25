import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_management_app/Service/api_service.dart';

class LoanHistoryPage extends StatefulWidget {
  final int branchId;
  const LoanHistoryPage({super.key, required this.branchId});

  @override
  State<LoanHistoryPage> createState() => _LoanHistoryPageState();
}

class _LoanHistoryPageState extends State<LoanHistoryPage> {
  List<dynamic> recentLoans = [];
  List<dynamic> loansDueSoon = [];
  bool isLoading = true;
  String? errorMessage;

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _displayDate(Map<String, dynamic> loan) {
    final loanDate = loan['loanDate'];
    if (loanDate != null && loanDate.toString().trim().isNotEmpty) {
      return loanDate.toString();
    }

    final nextEmiDate = loan['nextEmiDate'];
    if (nextEmiDate != null && nextEmiDate.toString().trim().isNotEmpty) {
      return nextEmiDate.toString();
    }

    return "N/A";
  }

  @override
  void initState() {
    super.initState();
    _fetchLoanHistory();
  }

  Future<void> _fetchLoanHistory() async {
    try {
      final apiService = Get.find<ApiService>();
      final historyResponse = await apiService.getRequest('/api/dashboard/loan-history/${widget.branchId}');

      // Fetch loans due soon
      final dueResponse = await apiService.getRequest('/api/dashboard/loans-due-soon/${widget.branchId}');

      if (historyResponse.statusCode == 200 && dueResponse.statusCode == 200) {
        setState(() {
          recentLoans = jsonDecode(historyResponse.body) ?? [];
          loansDueSoon = jsonDecode(dueResponse.body) ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load loan history';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching loan history: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFecb613);
    const Color bgLight = Color(0xFFF8F8F6);
    const Color textDark = Color(0xFF1e1e1e);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgLight.withOpacity(0.9),
        title: Text(
          "Loan History",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textDark,
          ),
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Loans Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Recent Loans",
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                      if (recentLoans.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "No recent loans",
                              style: GoogleFonts.manrope(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentLoans.length,
                          itemBuilder: (context, index) {
                            final loan = recentLoans[index];
                            return _buildLoanCard(
                              loan,
                              primaryColor,
                              Icons.trending_up,
                            );
                          },
                        ),
                      const SizedBox(height: 20),

                      // Loans Due Soon Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Loans Due Soon (Next 30 Days)",
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                      if (loansDueSoon.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "No loans due soon",
                              style: GoogleFonts.manrope(
                                color: Colors.green.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: loansDueSoon.length,
                          itemBuilder: (context, index) {
                            final loan = loansDueSoon[index];
                            return _buildLoanCard(
                              loan,
                              Colors.orange,
                              Icons.warning_amber,
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLoanCard(
    Map<String, dynamic> loan,
    Color accentColor,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor),
        ),
        title: Text(
          'Loan #${loan['id'] ?? "N/A"}',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ₹${_toDouble(loan['loanAmount']).toStringAsFixed(2)}',
              style: GoogleFonts.manrope(fontSize: 12),
            ),
            Text(
              'Status: ${loan['status'] ?? "UNKNOWN"}',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: loan['status'] == 'ACTIVE' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Text(
          _displayDate(loan),
          style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
