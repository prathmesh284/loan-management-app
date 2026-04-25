import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loan_management_app/Service/api_service.dart';
import 'package:loan_management_app/Validators/form_validators.dart';

class PayEmiPage extends StatefulWidget {
  final String loanId;
  final String customerId; // Added for receipt generation
  final double totalLoanAmount;
  final int totalEmis;
  final int paidEmis;
  final String? nextEmiDate;
  
  const PayEmiPage({
    super.key,
    required this.loanId,
    required this.customerId,
    required this.totalLoanAmount,
    required this.totalEmis,
    required this.paidEmis,
    this.nextEmiDate,
  });

  @override
  State<PayEmiPage> createState() => _PayEmiPageState();
}

class _PayEmiPageState extends State<PayEmiPage> {
  String selectedMethod = "CASH";
  String selectedMode = "MANUAL";
  String selectedUpiApp = "GOOGLE_PAY"; // Default UPI app
  final TextEditingController upiIdController = TextEditingController();
  final TextEditingController cashReferenceController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late String generatedReceiptId; // Auto-generated receipt ID

  String get actionButtonLabel {
    if (selectedMode != "RAZORPAY") {
      return "Confirm Payment";
    }
    return selectedMethod == "UPI" ? "Send Payment Request" : "Send Payment Link";
  }

  // 🎯 UPI Apps with icons
  final Map<String, Map<String, dynamic>> upiApps = {
    "GOOGLE_PAY": {
      "label": "Google Pay",
      "icon": Icons.payment,
      "color": Color(0xFF4285F4),
      "hint": "9876543210@googleplay"
    },
    "PHONEPE": {
      "label": "PhonePe",
      "icon": Icons.mobile_friendly,
      "color": Color(0xFF5B22D5),
      "hint": "9876543210@ybl"
    },
    "PAYTM": {
      "label": "Paytm",
      "icon": Icons.account_balance_wallet,
      "color": Color(0xFF002970),
      "hint": "9876543210@paytm"
    },
  };

  @override
  void initState() {
    super.initState();
    generatedReceiptId = generateReceiptId(); // Generate on page load
  }

  // 🎯 GENERATE RECEIPT ID
  String generateReceiptId() {
    // Format: RECIPT-YYYYMM_CUSTOMERID_LASTNUM_NO
    DateTime now = DateTime.now();
    String yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';
    
    // Extract last digit of customer ID
    String lastDigit = widget.customerId.isNotEmpty 
        ? widget.customerId.substring(widget.customerId.length - 1) 
        : '0';
    
    // Sequential number (in real app, get from backend)
    String sequentialNo = '${widget.paidEmis + 1}'.padLeft(3, '0');
    
    return 'RECIPT-$yearMonth\_${widget.customerId}\_$lastDigit\_$sequentialNo';
  }

  // 💰 CALCULATE EMI AMOUNT
  double get emiAmount {
    if (widget.totalEmis <= 0) return 0;
    return widget.totalLoanAmount / widget.totalEmis;
  }

  double get payableAmount => emiAmount;
  double get totalAmount => emiAmount;

