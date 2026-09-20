import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lumcal/main.dart';
import 'package:lumcal/providers/cable_sizing_provider.dart';
import 'package:lumcal/providers/lighting_provider.dart';
import 'package:lumcal/providers/short_circuit_provider.dart';

void main() {
  testWidgets('LightingCalculatorApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LightingProvider()),
          ChangeNotifierProvider(create: (_) => CableSizingProvider()),
          ChangeNotifierProvider(create: (_) => ShortCircuitProvider()),
        ],
        child: const LightingCalculatorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LUMCAL APP'), findsWidgets);
    expect(find.text('by BOUGHABA ABDESSAMIE'), findsWidgets);
  });
}

