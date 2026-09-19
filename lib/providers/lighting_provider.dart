import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../models/lighting_standard.dart';

/// موفر الحالة المسؤول عن إدارة الحسابات الرياضية وقائمة مشروع المنزل
class LightingProvider extends ChangeNotifier {
  // قائمة الغرف المحفوظة في مشروع المنزل
  final List<RoomCalculation> _projectRooms = [];

  // النتيجة المحسوبة حالياً في شاشة الحاسبة
  RoomCalculation? _currentCalculation;

  // وضع المظهر (فاتح / داكن)
  ThemeMode _themeMode = ThemeMode.system;

  // القيم المقترحة مسبقاً لملء النموذج عند اختيار معيار
  LightingStandard? _activePresetStandard;

  // Getters
  List<RoomCalculation> get projectRooms => List.unmodifiable(_projectRooms);
  RoomCalculation? get currentCalculation => _currentCalculation;
  ThemeMode get themeMode => _themeMode;
  LightingStandard? get activePresetStandard => _activePresetStandard;

  // إحصائيات مشروع المنزل التراكمية
  int get totalRoomsCount => _projectRooms.length;

  double get totalProjectArea =>
      _projectRooms.fold(0.0, (sum, r) => sum + r.area);

  double get totalProjectLumens =>
      _projectRooms.fold(0.0, (sum, r) => sum + r.totalRequiredLumens);

  int get totalProjectBulbs =>
      _projectRooms.fold(0, (sum, r) => sum + r.practicalBulbs);

  double get totalProjectWattage =>
      _projectRooms.fold(0.0, (sum, r) => sum + r.totalWattage);

  /// تبديل السمة (Light / Dark)
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  /// تنفيذ الحساب الرياضي بناءً على المدخلات
  RoomCalculation calculate({
    required String roomName,
    required double length,
    required double width,
    required double requiredLux,
    required double bulbLumen,
    required double bulbWattage,
  }) {
    final calculation = RoomCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: roomName.trim().isEmpty ? 'غرفة بدون اسم' : roomName.trim(),
      length: length,
      width: width,
      requiredLux: requiredLux,
      bulbLumen: bulbLumen,
      bulbWattage: bulbWattage,
      createdAt: DateTime.now(),
    );

    _currentCalculation = calculation;
    notifyListeners();
    return calculation;
  }

  /// تعيين معيار دولي لنقله إلى شاشة الحاسبة مباشرة
  void setPresetStandard(LightingStandard standard) {
    _activePresetStandard = standard;
    notifyListeners();
  }

  /// تفريغ المعيار بعد تعبئته في الحقول
  void clearPresetStandard() {
    _activePresetStandard = null;
    notifyListeners();
  }

  /// مسح نتيجة الحساب الحالية
  void clearCurrentCalculation() {
    _currentCalculation = null;
    notifyListeners();
  }

  /// إضافة النتيجة المحسوبة إلى قائمة مشروع المنزل
  bool addCurrentToProject() {
    if (_currentCalculation != null) {
      _projectRooms.add(_currentCalculation!);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// حذف غرفة محددة من قائمة المشروع
  void removeRoom(String id) {
    _projectRooms.removeWhere((room) => room.id == id);
    notifyListeners();
  }

  /// مسح جميع غرف المشروع
  void clearAllRooms() {
    _projectRooms.clear();
    notifyListeners();
  }

  /// توليد تقرير نصي شامل للمشروع باللغة العربية لمشاركته أو نسخه
  String generateProjectReport() {
    if (_projectRooms.isEmpty) {
      return 'لا توجد غرف مضافة في المشروع حتى الآن.';
    }

    final buffer = StringBuffer();
    buffer.writeln('==============================');
    buffer.writeln('🏠 تقرير متطلبات الإضاءة للمنزل');
    buffer.writeln('==============================\n');

    buffer.writeln('📊 الملخص العام:');
    buffer.writeln('• إجمالي عدد الغرف: $totalRoomsCount غرفة');
    buffer.writeln('• إجمالي المساحة: ${totalProjectArea.toStringAsFixed(1)} م²');
    buffer.writeln('• إجمالي اللومين المطلوب: ${totalProjectLumens.toStringAsFixed(0)} لومين');
    buffer.writeln('• إجمالي اللمبات المقترحة: $totalProjectBulbs لمبة');
    buffer.writeln('• إجمالي استهلاك الطاقة: ${totalProjectWattage.toStringAsFixed(1)} واط (${(totalProjectWattage / 1000).toStringAsFixed(2)} كيلوواط)\n');

    buffer.writeln('📋 تفاصيل الغرف:');
    for (int i = 0; i < _projectRooms.length; i++) {
      final r = _projectRooms[i];
      buffer.writeln('${i + 1}. ${r.name}:');
      buffer.writeln('   - الأبعاد: ${r.length}م × ${r.width}م (المساحة: ${r.area.toStringAsFixed(1)} م²)');
      buffer.writeln('   - شدة الإضاءة: ${r.requiredLux.toInt()} Lux');
      buffer.writeln('   - اللومين المطلوب: ${r.totalRequiredLumens.toStringAsFixed(0)} lm');
      buffer.writeln('   - اللمبات المقترحة: ${r.practicalBulbs} لمبة (قدرة ${r.bulbWattage.toInt()}W / ${r.bulbLumen.toInt()} lm)');
      buffer.writeln('   - استهلاك الغرفة: ${r.totalWattage.toStringAsFixed(1)} واط');
      buffer.writeln('------------------------------');
    }

    buffer.writeln('\nتم الحساب وفق المعايير الهندسية ومعامل الفواقد (Utilization & Loss Factor = 2).');
    return buffer.toString();
  }
}
