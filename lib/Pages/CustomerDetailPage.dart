import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_management_app/Pages/PayEmiPage.dart';
import 'package:loan_management_app/Service/api_service.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String customerId;
  final String name;
  final String imageUrl;

  const CustomerDetailsPage({
    super.key,
    required this.customerId,
    required this.name,
    required this.imageUrl,
  });

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  bool isLoading = true;
  bool isError = false;

  final apiService = Get.find<ApiService>();

  Map<String, dynamic>? customerProfile;
  List<Map<String, dynamic>> customerLoans = [];
  final Map<String, Map<String, dynamic>> paymentScheduleByLoanId = {};

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  double toDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  int toInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  Future<void> fetchCustomerData() async {
    try {
      final customerResponse = await apiService.getRequest(
        "/api/customers/by-id/${widget.customerId}",
      );
      final loansResponse = await apiService.getRequest(
        "/api/loans/customer/${widget.customerId}",
      );

      if (customerResponse.statusCode != 200 || loansResponse.statusCode != 200) {
        setState(() {
          isLoading = false;
          isError = true;
        });
        return;
      }

      final customerDecoded = jsonDecode(customerResponse.body);
      final loansDecoded = jsonDecode(loansResponse.body);

      final loans = (loansDecoded as List)
          .whereType<Map>()
          .map((loan) => Map<String, dynamic>.from(loan))
          .toList();

      loans.sort((a, b) {
        final aActive = isLoanActive(a) ? 0 : 1;
        final bActive = isLoanActive(b) ? 0 : 1;
        if (aActive != bActive) return aActive.compareTo(bActive);
        return toInt(b['id']).compareTo(toInt(a['id']));
      });

      final scheduleEntries = await Future.wait(
        loans.map((loan) async {
          final loanId = toInt(loan['id']);
          try {
            final scheduleResponse = await apiService.getRequest(
              "/api/emis/schedule/$loanId",
            );

            if (scheduleResponse.statusCode == 200) {
              final schedule = jsonDecode(scheduleResponse.body);
              if (schedule is Map<String, dynamic>) {
                return MapEntry(loanId.toString(), schedule);
              }
            }
          } catch (_) {}
          return null;
        }),
      );

      paymentScheduleByLoanId
        ..clear()
        ..addEntries(
          scheduleEntries.whereType<MapEntry<String, Map<String, dynamic>>>(),
        );

      setState(() {
        customerProfile = customerDecoded is Map<String, dynamic>
            ? customerDecoded
            : null;
        customerLoans = loans;
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      debugPrint("❌ Exception: $e");
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  bool isLoanActive(Map<String, dynamic> loan) {
    return loan['status']?.toString().toUpperCase() == "ACTIVE";
  }

  Map<String, dynamic>? scheduleFor(Map<String, dynamic> loan) {
    return paymentScheduleByLoanId[toInt(loan['id']).toString()];
  }

  int totalEmisFor(Map<String, dynamic> loan) {
    final schedule = scheduleFor(loan);
    return toInt(schedule?['totalEmis'] ?? loan['totalEmis'] ?? loan['tenure']);
  }

  int paidEmisFor(Map<String, dynamic> loan) {
    final schedule = scheduleFor(loan);
    return toInt(schedule?['paidEmis'] ?? loan['paidEmis']);
  }

  int remainingEmisFor(Map<String, dynamic> loan) {
    final schedule = scheduleFor(loan);
    return toInt(schedule?['remainingEmis'] ?? loan['remainingEmis']);
  }

  double remainingAmountFor(Map<String, dynamic> loan) {
    final schedule = scheduleFor(loan);
    return toDouble(schedule?['remainingAmount'] ?? loan['remainingAmount']);
  }

  double payableAmountFor(Map<String, dynamic> loan) {
    final schedule = scheduleFor(loan);
    return toDouble(schedule?['monthlyEmi'] ?? loan['emi']);
  }

  String nextEmiDateFor(Map<String, dynamic> loan) {
    final schedule = scheduleFor(loan);
    final value = schedule?['nextEmiDate'] ?? loan['nextEmiDate'];
    final text = value?.toString() ?? "";
    return text.isEmpty ? "N/A" : text;
  }

  bool isUpcomingEmi(Map<String, dynamic> loan) {
    return isLoanActive(loan) && remainingEmisFor(loan) > 0;
  }

  List<Map<String, dynamic>> get activeLoans {
    return customerLoans.where(isLoanActive).toList();
  }

  List<Map<String, dynamic>> get upcomingEmiLoans {
    return customerLoans.where(isUpcomingEmi).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.2,
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text("Failed to load customer details"))
              : RefreshIndicator(
                  onRefresh: fetchCustomerData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      buildCustomerHeader(),
                      const SizedBox(height: 18),
                      buildCustomerProfileCard(),
                      const SizedBox(height: 18),
                      buildSectionHeader(
                        title: "Active Loans",
                        actionLabel: "See All Loan Details",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerLoanDetailsPage(
                                customerName: widget.name,
                                loans: customerLoans,
                                paymentScheduleByLoanId: paymentScheduleByLoanId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      if (activeLoans.isEmpty)
                        buildEmptyCard("No active loans for this customer.")
                      else
                        ...activeLoans.map(buildCompactLoanCard),
                      const SizedBox(height: 18),
                      buildSectionHeader(
                        title: "Upcoming EMIs",
                        actionLabel: "See All EMI Details",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerEmiDetailsPage(
                                customerName: widget.name,
                                customerId: widget.customerId,
                                loans: customerLoans,
                                paymentScheduleByLoanId: paymentScheduleByLoanId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      if (upcomingEmiLoans.isEmpty)
                        buildEmptyCard("No upcoming EMI available right now.")
                      else
                        ...upcomingEmiLoans.map(buildUpcomingEmiCard),
                    ],
                  ),
                ),
    );
  }

  Widget buildCustomerHeader() {
    final name = customerProfile?['name']?.toString() ?? widget.name;
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: const Color(0xFFFAF6E8),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.customerId,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCustomerProfileCard() {
    final profile = customerProfile ?? {};
    final branchName = profile['branch'] is Map
        ? profile['branch']['name']?.toString() ?? "N/A"
        : "N/A";
    final isVerified = profile['isPhoneVerified'] == true;
    final isWhatsappOptIn = profile['isWhatsappOptIn'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Details",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          detailRow("Name", profile['name']?.toString() ?? widget.name),
          const SizedBox(height: 10),
          detailRow("Phone", profile['customerId']?.toString() ?? widget.customerId),
          const SizedBox(height: 10),
          detailRow("Email", profile['email']?.toString() ?? "N/A"),
          const SizedBox(height: 10),
          detailRow("Branch", branchName),
          const SizedBox(height: 10),
          detailRow("Aadhaar", profile['aadharNumber']?.toString() ?? "N/A"),
          const SizedBox(height: 10),
          detailRow("PAN", profile['panNumber']?.toString() ?? "N/A"),
          const SizedBox(height: 10),
          detailRow("Address", profile['address']?.toString() ?? "N/A"),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildTag(
                isVerified ? "Phone Verified" : "Phone Not Verified",
                isVerified ? Colors.green : Colors.orange,
              ),
              buildTag(
                isWhatsappOptIn ? "WhatsApp Opt-In" : "WhatsApp Opt-Out",
                isWhatsappOptIn ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }

  Widget buildCompactLoanCard(Map<String, dynamic> loan) {
    final totalAmount = toDouble(loan['totalAmount']);
    final remainingAmount = remainingAmountFor(loan);
    final totalEmis = totalEmisFor(loan);
    final paidEmis = paidEmisFor(loan);
    final progress =
        totalEmis > 0 ? (paidEmis / totalEmis).clamp(0, 1).toDouble() : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Loan #${loan['id']}",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                loan['status']?.toString() ?? "UNKNOWN",
                style: const TextStyle(
                  color: Color(0xFFecb613),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          detailRow("Loan Amount", "₹${toDouble(loan['loanAmount']).toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          detailRow("Total Payable", "₹${totalAmount.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          detailRow("Remaining Amount", "₹${remainingAmount.toStringAsFixed(2)}"),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: const Color(0xFFecb613),
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUpcomingEmiCard(Map<String, dynamic> loan) {
    final payableAmount = payableAmountFor(loan);
    final remainingAmount = remainingAmountFor(loan);
    final totalEmis = totalEmisFor(loan);
    final paidEmis = paidEmisFor(loan);
    final remainingEmis = remainingEmisFor(loan);
    final nextEmiDate = nextEmiDateFor(loan);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Loan #${loan['id']}",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          detailRow("Next EMI Date", nextEmiDate),
          const SizedBox(height: 8),
          detailRow("Upcoming EMI", "₹${payableAmount.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          detailRow("EMI Progress", "$paidEmis/$totalEmis paid"),
          const SizedBox(height: 8),
          detailRow("Remaining EMIs", remainingEmis.toString()),
          const SizedBox(height: 8),
          detailRow("Remaining Loan", "₹${remainingAmount.toStringAsFixed(2)}"),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: remainingEmis <= 0 || payableAmount <= 0
                  ? null
                  : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PayEmiPage(
                            loanId: loan['id']?.toString() ?? "",
                            customerId: widget.customerId,
                            remainingLoanAmount: remainingAmount,
                            payableAmount: payableAmount,
                            totalEmis: totalEmis,
                            paidEmis: paidEmis,
                            remainingEmis: remainingEmis,
                            nextEmiDate: nextEmiDate,
                          ),
                        ),
                      );

                      if (result != null &&
                          result is Map &&
                          result["success"] == true) {
                        await Future.delayed(const Duration(milliseconds: 400));
                        await fetchCustomerData();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFecb613),
                foregroundColor: Colors.black87,
              ),
              child: const Text("Pay EMI"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomerLoanDetailsPage extends StatelessWidget {
  final String customerName;
  final List<Map<String, dynamic>> loans;
  final Map<String, Map<String, dynamic>> paymentScheduleByLoanId;

  const CustomerLoanDetailsPage({
    super.key,
    required this.customerName,
    required this.loans,
    required this.paymentScheduleByLoanId,
  });

  double toDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  int toInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic>? scheduleFor(Map<String, dynamic> loan) {
    return paymentScheduleByLoanId[toInt(loan['id']).toString()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: Text("$customerName Loans"),
        backgroundColor: Colors.white,
        elevation: 0.2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          final loan = loans[index];
          final schedule = scheduleFor(loan);
          final totalEmis =
              toInt(schedule?['totalEmis'] ?? loan['totalEmis'] ?? loan['tenure']);
          final paidEmis = toInt(schedule?['paidEmis'] ?? loan['paidEmis']);
          final remainingEmis =
              toInt(schedule?['remainingEmis'] ?? loan['remainingEmis']);
          final remainingAmount =
              toDouble(schedule?['remainingAmount'] ?? loan['remainingAmount']);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Loan #${loan['id']}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _detailRow("Status", loan['status']?.toString() ?? "UNKNOWN"),
                const SizedBox(height: 8),
                _detailRow(
                  "Gold Details",
                  "${loan['goldItemType'] ?? 'Gold Loan'} • ${loan['goldPurity'] ?? ''}",
                ),
                const SizedBox(height: 8),
                _detailRow(
                  "Weight",
                  "${toDouble(loan['weight']).toStringAsFixed(2)} g",
                ),
                const SizedBox(height: 8),
                _detailRow(
                  "Loan Amount",
                  "₹${toDouble(loan['loanAmount']).toStringAsFixed(2)}",
                ),
                const SizedBox(height: 8),
                _detailRow(
                  "Interest Rate",
                  "${toDouble(loan['interestRate']).toStringAsFixed(2)}%",
                ),
                const SizedBox(height: 8),
                _detailRow(
                  "Monthly EMI",
                  "₹${toDouble(schedule?['monthlyEmi'] ?? loan['emi']).toStringAsFixed(2)}",
                ),
                const SizedBox(height: 8),
                _detailRow(
                  "Total Payable",
                  "₹${toDouble(loan['totalAmount']).toStringAsFixed(2)}",
                ),
                const SizedBox(height: 8),
                _detailRow(
                  "Remaining Amount",
                  "₹${remainingAmount.toStringAsFixed(2)}",
                ),
                const SizedBox(height: 8),
                _detailRow("Total EMIs", totalEmis.toString()),
                const SizedBox(height: 8),
                _detailRow("Paid EMIs", paidEmis.toString()),
                const SizedBox(height: 8),
                _detailRow("Remaining EMIs", remainingEmis.toString()),
                const SizedBox(height: 8),
                _detailRow(
                  "Next EMI Date",
                  schedule?['nextEmiDate']?.toString() ??
                      loan['nextEmiDate']?.toString() ??
                      "N/A",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class CustomerEmiDetailsPage extends StatefulWidget {
  final String customerName;
  final String customerId;
  final List<Map<String, dynamic>> loans;
  final Map<String, Map<String, dynamic>> paymentScheduleByLoanId;

  const CustomerEmiDetailsPage({
    super.key,
    required this.customerName,
    required this.customerId,
    required this.loans,
    required this.paymentScheduleByLoanId,
  });

  @override
  State<CustomerEmiDetailsPage> createState() => _CustomerEmiDetailsPageState();
}

class _CustomerEmiDetailsPageState extends State<CustomerEmiDetailsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> receiptHistory = [];
  final apiService = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();
    fetchEmiDetails();
  }

  double toDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0;
  }

  int toInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  Future<void> fetchEmiDetails() async {
    try {
      final response = await apiService.getRequest(
        "/api/emis/receipts/customer/${widget.customerId}",
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final receipts = (decoded as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        receipts.sort((a, b) {
          final aDate = a['paidDate']?.toString() ?? "";
          final bDate = b['paidDate']?.toString() ?? "";
          return bDate.compareTo(aDate);
        });

        setState(() {
          receiptHistory = receipts;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        title: Text("${widget.customerName} EMI Details"),
        backgroundColor: Colors.white,
        elevation: 0.2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Upcoming EMI Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...widget.loans
                    .where((loan) {
                      final schedule = widget.paymentScheduleByLoanId[
                          toInt(loan['id']).toString()];
                      return (schedule?['remainingEmis'] ?? loan['remainingEmis'] ?? 0) > 0;
                    })
                    .map((loan) {
                  final schedule =
                      widget.paymentScheduleByLoanId[toInt(loan['id']).toString()];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Loan #${loan['id']}",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _row(
                          "Next EMI Date",
                          schedule?['nextEmiDate']?.toString() ??
                              loan['nextEmiDate']?.toString() ??
                              "N/A",
                        ),
                        const SizedBox(height: 8),
                        _row(
                          "Upcoming EMI",
                          "₹${toDouble(schedule?['monthlyEmi'] ?? loan['emi']).toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        _row(
                          "Remaining EMIs",
                          "${toInt(schedule?['remainingEmis'] ?? loan['remainingEmis'])}",
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                const Text(
                  "EMI Payment History",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (receiptHistory.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      "No EMI receipt history found yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...receiptHistory.map((receipt) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receipt['receiptNumber']?.toString() ?? "Receipt",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          _row("Loan ID", receipt['loanId']?.toString() ?? "N/A"),
                          const SizedBox(height: 8),
                          _row(
                            "Amount Paid",
                            "₹${toDouble(receipt['amountPaid']).toStringAsFixed(2)}",
                          ),
                          const SizedBox(height: 8),
                          _row(
                            "Payment Method",
                            receipt['paymentMethod']?.toString() ?? "N/A",
                          ),
                          const SizedBox(height: 8),
                          _row(
                            "Paid Date",
                            receipt['paidDate']?.toString() ?? "N/A",
                          ),
                          const SizedBox(height: 8),
                          _row(
                            "Remaining EMIs",
                            receipt['remainingEmis']?.toString() ?? "N/A",
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
