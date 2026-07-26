import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shown exactly once, right after a brand-new user finishes OTP
/// verification (before they see any citizen/officer screen).
///
/// IMPORTANT: tapping "Officer" here does NOT grant officer access.
/// It only files a request — same as the profile screen's "Request
/// Officer Role" button. A citizen can freely tap it, but all it does
/// is create a pending record an existing officer has to approve. The
/// account's actual `role` field stays 'citizen' the entire time.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _loading = false;

  Future<void> _continueAsCitizen() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() => _loading = true);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'onboarded': true,
    });
    // AuthGate's live stream picks this up automatically and routes
    // to HomeScreen — no manual navigation needed here.
  }

  Future<void> _applyAsOfficer() async {
    final user = FirebaseAuth.instance.currentUser!;
    setState(() => _loading = true);

    final batch = FirebaseFirestore.instance.batch();
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final requestRef =
        FirebaseFirestore.instance.collection('officer_requests').doc(user.uid);

    // role is deliberately NOT touched here — it stays 'citizen' until
    // an existing officer approves this request.
    batch.update(userRef, {'onboarded': true});
    batch.set(requestRef, {
      'uid': user.uid,
      'phone': user.phoneNumber ?? '',
      'status': 'requested',
      'requestedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'How will you be using this app?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can change this later from your profile.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              OutlinedButton(
                onPressed: _loading ? null : _continueAsCitizen,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('I\'m a Citizen'),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _loading ? null : _applyAsOfficer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('I\'m a Law Enforcement Officer'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Officer accounts require verification by an existing '
                'officer before you get access to the case queue. You\'ll '
                'see the citizen app until then.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12.5),
              ),

              if (_loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}