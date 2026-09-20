import 'package:flutter_test/flutter_test.dart';
import 'package:lumcal/models/cable_calculation_result.dart';
import 'package:lumcal/providers/cable_sizing_provider.dart';
import 'package:lumcal/providers/lighting_provider.dart';
import 'package:lumcal/utils/pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PdfGenerator generates valid English-only project PDF report bytes', () async {
    final lightingProvider = LightingProvider();

    // Add sample rooms to project
    lightingProvider.calculate(
      roomName: 'Living Room',
      length: 6.0,
      width: 4.5,
      requiredLux: 200,
      bulbLumen: 806,
      bulbWattage: 9,
    );
    lightingProvider.addCurrentToProject();

    lightingProvider.calculate(
      roomName: 'Kitchen',
      length: 4.0,
      width: 3.5,
      requiredLux: 350,
      bulbLumen: 1050,
      bulbWattage: 12,
    );
    lightingProvider.addCurrentToProject();

    final cableProvider = CableSizingProvider();

    final bytes = await PdfGenerator.generateProjectPdf(
      lightingProvider: lightingProvider,
      cableProvider: cableProvider,
    );

    expect(bytes.isNotEmpty, true);
    expect(bytes.length, greaterThan(1000));
  });

  test('PdfGenerator generates valid English-only cable sizing report bytes', () async {
    final cableProvider = CableSizingProvider();
    final result = cableProvider.result!;

    final bytes = await PdfGenerator.generateCableReportPdf(
      result: result,
      provider: cableProvider,
    );

    expect(bytes.isNotEmpty, true);
    expect(bytes.length, greaterThan(1000));
  });
}
