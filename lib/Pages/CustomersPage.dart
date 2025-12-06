import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loan_management_app/Pages/AddNewCustomerPage.dart';
import 'package:loan_management_app/Pages/CustomerDetailPage.dart';

class CustomersPage extends StatefulWidget {
  final int branchId;

  const CustomersPage({super.key, required this.branchId});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  List<dynamic> customers = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "http://localhost:8080/api/customers/branch/${widget.branchId}",
        ), // ⚠️ Change to your IP!
      );

      if (response.statusCode == 200) {
        setState(() {
          customers = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color gold = Color(0xFFecb613);
    const Color bg = Color(0xFFF8F8F6);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text(
          "Customers",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text("Add Customer"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddNewCustomerPage(branchId: widget.branchId),
            ),
          ).then((_) => fetchCustomers());
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: gold),
                hintText: "Search customers",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: gold, width: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: gold, width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Customers",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Loading UI
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator())),

            // Error UI
            if (isError)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Failed to fetch customers."),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchCustomers,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),

            // Customer List UI
            if (!isLoading && !isError)
              Expanded(
                child: customers.isEmpty
                    ? const Center(
                        child: Text(
                          "No customers found.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final c = customers[index];

                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerDetailsPage(
                                  customerId: c['customerId'], // ✅ pass ID
                                  name: c['name'] ?? "Unknown",
                                  imageUrl:
                                      "https://ui-avatars.com/api/?name=${c['name']}",
                                ),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: gold.withOpacity(0.08),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundImage: NetworkImage(
                                      "https://ui-avatars.com/api/?name=${c['name']}",
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c['name'] ?? "",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          "ID: ${c['customerId']}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
