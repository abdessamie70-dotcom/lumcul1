import 'dart:math' as math;
import 'cable_capacity.dart';

/// كائن يمثل نتيجة حساب مقطع السلك والكابل الكهربائي وفق المعايير الهندسية
class CableCalculationResult {
  final String phase; // "1-Phase" أو "3-Phase"
  final double voltage; // الفولت
  final double loadValue; // قيمة الحمل
  final String loadType; // "kW" أو "kVA" أو "Amps"
  final double powerFactor; // معامل القدرة cos φ
  final double length; // طول الكابل بالمتر
  final String material; // "Copper" أو "Aluminum"
  final double maxDeltaVPct; // أقصى هبوط جهد مسموح به %
  final double correctionFactorK; // معامل التصحيح K

  final double designCurrentIb;
  final double requiredIz;
  final double conductivityGamma;
  final double maxDeltaVLimitVolts;
  final double minSectionForVoltageDropMinS;

  final CableCapacity? selectedCable;
  final double? cableCapacity; // Raw capacity from table
  final double? actualDeltaVVolts;
  final double? actualDeltaVPct;
  final int? suggestedBreakerAmps;
  final bool isOverCapacity;

  /// السعة النهائية للتحمل: Selected raw capacity from the table * Correction Factor (K)
  double? get finalCableCapacityIz =>
      cableCapacity != null ? cableCapacity! * correctionFactorK : null;

  CableCalculationResult._({
    required this.phase,
    required this.voltage,
    required this.loadValue,
    required this.loadType,
    required this.powerFactor,
    required this.length,
    required this.material,
    required this.maxDeltaVPct,
    required this.correctionFactorK,
    required this.designCurrentIb,
    required this.requiredIz,
    required this.conductivityGamma,
    required this.maxDeltaVLimitVolts,
    required this.minSectionForVoltageDropMinS,
    required this.selectedCable,
    required this.cableCapacity,
    required this.actualDeltaVVolts,
    required this.actualDeltaVPct,
    required this.suggestedBreakerAmps,
    required this.isOverCapacity,
  });

  /// إنشاء وحساب النتيجة بناءً على المدخلات الدقيقة
  factory CableCalculationResult.calculate({
    required String phase,
    required double voltage,
    required double loadValue,
    required String loadType,
    required double powerFactor,
    required double length,
    required String material,
    required double maxDeltaVPct,
    required double correctionFactorK,
  }) {
    final is1Phase = phase.contains('1');
    final isCopper = material.toLowerCase().contains('copper') || material.contains('نحاس');
    final double pf = (loadType == 'kW') ? powerFactor : 0.85;

    // 1. تيار التصميم Ib
    double ib;
    if (loadType == 'Amps') {
      ib = loadValue;
    } else if (loadType == 'kW') {
      if (is1Phase) {
        ib = (loadValue * 1000.0) / (voltage * pf);
      } else {
        ib = (loadValue * 1000.0) / (voltage * pf * math.sqrt(3));
      }
    } else {
      // kVA
      if (is1Phase) {
        ib = (loadValue * 1000.0) / voltage;
      } else {
        ib = (loadValue * 1000.0) / (voltage * math.sqrt(3));
      }
    }

    // 2. التيار المطلوب تحمله بعد معامل التصحيح Required Iz
    final k = correctionFactorK > 0 ? correctionFactorK : 1.0;
    final requiredIz = ib / k;

    // 3. الموصلية النوعية γ
    final double gamma = isCopper ? 56.0 : 35.0;

    // 4. أقصى هبوط جهد مسموح بالفولت
    final maxDeltaVLimit = voltage * (maxDeltaVPct / 100.0);

    // 5. أقل مقطع لتفادي هبوط الجهد Min S
    double minS;
    if (is1Phase) {
      minS = (2.0 * length * ib) / (gamma * maxDeltaVLimit);
    } else {
      minS = (math.sqrt(3) * length * ib * pf) / (gamma * maxDeltaVLimit);
    }

    // 6. اختيار الكابل من جدول البيانات
    CableCapacity? chosenCable;
    double? capacity;

    final candidates = CableCapacity.dataset.where((item) {
      final cap = item.getCapacity(material: material, phase: phase);
      return cap >= requiredIz && item.section >= minS;
    }).toList();

    if (candidates.isNotEmpty) {
      // اختيار أصغر مقطع يلبي الشرطين
      candidates.sort((a, b) => a.section.compareTo(b.section));
      chosenCable = candidates.first;
      capacity = chosenCable.getCapacity(material: material, phase: phase);
    }

    // 7. حساب هبوط الجهد الفعلي مع الكابل المختار
    double? actualDeltaV;
    double? actualDeltaVPctVal;
    if (chosenCable != null) {
      final s = chosenCable.section;
      if (is1Phase) {
        actualDeltaV = (2.0 * length * ib) / (gamma * s);
      } else {
        actualDeltaV = (math.sqrt(3) * length * ib * pf) / (gamma * s);
      }
      actualDeltaVPctVal = (actualDeltaV / voltage) * 100.0;
    }

    // 8. اقتراح القاطع الكهربائي المناسب (Circuit Breaker)
    int? suggestedBreaker;
    if (chosenCable != null) {
      const standardBreakers = [
        6, 10, 16, 20, 25, 32, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400
      ];
      for (final b in standardBreakers) {
        if (b >= ib) {
          suggestedBreaker = b;
          break;
        }
      }
      suggestedBreaker ??= 400;
    }

    return CableCalculationResult._(
      phase: phase,
      voltage: voltage,
      loadValue: loadValue,
      loadType: loadType,
      powerFactor: powerFactor,
      length: length,
      material: material,
      maxDeltaVPct: maxDeltaVPct,
      correctionFactorK: correctionFactorK,
      designCurrentIb: ib,
      requiredIz: requiredIz,
      conductivityGamma: gamma,
      maxDeltaVLimitVolts: maxDeltaVLimit,
      minSectionForVoltageDropMinS: minS,
      selectedCable: chosenCable,
      cableCapacity: capacity,
      actualDeltaVVolts: actualDeltaV,
      actualDeltaVPct: actualDeltaVPctVal,
      suggestedBreakerAmps: suggestedBreaker,
      isOverCapacity: chosenCable == null,
    );
  }
}
