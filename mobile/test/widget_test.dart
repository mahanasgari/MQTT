import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/app.dart';

void main() {
  testWidgets('App renders SmartPlug text', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartPlugApp()));
    await tester.pump();
    expect(find.text('SmartPlug'), findsOneWidget);
    // Flush splash / auth timers so the binding has no pending timers.
    await tester.pump(const Duration(seconds: 3));
  });
}
