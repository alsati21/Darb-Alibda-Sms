import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:darb_alibda_sms/core/network/api_client.dart';
import 'package:darb_alibda_sms/features/attendance/data/repositories/attendance_repository.dart';

class RecordingHttpClient extends http.BaseClient {
  RecordingHttpClient();

  Map<String, String>? capturedHeaders;
  String? capturedBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    capturedHeaders = request.headers;
    capturedBody = await utf8.decoder.bind(request.finalize()).join();

    final responseBody = '{"data":{"section_id":1,"date":"2026-06-29","counts":{"present":1,"absent":0,"late":0,"attendance_rate":100}}}';
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  @override
  void close() {}
}

void main() {
  group('AttendanceRepository', () {
    test('sends a JSON request with the expected student payload', () async {
      final client = RecordingHttpClient();
      final repository = AttendanceRepository(
        apiClient: ApiClient(inner: client, baseUrl: 'http://127.0.0.1:8000'),
      );

      await repository.batchUpdateAttendance(
        token: 'demo-token',
        sectionId: 1,
        date: '2026-06-29',
        scheduleId: 1,
        students: [
          {'student_id': 1, 'status': 'present'},
          {'student_id': 2, 'status': 'absent'},
        ],
      );

      expect(client.capturedHeaders, isNotNull);
      expect(client.capturedHeaders!['Content-Type'], 'application/json');
      expect(client.capturedBody, isNotNull);
      expect(client.capturedBody, contains('"students"'));
      expect(client.capturedBody, contains('"student_id":1'));
    });
  });
}
