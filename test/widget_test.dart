import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('MicinApp renders in Dark Mode smoke test', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MicinApp());

    // Verifikasi judul dan banner
    expect(find.text('MicinProject'), findsOneWidget);
    expect(find.text('Always Dark Mode'), findsOneWidget);
    expect(find.text('Tambah Task Baru'), findsOneWidget);

    // Verifikasi tema yang digunakan adalah dark
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.brightness, Brightness.dark);
  });
}
