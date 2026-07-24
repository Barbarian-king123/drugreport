import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final createdAt = (report['createdAt'] as DateTime?) != null
        ? DateFormat('dd MMM, HH:mm').format(report['createdAt'] as DateTime)
        : 'Unknown time';
    final status = report['verdict'] ?? report['status'] ?? 'pending';
    final caption = report['anonymous'] == true ? 'Anonymous report' : 'Reported by you';
    final imageUrls = List<String>.from(report['imageUrls'] ?? []);
    final videoUrls = List<String>.from(report['videoUrls'] ?? []);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(report['description'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(label: Text(status.toString().toUpperCase())),
              const SizedBox(width: 10),
              Text(caption, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Text(createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          if (imageUrls.isNotEmpty) ...[
            const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(imageUrls[index], width: 180, height: 120, fit: BoxFit.cover),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: imageUrls.length,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (videoUrls.isNotEmpty) ...[
            const Text('Video Evidence', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('${videoUrls.length} video(s) attached', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
          const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(report['location'] ?? 'Location not available', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
