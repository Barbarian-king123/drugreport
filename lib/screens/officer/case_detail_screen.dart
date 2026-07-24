import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/case_reason_codes.dart';

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

  Future<void> _setVerdict(String verdict, {String? reasonCode}) async {
    setState(() => _submitting = true);
    try {
      final reportRef = FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId);
      final reporterTokenId = widget.data['reporterTokenId'];

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final tokenQuery = await FirebaseFirestore.instance
            .collection('reporter_tokens')
            .where('token', isEqualTo: reporterTokenId)
            .limit(1)
            .get();

        tx.update(reportRef, {
          'verdict': verdict,
          'status': verdict == 'fabricated' ? 'fineIssued' : 'closed',
          'reasonCode': reasonCode,
          'verdictAt': FieldValue.serverTimestamp(),
        });

        if (tokenQuery.docs.isNotEmpty) {
          final uid = tokenQuery.docs.first.data()['uid'];
          final userRef = FirebaseFirestore.instance
              .collection('users')
              .doc(uid);

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
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showFabricatedReasonPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select reason (required)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...fabricatedReasonCodes.map(
            (code) => ListTile(
              title: Text(code),
              onTap: () {
                Navigator.pop(context);
                _setVerdict('fabricated', reasonCode: code);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final imageUrls = List<String>.from(data['imageUrls'] ?? []);
    final videoUrls = List<String>.from(data['videoUrls'] ?? []);

    return Scaffold(
      appBar: AppBar(title: const Text('Case Detail')),
      body: _submitting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(data['description'] ?? ''),
                const SizedBox(height: 20),
                if (imageUrls.isNotEmpty) ...[
                  const Text(
                    'Photos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: imageUrls
                          .map(
                            (url) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.network(
                                url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (videoUrls.isNotEmpty) ...[
                  Text(
                    '${videoUrls.length} video(s) attached',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                ],
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Set Verdict',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Verified — crime confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => _setVerdict('verified'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Inconclusive — no evidence either way'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  onPressed: () => _setVerdict('inconclusive'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Fabricated — proven false'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _showFabricatedReasonPicker,
                ),
              ],
            ),
    );
  }
}
