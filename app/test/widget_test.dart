import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:radian_app/main.dart';

void main() {
  testWidgets('RadianApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const RadianApp());
    await tester.pumpAndSettle();
  });
}