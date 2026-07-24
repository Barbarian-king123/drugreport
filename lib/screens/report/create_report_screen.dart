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
  final List<XFile> _images = [];
  final List<XFile> _videos = [];
  bool _submitting = false;
  bool _reportAnon = true;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _images.addAll(picked));
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _videos.add(picked));
    }
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
      final reportId = await _reportService.createReport(
        token,
        _descController.text.trim(),
        anonymous: _reportAnon,
      );

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
      appBar: AppBar(title: const Text('Report Issue')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Describe the issue', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'What did you see? Provide details of the incident or activity.',
            ),
          ),
          const SizedBox(height: 20),
          const Text('Add evidence (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _mediaButton(Icons.photo_library, 'Add Photo', _pickImages),
              _mediaButton(Icons.videocam, 'Add Video', _pickVideo),
            ],
          ),
          const SizedBox(height: 12),
          if (_images.isNotEmpty || _videos.isNotEmpty) ...[
            _mediaPreview(),
            const SizedBox(height: 20),
          ],
          const Text('Report anonymously', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _reportAnon,
            onChanged: (value) => setState(() => _reportAnon = value),
            title: const Text('Your identity will be hidden'),
            activeColor: const Color(0xFFE53341),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53341)),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('SUBMIT REPORT'),
          ),
        ],
      ),
    );
  }

  Widget _mediaButton(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF23232E)),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF17171F),
        minimumSize: const Size(150, 46),
      ),
    );
  }

  Widget _mediaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selected evidence', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._images.map((file) => _previewTile(file.name, Icons.photo)),
            ..._videos.map((file) => _previewTile(file.name, Icons.videocam)),
          ],
        ),
      ],
    );
  }

  Widget _previewTile(String label, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF23232E)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE53341)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
