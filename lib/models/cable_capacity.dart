/// نموذج يمثل جدول سعات الكابلات والأسلاك الكهربائية بالمليمتر المربع وفق معايير IEC 60364-5-52
class CableCapacity {
  final double section;

  // سعات النحاس بعزل PVC (70°C)
  final double cuPvc1Ph;
  final double cuPvc3Ph;

  // سعات الألمنيوم بعزل PVC (70°C)
  final double alPvc1Ph;
  final double alPvc3Ph;

  // سعات النحاس بعزل XLPE (90°C)
  final double cuXlpe1Ph;
  final double cuXlpe3Ph;

  // سعات الألمنيوم بعزل XLPE (90°C)
  final double alXlpe1Ph;
  final double alXlpe3Ph;

  const CableCapacity({
    required this.section,
    required this.cuPvc1Ph,
    required this.cuPvc3Ph,
    required this.alPvc1Ph,
    required this.alPvc3Ph,
    required this.cuXlpe1Ph,
    required this.cuXlpe3Ph,
    required this.alXlpe1Ph,
    required this.alXlpe3Ph,
  });

  /// الحصول على سعة التحمل بالأمبير بناءً على مادة الموصل، نوع العزل، طريقة التمديد، ونظام الأطوار
  double getCapacity({
    required String material,
    required String phase,
    String insulation = 'XLPE',
    String installationMethod = 'In Conduit / Trunking',
  }) {
    final isCopper = material.toLowerCase().contains('copper') || material.contains('نحاس');
    final is1Phase = phase.contains('1');
    final isXlpe = insulation.toUpperCase().contains('XLPE');

    double baseCapacity;
    if (isCopper) {
      if (isXlpe) {
        baseCapacity = is1Phase ? cuXlpe1Ph : cuXlpe3Ph;
      } else {
        baseCapacity = is1Phase ? cuPvc1Ph : cuPvc3Ph;
      }
    } else {
      if (isXlpe) {
        baseCapacity = is1Phase ? alXlpe1Ph : alXlpe3Ph;
      } else {
        baseCapacity = is1Phase ? alPvc1Ph : alPvc3Ph;
      }
    }

    // معامل طريقة التمديد بالنسبة للمرجع (Method B2 - In Conduit)
    final methodFactor = getInstallationMethodFactor(installationMethod);
    return baseCapacity * methodFactor;
  }

  /// معامل طريقة التمديد وفقاً لمعايير IEC 60364-5-52
  static double getInstallationMethodFactor(String method) {
    final m = method.toLowerCase();
    if (m.contains('direct buried') || m.contains('مدفون مباشرة')) {
      // Method D2: تبريد التربة المباشر يعطي سعة أعلى بحوالي 15-20%
      return 1.18;
    } else if (m.contains('underground duct') || m.contains('مجرى بالتربة') || m.contains('أنبوب في الأرض')) {
      // Method D1: أنبوب مدفون بالأرض
      return 1.05;
    } else if (m.contains('air') || m.contains('tray') || m.contains('هواء') || m.contains('حامل')) {
      // Method E / F: الهواء الطلق وحامل الكابلات المثقب يعطي سعة أعلى بحوالي 10-15%
      return 1.12;
    } else if (m.contains('surface') || m.contains('جدار') || m.contains('clipped')) {
      // Method C: مثبت مباشرة على السطح
      return 1.06;
    }
    // Method B1 / B2: داخل مجرى / ماسورة (المعيار المرجعي الأساسي 1.00)
    return 1.00;
  }

