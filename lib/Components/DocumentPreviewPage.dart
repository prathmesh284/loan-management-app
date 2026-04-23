import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loan_management_app/Service/api_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentPreviewPage extends StatelessWidget {
  final String url;
  final String? fileName;
  final int? documentId;

  const DocumentPreviewPage({
    super.key,
    required this.url,
    this.fileName,
    this.documentId,
  });

  String _normalizedPath(String value) {
    try {
      return Uri.parse(value).path.toLowerCase();
    } catch (_) {
      return value.toLowerCase();
    }
  }

  bool _hasImageExtension(String value) {
    final normalized = _normalizedPath(value);
    return normalized.endsWith(".jpg") ||
        normalized.endsWith(".jpeg") ||
        normalized.endsWith(".png") ||
        normalized.endsWith(".gif") ||
        normalized.endsWith(".webp");
  }

  bool _hasPdfExtension(String value) {
    final normalized = _normalizedPath(value);
    return normalized.endsWith(".pdf");
  }

  bool _isSignedS3Url(String value) {
    try {
      final uri = Uri.parse(value);
      return uri.queryParameters.containsKey('X-Amz-Signature') ||
          uri.queryParameters.containsKey('X-Amz-Credential') ||
          uri.queryParameters.containsKey('X-Amz-Algorithm');
    } catch (_) {
      return false;
    }
  }

  String _previewUrl(String value) {
    if (_isSignedS3Url(value)) return value;

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final uri = Uri.parse(value);
      return uri
          .replace(
            queryParameters: {...uri.queryParameters, 'timestamp': timestamp},
          )
          .toString();
    } catch (_) {
      final separator = value.contains('?') ? '&' : '?';
      return '$value${separator}timestamp=$timestamp';
    }
  }

  bool get isImageDocument {
    if (_hasImageExtension(url)) return true;
    if (fileName != null && _hasImageExtension(fileName!)) return true;
    return false;
  }

  bool get isPdfDocument {
    if (_hasPdfExtension(url)) return true;
    if (fileName != null && _hasPdfExtension(fileName!)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Document")),
      body: Builder(
        builder: (context) {
          if (isImageDocument) {
            return Center(
              child: InteractiveViewer(
                child: Image.network(
                  _previewUrl(url),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          "Failed to load image. Please refresh documents and try again.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },

                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            );
          } else if (isPdfDocument) {
            if (documentId != null) {
              return _PdfMemoryPreview(
                documentId: documentId!,
                fallbackUrl: _previewUrl(url),
              );
            }

            return SfPdfViewer.network(
              _previewUrl(url),
              onDocumentLoadFailed: (details) {
                debugPrint(
                  "PDF load failed: ${details.error} | ${details.description}",
                );
              },
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Unsupported file type"),
                    if (fileName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        fileName!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _PdfMemoryPreview extends StatefulWidget {
  final int documentId;
  final String fallbackUrl;

  const _PdfMemoryPreview({
    required this.documentId,
    required this.fallbackUrl,
  });

  @override
  State<_PdfMemoryPreview> createState() => _PdfMemoryPreviewState();
}

class _PdfMemoryPreviewState extends State<_PdfMemoryPreview> {
  final apiService = Get.find<ApiService>();
  late final Future<Uint8List> _pdfBytesFuture = _loadPdfBytes();
  bool _useNetworkFallback = false;

  Future<Uint8List> _loadPdfBytes() async {
    final response = await apiService.getRequest(
      "/api/documents/${widget.documentId}/content-base64",
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final base64File = data['base64File']?.toString();
    if (base64File == null || base64File.isEmpty) {
      throw Exception("PDF data is empty");
    }

    final bytes = base64Decode(base64File);
    if (!_hasPdfSignature(bytes)) {
      throw Exception(
        "Stored PDF is corrupted or invalid. Please delete it and upload the PDF again.",
      );
    }

    return bytes;
  }

  bool _hasPdfSignature(Uint8List bytes) {
    return bytes.length >= 5 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46 &&
        bytes[4] == 0x2D;
  }

  @override
  Widget build(BuildContext context) {
    if (_useNetworkFallback) {
      return _PdfNetworkPreview(url: widget.fallbackUrl);
    }

    return FutureBuilder<Uint8List>(
      future: _pdfBytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          debugPrint(
            "PDF API preview failed, falling back to URL: ${snapshot.error}",
          );
          return _PdfNetworkPreview(url: widget.fallbackUrl);
        }

        return SfPdfViewer.memory(
          snapshot.data!,
          onDocumentLoadFailed: (details) {
            debugPrint(
              "PDF memory load failed: ${details.error} | ${details.description}",
            );
            if (mounted) {
              setState(() => _useNetworkFallback = true);
            }
          },
        );
      },
    );
  }
}

class _PdfNetworkPreview extends StatelessWidget {
  final String url;

  const _PdfNetworkPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.network(
      url,
      onDocumentLoadFailed: (details) {
        debugPrint(
          "PDF network load failed: ${details.error} | ${details.description}",
        );
      },
    );
  }
}
