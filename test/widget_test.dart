// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:word_study/main.dart';
import 'package:word_study/services/hive_service.dart';

void main() {
  testWidgets('Word Study app smoke test', (WidgetTester tester) async {
    // Initialize Hive for testing
    await HiveService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const WordStudyApp());

    // Verify that the app loads with the home screen
    expect(find.text('Word Study'), findsOneWidget);
    expect(find.text('Suggested Passages'), findsOneWidget);
  });
}
