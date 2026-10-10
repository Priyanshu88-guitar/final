import 'package:flutter_test/flutter_test.dart';
import 'package:voltera/app/app.dart';

void main() {
  testWidgets('VolteraApp navigation flow smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VolteraApp());

    // Verify splash screen appears.
    expect(find.text('VOLTERA'), findsWidgets);

    // Advance time to complete splash screen timer and navigate to onboarding.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify onboarding screen appears.
    expect(find.text('AI-Powered EV Charging\nFor Two-Wheelers'), findsOneWidget);
  });
}
