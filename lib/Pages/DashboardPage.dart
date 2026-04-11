import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_management_app/Service/GoldPriceService.dart';

class DashboardPage extends StatefulWidget {
  final int branchId;
  const DashboardPage({super.key, required this.branchId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _goldData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load both gold price and dashboard stats concurrently
      final goldFuture = _loadGoldPrice();
      final statsFuture = _loadDashboardStats();

      await Future.wait([goldFuture, statsFuture]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading dashboard data';
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
      print('⚠️ Could not load gold price: $e');
      // Don't fail entire dashboard if gold price fails
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/dashboard/stats/${widget.branchId}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final stats = jsonDecode(response.body);
        setState(() {
          _dashboardStats = stats;
        });
      } else {
        throw Exception('Failed to load dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading dashboard stats: $e');
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Loan Management",
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Pending EMIs",
                            (_dashboardStats?['pendingEmis'] ?? 0).toString(),
                            Colors.orange,
                            textDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            "Overdue EMIs",
                            (_dashboardStats?['overdueEmis'] ?? 0).toString(),
                            Colors.red,
                            textDark,
                          ),
                        ),
                      ],
                    ),
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
                        ),
                        _quickLink(
                          Icons.person_add,
                          "New Customer",
                          primaryColor,
                          textDark,
                        ),
                        _quickLink(
                          Icons.receipt_long,
                          "Reports",
                          primaryColor,
                          textDark,
                        ),
                        _quickLink(
                          Icons.sms,
                          "Send SMS",
                          primaryColor,
                          textDark,
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
                    _paymentCard("Rohan Mehra", "23456", "₹ 5,000", "Jul 15"),
                    _paymentCard("Sonia Gupta", "78901", "₹ 7,500", "Jul 20"),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        "View All Upcoming Payments",
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
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 8),
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
  ) {
    return Container(
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
    );
  }

  Widget _paymentCard(
    String name,
    String customerId,
    String amount,
    String dueDate,
  ) {
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
              amount,
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


// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const Color primaryColor = Color(0xFFecb613);
//     const Color bgLight = Color(0xFFf8f8f6);
//     const Color textDark = Color(0xFF1e1e1e);

//     return Scaffold(
//       backgroundColor: bgLight,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: bgLight.withOpacity(0.9),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Aurum Jewels",
//                 style: GoogleFonts.manrope(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: textDark)),
//             Text("Main Branch",
//                 style: GoogleFonts.manrope(
//                     fontSize: 13, color: Colors.grey.shade600)),
//           ],
//         ),
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                   onPressed: () {},
//                   icon: const Icon(Icons.notifications_none_rounded,
//                       color: Colors.black87)),
//               Positioned(
//                 right: 10,
//                 top: 10,
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: primaryColor,
//                   ),
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Gold Price Card
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 gradient: const LinearGradient(
//                     colors: [Color(0xFFecb613), Color(0xFFf7d149)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight),
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3))
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.payments,
//                               color: Colors.white, size: 18),
//                           const SizedBox(width: 6),
//                           Text("Live Gold Price (24K)",
//                               style: GoogleFonts.manrope(
//                                   fontSize: 13,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600)),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const Icon(Icons.schedule,
//                               color: Colors.white70, size: 14),
//                           const SizedBox(width: 3),
//                           Text("just now",
//                               style: GoogleFonts.manrope(
//                                   color: Colors.white70, fontSize: 12)),
//                         ],
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("₹ 6,850/gm",
//                           style: GoogleFonts.manrope(
//                               color: Colors.white,
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold)),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text("+0.25%",
//                               style: GoogleFonts.manrope(
//                                   color: Colors.greenAccent.shade100,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600)),
//                           Text("vs yesterday",
//                               style: GoogleFonts.manrope(
//                                   color: Colors.white70, fontSize: 11)),
//                         ],
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Stats Row
//             Row(
//               children: [
//                 Expanded(
//                     child: _buildStatCard(
//                         "Users", "350", primaryColor, textDark)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: _buildStatCard(
//                         "Active Loans", "254", primaryColor, textDark)),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Quick Links
//             Text("Quick Links",
//                 style: GoogleFonts.manrope(
//                     fontSize: 16,
//                     color: textDark,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             GridView.count(
//               crossAxisCount: 4,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//               children: [
//                 _quickLink(Icons.add_card, "New Loan", primaryColor, textDark),
//                 _quickLink(Icons.person_add, "Add User", primaryColor, textDark),
//                 _quickLink(Icons.receipt_long, "Reports", primaryColor, textDark),
//                 _quickLink(Icons.sms, "Send SMS", primaryColor, textDark),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Upcoming Payments
//             Text("Upcoming Payments",
//                 style: GoogleFonts.manrope(
//                     fontSize: 16,
//                     color: textDark,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             _paymentCard("Rohan Mehra", "23456", "₹ 5,000", "Jul 15"),
//             _paymentCard("Sonia Gupta", "78901", "₹ 7,500", "Jul 20"),
//             const SizedBox(height: 6),
//             Center(
//                 child: Text("View All Upcoming Payments",
//                     style: GoogleFonts.manrope(
//                         color: primaryColor,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13))),

//             const SizedBox(height: 25),

//             // Activities
//             Text("Activities",
//                 style: GoogleFonts.manrope(
//                     fontSize: 16,
//                     color: textDark,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             _activityCard(
//                 Icons.request_quote,
//                 "New loan request from 'Amit Patel'.",
//                 "10 mins ago",
//                 Colors.green.shade200,
//                 "New"),
//             _activityCard(Icons.payments,
//                 "EMI payment of ₹5,000 received from 'Rohan M'.", "35 mins ago"),
//             _activityCard(Icons.quiz,
//                 "Inquiry about gold purity from 'Priya Singh'.", "1 hour ago"),
//             const SizedBox(height: 10),
//             Center(
//                 child: Text("View All Activities",
//                     style: GoogleFonts.manrope(
//                         color: primaryColor,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13))),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),

//       // Bottom Navigation Bar
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: primaryColor,
//         unselectedItemColor: Colors.grey.shade600,
//         showUnselectedLabels: true,
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.grid_view_rounded),
//               label: "Dashboard"

