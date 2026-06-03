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
  final TextEditingController searchController = TextEditingController();
  final Color primaryColor = const Color(0xFFecb613);

  Map<String, dynamic>? customerData;
  List<dynamic> customerDocuments = [];
  bool isSearching = false;
  String? searchError;

  Future<void> searchCustomerById([String? rawCustomerId]) async {
    final customerId = (rawCustomerId ?? searchController.text).trim();

    if (customerId.isEmpty) {
      setState(() {
        customerData = null;
        customerDocuments = [];
        searchError = "Enter customer phone number to search.";
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchError = null;
      customerData = null;
      customerDocuments = [];
    });

    try {
      final customerResponse = await apiService.getRequest(
        "/api/customers/by-id/$customerId",
      );

      if (customerResponse.statusCode != 200) {
        setState(() {
          searchError = "Customer not found for this phone number.";
          isSearching = false;
        });
        return;
      }

      final documentResponse = await apiService.getRequest(
        "/api/documents/customer/$customerId",
      );

      final Map<String, dynamic> fetchedCustomer = jsonDecode(
        customerResponse.body,
      );

      List<dynamic> fetchedDocuments = [];
      if (documentResponse.statusCode == 200) {
        fetchedDocuments = jsonDecode(documentResponse.body) as List<dynamic>;
      }

      setState(() {
        customerData = fetchedCustomer;
        customerDocuments = fetchedDocuments;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        searchError = "Failed to fetch customer documents.";
        isSearching = false;
      });
    }
  }

  String _docTitle(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return (doc['docName'] ?? doc['docType'] ?? 'Document').toString();
    }
    return "Document";
  }

  String _docType(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return (doc['docType'] ?? 'Unknown').toString();
    }
    return "Unknown";
  }

  String _docUrl(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return (doc['s3Url'] ?? '').toString();
    }
    return '';
  }

  int? _docId(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      final id = doc['id'];
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? '');
    }
    return null;
  }

  Future<void> _editDocument(Map<String, dynamic> doc) async {
    final id = _docId(doc);
    if (id == null) {
      Get.snackbar("Error", "Document ID not found");
      return;
    }

    final nameController = TextEditingController(text: _docTitle(doc));
    String selectedType = _docType(doc);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Document"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Document name",
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: "Document type",
                    ),
                    items: const [
                      DropdownMenuItem(value: "KYC", child: Text("KYC")),
                      DropdownMenuItem(
                        value: "LOAN",
                        child: Text("Loan Agreement"),
                      ),
                      DropdownMenuItem(
                        value: "GOLD",
                        child: Text("Gold Report"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true) return;

    final response = await apiService.putRequest("/api/documents/$id", {
      "docName": nameController.text.trim(),
      "docType": selectedType,
    });

    if (response.statusCode == 200) {
      Get.snackbar("Success", "Document updated");
      searchCustomerById();
    } else {
      Get.snackbar("Error", "Update failed: ${response.body}");
    }
  }

  Future<void> _deleteDocument(Map<String, dynamic> doc) async {
    final id = _docId(doc);
    if (id == null) {
      Get.snackbar("Error", "Document ID not found");
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Document?"),
        content: Text("This will permanently delete ${_docTitle(doc)}."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final response = await apiService.deleteRequest("/api/documents/$id");
    if (response.statusCode == 204 || response.statusCode == 200) {
      Get.snackbar("Success", "Document deleted");
      searchCustomerById();
    } else {
      Get.snackbar("Error", "Delete failed: ${response.body}");
    }
  }

  String _customerName(Map<String, dynamic> customer) {
    return (customer['name'] ?? 'Unknown Customer').toString();
  }

  String _customerId(Map<String, dynamic> customer) {
    return (customer['customerId'] ?? '').toString();
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDocumentsPage(
              customerName: _customerName(customer),
              customerId: _customerId(customer),
              documents: customerDocuments,
            ),
          ),
        );
        if (mounted && searchController.text.trim().isNotEmpty) {
          searchCustomerById();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primaryColor.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryColor.withOpacity(0.18),
              child: Icon(Icons.person, color: primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _customerName(customer),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _customerId(customer),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    customer['address']?.toString() ?? "Address not available",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  "${customerDocuments.length}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const Text(
                  "Docs",
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildStateView() {
    if (isSearching) {
      return const SizedBox(
        height: 320,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (customerData != null) {
      final crossAxisCount = MediaQuery.sizeOf(context).width >= 700 ? 3 : 2;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerCard(customerData!),
          const SizedBox(height: 18),
          Text(
            customerDocuments.isEmpty
                ? "No documents found for this customer."
                : "${customerDocuments.length} document(s) available",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          if (customerDocuments.isNotEmpty) ...[
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemCount: customerDocuments.length,
              itemBuilder: (context, index) {
                final doc = customerDocuments[index] as Map<String, dynamic>;
                final url = _docUrl(doc);

                return GestureDetector(
                  onTap: url.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DocumentPreviewPage(
                                url: url,
                                fileName: _docTitle(doc),
                                documentId: _docId(doc),
                              ),
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: primaryColor.withOpacity(0.28)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.description,
                                color: primaryColor,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "edit") {
                                  _editDocument(doc);
                                } else if (value == "delete") {
                                  _deleteDocument(doc);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          _docType(doc),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _docTitle(doc),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          url.isEmpty
                              ? "Preview unavailable"
                              : "Tap to preview",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      );
    }

    return SizedBox(
      height: 420,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open_rounded, size: 72, color: primaryColor),
              const SizedBox(height: 16),
              const Text(
                "Search customer by phone number",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                searchError ??
                    "Find a customer first, then open their documents in grid view.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'search_by_customer_id'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'search_by_customer_id_description'.tr,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => searchCustomerById(),
                    decoration: InputDecoration(
                      hintText: 'Customer Phone Number'.tr,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSearching ? null : () => searchCustomerById(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                  ),
                  child: const Text("Search"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStateView(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'document_storage'.tr,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildPageContent(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.upload_file),
        label: Text('upload'.tr),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadDocumentsPage(
                initialCustomerId: searchController.text.trim(),
              ),
            ),
          );

          if (result == true && searchController.text.trim().isNotEmpty) {
            searchCustomerById();
          }
        },
      ),
    );
  }
}

class UserDocumentsPage extends StatefulWidget {
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
  State<UserDocumentsPage> createState() => _UserDocumentsPageState();
}

class _UserDocumentsPageState extends State<UserDocumentsPage> {
  final apiService = Get.find<ApiService>();
  late List documents;

  @override
  void initState() {
    super.initState();
    documents = List.of(widget.documents);
  }

  String _docTitle(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return (doc['docName'] ?? doc['docType'] ?? 'Document').toString();
    }
    return "Document";
  }

  String _docType(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return (doc['docType'] ?? 'Unknown').toString();
    }
    return "Unknown";
  }

  String _docUrl(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      return (doc['s3Url'] ?? '').toString();
    }
    return '';
  }

  int? _docId(dynamic doc) {
    if (doc is Map<String, dynamic>) {
      final id = doc['id'];
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? '');
    }
    return null;
  }

  Future<void> _editDocument(Map<String, dynamic> doc, int index) async {
    final id = _docId(doc);
    if (id == null) {
      Get.snackbar("Error", "Document ID not found");
      return;
    }

    final nameController = TextEditingController(text: _docTitle(doc));
    String selectedType = _docType(doc);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Document"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Document name",
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: "Document type",
                    ),
                    items: const [
                      DropdownMenuItem(value: "KYC", child: Text("KYC")),
                      DropdownMenuItem(
                        value: "LOAN",
                        child: Text("Loan Agreement"),
                      ),
                      DropdownMenuItem(
                        value: "GOLD",
                        child: Text("Gold Report"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true) return;

    final response = await apiService.putRequest("/api/documents/$id", {
      "docName": nameController.text.trim(),
      "docType": selectedType,
    });

    if (response.statusCode == 200) {
      setState(() {
        documents[index] = jsonDecode(response.body) as Map<String, dynamic>;
      });
      Get.snackbar("Success", "Document updated");
    } else {
      Get.snackbar("Error", "Update failed: ${response.body}");
    }
  }

  Future<void> _deleteDocument(Map<String, dynamic> doc, int index) async {
    final id = _docId(doc);
    if (id == null) {
      Get.snackbar("Error", "Document ID not found");
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Document?"),
        content: Text("This will permanently delete ${_docTitle(doc)}."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final response = await apiService.deleteRequest("/api/documents/$id");
    if (response.statusCode == 204 || response.statusCode == 200) {
      setState(() => documents.removeAt(index));
      Get.snackbar("Success", "Document deleted");
    } else {
      Get.snackbar("Error", "Delete failed: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFecb613);
    final crossAxisCount = MediaQuery.sizeOf(context).width >= 700 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.customerName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customerId,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            documents.isEmpty
                ? SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    child: const Center(child: Text("No documents available")),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.02,
                    ),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index] as Map<String, dynamic>;
                      final url = _docUrl(doc);

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: url.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DocumentPreviewPage(
                                      url: url,
                                      fileName: _docTitle(doc),
                                      documentId: _docId(doc),
                                    ),
                                  ),
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.insert_drive_file_rounded,
                                    color: primaryColor,
                                    size: 30,
                                  ),
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == "edit") {
                                        _editDocument(doc, index);
                                      } else if (value == "delete") {
                                        _deleteDocument(doc, index);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: "edit",
                                        child: Text("Edit"),
                                      ),
                                      PopupMenuItem(
                                        value: "delete",
                                        child: Text("Delete"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                _docType(doc),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _docTitle(doc),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Tap to preview",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
