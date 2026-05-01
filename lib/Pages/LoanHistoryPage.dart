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
  int selectedTabIndex = 0;

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
      debugPrint('❌ Error fetching loan history: $e');
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
    final bool showingRecent = selectedTabIndex == 0;
    final List<dynamic> activeList = showingRecent ? recentLoans : loansDueSoon;
    final Color activeAccentColor = showingRecent ? primaryColor : Colors.orange;
    final IconData activeIcon = showingRecent ? Icons.trending_up : Icons.warning_amber;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgLight.withOpacity(0.9),
        title: Text(
          "Loan History",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildHorizontalTab(
                                label: "Recent",
                                subtitle: "Latest loans",
                                isSelected: showingRecent,
                                onTap: () => setState(() => selectedTabIndex = 0),
                                activeColor: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildHorizontalTab(
                                label: "Loan Due Soon",
                                subtitle: "Next 30 days",
                                isSelected: !showingRecent,
                                onTap: () => setState(() => selectedTabIndex = 1),
                                activeColor: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showingRecent ? "Recent Loans" : "Loans Due Soon",
                              style: GoogleFonts.manrope(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              showingRecent
                                  ? "Latest loan records for this branch"
                                  : "Loans with upcoming EMI dates",
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (activeList.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    showingRecent ? "No recent loans" : "No loans due soon",
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
                                itemCount: activeList.length,
                                itemBuilder: (context, index) {
                                  final loan = activeList[index];
                                  return _buildLoanCard(
                                    loan,
                                    activeAccentColor,
                                    activeIcon,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHorizontalTab({
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.14) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? activeColor : const Color(0xFF1e1e1e),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
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
