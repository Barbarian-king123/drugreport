import 'package:flutter_test/flutter_test.dart';
import 'package:drugreport/models/report_model.dart';
import 'package:drugreport/models/case_reason_codes.dart';

void main() {
  group('ReportModel Smoke Tests', () {
    test('ReportModel serialization and parsing', () {
      final map = {
        'reporterTokenId': 'tok-12345',
        'description': 'Suspected drug activity reported near metro station',
        'imageUrls': ['https://example.com/img1.jpg'],
        'videoUrls': <String>[],
        'verdict': 'verified',
        'status': 'closed',
        'location': {
          'latitude': 8.5241,
          'longitude': 76.9366,
          'address': 'Palayam, Thiruvananthapuram',
        },
      };

      final report = ReportModel.fromMap('rep-001', map);

      expect(report.id, equals('rep-001'));
      expect(report.reporterTokenId, equals('tok-12345'));
      expect(report.verdict, equals('verified'));
      expect(report.imageUrls.length, equals(1));
      expect(report.location?['latitude'], equals(8.5241));

      final serialized = report.toMap();
      expect(serialized['id'], equals('rep-001'));
      expect(serialized['description'], contains('Suspected drug activity'));
    });

    test('fabricatedReasonCodes contains standard reasons', () {
      expect(fabricatedReasonCodes, isNotEmpty);
      expect(fabricatedReasonCodes, contains('Reporter admitted report was invented'));
    });
  });
}
