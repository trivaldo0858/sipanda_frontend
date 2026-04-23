// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipanda_app/main.dart';

void main() {
  testWidgets('SipandaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SipandaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}