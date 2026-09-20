import 'dart:math' as math;
import 'cable_capacity.dart';

/// كائن يمثل نتيجة حساب مقطع السلك والكابل الكهربائي وفق المعايير الهندسية IEC 60364-5-52
class CableCalculationResult {
  final String phase; // "1-Phase" أو "3-Phase"
  final double voltage; // الفولت
  final double loadValue; // قيمة الحمل
  final String loadType; // "kW" أو "kVA" أو "Amps"
  final double powerFactor; // معامل القدرة cos φ
  final double length; // طول الكابل بالمتر
  final String material; // "Copper" أو "Aluminum"
  final double maxDeltaVPct; // أقصى هبوط جهد مسموح به %
  final double correctionFactorK; // معامل التصحيح الإجمالي K

  // المعايير الإضافية المتقدمة
  final String insulation; // "XLPE" أو "PVC"
  final String installationMethod; // طريقة التمديد
  final double temperature; // درجة حرارة الوسط المحيط أو التربة
  final double temperatureFactorKtemp; // معامل تصحيح الحرارة
  final int groupingCircuitsCount; // عدد الدوائر المتجاورة
  final double groupingFactorKgroup; // معامل التجاور
  final String coreType; // "Multi-Core" أو "Single-Core"

  final double designCurrentIb;
  final double requiredIz;
  final double conductivityGamma;
  final double maxDeltaVLimitVolts;
  final double minSectionForVoltageDropMinS;

  final CableCapacity? selectedCable;
  final double? cableCapacity; // السعة المصححة بطريقة التمديد
  final double? actualDeltaVVolts;
  final double? actualDeltaVPct;
  final int? suggestedBreakerAmps;
  final bool isOverCapacity;

  /// السعة النهائية للتحمل: Selected capacity from the table * Correction Factor (K)
  double? get finalCableCapacityIz =>
      cableCapacity != null ? cableCapacity! * correctionFactorK : null;

  /// المقطع الموصى به بالكابل
  double get recommendedSection => selectedCable?.section ?? 0.0;

  /// مادة الموصل
  String get conductorMaterial => material;

  /// سعة التحمل النهائية Iz
  double get finalCapacityIz => finalCableCapacityIz ?? 0.0;

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
    required this.insulation,
    required this.installationMethod,
    required this.temperature,
    required this.temperatureFactorKtemp,
    required this.groupingCircuitsCount,
    required this.groupingFactorKgroup,
    required this.coreType,
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
    String? material,
    String? conductorMaterial,
    required double maxDeltaVPct,
    double? correctionFactorK,
    String insulation = 'XLPE',
    String installationMethod = 'In Conduit / Trunking',
    double temperature = 30.0,
    int groupingCircuitsCount = 1,
    String coreType = 'Multi-Core',
  }) {
    final String chosenMaterial = material ?? conductorMaterial ?? 'Copper';
    final is1Phase = phase.contains('1');
    final isCopper = chosenMaterial.toLowerCase().contains('copper') || chosenMaterial.contains('نحاس');
    final double pf = (loadType == 'kW') ? powerFactor : 0.85;

    // 1. حساب معاملات التصحيح المعيارية K_temp و K_group
    final kTemp = CableCapacity.calculateTemperatureFactor(
      temperature: temperature,
      insulation: insulation,
      installationMethod: installationMethod,
    );

    final kGroup = CableCapacity.calculateGroupingFactor(
      circuitsCount: groupingCircuitsCount,
      coreType: coreType,
      installationMethod: installationMethod,
    );

    // إذا لم يتم تحديد K يدوياً، يحسب آلياً: K = K_temp * K_group
    final double computedK = (correctionFactorK != null && correctionFactorK > 0)
        ? correctionFactorK
        : (kTemp * kGroup);

    final effectiveK = computedK > 0 ? computedK : 1.0;

    // 2. تيار التصميم Ib
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

    // 3. التيار المطلوب تحمله بعد معامل التصحيح Required Iz
    final requiredIz = ib / effectiveK;

    // 4. الموصلية النوعية γ (نحاس = 56، ألمنيوم = 35)
    final double gamma = isCopper ? 56.0 : 35.0;

    // 5. أقصى هبوط جهد مسموح بالفولت
    final maxDeltaVLimit = voltage * (maxDeltaVPct / 100.0);

    // 6. أقل مقطع لتفادي هبوط الجهد Min S
    double minS;
    if (is1Phase) {
      minS = (2.0 * length * ib) / (gamma * maxDeltaVLimit);
    } else {
      minS = (math.sqrt(3) * length * ib * pf) / (gamma * maxDeltaVLimit);
    }

    // 7. اختيار الكابل من جدول البيانات وفق العزل وطريقة التمديد
    CableCapacity? chosenCable;
    double? capacity;

    final candidates = CableCapacity.dataset.where((item) {
      final cap = item.getCapacity(
        material: chosenMaterial,
        phase: phase,
        insulation: insulation,
        installationMethod: installationMethod,
      );
      return cap >= requiredIz && item.section >= minS;
    }).toList();

    if (candidates.isNotEmpty) {
      candidates.sort((a, b) => a.section.compareTo(b.section));
      chosenCable = candidates.first;
      capacity = chosenCable.getCapacity(
        material: chosenMaterial,
        phase: phase,
        insulation: insulation,
        installationMethod: installationMethod,
      );
    }

    // 8. حساب هبوط الجهد الفعلي مع الكابل المختار
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

    // 9. اقتراح القاطع الكهربائي المناسب (Circuit Breaker)
    int? suggestedBreaker;
    if (chosenCable != null) {
      const standardBreakers = [
        6, 10, 16, 20, 25, 32, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630
      ];
      for (final b in standardBreakers) {
        if (b >= ib) {
          suggestedBreaker = b;
          break;
        }
      }
      suggestedBreaker ??= 630;
    }

    return CableCalculationResult._(
      phase: phase,
      voltage: voltage,
      loadValue: loadValue,
      loadType: loadType,
      powerFactor: powerFactor,
      length: length,
      material: chosenMaterial,
      maxDeltaVPct: maxDeltaVPct,
      correctionFactorK: effectiveK,
      insulation: insulation,
      installationMethod: installationMethod,
      temperature: temperature,
      temperatureFactorKtemp: kTemp,
      groupingCircuitsCount: groupingCircuitsCount,
      groupingFactorKgroup: kGroup,
      coreType: coreType,
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