//           ),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.group), label: "Customers"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.account_balance_wallet), label: "Loans"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.description), label: "Documents"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.calculate), label: "Calculator"),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, Color primary, Color text) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: primary.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Text(title,
//               style: GoogleFonts.manrope(
//                   color: Colors.grey.shade700,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500)),
//           const SizedBox(height: 4),
//           Text(value,
//               style: GoogleFonts.manrope(
//                   fontSize: 22, fontWeight: FontWeight.bold, color: text)),
//         ],
//       ),
//     );
//   }

//   Widget _quickLink(IconData icon, String label, Color primary, Color text) {
//     return Container(
//       decoration: BoxDecoration(
//         color: primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//               radius: 16,
//               backgroundColor: primary.withOpacity(0.25),
//               child: Icon(icon, size: 18, color: primary)),
//           const SizedBox(height: 5),
//           Text(label,
//               textAlign: TextAlign.center,
//               style: GoogleFonts.manrope(
//                   fontSize: 11,
//                   color: Colors.grey.shade800,
//                   fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }

//   Widget _paymentCard(
//       String name, String id, String amount, String dateLabel) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: const [
//           BoxShadow(
//               color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: const Color(0xFFecb613).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(dateLabel.split(" ")[0].toUpperCase(),
//                       style: GoogleFonts.manrope(
//                           fontSize: 10, color: const Color(0xFFecb613))),
//                   Text(dateLabel.split(" ")[1],
//                       style: GoogleFonts.manrope(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: const Color(0xFFecb613))),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name,
//                     style: GoogleFonts.manrope(
//                         fontSize: 13,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w600)),
//                 Text("Loan ID: $id",
//                     style: GoogleFonts.manrope(
//                         fontSize: 11, color: Colors.grey.shade600)),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(amount,
//                   style: GoogleFonts.manrope(
//                       fontSize: 13,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w600)),
//               Container(
//                 margin: const EdgeInsets.only(top: 3),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                     color: Colors.orange.shade100,
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Text("Upcoming",
//                     style: GoogleFonts.manrope(
//                         color: Colors.orange.shade800,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600)),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _activityCard(IconData icon, String desc, String time,
//       [Color? badgeColor, String? badgeText]) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: const [
//             BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
//           ]),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//               backgroundColor: const Color(0xFFecb613).withOpacity(0.2),
//               child: Icon(icon, color: const Color(0xFFecb613), size: 18)),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(desc,
//                     style: GoogleFonts.manrope(
//                         fontSize: 12,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w500)),
//                 Text(time,
//                     style: GoogleFonts.manrope(
//                         fontSize: 10, color: Colors.grey.shade600)),
//               ],
//             ),
//           ),
//           if (badgeText != null)
//             Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                   color: badgeColor ?? Colors.green.shade100,
//                   borderRadius: BorderRadius.circular(8)),
//               child: Text(badgeText,
//                   style: GoogleFonts.manrope(
//                       fontSize: 10,
//                       color: Colors.green.shade800,
//                       fontWeight: FontWeight.w600)),
//             )
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:loan_management_app/Components/NavigationBarPage.dart';

// class DashboardPage extends StatefulWidget {
//   final int branchId;
//   const DashboardPage({super.key, required this.branchId});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   Map<String, dynamic>? _goldData;
//   Map<String, dynamic>? _dashboardStats;
//   bool _isLoading = true;
//   bool _isError = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadDashboardData();
//   }

//   Future<void> _loadDashboardData() async {
//     try {
//       // Load both gold price and dashboard stats concurrently
//       await Future.wait([
//         _loadGoldPrice(),
//         _loadDashboardStats(),
//       ]);
//     } catch (e) {
//       print('❌ Error loading dashboard: $e');
//       if (mounted) {
//         setState(() {
//           _isError = true;
//           _errorMessage = 'Error loading dashboard data';
//         });
//       }
//     }
//   }

//   Future<void> _loadGoldPrice() async {
//     if (!mounted) return;

//     try {
//       final service = GoldPriceService();
//       final data = await service.fetch24kGoldPriceINR();

//       if (!mounted) return;

//       if (data != null) {
//         setState(() {
//           _goldData = data;
//           _isError = false;
//         });
//       }
//     } catch (e) {
//       print('⚠️ Could not load gold price: $e');
//       // Don't fail entire dashboard if gold price fails
//     }
//   }

//   Future<void> _loadDashboardStats() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:8080/api/dashboard/stats/${widget.branchId}'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 10));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final stats = jsonDecode(response.body);
//         setState(() {
//           _dashboardStats = stats;
//           _isLoading = false;
//           _isError = false;
//         });
//       } else {
//         throw Exception('Failed to load dashboard stats: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error loading dashboard stats: $e');
//       if (!mounted) return;

//       setState(() {
//         _dashboardStats = {
//           'totalCustomers': 0,
//           'activeLoanCount': 0,
//           'totalAmountLent': 0,
//           'pendingEmis': 0,
//           'overdueEmis': 0,
//         };
//         _isLoading = false;
//         _isError = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const Color primaryColor = Color(0xFFecb613);
//     const Color bgLight = Color(0xFFf8f8f6);
//     const Color textDark = Color(0xFF1e1e1e);

//     return Scaffold(
//       backgroundColor: bgLight,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: bgLight.withOpacity(0.9),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Tanishaq Jewels",
//               style: GoogleFonts.manrope(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: textDark,
//               ),
//             ),
//             Text(
//               "Main Branch",
//               style: GoogleFonts.manrope(
//                 fontSize: 13,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(
//                   Icons.notifications_none_rounded,
//                   color: Colors.black87,
//                 ),
//               ),
//               Positioned(
//                 right: 10,
//                 top: 10,
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: primaryColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadDashboardData,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(12),
//           child: _isLoading
//               ? const Center(
//                   child: CircularProgressIndicator(color: primaryColor),
//                 )
//               : Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _goldPriceCard(primaryColor, _goldData),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatCard(
//                             "Customers",
//                             (_dashboardStats?['totalCustomers'] ?? 0).toString(),
//                             primaryColor,
//                             textDark,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _buildStatCard(
//                             "Active Loans",
//                             (_dashboardStats?['activeLoanCount'] ?? 0).toString(),
//                             primaryColor,
//                             textDark,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatCard(
//                             "Pending EMIs",
//                             (_dashboardStats?['pendingEmis'] ?? 0).toString(),
//                             Colors.orange,
//                             textDark,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _buildStatCard(
//                             "Overdue EMIs",
//                             (_dashboardStats?['overdueEmis'] ?? 0).toString(),
//                             Colors.red,
//                             textDark,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       "Quick Links",
//                       style: GoogleFonts.manrope(
//                         fontSize: 16,
//                         color: textDark,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     GridView.count(
//                       crossAxisCount: 4,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisSpacing: 8,
//                       mainAxisSpacing: 8,
//                       children: [
//                         _quickLink(
//                           Icons.add_card,
//                           "New Loan",
//                           primaryColor,
//                           textDark,
//                         ),
//                         _quickLink(
//                           Icons.person_add,
//                           "Add User",
//                           primaryColor,
//                           textDark,
//                         ),
//                         _quickLink(
//                           Icons.receipt_long,
//                           "Reports",
//                           primaryColor,
//                           textDark,
//                         ),
//                         _quickLink(Icons.sms, "Send SMS", primaryColor, textDark),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       "Upcoming Payments",
//                       style: GoogleFonts.manrope(
//                         fontSize: 16,
//                         color: textDark,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     _paymentCard("Rohan Mehra", "23456", "₹ 5,000", "Jul 15"),
//                     _paymentCard("Sonia Gupta", "78901", "₹ 7,500", "Jul 20"),
//                     const SizedBox(height: 6),
//                     Center(
//                       child: Text(
//                         "View All Upcoming Payments",
//                         style: GoogleFonts.manrope(
//                           color: primaryColor,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                   ],
//                 ),
//         ),
//       ),
              
//               const SizedBox(height: 10),
//               _activityCard(
//                 Icons.request_quote,
//                 "New loan request from 'Amit Patel'.",
//                 "10 mins ago",
//                 Colors.green.shade200,
//                 "New",
//               ),
//               _activityCard(
//                 Icons.payments,
//                 "EMI payment of ₹5,000 received from 'Rohan M'.",
//                 "35 mins ago",
//               );
//               _activityCard(
//                 Icons.quiz,
//                 "Inquiry about gold purity from 'Priya Singh'.",
//                 "1 hour ago",
//               );
//               const SizedBox(height: 10),
//               Center(
//                 child: Text(
//                   "View All Activities",
//                   style: GoogleFonts.manrope(
//                     color: primaryColor,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: NavigationBarPage(branchId: widget.branchId),
//     );
//   }

//   Widget _goldPriceCard(Color primaryColor, Map<String, dynamic>? goldData) {
//     String priceText;
//     String changePercent = '';
//     String comparisonText = '';

//     if (_isLoading) {
//       priceText = 'Loading...';
//     } else if (_isError || goldData == null) {
//       priceText = 'Error fetching price';
//     } else {
//       final double price = (goldData['price'] as num).toDouble() / 31.1035;
//       final double changePercentVal =
//           (goldData['chp'] as num?)?.toDouble() ?? 0.0;
//       priceText = '₹ ${price.toStringAsFixed(2)}/gm';
//       changePercent =
//           '${changePercentVal >= 0 ? '+' : ''}${changePercentVal.toStringAsFixed(2)}%';
//       comparisonText = 'vs yesterday';
//     }

//     final bool isPositive = (goldData?['chp'] ?? 0) >= 0;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         gradient: const LinearGradient(
//           colors: [Color(0xFFecb613), Color(0xFFf7d149)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 priceText,
//                 style: GoogleFonts.manrope(
//                   color: Colors.white,
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Live 24K Gold Rate (INR)",
//                 style: GoogleFonts.manrope(
//                   color: Colors.white70,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 changePercent,
//                 style: GoogleFonts.manrope(
//                   color: isPositive
//                       ? Colors.greenAccent.shade100
//                       : Colors.redAccent.shade100,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 comparisonText,
//                 style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, Color primary, Color text) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: primary.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.manrope(
//               color: Colors.grey.shade700,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: GoogleFonts.manrope(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: text,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _quickLink(IconData icon, String label, Color primary, Color text) {
//     return Container(
//       decoration: BoxDecoration(
//         color: primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 16,
//             backgroundColor: primary.withOpacity(0.25),
//             child: Icon(icon, size: 18, color: primary),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.manrope(
//               fontSize: 11,
//               color: Colors.grey.shade800,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _paymentCard(String name, String id, String amount, String dateLabel) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: const Color(0xFFecb613).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     dateLabel.split(" ")[0].toUpperCase(),
//                     style: GoogleFonts.manrope(
//                       fontSize: 10,
//                       color: const Color(0xFFecb613),
//                     ),
//                   ),
//                   Text(
//                     dateLabel.split(" ")[1],
//                     style: GoogleFonts.manrope(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFFecb613),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: GoogleFonts.manrope(
//                     fontSize: 13,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   "Loan ID: $id",
//                   style: GoogleFonts.manrope(
//                     fontSize: 11,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 amount,
//                 style: GoogleFonts.manrope(
//                   fontSize: 13,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.only(top: 3),
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   "Upcoming",
//                   style: GoogleFonts.manrope(
//                     color: Colors.orange.shade800,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _activityCard(
//     IconData icon,
//     String desc,
//     String time, [
//     Color? badgeColor,
//     String? badgeText,
//   ]) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             backgroundColor: const Color(0xFFecb613).withOpacity(0.2),
//             child: Icon(icon, color: const Color(0xFFecb613), size: 18),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   desc,
//                   style: GoogleFonts.manrope(
//                     fontSize: 12,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   time,
//                   style: GoogleFonts.manrope(
//                     fontSize: 10,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (badgeText != null)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: badgeColor ?? Colors.green.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 badgeText,
//                 style: GoogleFonts.manrope(
//                   fontSize: 10,
//                   color: Colors.green.shade800,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class GoldPriceService {
//   final String apiKey = 'goldapi-1wwsrsmhk1a21u-io'; // your API key

//   Future<Map<String, dynamic>?> fetch24kGoldPriceINR() async {
//     final url = Uri.parse('https://www.goldapi.io/api/XAU/INR');

//     try {
//       final response = await http.get(
//         url,
//         headers: {'x-access-token': apiKey, 'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         debugPrint("✅ Gold price fetched successfully");
//         return data;
//       } else {
//         debugPrint("❌ API Error ${response.statusCode}: ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       debugPrint("⚠️ Network error: $e");
//       return null;
//     }
//   }
// }
