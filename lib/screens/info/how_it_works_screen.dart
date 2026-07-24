import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'title': 'Submit report',
        'subtitle': 'Add a description, photos, or video and send it to our review team.',
      },
      {
        'title': 'Review by officers',
        'subtitle': 'Trusted officers verify evidence and mark the report accurately.',
      },
      {
        'title': 'Trust score update',
        'subtitle': 'Verified reports increase your score; false reports decrease it.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('How It Works'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How SafeReport Works',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Submit accurate reports, let officers verify them, and keep track of how your trust score changes based on the outcome.',
                    style: TextStyle(color: Colors.grey, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...steps.map(
            (step) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF17171F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF23232E)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                leading: Container(
                  width: 41,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53341).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check, color: Color(0xFFE53341)),
                ),
                title: Text(step['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(step['subtitle']!, style: const TextStyle(color: Colors.grey)),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            color: const Color(0xFF17171F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF23232E))),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Score Impact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  Text('• Verified reports: +5 points', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text('• Fake / fabricated reports: -20 points', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
