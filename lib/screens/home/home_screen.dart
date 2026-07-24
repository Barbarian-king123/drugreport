import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../report/create_report_screen.dart';
import '../report/my_reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 50) return const Color(0xFFFFA726);
    return const Color(0xFFE53341);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE53341),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('SafeReport', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final score = data?['trustScore'] ?? 100;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: score / 100,
                              strokeWidth: 5,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(_scoreColor(score)),
                            ),
                          ),
                          Text('$score', style: TextStyle(fontWeight: FontWeight.bold, color: _scoreColor(score))),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Trust Score', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text(
                              score >= 80 ? 'Excellent' : score >= 50 ? 'Good standing' : 'Warning zone',
                              style: TextStyle(color: _scoreColor(score), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _actionTile(
                    context,
                    icon: Icons.report,
                    label: 'Report Issue',
                    color: const Color(0xFFE53341),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportScreen())),
                  ),
                  _actionTile(
                    context,
                    icon: Icons.list_alt,
                    label: 'My Reports',
                    color: const Color(0xFF2E7D32),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReportsScreen())),
                  ),
                  _actionTile(
                    context,
                    icon: Icons.map_outlined,
                    label: 'Nearby Reports',
                    color: const Color(0xFF1565C0),
                    onTap: () {},
                  ),
                  _actionTile(
                    context,
                    icon: Icons.info_outline,
                    label: 'How It Works',
                    color: const Color(0xFF6A1B9A),
                    onTap: () {},
                  ),
                ],
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
