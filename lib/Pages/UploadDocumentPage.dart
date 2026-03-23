// import 'package:flutter/material.dart';

// class UploadDocumentsPage extends StatelessWidget {
//   const UploadDocumentsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // final Color primaryColor = const Color(0xFFecb613);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white.withOpacity(0.9),
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Documents",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(14.0),
//         child: ListView(
//           children: const [
//             Text(
//               "Upload Documents",
//               style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
//             ),
//             SizedBox(height: 16),
//             UploadTile(
//               icon: Icons.badge,
//               title: "KYC Documents",
//               subtitle: "Upload customer's KYC documents",
//             ),
//             UploadTile(
//               icon: Icons.description,
//               title: "Loan Agreement",
//               subtitle: "Upload customer's loan agreement",
//             ),
//             UploadTile(
//               icon: Icons.receipt_long,
//               title: "Gold Valuation Report",
//               subtitle: "Upload customer's gold valuation report",
//             ),
//           ],
//         ),
//       ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   type: BottomNavigationBarType.fixed,
//       //   selectedItemColor: primaryColor,
//       //   unselectedItemColor: Colors.black54,
//       //   currentIndex: 3,
//       //   items: const [
//       //     BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
//       //     BottomNavigationBarItem(icon: Icon(Icons.group), label: "Customers"),
//       //     BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Loans"),
//       //     BottomNavigationBarItem(icon: Icon(Icons.description, fill: 1), label: "Documents"),
//       //     BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
//       //   ],
//       // ),
//     );
//   }
// }

// class UploadTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;

//   const UploadTile({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final Color primaryColor = const Color(0xFFecb613);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: primaryColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: primaryColor.withOpacity(0.2),
//           child: Icon(icon, color: primaryColor, size: 20),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: const TextStyle(fontSize: 11, color: Colors.black54),
//         ),
//         trailing: const Icon(Icons.chevron_right, color: Colors.black45, size: 18),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loan_management_app/Service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadDocumentsPage extends StatefulWidget {
  const UploadDocumentsPage({super.key});

  @override
  State<UploadDocumentsPage> createState() => _UploadDocumentsPageState();
}

class _UploadDocumentsPageState extends State<UploadDocumentsPage> {
  final customerIdController = TextEditingController();
  final customerNameController = TextEditingController();
  final apiService = Get.find<ApiService>();

  String docType = "KYC";

  File? file; // mobile
  Uint8List? fileBytes; // web
  String? fileName;

  bool isLoading = false;

  final Color primaryColor = const Color(0xFFecb613);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  // 📂 PICK FILE (WEB + MOBILE)
  Future pickFile() async {
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

  // 🚀 UPLOAD
  Future upload() async {
    print("Upload clicked");

    if (customerIdController.text.isEmpty ||
        customerNameController.text.isEmpty) {
      print("Fields empty");
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    if ((kIsWeb && fileBytes == null) || (!kIsWeb && file == null)) {
      print("File not selected");
      Get.snackbar("Error", "Please select a file");
      return;
    }

    setState(() => isLoading = true);

    try {
      String? token = await _getToken();
      var uri = Uri.parse("http://127.0.0.1:8080/documents/upload");
      print("Sending request to: $uri");
      var request = http.MultipartRequest("POST", uri);
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['customerId'] = customerIdController.text;
      request.fields['customerName'] = customerNameController.text;
      request.fields['docType'] = docType;

      if (kIsWeb) {
        print("Uploading via WEB");
        request.files.add(
          http.MultipartFile.fromBytes('file', fileBytes!, filename: fileName),
        );
      } else {
        print("Uploading via MOBILE");
        request.files.add(
          await http.MultipartFile.fromPath('file', file!.path),
        );
      }

      var res = await request.send();

      print("Response status: ${res.statusCode}");

      var responseBody = await res.stream.bytesToString();
      print("Response body: $responseBody");

      setState(() => isLoading = false);

      if (res.statusCode == 200) {
        Get.snackbar("Success", "Document uploaded 🎉");
        Navigator.pop(context);
      } else {
        Get.snackbar("Error", "Upload failed: $responseBody");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
      Get.snackbar("Error", "Exception occurred");
    }
  }

  // 🎨 UI COMPONENT
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📦 Card UI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                children: [
                  buildTextField(
                    label: "Customer Name",
                    controller: customerNameController,
                  ),
                  buildTextField(
                    label: "Customer Phone",
                    controller: customerIdController,
                  ),

                  // 🎯 Dropdown
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
                      items: ["KYC", "Loan Agreement", "Gold Report"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => docType = val!);
                      },
                    ),
                  ),

                  // 📂 File Picker
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
                          Text(
                            fileName ?? "Select File",
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🚀 Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : upload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Upload Document"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
