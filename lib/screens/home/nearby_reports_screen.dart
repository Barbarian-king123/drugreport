import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import 'package:intl/intl.dart';

class NearbyReportsScreen extends StatelessWidget {
  NearbyReportsScreen({super.key});

  final _reportService = ReportService();

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'verified') return Colors.green;
    if (normalized == 'fabricated') return Colors.red;
    if (normalized == 'inconclusive') return Colors.orange;
    return Colors.blueGrey;
  }

  String _readableStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Verified';
      case 'fabricated':
        return 'Fabricated';
      case 'inconclusive':
        return 'Inconclusive';
      case 'submitted':
        return 'Submitted';
      case 'fineissued':
        return 'Fine Issued';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Reports')),
      body: StreamBuilder<List<ReportModel>>(
        stream: _reportService.nearbyReports(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No nearby reports yet. Be the first to submit an issue and help keep the community safe.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final createdAt = report.createdAt != null
                  ? DateFormat('dd MMM, HH:mm').format(report.createdAt!)
                  : 'Unknown time';
              final status = _readableStatus(report.verdict);
              final statusColor = _statusColor(report.verdict);

              return Card(
                color: const Color(0xFF17171F),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
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
