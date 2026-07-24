import 'package:flutter/material.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Banned')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Icon(Icons.lock_outline, size: 82, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Banned',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your account has been permanently banned for multiple violations of community guidelines.',
              style: TextStyle(color: Colors.grey, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Score: 0 / 100',
                style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53341)),
              onPressed: () {},
              child: const Text('LEARN MORE'),
            ),
          ],
        ),
      ),
    );
  }
}
