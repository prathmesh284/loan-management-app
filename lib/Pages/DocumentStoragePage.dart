import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_management_app/Components/DocumentPreviewPage.dart';
import 'package:loan_management_app/Pages/UploadDocumentPage.dart';
import 'package:loan_management_app/Service/api_service.dart';

class DocumentStoragePage extends StatefulWidget {
  final int branchId;
  const DocumentStoragePage({super.key, required this.branchId});

  @override
  State<DocumentStoragePage> createState() => _DocumentStoragePageState();
}

class _DocumentStoragePageState extends State<DocumentStoragePage> {
  final apiService = Get.find<ApiService>();

  Map<String, List<dynamic>> groupedDocs = {};
  final Color primaryColor = const Color(0xFFecb613);

  // 🔍 SEARCH + GROUPING
  void searchDocuments(String keyword) async {
    final res = await apiService.getRequest(
      "/documents/search?keyword=$keyword",
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      Map<String, List<dynamic>> temp = {};

      for (var doc in data) {
        String key = doc['customerId'];

        if (!temp.containsKey(key)) {
          temp[key] = [];
        }
        temp[key]!.add(doc);
      }

      setState(() {
        groupedDocs = temp;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchDocuments("");
  }

  // 👤 USER CARD
  Widget buildUserCard(String name, String id, List docs) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDocumentsPage(
              customerName: name,
              customerId: id,
              documents: docs,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.2),
              child: Icon(Icons.person, color: primaryColor),
            ),

            const SizedBox(width: 12),

            // 📄 INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    id,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // 📊 DOC COUNT
            Column(
              children: [
                Text(
                  "${docs.length}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const Text("Docs", style: TextStyle(fontSize: 10)),
              ],
            ),

            const SizedBox(width: 10),

            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
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
          "Document Storage",
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 SEARCH
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: searchDocuments,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search by name or phone",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📌 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Customers",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "${groupedDocs.length} users",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📂 LIST
            Expanded(
              child: groupedDocs.isEmpty
                  ? const Center(child: Text("No documents found"))
                  : ListView.builder(
                      itemCount: groupedDocs.keys.length,
                      itemBuilder: (context, index) {
                        String customerId = groupedDocs.keys.elementAt(index);
                        List docs = groupedDocs[customerId]!;

                        String customerName = docs[0]['customerName'] ?? "";

                        return buildUserCard(customerName, customerId, docs);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const UploadDocumentsPage(),
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// 📂 USER DOCUMENT PAGE (INSIDE SAME FILE)
////////////////////////////////////////////////////////

class UserDocumentsPage extends StatelessWidget {
  final String customerName;
  final String customerId;
  final List documents;

  const UserDocumentsPage({
    super.key,
    required this.customerName,
    required this.customerId,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFecb613);

    return Scaffold(
      appBar: AppBar(title: Text(customerName)),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.insert_drive_file, color: primaryColor),
                title: Text(doc['docType']),
                subtitle: const Text("Tap to view"),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // 👉 Here you can open S3 URL
                  String url = doc['s3Url'] ?? "";
                  print("Open file: $url");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentPreviewPage(url: url),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
