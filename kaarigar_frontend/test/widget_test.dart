import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_seekho/main.dart';

void main() {
  testWidgets('App launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KarigarApp()));
    await tester.pump();
    expect(find.text('KARIGAR'), findsOneWidget);
  });
}
