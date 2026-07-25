import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OfficerRequestsScreen extends StatelessWidget {
  const OfficerRequestsScreen({super.key});

  Future<void> _approve(RequestSnapshot req) async {
    final uid = req.data()['uid'] as String?;
    if (uid == null) return;
    final admin = FirebaseAuth.instance.currentUser!.uid;
    final batch = FirebaseFirestore.instance.batch();
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final reqRef = FirebaseFirestore.instance.collection('officer_requests').doc(req.id);

    batch.update(userRef, {'role': 'officer'});
    batch.update(reqRef, {
      'status': 'approved',
      'admin': admin,
      'handledAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> _reject(RequestSnapshot req) async {
    final admin = FirebaseAuth.instance.currentUser!.uid;
    final reqRef = FirebaseFirestore.instance.collection('officer_requests').doc(req.id);
    await reqRef.update({'status': 'rejected', 'admin': admin, 'handledAt': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Officer Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('officer_requests').where('status', isEqualTo: 'requested').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No officer requests'));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final phone = data['phone'] ?? 'Unknown';
              return Card(
                child: ListTile(
                  title: Text('User: ${data['uid'] ?? ''}'),
                  subtitle: Text('Phone: $phone'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    TextButton(onPressed: () async { await _reject(RequestSnapshot(doc.id, data)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected'))); }, child: const Text('Reject')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () async { await _approve(RequestSnapshot(doc.id, data)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approved'))); }, child: const Text('Approve')),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Lightweight wrapper to present request document data with id
class RequestSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  RequestSnapshot(this.id, this._data);
  Map<String, dynamic> data() => _data;
}
