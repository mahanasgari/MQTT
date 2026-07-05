import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartplug/app.dart';

void main() {
  testWidgets('App renders SmartPlug text', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartPlugApp()));
    expect(find.text('SmartPlug'), findsOneWidget);
  });
}
