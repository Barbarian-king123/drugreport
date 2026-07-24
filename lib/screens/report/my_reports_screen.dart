import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final reportService = ReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: FutureBuilder<String>(
        future: reportService.getOrCreateReporterToken(uid),
        builder: (context, tokenSnap) {
          if (!tokenSnap.hasData) return const Center(child: CircularProgressIndicator());
          return StreamBuilder<List<ReportModel>>(
            stream: reportService.myReports(tokenSnap.data!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final reports = snapshot.data!;
              if (reports.isEmpty) return const Center(child: Text('No reports yet'));
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: reports.length,
                itemBuilder: (context, i) {
                  final r = reports[i];
                  return Card(
                    child: ListTile(
                      title: Text(r.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(r.createdAt != null ? DateFormat('dd MMM, HH:mm').format(r.createdAt!) : ''),
                      trailing: Chip(label: Text(r.verdict)),
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
