import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shield_logo.dart';

class CaseDetailScreen extends StatefulWidget {
  final String reportId;
  final Map<String, dynamic> data;

  const CaseDetailScreen({
    super.key,
    required this.reportId,
    required this.data,
  });

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  bool _submitting = false;
  final TextEditingController _noteController = TextEditingController();
  final List<Map<String, String>> _internalNotes = [
    {
      'author': 'SGT. HARRIS',
      'time': '10 MIN AGO',
      'body':
          'Patrol unit 42 dispatched for initial sweep. No active exchange seen, but vehicle matching description is registered to a known associate.',
    },
  ];

  Future<void> _setVerdict(String verdict, {String? reasonCode}) async {
    setState(() => _submitting = true);
    try {
      final reportRef = FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId);
      final reporterTokenId = widget.data['reporterTokenId'];

      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.update(reportRef, {
          'verdict': verdict,
          'status': verdict == 'fabricated'
              ? 'fineIssued'
              : verdict == 'investigating'
                  ? 'investigating'
                  : 'closed',
          'reasonCode': reasonCode,
          'verdictAt': FieldValue.serverTimestamp(),
        });

        if (reporterTokenId != null && verdict != 'investigating') {
          final tokenQuery = await FirebaseFirestore.instance
              .collection('reporter_tokens')
              .where('token', isEqualTo: reporterTokenId)
              .limit(1)
              .get();

          if (tokenQuery.docs.isNotEmpty) {
            final uid = tokenQuery.docs.first.data()['uid'];
            final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

            if (verdict == 'verified') {
              tx.update(userRef, {
                'trustScore': FieldValue.increment(5),
                'reportsVerified': FieldValue.increment(1),
              });
            } else if (verdict == 'fabricated') {
              tx.update(userRef, {
                'trustScore': FieldValue.increment(-20),
                'reportsFabricated': FieldValue.increment(1),
              });
            }
          }
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Case status updated to $verdict')),
      );
      if (verdict != 'investigating') Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _internalNotes.insert(0, {
        'author': 'OFFICER ME',
        'time': 'JUST NOW',
        'body': text,
      });
      _noteController.clear();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caseId = widget.reportId.length > 7
        ? widget.reportId.substring(0, 7).toUpperCase()
        : widget.reportId.toUpperCase();
    final priority = (widget.data['priority'] ?? 'HIGH PRIORITY').toString().toUpperCase();
    final title = widget.data['description'] ?? 'Suspected Distribution';
    final location = widget.data['location']?['address'] ?? '1224 Oakwood St.';
    final ts = (widget.data['createdAt'] as Timestamp?)?.toDate();
    final dateStr = ts != null ? DateFormat('MMM dd, yyyy • HH:mm').format(ts) : 'Oct 24, 2023 • 23:15';
    final trustScore = widget.data['trustScore'] ?? 88;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const AppShieldLogo(size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'Report Details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryCoral,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: AppColors.onCoralText,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Top Map Header Tile with Overlay Location Card (Matching Image 3)
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2028),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bg.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INCIDENT LOCATION',
                          style: TextStyle(
                            color: AppColors.trustGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          location,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryCoral,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: AppColors.onCoralText,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Main Case Info Card (Matching Image 3)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CASE ID #$caseId',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.highPriorityAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.highPriorityAmber),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.highPriorityAmber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            priority.contains('PRIORITY') ? priority : '$priority PRIORITY',
                            style: const TextStyle(
                              color: AppColors.highPriorityAmber,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  'Reported consistent suspicious activity involving frequent short-stay vehicles and hand-to-hand exchanges during late-night hours (22:00 - 03:00). Observer notes distinct vehicle patterns and chemical odors.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.surfaceBorder, height: 1),
                const SizedBox(height: 16),

                // Reported At & Trust Score Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REPORTED AT',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.9,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TRUST SCORE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.9,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$trustScore/100',
                          style: const TextStyle(
                            color: AppColors.trustGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Evidence Files Section (Matching Image 3)
          const Text(
            'Evidence Files (4)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildEvidenceTile(Icons.zoom_in, 'CAM04 FEED-A', false),
              _buildEvidenceTile(Icons.image, 'EVIDENCE 02', false),
              _buildEvidenceTile(Icons.videocam_outlined, '0:15s', true),
              _buildEvidenceTile(Icons.mic_outlined, '0:42s', true),
            ],
          ),
          const SizedBox(height: 24),

          // Internal Notes Section (Matching Image 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Internal Notes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: _addNote,
                child: Row(
                  children: const [
                    Icon(Icons.add, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      'ADD NOTE',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Render Notes Feed
          ..._internalNotes.map((note) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 3.5,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryCoral,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                note['author']!,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.9,
                                ),
                              ),
                              Text(
                                note['time']!,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            note['body']!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

          // Note Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: TextField(
              controller: _noteController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a new internal update...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primaryCoral),
                  onPressed: _addNote,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons Section (Matching Image 3)
          // 1. Primary Pink Button: Mark as Investigating
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : () => _setVerdict('investigating'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCoral,
                foregroundColor: AppColors.onCoralText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.visibility_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Mark as Investigating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Split Buttons: Resolved & Reject
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : () => _setVerdict('verified'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.trustGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_outline, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Resolved',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : () => _setVerdict('fabricated'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cancel_outlined, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEvidenceTile(IconData icon, String label, bool isMedia) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2028),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              icon,
              size: 34,
              color: AppColors.textSecondary,
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
