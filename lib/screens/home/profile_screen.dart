import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../auth/logout_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'Profile & Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.criticalRed),
            tooltip: 'Sign Out',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LogoutScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: uid.isNotEmpty
            ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
            : null,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCoral),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final score = data?['trustScore'] ?? 100;
          final reportsSubmitted = data?['reportsSubmitted'] ?? 0;
          final verified = data?['reportsVerified'] ?? 0;
          final fabricated = data?['reportsFabricated'] ?? 0;
          final phone = data?['phoneNumber'] ?? user?.phoneNumber ?? 'Signed In';
          final role = (data?['role'] ?? 'citizen').toString().toLowerCase();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Identity Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryCoral,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 34, color: AppColors.onCoralText),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phone,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: role == 'officer'
                                  ? AppColors.primaryCoral.withValues(alpha: 0.15)
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: role == 'officer'
                                    ? AppColors.primaryCoral
                                    : AppColors.surfaceBorder,
                              ),
                            ),
                            child: Text(
                              role == 'officer' ? 'LAW ENFORCEMENT OFFICER' : 'CITIZEN ACCOUNT',
                              style: TextStyle(
                                color: role == 'officer' ? AppColors.primaryCoral : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Trust Score Block
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.shield_outlined, color: AppColors.trustGreen, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Citizen Trust Score',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$score / 100',
                          style: const TextStyle(
                            color: AppColors.trustGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _statTile('Submitted', reportsSubmitted.toString(), Icons.article_outlined)),
                        const SizedBox(width: 8),
                        Expanded(child: _statTile('Verified', verified.toString(), Icons.verified_user_outlined)),
                        const SizedBox(width: 8),
                        Expanded(child: _statTile('Rejected', fabricated.toString(), Icons.gpp_bad_outlined)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Account Details & Officer Request
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Credentials',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _detailRow('User ID', uid.length > 12 ? '${uid.substring(0, 12)}...' : uid),
                    const SizedBox(height: 10),
                    _detailRow('Auth Method', 'Phone SMS OTP'),
                    const SizedBox(height: 10),
                    _detailRow('Account Status', 'Active & Verified'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Prominent End Session Button
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogoutScreen()),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('End Active Session / Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.criticalRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
        Text(val, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}