import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/main.dart';

void main() {
  testWidgets('CoffeeCraft initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CoffeeCraftApp(),
      ),
    );

    expect(find.text('CoffeeCraft'), findsOneWidget);
  });
}
