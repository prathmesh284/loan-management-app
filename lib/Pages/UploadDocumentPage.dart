import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loan_management_app/Service/api_service.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadDocumentsPage extends StatefulWidget {
  final String? initialCustomerId;

  const UploadDocumentsPage({super.key, this.initialCustomerId});

  @override
  State<UploadDocumentsPage> createState() => _UploadDocumentsPageState();
}

class _UploadDocumentsPageState extends State<UploadDocumentsPage> {
  final customerIdController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerAddressController = TextEditingController();
  final apiService = Get.find<ApiService>();
  final Map<String, String> documentTypeLabels = {
    "KYC": "KYC",
    "LOAN": "Loan Agreement",
    "GOLD": "Gold Report",
  };

  String docType = "KYC";
  File? file;
  Uint8List? fileBytes;
  String? fileName;
  bool isLoading = false;
  bool isLoadingCustomer = false;
  String? customerError;

  final Color primaryColor = const Color(0xFFecb613);

  @override
  void initState() {
    super.initState();
    if ((widget.initialCustomerId ?? '').trim().isNotEmpty) {
      customerIdController.text = widget.initialCustomerId!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchCustomerDetails();
      });
    }
  }

  @override
  void dispose() {
    customerIdController.dispose();
    customerNameController.dispose();
    customerAddressController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  String _mimeTypeForFileName(String? name) {
    return lookupMimeType(name ?? '') ?? 'application/octet-stream';
  }

  Future<void> fetchCustomerDetails() async {
    final customerId = customerIdController.text.trim();

    if (customerId.isEmpty) {
      setState(() {
        customerError = "Enter customer phone number.";
        customerNameController.clear();
        customerAddressController.clear();
      });
      return;
    }

    setState(() {
      isLoadingCustomer = true;
      customerError = null;
    });

    try {
      final response = await apiService.getRequest(
        "/api/customers/by-id/$customerId",
      );

      if (response.statusCode == 200) {
        final customer = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          customerNameController.text = customer['name']?.toString() ?? '';
          customerAddressController.text =
              customer['address']?.toString() ?? '';
          isLoadingCustomer = false;
        });
      } else {
        setState(() {
          customerNameController.clear();
          customerAddressController.clear();
          customerError = "Customer not found for this phone number.";
          isLoadingCustomer = false;
        });
      }
    } catch (e) {
      setState(() {
        customerError = "Failed to fetch customer details.";
        customerNameController.clear();
        customerAddressController.clear();
        isLoadingCustomer = false;
      });
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      setState(() {
        fileName = result.files.first.name;
        if (kIsWeb) {
          fileBytes = result.files.first.bytes;
        } else {
          file = File(result.files.first.path!);
        }
      });
    }
  }

  Future<void> upload() async {
    if (customerIdController.text.trim().isEmpty ||
        customerNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Fetch customer details first");
      return;
    }

    if ((kIsWeb && fileBytes == null) || (!kIsWeb && file == null)) {
      Get.snackbar("Error", "Please select a file");
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await _getToken();
      final uri = Uri.parse(
        "${apiService.baseUrl}/api/documents/upload-base64",
      );

      if (token == null || token.isEmpty) {
        setState(() => isLoading = false);
        Get.snackbar(
          "Error",
          "Authentication token missing. Please login again.",
        );
        return;
      }

      if (!kIsWeb && fileBytes == null && file != null) {
        fileBytes = await file!.readAsBytes();
      }

      debugPrint('📤 [UPLOAD] Sending base64 upload request to: $uri');
      debugPrint(
        '📝 [UPLOAD] Fields: customerId=${customerIdController.text.trim()}, docType=$docType, docName=${fileName ?? 'document'}, size=${fileBytes?.length ?? 0} bytes',
      );

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'customerId': customerIdController.text.trim(),
          'customerName': customerNameController.text.trim(),
          'docType': docType,
          'docName': fileName ?? 'document',
          'fileName': fileName ?? 'document',
          'contentType': _mimeTypeForFileName(fileName),
          'base64File': base64Encode(fileBytes!),
        }),
      );

      debugPrint('📥 [UPLOAD] Response status: ${response.statusCode}');
      final responseBody = response.body;
      debugPrint('📦 [UPLOAD] Response body: $responseBody');

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        Get.snackbar("Success", "Document uploaded");
        Navigator.pop(context, true);
      } else {
        Get.snackbar("Error", "Upload failed: $responseBody");
      }
    } catch (e, stackTrace) {
      setState(() => isLoading = false);
      debugPrint('❌ [DOC-UPLOAD] Exception: $e');
      debugPrint('📍 [DOC-UPLOAD] Stacktrace: $stackTrace');
      Get.snackbar("Error", "Exception occurred while uploading");
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: primaryColor.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Upload Document",
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Find Customer",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Enter customer phone number and fetch details before uploading.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildTextField(
                            label: "Customer Phone",
                            controller: customerIdController,
                            keyboardType: TextInputType.phone,
                            suffixIcon: isLoadingCustomer
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () => fetchCustomerDetails(),
                                    icon: const Icon(Icons.search),
                                  ),
                            onChanged: (value) {
                              if (value.trim().length == 10) {
                                fetchCustomerDetails();
                              }
                            },
                          ),
                          buildTextField(
                            label: "Customer Name",
                            controller: customerNameController,
                            readOnly: true,
                          ),
                          buildTextField(
                            label: "Address",
                            controller: customerAddressController,
                            readOnly: true,
                          ),
                          if (customerError != null) ...[
                            Text(
                              customerError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: docType,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: documentTypeLabels.entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() => docType = val!);
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: pickFile,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      fileName ?? "Select File",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : upload,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : const Text("Upload Document"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.72),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 18),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: primaryColor),
                        const SizedBox(height: 14),
                        const Text(
                          "Uploading document...",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Please wait while we save it securely.",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
