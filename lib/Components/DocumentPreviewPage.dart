import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentPreviewPage extends StatelessWidget {
  final String url;

  const DocumentPreviewPage({super.key, required this.url});

  bool isImage(String url) {
    return url.toLowerCase().endsWith(".jpg") ||
        url.toLowerCase().endsWith(".jpeg") ||
        url.toLowerCase().endsWith(".png");
  }

  bool isPdf(String url) {
    return url.toLowerCase().endsWith(".pdf");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Document")),
      body: Builder(
        builder: (context) {
          if (isImage(url)) {
            return Center(
              child: InteractiveViewer(
                child: Image.network(
                  "$url?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                  fit: BoxFit.contain,

                  // 🔥 ADD THIS (VERY IMPORTANT)
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text("Failed to load image"));
                  },

                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            );
          } else if (isPdf(url)) {
            return SfPdfViewer.network(url);
          } else {
            return const Center(child: Text("Unsupported file type"));
          }
        },
      ),
    );
  }
}
