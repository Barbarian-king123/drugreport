import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/report_service.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});
  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _descController = TextEditingController();
  final _picker = ImagePicker();
  final _reportService = ReportService();
  final List<File> _images = [];
  final List<File> _videos = [];
  bool _submitting = false;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) setState(() => _images.addAll(picked.map((x) => File(x.path))));
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) setState(() => _videos.add(File(picked.path)));
  }

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) {
      _snack('Add a description first');
      return;
    }
    setState(() => _submitting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final token = await _reportService.getOrCreateReporterToken(uid);
      final reportId = await _reportService.createReport(token, _descController.text.trim());

      final imageUrls = <String>[];
      for (final f in _images) {
        imageUrls.add(await _reportService.uploadImage(f, reportId));
      }
      final videoUrls = <String>[];
      for (final f in _videos) {
        videoUrls.add(await _reportService.uploadVideo(f, reportId));
      }
      await _reportService.attachMedia(reportId, imageUrls, videoUrls);

      if (!mounted) return;
      Navigator.pop(context);
      _snack('Report submitted!');
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'What did you see?'),
          ),
          const SizedBox(height: 20),
          const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${_images.length} selected'),
          OutlinedButton(onPressed: _pickImages, child: const Text('Add Photos')),
          const SizedBox(height: 20),
          const Text('Videos', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${_videos.length} selected'),
          OutlinedButton(onPressed: _pickVideo, child: const Text('Add Video')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting ? const CircularProgressIndicator() : const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
