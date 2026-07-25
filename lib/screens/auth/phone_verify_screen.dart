import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class PhoneVerifyScreen extends StatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  State<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends State<PhoneVerifyScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _auth = AuthService();
  String? _verificationId;
  String _status = '';

  Future<void> _send() async {
    setState(() => _status = 'Sending OTP...');
    await _auth.sendOtp(
      phone: _phoneController.text.trim(),
      onCodeSent: (vid) => setState(() {
        _verificationId = vid;
        _status = 'OTP sent';
      }),
      onError: (err) => setState(() => _status = 'Error: $err'),
    );
  }

  Future<void> _verify() async {
    if (_verificationId == null) return setState(() => _status = 'No verification id');
    try {
      setState(() => _status = 'Verifying...');
      await _auth.verifyOtp(_verificationId!, _codeController.text.trim());
      if (!mounted) return;
      setState(() => _status = 'Verified');
      Navigator.pop(context);
    } catch (e) {
      setState(() => _status = 'Verify failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone (include +country)') ,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _send, child: const Text('Send OTP')),
            const SizedBox(height: 12),
            TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'OTP code')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _verify, child: const Text('Verify')),
            const SizedBox(height: 12),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
