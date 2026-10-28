import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:personal_eco_tracker/main.dart';

Future<void> pumpToLoginScreen(WidgetTester tester) async {
  await tester.pumpWidget(const PersonalEcoTracker());

  // Advance past the splash screen timer.
  await tester.pump(const Duration(seconds: 4));
  await tester.pump();

  // Wait for the Welcome screen to appear.
  expect(find.text('Get Started'), findsOneWidget);

  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();

  expect(find.text('Welcome Back'), findsOneWidget);
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Login screen renders core UI elements', (
    WidgetTester tester,
  ) async {
    await pumpToLoginScreen(tester);

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Login form shows validation errors on empty submit', (
    WidgetTester tester,
  ) async {
    await pumpToLoginScreen(tester);

    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');

    expect(signInButton, findsOneWidget);

    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
