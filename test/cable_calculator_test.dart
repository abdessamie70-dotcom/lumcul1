import 'package:flutter_test/flutter_test.dart';
import 'package:lumcal/models/cable_calculation_result.dart';

void main() {
  group('اختبارات الحسابات الهندسية لمقاطع الكابلات والأسلاك', () {
    test('التحقق من حساب الكابل الثلاثي الأطوار وفق المعايير الافتراضية', () {
      // 3-Phase, 400V, 45kW, PF=0.85, 85m, Copper, Max ΔV 3%, K=0.87
      final result = CableCalculationResult.calculate(
        phase: '3-Phase',
        voltage: 400.0,
        loadValue: 45.0,
        loadType: 'kW',
        powerFactor: 0.85,
        length: 85.0,
        material: 'Copper',
        maxDeltaVPct: 3.0,
        correctionFactorK: 0.87,
      );

      // 1. تيار التصميم Ib: 45000 / (400 * 0.85 * sqrt(3)) ≈ 76.414 A
      expect(result.designCurrentIb, closeTo(76.41, 0.1));

      // 2. التيار المطلوب تحمله Iz: 76.414 / 0.87 ≈ 87.83 A
      expect(result.requiredIz, closeTo(87.83, 0.1));

      // 3. أقصى هبوط جهد مسموح: 400 * 0.03 = 12V
      expect(result.maxDeltaVLimitVolts, equals(12.0));

      // 4. أقل مقطع لهبوط الجهد Min S: (sqrt(3) * 85 * 76.414 * 0.85) / (56 * 12) ≈ 14.24 mm²
      expect(result.minSectionForVoltageDropMinS, closeTo(14.24, 0.2));

      // 5. الكابل المختار يجب أن يكون 25 mm² لأن سعتها 89A >= 87.83A و 25 >= 14.24
      expect(result.selectedCable, isNotNull);
      expect(result.selectedCable!.section, equals(25.0));
      expect(result.cableCapacity, equals(89.0));

      // 6. هبوط الجهد الفعلي مع كابل 25 mm²:
      // actualDeltaV = (sqrt(3) * 85 * 76.414 * 0.85) / (56 * 25) ≈ 6.83V (1.71%)
      expect(result.actualDeltaVPct, lessThanOrEqualTo(3.0));
      expect(result.actualDeltaVPct, closeTo(1.71, 0.1));
    });

    test('التحقق من حساب خط إنارة أحادي الطور 1-Phase', () {
      // 1-Phase, 230V, 1.5kW, PF=0.9, 25m, Copper, Max ΔV 3%, K=0.87
      final result = CableCalculationResult.calculate(
        phase: '1-Phase',
        voltage: 230.0,
        loadValue: 1.5,
        loadType: 'kW',
        powerFactor: 0.90,
        length: 25.0,
        material: 'Copper',
        maxDeltaVPct: 3.0,
        correctionFactorK: 0.87,
      );

      // Ib = 1500 / (230 * 0.9) = 7.246 A
      expect(result.designCurrentIb, closeTo(7.25, 0.1));
      // Required Iz = 7.246 / 0.87 ≈ 8.33 A
      expect(result.requiredIz, closeTo(8.33, 0.1));
      // Min S = (2 * 25 * 7.246) / (56 * 6.9) ≈ 0.93 mm²
      expect(result.minSectionForVoltageDropMinS, lessThan(1.5));

      // الكابل المختار يجب أن يكون 1.5 mm²
      expect(result.selectedCable, isNotNull);
      expect(result.selectedCable!.section, equals(1.5));
      expect(result.suggestedBreakerAmps, equals(10));
    });

    test('التحقق من حالة الحمل الفائق التي تتطلب كابلات على التوازي', () {
      // حمل ضخم جداً 500 kW
      final result = CableCalculationResult.calculate(
        phase: '3-Phase',
        voltage: 400.0,
        loadValue: 500.0,
        loadType: 'kW',
        powerFactor: 0.85,
        length: 100.0,
        material: 'Copper',
        maxDeltaVPct: 3.0,
        correctionFactorK: 0.87,
      );

      expect(result.isOverCapacity, isTrue);
      expect(result.selectedCable, isNull);
    });
  });
}
