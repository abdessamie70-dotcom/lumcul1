import 'package:flutter_test/flutter_test.dart';
import 'package:lumcal/models/short_circuit_model.dart';
import 'package:lumcal/models/room_model.dart';
import 'package:lumcal/models/cable_calculation_result.dart';
import 'package:lumcal/providers/lighting_provider.dart';

void main() {
  group('اختبارات تيار القصر ومنحنيات الفصل IEC 60909 / IEC 60898-1', () {
    test('حساب تيار القصر ثلاثي الطور والتحقق من الفصل اللحظي لمنحنى C', () {
      final result = ShortCircuitResult.calculate(
        circuitName: 'غرفة المعيشة',
        isThreePhase: true,
        voltage: 400.0,
        upstreamIscKa: 15.0,
        cableSection: 25.0,
        cableLength: 50.0,
        conductorMaterial: 'Copper',
        insulationType: 'XLPE',
        clearingTime: 0.10,
        ratedCurrentIn: 63.0,
        curve: TrippingCurve.c,
      );

      // تيار قصر المنبع 15 kA
      expect(result.iscMaxKa, equals(15.0));

      // تيار القصر الأدنى في نهاية الكابل يجب أن يكون محسوباً وموجباً
      expect(result.iscMinA, greaterThan(500.0));

      // التحقق من عتبة منحنى C (5In إلى 10In => 315A إلى 630A)
      expect(result.magneticMinThreshold, equals(315.0));
      expect(result.magneticMaxThreshold, equals(630.0));

      // بما أن Isc_min > 630A، يجب أن يكون الفصل اللحظي محققاً
      expect(result.isInstantaneousTripOk, isTrue);

      // الكابل 25 mm² يجب أن يحقق التحمل الحراري
      expect(result.isThermallyProtected, isTrue);
      expect(result.cableSection, greaterThanOrEqualTo(result.thermalMinSectionReq));
    });

    test('التحقق من مضاعفات منحنيات الفصل المختلفة B, C, D, K, Z', () {
      expect(TrippingCurve.b.minMagneticMultiplier, equals(3.0));
      expect(TrippingCurve.b.maxMagneticMultiplier, equals(5.0));

      expect(TrippingCurve.c.minMagneticMultiplier, equals(5.0));
      expect(TrippingCurve.c.maxMagneticMultiplier, equals(10.0));

      expect(TrippingCurve.d.minMagneticMultiplier, equals(10.0));
      expect(TrippingCurve.d.maxMagneticMultiplier, equals(20.0));

      expect(TrippingCurve.k.minMagneticMultiplier, equals(8.0));
      expect(TrippingCurve.k.maxMagneticMultiplier, equals(12.0));

      expect(TrippingCurve.z.minMagneticMultiplier, equals(2.0));
      expect(TrippingCurve.z.maxMagneticMultiplier, equals(3.0));
    });

    test('اختبار دمج عناصر المشروع ذات التسمية المتطابقة في LightingProvider', () {
      final provider = LightingProvider();

      // 1. إضافة إنارة لغرفة المعيشة
      final room = provider.calculate(
        roomName: 'غرفة المعيشة',
        length: 5.0,
        width: 4.0,
        requiredLux: 200.0,
        bulbLumen: 806.0,
        bulbWattage: 9.0,
      );
      provider.addOrUpdateLightingToProject(room);

      expect(provider.totalUnifiedItemsCount, equals(1));
      expect(provider.unifiedProjectItems.first.hasLighting, isTrue);
      expect(provider.unifiedProjectItems.first.hasCable, isFalse);

      // 2. إضافة كابل بنفس التسمية "غرفة المعيشة"
      final cable = CableCalculationResult.calculate(
        phase: '3-Phase',
        voltage: 400.0,
        loadValue: 45.0,
        loadType: 'kW',
        powerFactor: 0.85,
        length: 85.0,
        conductorMaterial: 'Copper',
        insulation: 'XLPE',
        installationMethod: 'In Conduit / Trunking',
        temperature: 30.0,
        groupingCircuitsCount: 1,
        coreType: 'Multi-core',
        maxDeltaVPct: 3.0,
      );
      provider.addOrUpdateCableToProject('غرفة المعيشة', cable);

      // يجب أن يظل عدد العناصر الموحدة 1 مدمجاً
      expect(provider.totalUnifiedItemsCount, equals(1));
      expect(provider.unifiedProjectItems.first.hasLighting, isTrue);
      expect(provider.unifiedProjectItems.first.hasCable, isTrue);

      // 3. إضافة تيار قصر بنفس التسمية "غرفة المعيشة"
      final sc = ShortCircuitResult.calculate(
        circuitName: 'غرفة المعيشة',
        isThreePhase: true,
        voltage: 400.0,
        upstreamIscKa: 15.0,
        cableSection: 25.0,
        cableLength: 50.0,
        conductorMaterial: 'Copper',
        insulationType: 'XLPE',
        clearingTime: 0.10,
        ratedCurrentIn: 63.0,
        curve: TrippingCurve.c,
      );
      provider.addOrUpdateShortCircuitToProject('غرفة المعيشة', sc);

      // يجب أن يظل 1 ويشمل الثلاثة معاً
      expect(provider.totalUnifiedItemsCount, equals(1));
      final unifiedItem = provider.unifiedProjectItems.first;
      expect(unifiedItem.hasLighting, isTrue);
      expect(unifiedItem.hasCable, isTrue);
      expect(unifiedItem.hasShortCircuit, isTrue);
    });

    test('اختبار تبديل اللغة في LightingProvider', () {
      final provider = LightingProvider();
      expect(provider.isArabic, isTrue);
      expect(provider.locale.languageCode, equals('ar'));

      provider.toggleLocale();
      expect(provider.isArabic, isFalse);
      expect(provider.locale.languageCode, equals('en'));

      provider.toggleLocale();
      expect(provider.isArabic, isTrue);
      expect(provider.locale.languageCode, equals('ar'));
    });
  });
}
