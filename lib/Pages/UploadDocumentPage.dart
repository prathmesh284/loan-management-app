import 'package:flutter/material.dart';

class UploadDocumentsPage extends StatelessWidget {
  const UploadDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final Color primaryColor = const Color(0xFFecb613);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Documents",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView(
          children: const [
            Text(
              "Upload Documents",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 16),
            UploadTile(
              icon: Icons.badge,
              title: "KYC Documents",
              subtitle: "Upload customer's KYC documents",
            ),
            UploadTile(
              icon: Icons.description,
              title: "Loan Agreement",
              subtitle: "Upload customer's loan agreement",
            ),
            UploadTile(
              icon: Icons.receipt_long,
              title: "Gold Valuation Report",
              subtitle: "Upload customer's gold valuation report",
            ),
          ],
        ),
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
      //     BottomNavigationBarItem(icon: Icon(Icons.description, fill: 1), label: "Documents"),
      //     BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
      //   ],
      // ),
    );
  }
}

class UploadTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const UploadTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFecb613);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.2),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45, size: 18),
      ),
    );
  }
}
