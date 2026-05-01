import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_management_app/Service/GoldPriceService.dart';
import 'package:loan_management_app/Service/api_service.dart';
import 'package:loan_management_app/Pages/EMICalculatorPage.dart';
import 'package:loan_management_app/Pages/AddNewCustomerPage.dart';
import 'package:loan_management_app/Pages/LoanHistoryPage.dart';
import 'package:loan_management_app/Pages/CustomersPage.dart';

class DashboardPage extends StatefulWidget {
  final int branchId;
  const DashboardPage({super.key, required this.branchId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _goldData;
  String? _branchName;
  List<dynamic> _upcomingPayments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Critical path: load only the minimum needed for first paint.
      await _loadDashboardStats();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Non-critical sections continue in the background.
      _loadBranchName();
      _loadGoldPrice();
      _loadUpcomingPayments();
    } catch (e) {
      debugPrint('❌ Error loading dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading dashboard data';
        });
      }
    }
  }

  Future<void> _loadBranchName() async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.getRequest('/api/branches/details?branchId=${widget.branchId}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final branchData = jsonDecode(response.body);
        setState(() {
          _branchName = branchData['branchName'] ?? 'Branch';
        });
      } else {
        debugPrint('⚠️ Failed to load branch name: ${response.statusCode}');
        setState(() {
          _branchName = 'Branch';
        });
      }
    } catch (e) {
      debugPrint('⚠️ Could not load branch name: $e');
      if (mounted) {
        setState(() {
          _branchName = 'Branch';
        });
      }
    }
  }

  Future<void> _loadGoldPrice() async {
    try {
      final service = GoldPriceService();
      final data = await service.fetchAndStoreGoldPrice();

      if (mounted && data != null) {
        setState(() {
          _goldData = data;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Could not load gold price: $e');
      // Don't fail entire dashboard if gold price fails
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.getRequest('/api/dashboard/stats/${widget.branchId}');

      if (response.statusCode == 200) {
        final stats = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _dashboardStats = stats;
        });
      } else {
        throw Exception('Failed to load dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error loading dashboard stats: $e');
      if (!mounted) return;

      // Provide default empty stats if load fails
      setState(() {
        _dashboardStats = {
          'totalCustomers': 0,
          'activeLoanCount': 0,
          'totalAmountLent': 0,
          'pendingEmis': 0,
          'overdueEmis': 0,
        };
      });
    }
  }

  Future<void> _loadUpcomingPayments() async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.getRequest(
        '/api/dashboard/loans-due-soon/${widget.branchId}?days=3',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _upcomingPayments = jsonDecode(response.body) ?? [];
        });
      } else {
        throw Exception('Failed to load upcoming payments: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error loading upcoming payments: $e');
      if (!mounted) return;

      setState(() {
        _upcomingPayments = [];
      });
    }
  }

  Future<void> _logout() async {
    debugPrint('🚪 [LOGOUT] Logout initiated');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('❌ [LOGOUT] Cancelled by user');
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                debugPrint('✅ [LOGOUT] Logout confirmed');
                Navigator.of(context).pop();
                
                try {
                  debugPrint('🔄 [LOGOUT] Calling logout on ApiService');
                  final apiService = Get.find<ApiService>();
                  await apiService.logout();
                  debugPrint('✅ [LOGOUT] Logout successful');
                  
                  debugPrint('🎯 [LOGOUT] Navigating to login page');
                  Get.offAllNamed('/login');
                } catch (e) {
                  debugPrint('❌ [LOGOUT] Error during logout: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
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
        titleSpacing: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _branchName ?? "Loan Management",
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textDark,
                ),
              ),
              Text(
                "Branch Dashboard",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black87,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.black87,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFecb613)),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gold Price Card
                    _goldPriceCard(primaryColor, _goldData),
                    const SizedBox(height: 16),

                    // Statistics Row 1
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Customers",
                            (_dashboardStats?['totalCustomers'] ?? 0).toString(),
                            primaryColor,
                            textDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            "Active Loans",
                            (_dashboardStats?['activeLoanCount'] ?? 0).toString(),
                            primaryColor,
                            textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Statistics Row 2
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildStatCard(
                    //         "Pending EMIs",
                    //         (_dashboardStats?['pendingEmis'] ?? 0).toString(),
                    //         Colors.orange,
                    //         textDark,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     Expanded(
                    //       child: _buildStatCard(
                    //         "Overdue EMIs",
                    //         (_dashboardStats?['overdueEmis'] ?? 0).toString(),
                    //         Colors.red,
                    //         textDark,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 20),

                    // Quick Links
                    Text(
                      "Quick Links",
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        _quickLink(
                          Icons.add_card,
                          "New Loan",
                          primaryColor,
                          textDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmiCalculatorPage(branchId: widget.branchId),
                            ),
                          ),
                        ),
                        _quickLink(
                          Icons.person_add,
                          "New Customer",
                          primaryColor,
                          textDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddNewCustomerPage(branchId: widget.branchId),
                            ),
                          ),
                        ),
                        _quickLink(
                          Icons.receipt_long,
                          "Reports",
                          primaryColor,
                          textDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoanHistoryPage(branchId: widget.branchId),
                            ),
                          ),
                        ),
                        _quickLink(
                          Icons.sms,
                          "Customers",
                          primaryColor,
                          textDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomersPage(branchId: widget.branchId),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Upcoming Payments Section
                    Text(
                      "Upcoming Payments",
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_upcomingPayments.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Loading upcoming payments or no payments due in the next 3 days.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      ..._upcomingPayments
                          .take(5)
                          .map((loan) => _paymentCard(Map<String, dynamic>.from(loan)))
                          .toList(),
                    const SizedBox(height: 6),
                    if (_upcomingPayments.isNotEmpty)
                      Center(
                        child: Text(
                          "Showing payments due in next 3 days",
                          style: GoogleFonts.manrope(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _goldPriceCard(Color primaryColor, Map<String, dynamic>? goldData) {
    String pricePerGramText;
    String pricePerKgText;

    if (goldData != null) {
      final double pricePerGram = (goldData['price_per_gram'] ?? 0).toDouble();
      final double pricePerKg = (goldData['price_per_kg'] ?? 0).toDouble();
      
      pricePerGramText = '₹${pricePerGram.toStringAsFixed(2)}/g';
      pricePerKgText = '₹${(pricePerKg).toStringAsFixed(0)}/kg';
    } else {
      pricePerGramText = 'Loading...';
      pricePerKgText = 'Loading...';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.payments, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Live Gold Price (24K)",
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                "just now",
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Per Gram",
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    pricePerGramText,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Per KG",
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    pricePerKgText,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color accentColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up,
                  color: accentColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickLink(
    IconData icon,
    String label,
    Color accentColor,
    Color textColor,
    {required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard(Map<String, dynamic> loan) {
    final customer = loan['customer'] is Map
        ? Map<String, dynamic>.from(loan['customer'])
        : <String, dynamic>{};
    final String name = customer['name']?.toString() ?? 'Customer';
    final String customerId = customer['customerId']?.toString() ?? 'N/A';
    final dynamic rawAmount = loan['emi'] ?? loan['loanAmount'] ?? 0;
    final double amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount.toString()) ?? 0;
    final String dueDate = loan['nextEmiDate']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFecb613).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.calendar_today,
            color: Color(0xFFecb613),
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          'ID: $customerId',
          style: GoogleFonts.manrope(fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹ ${amount.toStringAsFixed(2)}',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              dueDate,
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
