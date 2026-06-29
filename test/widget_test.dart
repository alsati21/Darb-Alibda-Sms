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
}
