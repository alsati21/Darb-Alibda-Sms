import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:darb_alibda_sms/core/network/api_client.dart';
import 'package:darb_alibda_sms/features/grades/data/repositories/grades_repository.dart';

void main() {
  test('fetchSubjectComponents parses nested component collections from API response', () async {
    final repository = GradesRepository(
      apiClient: ApiClient(
        inner: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'components': [
                  {'id': 2, 'name': 'شفهي'},
                  {'id': 6, 'name': 'تطبيقي'},
                  {'id': 1, 'name': 'كتابي'},
                ],
              },
            }),
            200,
            headers: {'Content-Type': 'application/json'},
          );
        }),
      ),
    );

    final components = await repository.fetchSubjectComponents('token', 2);

    expect(components.map((c) => c.id), containsAll([1, 2, 6]));
    expect(components.map((c) => c.name), containsAll(['كتابي', 'شفهي', 'تطبيقي']));
  });
}
