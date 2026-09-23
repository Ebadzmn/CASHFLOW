import 'package:flutter_test/flutter_test.dart';
import 'package:cashflow_inc_exp/app.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());
  });
}
