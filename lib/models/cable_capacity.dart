/// نموذج يمثل جدول سعات الكابلات والأسلاك الكهربائية بالمليمتر المربع
class CableCapacity {
  final double section;
  final double cu1Ph;
  final double cu3Ph;
  final double al1Ph;
  final double al3Ph;

  const CableCapacity({
    required this.section,
    required this.cu1Ph,
    required this.cu3Ph,
    required this.al1Ph,
    required this.al3Ph,
  });

  /// الحصول على سعة التحمل بالأمبير بناءً على مادة الموصل ونظام الأطوار
  double getCapacity({required String material, required String phase}) {
    final isCopper = material.toLowerCase().contains('copper') || material.contains('نحاس');
    final is1Phase = phase.contains('1');

    if (isCopper) {
      return is1Phase ? cu1Ph : cu3Ph;
    } else {
      return is1Phase ? al1Ph : al3Ph;
    }
  }

  /// جدول السعات المعيارية المعتمد من ملف الإكسل والمواصفات العالمية
  static const List<CableCapacity> dataset = [
    CableCapacity(section: 1.5, cu1Ph: 17.5, cu3Ph: 15.5, al1Ph: 13.5, al3Ph: 12.0),
    CableCapacity(section: 2.5, cu1Ph: 24.0, cu3Ph: 21.0, al1Ph: 18.5, al3Ph: 16.5),
    CableCapacity(section: 4.0, cu1Ph: 32.0, cu3Ph: 28.0, al1Ph: 25.0, al3Ph: 22.0),
    CableCapacity(section: 6.0, cu1Ph: 41.0, cu3Ph: 36.0, al1Ph: 32.0, al3Ph: 28.0),
    CableCapacity(section: 10.0, cu1Ph: 57.0, cu3Ph: 50.0, al1Ph: 44.0, al3Ph: 39.0),
    CableCapacity(section: 16.0, cu1Ph: 76.0, cu3Ph: 68.0, al1Ph: 60.0, al3Ph: 53.0),
    CableCapacity(section: 25.0, cu1Ph: 101.0, cu3Ph: 89.0, al1Ph: 79.0, al3Ph: 70.0),
    CableCapacity(section: 35.0, cu1Ph: 125.0, cu3Ph: 110.0, al1Ph: 97.0, al3Ph: 86.0),
    CableCapacity(section: 50.0, cu1Ph: 151.0, cu3Ph: 134.0, al1Ph: 118.0, al3Ph: 104.0),
    CableCapacity(section: 70.0, cu1Ph: 192.0, cu3Ph: 171.0, al1Ph: 150.0, al3Ph: 133.0),
    CableCapacity(section: 95.0, cu1Ph: 232.0, cu3Ph: 207.0, al1Ph: 181.0, al3Ph: 161.0),
    CableCapacity(section: 120.0, cu1Ph: 269.0, cu3Ph: 239.0, al1Ph: 210.0, al3Ph: 186.0),
    CableCapacity(section: 150.0, cu1Ph: 300.0, cu3Ph: 262.0, al1Ph: 234.0, al3Ph: 204.0),
    CableCapacity(section: 185.0, cu1Ph: 341.0, cu3Ph: 296.0, al1Ph: 266.0, al3Ph: 231.0),
    CableCapacity(section: 240.0, cu1Ph: 400.0, cu3Ph: 346.0, al1Ph: 312.0, al3Ph: 270.0),
  ];
}
