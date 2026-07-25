import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/report_model.dart';

class ReportService {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<String> getOrCreateReporterToken(String uid) async {
    final ref = _db.collection('reporter_tokens').doc(uid);
    final doc = await ref.get();
    if (doc.exists) return doc['token'];
    final token = _uuid.v4();
    await ref.set({'token': token, 'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
    return token;
  }

  Future<String> createReport(String reporterToken, String description, {bool anonymous = true, Map<String, dynamic>? location}) async {
    final data = {
      'reporterTokenId': reporterToken,
      'description': description,
      'anonymous': anonymous,
      'imageUrls': [],
      'videoUrls': [],
      'verdict': 'pending',
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (location != null) {
      data['location'] = location;
    }

    final ref = await _db.collection('reports').add(data);
    return ref.id;
  }

  Future<void> attachMedia(String reportId, List<String> imageUrls, List<String> videoUrls) async {
    await _db.collection('reports').doc(reportId).update({
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
    });
  }

  Future<String> uploadImage(XFile file, String reportId) async {
    final ref = FirebaseStorage.instance.ref('reports/$reportId/images/${_uuid.v4()}.jpg');
    final bytes = await file.readAsBytes();
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  Future<String> uploadVideo(XFile file, String reportId) async {
    final ref = FirebaseStorage.instance.ref('reports/$reportId/videos/${_uuid.v4()}.mp4');
    final bytes = await file.readAsBytes();
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'video/mp4'),
    );
    return ref.getDownloadURL();
  }

  Stream<List<ReportModel>> myReports(String reporterToken) {
    return _db
        .collection('reports')
        .where('reporterTokenId', isEqualTo: reporterToken)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ReportModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<ReportModel>> nearbyReports() {
    return _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map((d) => ReportModel.fromMap(d.id, d.data())).toList());
  }
}
