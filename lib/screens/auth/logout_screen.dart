import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  bool _isLoggingOut = false;
  bool _clearCacheOnLogout = true;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session termination failed: $e'),
            backgroundColor: AppColors.criticalRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';
    final phone = user?.phoneNumber ?? 'Anonymous User';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security & Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: uid.isNotEmpty
              ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
              : null,
          builder: (context, snapshot) {
            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final role = (userData?['role'] ?? 'citizen').toString().toUpperCase();
            final displayPhone = userData?['phoneNumber'] ?? phone;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Lock/Shield Visual Indicator
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceElevated,
                            border: Border.all(
                              color: AppColors.criticalRed.withValues(alpha: 0.35),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.criticalRed.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.security_rounded,
                          size: 40,
                          color: AppColors.criticalRed,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'End Active Session',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign out of your active DrugReport profile on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Real Active User Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: AppColors.primaryCoral, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayPhone.isEmpty ? 'Account Signed In' : displayPhone,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: AppColors.trustGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'SESSION ACTIVE',
                                        style: TextStyle(
                                          color: AppColors.trustGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: role == 'OFFICER'
                                    ? AppColors.primaryCoral.withValues(alpha: 0.15)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: role == 'OFFICER'
                                      ? AppColors.primaryCoral
                                      : AppColors.surfaceBorder,
                                ),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  color: role == 'OFFICER'
                                      ? AppColors.primaryCoral
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: AppColors.surfaceBorder, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Authentication Status',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            Text(
                              'Verified Phone OTP',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interactive Security Preference Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.cleaning_services_outlined, size: 20, color: AppColors.textSecondary),
                            SizedBox(width: 12),
                            Text(
                              'Clear temporary local cache',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _clearCacheOnLogout,
                          onChanged: (val) => setState(() => _clearCacheOnLogout = val),
                          activeTrackColor: AppColors.primaryCoral,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Confirm & End Session Action
                  ElevatedButton(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.criticalRed,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoggingOut
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign Out of Device',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Keep Signed In',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
