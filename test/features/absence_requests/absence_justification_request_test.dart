import 'package:flutter_test/flutter_test.dart';
import 'package:darb_alibda_sms/features/absence_requests/data/models/absence_justification_request.dart';

void main() {
  group('AbsenceJustificationRequest', () {
    test('parses backend payload into a typed request model', () {
      final payload = {
        'id': 12,
        'student': {'full_name': 'سلمان محمد'},
        'class_name': 'الصف الثالث',
        'section_name': 'شعبة A',
        'absence_date': '2024-05-12',
        'reason': 'مرض مفاجئ',
        'status': 'pending',
        'review_note': '',
        'parent': {'name': 'محمد سالم', 'phone': '0912345678'},
        'attachments': [
          {'file_name': 'report.pdf'}
        ],
        'created_at': '2024-05-12 10:00:00',
      };

      final request = AbsenceJustificationRequest.fromJson(payload);

      expect(request.id, 12);
      expect(request.studentName, 'سلمان محمد');
      expect(request.className, 'الصف الثالث • شعبة A');
      expect(request.reason, 'مرض مفاجئ');
      expect(request.hasAttachment, isTrue);
      expect(request.parentPhone, '0912345678');
    });
  });
}
