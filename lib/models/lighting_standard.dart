import 'package:flutter/material.dart';

/// نموذج يمثل المعايير الدولية للإضاءة (CIBSE / EN 12464)
class LightingStandard {
  final String id;
  final String roomName;
  final String luxRange;
  final double defaultLux;
  final String kelvin;
  final String colorDescription;
  final String notes;
  final IconData icon;
  final Color accentColor;

  const LightingStandard({
    required this.id,
    required this.roomName,
    required this.luxRange,
    required this.defaultLux,
    required this.kelvin,
    required this.colorDescription,
    required this.notes,
    required this.icon,
    required this.accentColor,
  });

  /// قائمة المعايير المستخرجة من جدول البيانات والمواصفات العالمية
  static const List<LightingStandard> standards = [
    LightingStandard(
      id: 'bedroom',
      roomName: 'غرفة النوم',
      luxRange: '100 - 150 Lux',
      defaultLux: 150,
      kelvin: '2700K - 3000K',
      colorDescription: 'أبيض دافئ (Warm White)',
      notes: 'إضاءة مريحة للعين وتساعد على الاسترخاء والهدوء.',
      icon: Icons.bed_rounded,
      accentColor: Color(0xFFF59E0B),
    ),
    LightingStandard(
      id: 'living_room',
      roomName: 'غرفة المعيشة',
      luxRange: '150 - 200 Lux',
      defaultLux: 200,
      kelvin: '3000K',
      colorDescription: 'أبيض دافئ ناعم (Warm White)',
      notes: 'إضاءة متوازنة للحياة اليومية، مع إمكانية استخدام خافت الإضاءة (Dimmer).',
      icon: Icons.weekend_rounded,
      accentColor: Color(0xFFEAB308),
    ),
    LightingStandard(
      id: 'kitchen',
      roomName: 'المطبخ',
      luxRange: '300 - 500 Lux',
      defaultLux: 350,
      kelvin: '4000K',
      colorDescription: 'أبيض محايد (Natural White)',
      notes: 'إضاءة قوية ورؤية واضحة لأماكن التحضير والطهي لتجنب الحوادث.',
      icon: Icons.kitchen_rounded,
      accentColor: Color(0xFF10B981),
    ),
    LightingStandard(
      id: 'office',
      roomName: 'المكتب / الدراسة',
      luxRange: '400 - 500 Lux',
      defaultLux: 450,
      kelvin: '4000K - 5000K',
      colorDescription: 'أبيض بارد نهاري (Cool White / Daylight)',
      notes: 'تحفيز التركيز وزيادة الإنتاجية وتقليل إجهاد العين أثناء القراءة.',
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF3B82F6),
    ),
    LightingStandard(
      id: 'bathroom',
      roomName: 'الحمامات',
      luxRange: '150 - 300 Lux',
      defaultLux: 250,
      kelvin: '3000K - 4000K',
      colorDescription: 'أبيض دافئ إلى محايد',
      notes: 'يجب مراعاة معايير عزل الماء والرطوبة للوحدات (IP44 / IP65).',
      icon: Icons.bathtub_rounded,
      accentColor: Color(0xFF06B6D4),
    ),
    LightingStandard(
      id: 'corridor',
      roomName: 'الممرات والمداخل',
      luxRange: '100 - 150 Lux',
      defaultLux: 120,
      kelvin: '3000K',
      colorDescription: 'أبيض دافئ',
      notes: 'إضاءة ممر آمنة وتوجيهية واضحة دون أي توهج مزعج.',
      icon: Icons.directions_walk_rounded,
      accentColor: Color(0xFF8B5CF6),
    ),
    LightingStandard(
      id: 'dining',
      roomName: 'غرفة الطعام',
      luxRange: '150 - 250 Lux',
      defaultLux: 200,
      kelvin: '2700K - 3000K',
      colorDescription: 'أبيض دافئ وجذاب',
      notes: 'تركيز الإضاءة فوق طاولة الطعام لخلق جو مريح وجذاب للوجبات.',
      icon: Icons.dining_rounded,
      accentColor: Color(0xFFEC4899),
    ),
  ];
}