  /// حساب معامل تصحيح درجة الحرارة K_temp وفقاً لـ IEC 60364-5-52
  static double calculateTemperatureFactor({
    required double temperature,
    required String insulation,
    required String installationMethod,
  }) {
    final isXlpe = insulation.toUpperCase().contains('XLPE');
    final isBuried = installationMethod.toLowerCase().contains('buried') ||
        installationMethod.toLowerCase().contains('duct') ||
        installationMethod.contains('مدفون');

    if (isBuried) {
      // درجة الحرارة المرجعية للتربة 20°C (IEC 60364-5-52 Table B.52.15)
      if (isXlpe) {
        if (temperature <= 10) return 1.07;
        if (temperature <= 15) return 1.04;
        if (temperature <= 20) return 1.00;
        if (temperature <= 25) return 0.96;
        if (temperature <= 30) return 0.93;
        if (temperature <= 35) return 0.89;
        return 0.85; // 40°C+
      } else {
        // PVC
        if (temperature <= 10) return 1.10;
        if (temperature <= 15) return 1.05;
        if (temperature <= 20) return 1.00;
        if (temperature <= 25) return 0.95;
        if (temperature <= 30) return 0.89;
        if (temperature <= 35) return 0.84;
        return 0.77; // 40°C+
      }
    } else {
      // درجة الحرارة المرجعية للهواء 30°C (IEC 60364-5-52 Table B.52.14)
      if (isXlpe) {
        if (temperature <= 25) return 1.04;
        if (temperature <= 30) return 1.00;
        if (temperature <= 35) return 0.96;
        if (temperature <= 40) return 0.91;
        if (temperature <= 45) return 0.87;
        if (temperature <= 50) return 0.82;
        if (temperature <= 55) return 0.76;
        return 0.71; // 60°C+
      } else {
        // PVC
        if (temperature <= 25) return 1.06;
        if (temperature <= 30) return 1.00;
        if (temperature <= 35) return 0.94;
        if (temperature <= 40) return 0.87;
        if (temperature <= 45) return 0.79;
        if (temperature <= 50) return 0.71;
        if (temperature <= 55) return 0.61;
        return 0.50; // 60°C+
      }
    }
  }

  /// حساب معامل التجاور K_group وفقاً لـ IEC 60364-5-52 Table B.52.17
  static double calculateGroupingFactor({
    required int circuitsCount,
    required String coreType,
    required String installationMethod,
  }) {
    if (circuitsCount <= 1) return 1.00;

    final isBuried = installationMethod.toLowerCase().contains('buried') ||
        installationMethod.contains('مدفون');

    if (isBuried) {
      // كابلات مدفونة في الأرض
      switch (circuitsCount) {
        case 2: return 0.80;
        case 3: return 0.70;
        case 4: return 0.65;
        case 5: return 0.60;
        default: return 0.55; // 6 أو أكثر
      }
    } else {
      // كابلات في الهواء أو المواسير أو الحوامل
      switch (circuitsCount) {
        case 2: return 0.80;
        case 3: return 0.70;
        case 4: return 0.65;
        case 5: return 0.60;
        case 6: return 0.57;
        case 7: return 0.54;
        case 8: return 0.52;
        case 9: return 0.50;
        default: return 0.45; // 10 أو أكثر
      }
    }
  }

