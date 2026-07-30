// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:darb_alibda_sms/features/auth/data/repositories/auth_repository.dart';
import 'package:darb_alibda_sms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:darb_alibda_sms/features/auth/presentation/pages/login_page.dart';

class _FakeAuthRepository extends AuthRepository {
  @override
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    String? fcmToken,
  }) async {
    throw ApiValidationException(
      errors: {
        'password': ['كلمة المرور خاطئة. حاول مرة أخرى.'],
      },
      message: 'البيانات المقدمة غير صالحة.',
    );
  }
}

void main() {
  testWidgets('Login screen renders its auth form', (WidgetTester tester) async {
    final authCubit = AuthCubit(AuthRepository());

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('أهلاً بك'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });

  testWidgets('Login screen shows the backend validation error from the password field', (WidgetTester tester) async {
    final authCubit = AuthCubit(_FakeAuthRepository());

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), '0999999999');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('كلمة المرور خاطئة'), findsOneWidget);
  });
}
