import 'dart:math';

/// يمثل أنواع منحنيات الفصل للقواطع وفق IEC 60898-1 / IEC 60947-2
enum TrippingCurve {
  b('B', 3.0, 5.0),
  c('C', 5.0, 10.0),
  d('D', 10.0, 20.0),
  k('K', 8.0, 12.0),
  z('Z', 2.0, 3.0);

  final String code;
  final double minMagneticMultiplier;
  final double maxMagneticMultiplier;

  const TrippingCurve(this.code, this.minMagneticMultiplier, this.maxMagneticMultiplier);

  String description(bool isArabic) {
    if (isArabic) {
      switch (this) {
        case TrippingCurve.b:
          return 'منحنى B (3 إلى 5 In): مخصص لدوائر الإنارة، والخطوط الطويلة جداً، والتطبيقات بدون تيارات إقلاع.';
        case TrippingCurve.c:
          return 'منحنى C (5 إلى 10 In): المنحنى القياسي الأكثر انتشاراً للأحمال المنزلية والتجارية والمقابس.';
        case TrippingCurve.d:
          return 'منحنى D (10 إلى 20 In): مخصص للأحمال ذات تيار بدء مرتفع مثل المحركات والمحولات الكبيرة.';
        case TrippingCurve.k:
          return 'منحنى K (8 إلى 12 In): لحماية المحركات مع تيار بدء مرتفع دون التعرض للفصل الخاطئ.';
        case TrippingCurve.z:
          return 'منحنى Z (2 إلى 3 In): شديد الحساسية لحماية الدوائر الإلكترونية الحساسة وشبه الموصلات.';
      }
    } else {
      switch (this) {
        case TrippingCurve.b:
          return 'Curve B (3 to 5 In): Ideal for lighting circuits, long cable runs, and circuits without inrush surges.';
        case TrippingCurve.c:
          return 'Curve C (5 to 10 In): General commercial and domestic standard curve for sockets and general loads.';
        case TrippingCurve.d:
          return 'Curve D (10 to 20 In): Designed for high inrush currents, large motors, transformers, and industrial machinery.';
        case TrippingCurve.k:
          return 'Curve K (8 to 12 In): Designed for motor protection with high starting surge without nuisance tripping.';
        case TrippingCurve.z:
          return 'Curve Z (2 to 3 In): High sensitivity for protecting sensitive semiconductors and electronic controls.';
      }
    }
  }
}

/// نتيجة حساب تيار القصر والتحقق من القاطع
class ShortCircuitResult {
  final String circuitName;
  final bool isThreePhase;
  final double voltage;
  final double upstreamIscKa;
  final double cableSection;
  final double cableLength;
  final String conductorMaterial;
  final String insulationType;
  final double clearingTime; // بالثواني
  final double ratedCurrentIn; // In
  final TrippingCurve curve;

  final double iscMaxKa; // أقصى تيار قصر عند بداية الكابل
  final double iscMinA; // أدنى تيار قصر عند نهاية الكابل
  final double thermalMinSectionReq; // S_min للتحمل الحراري
  final bool isThermallyProtected; // هل المقطع الفعلي يحقق التحمل الحراري
  final double magneticMinThreshold; // Imag_min
  final double magneticMaxThreshold; // Imag_max
  final bool isInstantaneousTripOk; // هل تيار القصر الأدنى أكبر من عتبة القاطع
  final double maxPermissibleLength; // L_max لضمان الفصل المغناطيسي

  const ShortCircuitResult({
    required this.circuitName,
    required this.isThreePhase,
    required this.voltage,
    required this.upstreamIscKa,
    required this.cableSection,
    required this.cableLength,
    required this.conductorMaterial,
    required this.insulationType,
    required this.clearingTime,
    required this.ratedCurrentIn,
    required this.curve,
    required this.iscMaxKa,
    required this.iscMinA,
    required this.thermalMinSectionReq,
    required this.isThermallyProtected,
    required this.magneticMinThreshold,
    required this.magneticMaxThreshold,
    required this.isInstantaneousTripOk,
    required this.maxPermissibleLength,
  });

