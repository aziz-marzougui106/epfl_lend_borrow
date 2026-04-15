import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:epfl_lend_borrow/main.dart';

void main() {
  testWidgets('Marketplace App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Marketplace title is present
    expect(find.text('Marketplace'), findsWidgets);
  });
}
