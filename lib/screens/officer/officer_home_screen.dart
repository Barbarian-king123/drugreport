import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'case_detail_screen.dart';
import 'officer_requests_screen.dart';

class OfficerHomeScreen extends StatelessWidget {
  const OfficerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Officer requests',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfficerRequestsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final verdict = (data['verdict'] ?? '').toString().toLowerCase();
            return verdict.isEmpty || verdict == 'pending';
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No pending cases'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final ts = (data['createdAt'] as Timestamp?)?.toDate();
              return Card(
                child: ListTile(
                  title: Text(
                    data['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    ts != null ? DateFormat('dd MMM, HH:mm').format(ts) : '',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CaseDetailScreen(reportId: doc.id, data: data),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
