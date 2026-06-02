import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpVerificationDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String phoneNumber;
  final Future<http.Response> Function(String otpCode) onVerify;
  final Future<http.Response> Function() onResend;

  const OtpVerificationDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.phoneNumber,
    required this.onVerify,
    required this.onResend,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String phoneNumber,
    required Future<http.Response> Function(String otpCode) onVerify,
    required Future<http.Response> Function() onResend,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpVerificationDialog(
        title: title,
        subtitle: subtitle,
        phoneNumber: phoneNumber,
        onVerify: onVerify,
        onResend: onResend,
      ),
    );
    return result ?? false;
  }

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  String? _message;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otpCode = _otpController.text.trim();
    if (otpCode.length != 6) {
      setState(() => _message = 'Enter a valid 6-digit OTP.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _message = null;
    });

    try {
      final response = await widget.onVerify(otpCode);
      final payload = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (payload['success'] == true) {
          if (!mounted) return;
          Navigator.of(context).pop(true);
          return;
        }

        setState(() {
          _message = payload['message']?.toString() ?? 'OTP verification failed.';
        });
        return;
      }

      setState(() {
        _message = payload['message']?.toString() ?? 'OTP verification failed.';
      });
    } catch (e) {
      setState(() => _message = 'Could not verify OTP: $e');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _message = null;
    });

    try {
      final response = await widget.onResend();
      final payload = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _message = payload['message']?.toString() ?? 'OTP resent successfully.';
        });
      } else {
        setState(() {
          _message = payload['message']?.toString() ?? 'Failed to resend OTP.';
        });
      }
    } catch (e) {
      setState(() => _message = 'Could not resend OTP: $e');
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
    } catch (_) {}
    return {'message': body};
  }

  @override
  Widget build(BuildContext context) {
    const ember = Color(0xFFC9892F);
    const ink = Color(0xFF1D160B);
    const mist = Color(0xFFF8F3E8);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E8), Color(0xFFF6E1B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF5B4B2E),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: mist,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE6D5AA)),
              ),
              child: Text(
                'OTP sent to ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'Enter 6-digit OTP',
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: ember, width: 1.8),
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(
                _message!,
                style: TextStyle(
                  fontSize: 12.5,
                  color: _message!.toLowerCase().contains('success')
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isResending ? null : _resendOtp,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFD5BC81)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isResending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Verify & Continue',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
