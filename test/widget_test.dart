import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lumcal/main.dart';
import 'package:lumcal/providers/lighting_provider.dart';

void main() {
  testWidgets('LightingCalculatorApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LightingProvider(),
        child: const LightingCalculatorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('حاسبة الإضاءة المنزلية'), findsWidgets);
    expect(find.text('احسب الإضاءة المطلوبة'), findsOneWidget);
  });
}
