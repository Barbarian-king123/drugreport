import 'package:flutter/material.dart';

class WarningScreen extends StatelessWidget {
  final int score;
  const WarningScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Trust Score')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Icon(Icons.warning_amber_rounded, size: 82, color: Colors.amber),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your trust score is getting low.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $score / 100',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Please make sure your reports are accurate and honest. False or misleading reports lower your score and can lead to account restrictions.',
              style: TextStyle(color: Colors.grey, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53341)),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK, I UNDERSTAND'),
            ),
          ],
        ),
      ),
    );
  }
}
