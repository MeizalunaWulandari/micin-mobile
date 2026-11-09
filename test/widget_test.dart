import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('MicinApp renders in Dark Mode smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MicinApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'MicinProject');
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.brightness, Brightness.dark);
  });
}