  @override
  Widget build(BuildContext context) {
    const Color gold = Color(0xFFecb613);
    const Color bg = Color(0xFFF8F8F6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          "Pay EMI",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: gold,
        elevation: 0.3,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- GENERATED RECEIPT ID ----------
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: gold, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, color: gold, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Receipt ID (Auto-Generated)",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                generatedReceiptId,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            // Copy to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Receipt ID copied!")),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------- EMI SUMMARY ----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        rowItem(
                          "Total Loan Amount",
                          "₹${widget.totalLoanAmount.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        rowItem(
                          "Total Months (EMIs)",
                          "${widget.totalEmis}",
                        ),
                        const SizedBox(height: 8),
                        rowItem(
                          "Monthly EMI Amount",
                          "₹${emiAmount.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        rowItem(
                          "Current Payable",
                          "₹${payableAmount.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),
                        rowItem(
                          "EMI Status",
                          "${widget.paidEmis}/${widget.totalEmis} Paid",
                        ),
                        const SizedBox(height: 8),
                        rowItem(
                          "Due Date",
                          widget.nextEmiDate ?? "Not Available",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Select Payment Method",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------- CASH ----------
                  paymentOption(
                    title: "Cash Payment",
                    subtitle: "Pay in cash at branch",
                    selected: selectedMethod == "CASH",
                    icon: Icons.attach_money_rounded,
                    onTap: () => setState(() {
                      selectedMethod = "CASH";
                      selectedMode = "MANUAL";
                    }),
                  ),

                  const SizedBox(height: 14),

                  // ---------- UPI PAYMENT ----------
                  paymentOption(
                    title: "UPI Payment",
                    subtitle: "Google Pay, PhonePe, Paytm",
                    selected: selectedMethod == "UPI",
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () => setState(() {
                      selectedMethod = "UPI";
                      selectedMode = "RAZORPAY";
                    }),
                  ),

                  const SizedBox(height: 14),

                  // ---------- ONLINE TRANSFER ----------
                  paymentOption(
                    title: "Online Transfer",
                    subtitle: "Bank transfer/Card payment",
                    selected: selectedMethod == "ONLINE_TRANSFER",
                    icon: Icons.credit_card_rounded,
                    onTap: () => setState(() {
                      selectedMethod = "ONLINE_TRANSFER";
                      selectedMode = "RAZORPAY";
                    }),
                  ),

                  const SizedBox(height: 20),

                  // ---------- CASH PAYMENT SECTION ----------
                  if (selectedMethod == "CASH") cashPaymentSection(),

                  // ---------- UPI PAYMENT SECTION ----------
                  if (selectedMethod == "UPI") upiPaymentSection(),

                  // ---------- ONLINE TRANSFER SECTION ----------
                  if (selectedMethod == "ONLINE_TRANSFER")
                    onlinePaymentSection(),

                  const SizedBox(height: 30),

                  // ---------- PAY BUTTON ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black87,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              actionButtonLabel,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============= PAYMENT HANDLER =============
  void handlePayment() async {
    if (selectedMethod == "CASH") {
      if (cashReferenceController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter reference/receipt number"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      showCashPaymentConfirmation();
    } else if (selectedMethod == "UPI") {
      processOnlinePayment();
    } else {
      processOnlinePayment();
    }
  }

  // 🎯 CASH PAYMENT CONFIRMATION
  void showCashPaymentConfirmation() {
    const Color gold = Color(0xFFecb613);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Cash Payment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Payment Details:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Payable Amount:"),
                  Text(
                    "₹${payableAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Receipt ID:"),
                  Text(
                    generatedReceiptId,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Reference #:"),
                  Text(
                    cashReferenceController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Payment Method:"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Cash",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFecb613)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: gold),
              onPressed: () {
                Navigator.pop(context);
                processCashPayment();
              },
              child: const Text(
                "Confirm Payment",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }

  // 💵 PROCESS CASH PAYMENT
  void processCashPayment() async {
    setState(() => isLoading = true);

    try {
      final apiService = Get.find<ApiService>();

      final body = {
        "loanId": int.parse(widget.loanId),
        "amount": payableAmount,
        "paymentMethod": "CASH",
        "paymentMode": "MANUAL",
        "remarks": remarksController.text,
        "receiptNumber": generatedReceiptId, // Include generated receipt ID
        "generateReceipt": true,
      };

      final response = await apiService.postRequest(
        "/api/emis/process-payment",
        body,
      );

      print("📡 CASH PAYMENT STATUS: ${response.statusCode}");
      print("📦 CASH PAYMENT BODY: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        showSuccessDialog(
          "Payment Successful!",
          "Receipt: ${jsonResponse['receiptNumber'] ?? generatedReceiptId}\n\nAmount Paid: ₹${payableAmount.toStringAsFixed(2)}",
        );

        Navigator.pop(context, {
          "success": true,
          "loanId": widget.loanId,
          "receiptNumber": jsonResponse['receiptNumber'] ?? generatedReceiptId,
          "emiId": jsonResponse['emiId'],
          "amountPaid": jsonResponse['amountPaid'],
        });
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? "Payment processing failed");
      }
    } catch (e) {
      print("❌ CASH PAYMENT ERROR: $e");
      showErrorDialog("Payment Failed", e.toString());
    }

    setState(() => isLoading = false);
  }

  // 💳 PROCESS ONLINE PAYMENT (Razorpay)
  void processOnlinePayment() async {
    setState(() => isLoading = true);

    try {
      final apiService = Get.find<ApiService>();

      final initiateBody = {
        "loanId": int.parse(widget.loanId),
        "amount": payableAmount,
        "customerId": widget.customerId,
        "gateway": "razorpay",
        "paymentMethod": selectedMethod,
        "upiApp": selectedUpiApp,
        "upiId": selectedMethod == "UPI" ? upiIdController.text : null,
        "receiptNumber": generatedReceiptId,
      };

      final initiateResponse = await apiService.postRequest(
        "/api/payments/initiate",
        initiateBody,
      );

      print("📡 RAZORPAY INITIATE STATUS: ${initiateResponse.statusCode}");
      print("📦 RAZORPAY INITIATE BODY: ${initiateResponse.body}");

      if (initiateResponse.statusCode == 200) {
        var responseData = jsonDecode(initiateResponse.body);
        final paymentLink = (responseData['paymentLink'] ?? "").toString();
        if (paymentLink.isEmpty) {
          throw Exception(responseData['message'] ?? "Payment link was not created");
        }
        showPaymentRequestSentDialog(paymentLink);
      } else {
        String errorMessage = "Failed to create payment link";
        try {
          final errorData = jsonDecode(initiateResponse.body);
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        } catch (_) {
          if (initiateResponse.body.trim().isNotEmpty) {
            errorMessage = initiateResponse.body;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("❌ RAZORPAY ERROR: $e");
      showErrorDialog("Payment Initiation Failed", e.toString());
    }

    setState(() => isLoading = false);
  }

  // 📱 SHOW PAYMENT LINK DIALOG
  void showPaymentRequestSentDialog(String paymentLink) {
    const Color gold = Color(0xFFecb613);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Payment Request Sent"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedMethod == "UPI"
                    ? "The payment request has been created for the borrower. Razorpay will send the payment link to the customer's registered phone number, and email if available."
                    : "The payment link has been created and sent to the borrower using the contact details saved for this customer.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "Amount: ₹${payableAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Receipt ID: $generatedReceiptId",
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Borrower contact: ${widget.customerId}",
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: gold),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            TextButton(
              onPressed: () async {
                final uri = Uri.tryParse(paymentLink);
                if (uri == null ||
                    !await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    )) {
                  showErrorDialog(
                    "Payment Link Error",
                    "Could not open payment link.",
                  );
                }
              },
              child: const Text("Preview Link"),
            ),
          ],
        );
      },
    );
  }

