/// كائن يمثل بيانات الغرفة وحسابات الإضاءة المرتبطة بها
class RoomCalculation {
  final String id;
  final String name;
  final double length;
  final double width;
  final double requiredLux;
  final double bulbLumen;
  final double bulbWattage;
  final DateTime createdAt;

  const RoomCalculation({
    required this.id,
    required this.name,
    required this.length,
    required this.width,
    required this.requiredLux,
    required this.bulbLumen,
    required this.bulbWattage,
    required this.createdAt,
  });

  /// المساحة بالمتر المربع: الطول × العرض
  double get area => length * width;

  /// إجمالي اللومين المطلوب: المساحة × شدة الإضاءة (Lux) × 2
  /// المعامل 2 يعوض فواقد الامتصاص وانعكاسية الأسطح وعوامل الاستخدام
  double get totalRequiredLumens => area * requiredLux * 2.0;

  /// عدد اللمبات النظري الدقيق: إجمالي اللومين / لومين اللمبة
  double get nominalBulbs {
    if (bulbLumen <= 0) return 0.0;
    return totalRequiredLumens / bulbLumen;
  }

  /// عدد اللمبات المقترح عملياً: جبر لأقرب عدد صحيح أكبر
  int get practicalBulbs {
    if (nominalBulbs <= 0) return 0;
    return nominalBulbs.ceil();
  }

  /// إجمالي استهلاك الطاقة بالواط: عدد اللمبات المقترح × قدرة اللمبة
  double get totalWattage => practicalBulbs * bulbWattage;

  /// نسخة جديدة مع إمكانية تعديل الخصائص
  RoomCalculation copyWith({
    String? id,
    String? name,
    double? length,
    double? width,
    double? requiredLux,
    double? bulbLumen,
    double? bulbWattage,
    DateTime? createdAt,
  }) {
    return RoomCalculation(
      id: id ?? this.id,
      name: name ?? this.name,
      length: length ?? this.length,
      width: width ?? this.width,
      requiredLux: requiredLux ?? this.requiredLux,
      bulbLumen: bulbLumen ?? this.bulbLumen,
      bulbWattage: bulbWattage ?? this.bulbWattage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
