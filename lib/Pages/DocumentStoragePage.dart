import 'package:flutter/material.dart';
import 'package:loan_management_app/Pages/UploadDocumentPage.dart';

class DocumentStoragePage extends StatelessWidget {
  const DocumentStoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFecb613);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Document Storage",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black54),
                hintText: "Search by User ID",
                hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                filled: true,
                fillColor: primaryColor.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Recent Documents",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  DocumentTile(userId: "#12345", documents: "3 documents"),
                  DocumentTile(userId: "#67890", documents: "2 documents"),
                  DocumentTile(userId: "#11223", documents: "5 documents"),
                  DocumentTile(userId: "#44556", documents: "1 document"),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadDocumentsPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: primaryColor,
      //   unselectedItemColor: Colors.black54,
      //   currentIndex: 3,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      //     BottomNavigationBarItem(icon: Icon(Icons.group), label: "Customers"),
      //     BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Loans"),
      //     BottomNavigationBarItem(icon: Icon(Icons.folder, fill: 1), label: "Documents"),
      //     BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
      //   ],
      // ),
    );
  }
}

class DocumentTile extends StatelessWidget {
  final String userId;
  final String documents;

  const DocumentTile({super.key, required this.userId, required this.documents});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFecb613);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.2),
          child: Icon(Icons.person, color: primaryColor, size: 20),
        ),
        title: Text(
          "User ID: $userId",
          style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          documents,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45, size: 18),
      ),
    );
  }
}
