import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/nearby_reports_screen.dart';
import '../home/profile_screen.dart';
import '../info/banned_screen.dart';
import '../info/how_it_works_screen.dart';
import '../info/warning_screen.dart';
import '../report/create_report_screen.dart';
import '../report/my_reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 50) return const Color(0xFFFFA726);
    return const Color(0xFFE53341);
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 50) return 'Good';
    if (score >= 20) return 'Warning';
    return 'Banned';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53341),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('SafeReport', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final score = data?['trustScore'] ?? 100;
          final level = _scoreLabel(score);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Trust Score', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                const SizedBox(height: 8),
                                Text('$score / 100', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(level, style: TextStyle(color: _scoreColor(score), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Material(
                            color: _scoreColor(score).withOpacity(0.12),
                            shape: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Icon(Icons.speed, size: 28, color: _scoreColor(score)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: score / 100,
                        color: _scoreColor(score),
                        backgroundColor: Colors.white10,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _statusTag('Verified +5', const Color(0xFF4CAF50))),
                          const SizedBox(width: 10),
                          Expanded(child: _statusTag('Fake -20', const Color(0xFFE53341))),
                        ],
                      ),
                      if (level == 'Warning') ...[
                        const SizedBox(height: 16),
                        _alertCard(
                          context,
                          icon: Icons.warning_amber_rounded,
                          title: 'Low trust score',
                          subtitle: 'Your score is low. Submit accurate reports to recover.',
                          actionLabel: 'Learn more',
                          action: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => WarningScreen(score: score)),
                          ),
                        ),
                      ] else if (level == 'Banned') ...[
                        const SizedBox(height: 16),
                        _alertCard(
                          context,
                          icon: Icons.lock_outline,
                          title: 'Account banned',
                          subtitle: 'Your account is banned for repeated violations.',
                          actionLabel: 'Learn more',
                          action: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BannedScreen()),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _actionTile(
                    context,
                    icon: Icons.report,
                    label: 'Report Issue',
                    color: const Color(0xFFE53341),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateReportScreen()),
                    ),
                  ),
                  _actionTile(
                    context,
                    icon: Icons.list_alt,
                    label: 'My Reports',
                    color: const Color(0xFF2E7D32),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyReportsScreen()),
                    ),
                  ),
                  _actionTile(
                    context,
                    icon: Icons.map_outlined,
                    label: 'Nearby Reports',
                    color: const Color(0xFF1565C0),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NearbyReportsScreen()),
                    ),
                  ),
                  _actionTile(
                    context,
                    icon: Icons.info_outline,
                    label: 'How It Works',
                    color: const Color(0xFF6A1B9A),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HowItWorksScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SafeReport mission', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        'Submit responsible reports to help keep the community safe. Keep your account in good standing by reporting accurate information.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF17171F),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _alertCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback action,
  }) {
    return Card(
      color: const Color(0xFF1E1E27),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white12,
              child: Icon(icon, color: const Color(0xFFE53341), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, height: 1.4)),
                ],
              ),
            ),
            TextButton(
              onPressed: action,
              child: Text(actionLabel, style: const TextStyle(color: Color(0xFFE53341))),
            ),
          ],
        ),
      ),
    );
  }
}