  // ✅ SUCCESS DIALOG
  void showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ❌ ERROR DIALOG
  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ============= UI WIDGETS =============

  Widget rowItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget paymentOption({
    required String title,
    required String subtitle,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    const Color gold = Color(0xFFecb613);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? gold : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? gold.withOpacity(0.20) : Colors.white,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: gold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: gold, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? gold : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // 💰 CASH PAYMENT SECTION
  Widget cashPaymentSection() {
    const Color gold = Color(0xFFecb613);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: gold, width: 0.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, color: gold, size: 24),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cash Payment",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Receipt will be auto-generated",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Amount to Pay:", style: TextStyle(fontSize: 13)),
                  Text(
                    "₹${payableAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFecb613),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Reference Number (Optional)",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: cashReferenceController,
          decoration: InputDecoration(
            hintText: "Bank receipt or transaction reference",
            prefixIcon: const Icon(Icons.receipt, color: gold),
            filled: true,
            fillColor: gold.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Remarks (Optional)",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: remarksController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Additional notes about payment",
            prefixIcon: const Icon(Icons.note, color: gold),
            filled: true,
            fillColor: gold.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // 📱 UPI PAYMENT SECTION
  Widget upiPaymentSection() {
    const Color gold = Color(0xFFecb613);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏦 UPI APP SELECTION
        const Text(
          "Select UPI App",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Column(
          children: upiApps.entries.map((entry) {
            String key = entry.key;
            Map<String, dynamic> app = entry.value;
            bool isSelected = selectedUpiApp == key;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? gold : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
                color: isSelected ? gold.withOpacity(0.1) : Colors.white,
              ),
              child: ListTile(
                leading: Icon(
                  app['icon'],
                  color: app['color'],
                  size: 28,
                ),
                title: Text(
                  app['label'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Radio(
                  value: key,
                  groupValue: selectedUpiApp,
                  onChanged: (value) {
                    setState(() => selectedUpiApp = value.toString());
                  },
                  activeColor: gold,
                ),
                onTap: () {
                  setState(() => selectedUpiApp = key);
                },
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 📝 UPI ID INPUT
        const Text(
          "UPI ID (Optional)",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: upiIdController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: upiApps[selectedUpiApp]?['hint'] ?? "your.name@upi",
            prefixIcon: Icon(upiApps[selectedUpiApp]?['icon'], color: gold),
            filled: true,
            fillColor: gold.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),

        const SizedBox(height: 16),

        // ℹ️ UPI INFO
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "The borrower will receive the Razorpay payment request on their registered phone number. The selected app is stored as staff preference only.",
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 💰 AMOUNT DISPLAY
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount to Pay:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${payableAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFecb613),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 💳 ONLINE TRANSFER SECTION
  Widget onlinePaymentSection() {
    const Color gold = Color(0xFFecb613);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: gold, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, color: gold, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Secure Payment",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "Powered by Razorpay - PCI-DSS Compliant",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${payableAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFecb613),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Accept all major cards, net banking, and wallets",
                  style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
