import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_seekho_flutter/main.dart';

void main() {
  testWidgets('App launches and renders successfully', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Pump and settle with a duration long enough to exhaust splash screen timers.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that MyApp builds successfully without crashing.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
