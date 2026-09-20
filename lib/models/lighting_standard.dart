import 'package:flutter/material.dart';

/// نموذج يمثل المعايير الدولية للإضاءة (CIBSE / EN 12464)
class LightingStandard {
  final String id;
  final String roomNameAr;
  final String roomNameEn;
  final String luxRange;
  final double defaultLux;
  final String kelvin;
  final String colorDescriptionAr;
  final String colorDescriptionEn;
  final String notesAr;
  final String notesEn;
  final IconData icon;
  final Color accentColor;

  const LightingStandard({
    required this.id,
    required this.roomNameAr,
    required this.roomNameEn,
    required this.luxRange,
    required this.defaultLux,
    required this.kelvin,
    required this.colorDescriptionAr,
    required this.colorDescriptionEn,
    required this.notesAr,
    required this.notesEn,
    required this.icon,
    required this.accentColor,
  });

  String get roomName => roomNameAr;
  String getRoomName(bool isArabic) => isArabic ? roomNameAr : roomNameEn;
  String getColorDescription(bool isArabic) => isArabic ? colorDescriptionAr : colorDescriptionEn;
  String getNotes(bool isArabic) => isArabic ? notesAr : notesEn;

  /// قائمة المعايير المستخرجة من جدول البيانات والمواصفات العالمية
  static const List<LightingStandard> standards = [
    LightingStandard(
      id: 'bedroom',
      roomNameAr: 'غرفة النوم',
      roomNameEn: 'Bedroom',
      luxRange: '100 - 150 Lux',
      defaultLux: 150,
      kelvin: '2700K - 3000K',
      colorDescriptionAr: 'أبيض دافئ (Warm White)',
      colorDescriptionEn: 'Warm White (2700K - 3000K)',
      notesAr: 'إضاءة مريحة للعين وتساعد على الاسترخاء والهدوء.',
      notesEn: 'Comfortable, relaxing lighting to aid rest and reduce eye strain.',
      icon: Icons.bed_rounded,
      accentColor: Color(0xFFF59E0B),
    ),
    LightingStandard(
      id: 'living_room',
      roomNameAr: 'غرفة المعيشة',
      roomNameEn: 'Living Room',
      luxRange: '150 - 200 Lux',
      defaultLux: 200,
      kelvin: '3000K',
      colorDescriptionAr: 'أبيض دافئ ناعم (Warm White)',
      colorDescriptionEn: 'Soft Warm White (3000K)',
      notesAr: 'إضاءة متوازنة للحياة اليومية، مع إمكانية استخدام خافت الإضاءة (Dimmer).',
      notesEn: 'Balanced lighting for daily activities, ideal with dimmer control.',
      icon: Icons.weekend_rounded,
      accentColor: Color(0xFFEAB308),
    ),
    LightingStandard(
      id: 'kitchen',
      roomNameAr: 'المطبخ',
      roomNameEn: 'Kitchen',
      luxRange: '300 - 500 Lux',
      defaultLux: 350,
      kelvin: '4000K',
      colorDescriptionAr: 'أبيض محايد (Natural White)',
      colorDescriptionEn: 'Neutral White (4000K)',
      notesAr: 'إضاءة قوية ورؤية واضحة لأماكن التحضير والطهي لتجنب الحوادث.',
      notesEn: 'High illuminance for food preparation and cooking safety.',
      icon: Icons.kitchen_rounded,
      accentColor: Color(0xFF10B981),
    ),
    LightingStandard(
      id: 'office',
      roomNameAr: 'المكتب / الدراسة',
      roomNameEn: 'Office / Study',
      luxRange: '400 - 500 Lux',
      defaultLux: 450,
      kelvin: '4000K - 5000K',
      colorDescriptionAr: 'أبيض بارد نهاري (Cool White / Daylight)',
      colorDescriptionEn: 'Cool Daylight (4000K - 5000K)',
      notesAr: 'تحفيز التركيز وزيادة الإنتاجية وتقليل إجهاد العين أثناء القراءة.',
      notesEn: 'Promotes focus, enhances productivity, and prevents eye fatigue.',
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF3B82F6),
    ),
    LightingStandard(
      id: 'bathroom',
      roomNameAr: 'الحمامات',
      roomNameEn: 'Bathroom',
      luxRange: '150 - 300 Lux',
      defaultLux: 250,
      kelvin: '3000K - 4000K',
      colorDescriptionAr: 'أبيض دافئ إلى محايد',
      colorDescriptionEn: 'Warm to Neutral White (3000K - 4000K)',
      notesAr: 'يجب مراعاة معايير عزل الماء والرطوبة للوحدات (IP44 / IP65).',
      notesEn: 'Requires moisture-resistant fixtures with IP44 / IP65 ratings.',
      icon: Icons.bathtub_rounded,
      accentColor: Color(0xFF06B6D4),
    ),
    LightingStandard(
      id: 'corridor',
      roomNameAr: 'الممرات والمداخل',
      roomNameEn: 'Hallways & Corridors',
      luxRange: '100 - 150 Lux',
      defaultLux: 120,
      kelvin: '3000K',
      colorDescriptionAr: 'أبيض دافئ',
      colorDescriptionEn: 'Warm White (3000K)',
      notesAr: 'إضاءة ممر آمنة وتوجيهية واضحة دون أي توهج مزعج.',
      notesEn: 'Safe pathway guidance without glare or shadows.',
      icon: Icons.directions_walk_rounded,
      accentColor: Color(0xFF8B5CF6),
    ),
    LightingStandard(
      id: 'dining',
      roomNameAr: 'غرفة الطعام',
      roomNameEn: 'Dining Room',
      luxRange: '150 - 250 Lux',
      defaultLux: 200,
      kelvin: '2700K - 3000K',
      colorDescriptionAr: 'أبيض دافئ وجذاب',
      colorDescriptionEn: 'Inviting Warm White (2700K - 3000K)',
      notesAr: 'تركيز الإضاءة فوق طاولة الطعام لخلق جو مريح وجذاب للوجبات.',
      notesEn: 'Direct focus over dining table for a warm, welcoming ambiance.',
      icon: Icons.dining_rounded,
      accentColor: Color(0xFFEC4899),
    ),
  ];
}
