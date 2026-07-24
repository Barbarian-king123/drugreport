import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});
  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  String _status = '';
  bool _loading = false;

  Future<void> _sendOtp() async {
    setState(() { _status = 'Sending OTP...'; _loading = true; });
    final phone = '+91${_phoneController.text.trim()}';
    await _authService.sendOtp(
      phone: phone,
      onCodeSent: (verificationId) {
        setState(() { _status = 'OTP sent!'; _loading = false; });
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => OtpScreen(verificationId: verificationId),
        ));
      },
      onError: (error) => setState(() { _status = 'Error: $error'; _loading = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your number')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number', prefixText: '+91 ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _sendOtp,
              child: _loading ? const CircularProgressIndicator() : const Text('Send OTP'),
            ),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
