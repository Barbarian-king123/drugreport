import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterTokenId;
  final String description;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final String verdict;
  final String status;
  final DateTime? createdAt;

  ReportModel({
    required this.id,
    required this.reporterTokenId,
    required this.description,
    required this.imageUrls,
    required this.videoUrls,
    required this.verdict,
    required this.status,
    this.createdAt,
  });

  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,
      reporterTokenId: map['reporterTokenId'] ?? '',
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrls: List<String>.from(map['videoUrls'] ?? []),
      verdict: map['verdict'] ?? 'pending',
      status: map['status'] ?? 'submitted',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterTokenId': reporterTokenId,
      'description': description,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'verdict': verdict,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