  /// مصنع الحساب الهندسي وفق معايير IEC 60909 و IEC 60364-4-41
  factory ShortCircuitResult.calculate({
    required String circuitName,
    required bool isThreePhase,
    required double voltage,
    required double upstreamIscKa,
    required double cableSection,
    required double cableLength,
    required String conductorMaterial,
    required String insulationType,
    required double clearingTime,
    required double ratedCurrentIn,
    required TrippingCurve curve,
  }) {
    final bool isCu = conductorMaterial.toLowerCase().contains('cu') ||
        conductorMaterial.toLowerCase().contains('copper') ||
        conductorMaterial.contains('نحاس');
    final bool isXlpe = insulationType.toUpperCase().contains('XLPE');

    // المقاومة النوعية الساخنة rho_hot عند القصر (IEC 60364-4-41)
    final double rhoHot = isCu ? 0.0225 : 0.036; // ohm.mm²/m

    // معامل K للتحمل الحراري للكابل
    double kFactor = 143.0;
    if (isCu && !isXlpe) {
      kFactor = 115.0;
    } else if (!isCu && isXlpe) {
      kFactor = 94.0;
    } else if (!isCu && !isXlpe) {
      kFactor = 76.0;
    }

    final double uph = isThreePhase ? 230.0 : voltage;
    final double un = voltage;
    final double iscSourceA = upstreamIscKa * 1000.0;

    // ممانعة المنبع Z_upstream
    final double zUpstream = isThreePhase
        ? (un / (sqrt(3) * iscSourceA))
        : (un / iscSourceA);

    // مقاومة الكابل
    final double rCable = (rhoHot * cableLength) / cableSection;

    // 1. أقصى تيار قصر Isc_max
    final double iscMaxKa = upstreamIscKa;

    // 2. أدنى تيار قصر في نهاية الخط Isc_min (Phase-to-Neutral / Phase-to-Earth)
    // حسب IEC 60364-4-41: Isc_min = (0.8 * Uph) / (2 * (R_cable + Z_upstream))
    final double totalRmin = (2.0 * rCable) + zUpstream;
    final double iscMinA = (0.8 * uph) / totalRmin;

    // 3. التحقق من التحمل الحراري S_min = sqrt(Isc² * t) / k
    final double sMinReq = (sqrt(pow(iscSourceA, 2) * clearingTime)) / (kFactor * 10.0);
    final bool isThermallyProtected = cableSection >= sMinReq;

    // 4. عتبات الفصل المغناطيسي
    final double imagMin = ratedCurrentIn * curve.minMagneticMultiplier;
    final double imagMax = ratedCurrentIn * curve.maxMagneticMultiplier;

    // 5. التحقق من الفصل اللحظي
    final bool isInstantaneousTripOk = iscMinA >= imagMax;

    // 6. أقصى طول مسموح للكابل لضمان الفصل المغناطيسي L_max
    final double lMax = (0.8 * uph * cableSection) / (2.0 * rhoHot * imagMax);

    return ShortCircuitResult(
      circuitName: circuitName,
      isThreePhase: isThreePhase,
      voltage: voltage,
      upstreamIscKa: upstreamIscKa,
      cableSection: cableSection,
      cableLength: cableLength,
      conductorMaterial: conductorMaterial,
      insulationType: insulationType,
      clearingTime: clearingTime,
      ratedCurrentIn: ratedCurrentIn,
      curve: curve,
      iscMaxKa: iscMaxKa,
      iscMinA: iscMinA,
      thermalMinSectionReq: sMinReq,
      isThermallyProtected: isThermallyProtected,
      magneticMinThreshold: imagMin,
      magneticMaxThreshold: imagMax,
      isInstantaneousTripOk: isInstantaneousTripOk,
      maxPermissibleLength: lMax,
    );
  }
}
