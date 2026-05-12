import 'package:flutter_test/flutter_test.dart';
import 'package:financial_tracker/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verify the app scaffolding renders without crash
    await tester.pumpWidget(const FinancialTrackerApp());
    expect(find.byType(FinancialTrackerApp), findsOneWidget);
  });
}
