import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final score = data?['trustScore'] ?? 0;
          final reportsSubmitted = data?['reportsSubmitted'] ?? 0;
          final verified = data?['reportsVerified'] ?? 0;
          final fabricated = data?['reportsFabricated'] ?? 0;
          final phone = data?['phoneNumber'] ?? 'Unknown';
          final role = data?['role'] ?? 'citizen';
          final requestStatus = data?['officerRequestStatus'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(radius: 42, backgroundColor: const Color(0xFFE53341), child: const Icon(Icons.person, size: 40)),
              const SizedBox(height: 16),
              const Text('Your profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(phone, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trust Score', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('$score / 100', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statBlock('Submitted', reportsSubmitted.toString()),
                          _statBlock('Verified', verified.toString()),
                          _statBlock('Fake', fabricated.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Account details', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Role: $role', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text('Joined: ${DateTime.now().year}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      if (role != 'officer')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: requestStatus == 'requested'
                                ? null
                                : () async {
                                    await FirebaseFirestore.instance
                                        .collection('officer_requests')
                                        .doc(uid)
                                        .set({
                                      'uid': uid,
                                      'phone': phone,
                                      'status': 'requested',
                                      'requestedAt': FieldValue.serverTimestamp(),
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Officer role requested')),
                                      );
                                    }
                                  },
                            child: Text(
                              requestStatus == 'requested'
                                  ? 'Request Pending'
                                  : 'Request Officer Role',
                            ),
                          ),
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

  Widget _statBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}