  /// جدول السعات المعيارية المعتمد وفقاً لـ IEC 60364-5-52 (In Conduit - Method B2)
  static const List<CableCapacity> dataset = [
    CableCapacity(
      section: 1.5,
      cuPvc1Ph: 17.5, cuPvc3Ph: 15.5, alPvc1Ph: 13.5, alPvc3Ph: 12.0,
      cuXlpe1Ph: 22.0, cuXlpe3Ph: 19.5, alXlpe1Ph: 17.0, alXlpe3Ph: 15.0,
    ),
    CableCapacity(
      section: 2.5,
      cuPvc1Ph: 24.0, cuPvc3Ph: 21.0, alPvc1Ph: 18.5, alPvc3Ph: 16.5,
      cuXlpe1Ph: 30.0, cuXlpe3Ph: 26.0, alXlpe1Ph: 23.0, alXlpe3Ph: 20.0,
    ),
    CableCapacity(
      section: 4.0,
      cuPvc1Ph: 32.0, cuPvc3Ph: 28.0, alPvc1Ph: 25.0, alPvc3Ph: 22.0,
      cuXlpe1Ph: 40.0, cuXlpe3Ph: 35.0, alXlpe1Ph: 31.0, alXlpe3Ph: 27.0,
    ),
    CableCapacity(
      section: 6.0,
      cuPvc1Ph: 41.0, cuPvc3Ph: 36.0, alPvc1Ph: 32.0, alPvc3Ph: 28.0,
      cuXlpe1Ph: 51.0, cuXlpe3Ph: 44.0, alXlpe1Ph: 39.0, alXlpe3Ph: 34.0,
    ),
    CableCapacity(
      section: 10.0,
      cuPvc1Ph: 57.0, cuPvc3Ph: 50.0, alPvc1Ph: 44.0, alPvc3Ph: 39.0,
      cuXlpe1Ph: 70.0, cuXlpe3Ph: 60.0, alXlpe1Ph: 54.0, alXlpe3Ph: 47.0,
    ),
    CableCapacity(
      section: 16.0,
      cuPvc1Ph: 76.0, cuPvc3Ph: 68.0, alPvc1Ph: 60.0, alPvc3Ph: 53.0,
      cuXlpe1Ph: 94.0, cuXlpe3Ph: 80.0, alXlpe1Ph: 73.0, alXlpe3Ph: 62.0,
    ),
    CableCapacity(
      section: 25.0,
      cuPvc1Ph: 101.0, cuPvc3Ph: 89.0, alPvc1Ph: 79.0, alPvc3Ph: 70.0,
      cuXlpe1Ph: 119.0, cuXlpe3Ph: 105.0, alXlpe1Ph: 92.0, alXlpe3Ph: 82.0,
    ),
    CableCapacity(
      section: 35.0,
      cuPvc1Ph: 125.0, cuPvc3Ph: 110.0, alPvc1Ph: 97.0, alPvc3Ph: 86.0,
      cuXlpe1Ph: 148.0, cuXlpe3Ph: 128.0, alXlpe1Ph: 115.0, alXlpe3Ph: 100.0,
    ),
    CableCapacity(
      section: 50.0,
      cuPvc1Ph: 151.0, cuPvc3Ph: 134.0, alPvc1Ph: 118.0, alPvc3Ph: 104.0,
      cuXlpe1Ph: 180.0, cuXlpe3Ph: 154.0, alXlpe1Ph: 140.0, alXlpe3Ph: 119.0,
    ),
    CableCapacity(
      section: 70.0,
      cuPvc1Ph: 192.0, cuPvc3Ph: 171.0, alPvc1Ph: 150.0, alPvc3Ph: 133.0,
      cuXlpe1Ph: 232.0, cuXlpe3Ph: 194.0, alXlpe1Ph: 179.0, alXlpe3Ph: 152.0,
    ),
    CableCapacity(
      section: 95.0,
      cuPvc1Ph: 232.0, cuPvc3Ph: 207.0, alPvc1Ph: 181.0, alPvc3Ph: 161.0,
      cuXlpe1Ph: 282.0, cuXlpe3Ph: 233.0, alXlpe1Ph: 217.0, alXlpe3Ph: 182.0,
    ),
    CableCapacity(
      section: 120.0,
      cuPvc1Ph: 269.0, cuPvc3Ph: 239.0, alPvc1Ph: 210.0, alPvc3Ph: 186.0,
      cuXlpe1Ph: 328.0, cuXlpe3Ph: 268.0, alXlpe1Ph: 252.0, alXlpe3Ph: 210.0,
    ),
    CableCapacity(
      section: 150.0,
      cuPvc1Ph: 300.0, cuPvc3Ph: 262.0, alPvc1Ph: 234.0, alPvc3Ph: 204.0,
      cuXlpe1Ph: 379.0, cuXlpe3Ph: 300.0, alXlpe1Ph: 290.0, alXlpe3Ph: 240.0,
    ),
    CableCapacity(
      section: 185.0,
      cuPvc1Ph: 341.0, cuPvc3Ph: 296.0, alPvc1Ph: 266.0, alPvc3Ph: 231.0,
      cuXlpe1Ph: 434.0, cuXlpe3Ph: 340.0, alXlpe1Ph: 332.0, alXlpe3Ph: 273.0,
    ),
    CableCapacity(
      section: 240.0,
      cuPvc1Ph: 400.0, cuPvc3Ph: 346.0, alPvc1Ph: 312.0, alPvc3Ph: 270.0,
      cuXlpe1Ph: 514.0, cuXlpe3Ph: 398.0, alXlpe1Ph: 397.0, alXlpe3Ph: 321.0,
    ),
  ];
}
