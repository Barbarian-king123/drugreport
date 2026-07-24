import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  Widget _verdictChip(String verdict) {
    final normalized = verdict.toLowerCase();
    final color = normalized == 'verified'
        ? Colors.green
        : normalized == 'fake'
            ? Colors.red
            : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        verdict.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final reportService = ReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: FutureBuilder<String>(
        future: reportService.getOrCreateReporterToken(uid),
        builder: (context, tokenSnap) {
          if (tokenSnap.hasError) {
            return Center(child: Text('Token error: ${tokenSnap.error}'));
          }
          if (!tokenSnap.hasData) return const Center(child: CircularProgressIndicator());

          return StreamBuilder<List<ReportModel>>(
            stream: reportService.myReports(tokenSnap.data!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Error loading reports:\n${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final reports = snapshot.data!;
              if (reports.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'No reports yet. Submit your first SafeReport and track verdicts here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: reports.length,
                itemBuilder: (context, i) {
                  final r = reports[i];
                  return Card(
                    color: const Color(0xFF17171F),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailScreen(report: {
                            ...r.toMap(),
                            'createdAt': r.createdAt,
                          }),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  r.createdAt != null ? DateFormat('dd MMM, HH:mm').format(r.createdAt!) : '',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const Spacer(),
                                _verdictChip(r.verdict),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}