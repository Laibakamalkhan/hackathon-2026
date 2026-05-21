import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_seekho/core/constants/app_durations.dart';
import 'package:ai_seekho/main.dart';

void main() {
  testWidgets('App launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [backendOnlineProvider.overrideWithValue(false)],
        child: const KarigarApp(),
      ),
    );
    await tester.pump();
    expect(find.text('KARIGAR'), findsOneWidget);
    // Splash schedules navigation via Future.delayed — flush timer before dispose.
    await tester.pump(AppDurations.splash);
    await tester.pump();
  });
}
