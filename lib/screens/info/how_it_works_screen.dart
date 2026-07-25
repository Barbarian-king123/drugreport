import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  Widget _buildStep(int index, String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF23232E)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        leading: Semantics(
          label: 'Step ${index + 1}',
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE53341).withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFE53341)),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.4)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                children: const [
                  Text('How SafeReport Works', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 10),
                  Text(
                    'SafeReport lets citizens report suspected drug-related activity anonymously or with a verified identity. Reports are reviewed by trusted officers and the community, and verified reports improve your Trust Score. Follow the guidelines below to make your reports useful and safe.',
                    style: TextStyle(color: Colors.grey, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Steps
          _buildStep(0, '1. Prepare your report', 'Take clear photos or short videos, note exact location, time, and a short description of what you observed.', Icons.note_alt),
          _buildStep(1, '2. Submit with evidence', 'Attach photos or video, select location on the map and submit. You can submit anonymously or verify your phone for a stronger Trust Score.', Icons.upload_file),
          _buildStep(2, '3. Officer & community review', 'Trusted officers and community reviewers verify evidence. Officers may request more details before marking as verified.', Icons.how_to_reg),
          _buildStep(3, '4. Outcome & Trust Score', 'If verified, your Trust Score increases. If a report is found to be false, your score will decrease.', Icons.score),

          const SizedBox(height: 8),

          // Score details
          Card(
            margin: EdgeInsets.zero,
            color: const Color(0xFF17171F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF23232E))),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Score Impact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                Text('• Verified reports: +5 points', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text('• Partially verified (needs more evidence): +2 points', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text('• False / fabricated reports: -20 points', style: TextStyle(color: Colors.white70)),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // Privacy and Officer role
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Privacy & Officer Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                Text('• Reports can be submitted anonymously. Phone verification is optional but improves credibility.', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text('• Officer accounts are verified by the system administrators. Officers have extra tools to review evidence and mark reports as verified.', style: TextStyle(color: Colors.white70)),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // Safety & legal
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Safety & Legal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                Text('• Do not place yourself in danger to collect evidence. Stay safe and report from a secure distance.', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text('• False reporting may have consequences within the app (score loss, suspension) and may be illegal in some jurisdictions.', style: TextStyle(color: Colors.white70)),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // FAQ
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('FAQ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ExpansionTile(
                  title: const Text('Can I report anonymously?'),
                  children: const [Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Yes — anonymous reports are accepted. Verified reports have more weight.', style: TextStyle(color: Colors.white70))),],
                ),
                ExpansionTile(
                  title: const Text('What is an officer?'),
                  children: const [Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Officers are verified accounts used by moderators or law enforcement to validate reports.', style: TextStyle(color: Colors.white70))),],
                ),
              ]),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
