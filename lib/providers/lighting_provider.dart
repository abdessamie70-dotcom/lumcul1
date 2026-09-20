import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../models/lighting_standard.dart';
import '../models/cable_calculation_result.dart';
import '../models/short_circuit_model.dart';

/// موفر الحالة المسؤول عن إدارة الحسابات الرياضية وقائمة مشروع المنزل واللغات
class LightingProvider extends ChangeNotifier {
  // اللغة الحالية للتطبيق (الافتراضية: العربية)
  Locale _locale = const Locale('ar');

  // قائمة الغرف المحفوظة في مشروع المنزل (للتوافق)
  final List<RoomCalculation> _projectRooms = [];

  // خريطة عناصر المشروع الموحدة (المفتاح هو اسم الدائرة/الفراغ لدمج العناصر ذات التسمية المتطابقة)
  final Map<String, UnifiedProjectItem> _projectItems = {};

  // النتيجة المحسوبة حالياً في شاشة الحاسبة
  RoomCalculation? _currentCalculation;

  // وضع المظهر (فاتح / داكن)
  ThemeMode _themeMode = ThemeMode.system;

  // القيم المقترحة مسبقاً لملء النموذج عند اختيار معيار
  LightingStandard? _activePresetStandard;

  // Getters
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  List<RoomCalculation> get projectRooms => List.unmodifiable(_projectRooms);
  List<UnifiedProjectItem> get unifiedProjectItems => _projectItems.values.toList();
  int get totalUnifiedItemsCount => _projectItems.length;

  RoomCalculation? get currentCalculation => _currentCalculation;
  ThemeMode get themeMode => _themeMode;
  LightingStandard? get activePresetStandard => _activePresetStandard;

  // إحصائيات مشروع المنزل التراكمية
  int get totalRoomsCount => _projectItems.values.where((e) => e.hasLighting).length;

  double get totalProjectArea => _projectItems.values.fold(0.0, (sum, e) => sum + (e.lighting?.area ?? 0.0));

  double get totalProjectLumens => _projectItems.values.fold(0.0, (sum, e) => sum + (e.lighting?.totalRequiredLumens ?? 0.0));

  int get totalProjectBulbs => _projectItems.values.fold(0, (sum, e) => sum + (e.lighting?.practicalBulbs ?? 0));

  double get totalProjectWattage => _projectItems.values.fold(0.0, (sum, e) => sum + (e.lighting?.totalWattage ?? 0.0));

  int get totalCablesCount => _projectItems.values.where((e) => e.hasCable).length;
  int get totalBreakersCount => _projectItems.values.where((e) => e.hasShortCircuit).length;

  /// تبديل لغة التطبيق بين العربية والإنجليزية
  void toggleLocale() {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }

  void setLocale(Locale l) {
    _locale = l;
    notifyListeners();
  }

  /// تبديل السمة (Light / Dark)
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  /// تنفيذ الحساب الرياضي للإضاءة بناءً على المدخلات
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
      name: roomName.trim().isEmpty ? (isArabic ? 'غرفة بدون اسم' : 'Unnamed Room') : roomName.trim(),
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

  /// إضافة أو تحديث إضاءة في مشروع المنزل مع الدمج التلقائي عند تطابق التسمية
  bool addCurrentToProject() {
    if (_currentCalculation != null) {
      addOrUpdateLightingToProject(_currentCalculation!);
      return true;
    }
    return false;
  }

  void addOrUpdateLightingToProject(RoomCalculation room) {
    final key = room.name.trim();
    if (_projectItems.containsKey(key)) {
      final existing = _projectItems[key]!;
      _projectItems[key] = existing.copyWith(
        lighting: room,
        updatedAt: DateTime.now(),
      );
    } else {
      _projectItems[key] = UnifiedProjectItem(
        id: room.id,
        name: key,
        lighting: room,
        updatedAt: DateTime.now(),
      );
    }

    _projectRooms.removeWhere((r) => r.name.trim() == key);
    _projectRooms.add(room);

    notifyListeners();
  }

  /// إضافة أو تحديث كابل في مشروع المنزل مع الدمج التلقائي عند تطابق التسمية
  void addOrUpdateCableToProject(String circuitName, CableCalculationResult cable) {
    final key = circuitName.trim().isEmpty ? (isArabic ? 'كابل التغذية' : 'Feeder Cable') : circuitName.trim();
    if (_projectItems.containsKey(key)) {
      final existing = _projectItems[key]!;
      _projectItems[key] = existing.copyWith(
        cable: cable,
        updatedAt: DateTime.now(),
      );
    } else {
      _projectItems[key] = UnifiedProjectItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: key,
        cable: cable,
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  /// إضافة أو تحديث تيار القصر والقاطع في مشروع المنزل مع الدمج التلقائي عند تطابق التسمية
  void addOrUpdateShortCircuitToProject(String circuitName, ShortCircuitResult sc) {
    final key = circuitName.trim().isEmpty ? (isArabic ? 'حماية الدائرة' : 'Circuit Protection') : circuitName.trim();
    if (_projectItems.containsKey(key)) {
      final existing = _projectItems[key]!;
      _projectItems[key] = existing.copyWith(
        shortCircuit: sc,
        updatedAt: DateTime.now(),
      );
    } else {
      _projectItems[key] = UnifiedProjectItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: key,
        shortCircuit: sc,
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  /// حذف عنصر موحد محدد من قائمة المشروع
  void removeUnifiedItem(String id) {
    _projectItems.removeWhere((key, item) => item.id == id);
    _projectRooms.removeWhere((room) => room.id == id);
    notifyListeners();
  }

  /// مسح جميع عناصر المشروع
  void clearAllRooms() {
    _projectItems.clear();
    _projectRooms.clear();
    notifyListeners();
  }

  /// توليد نص تقرير مشروع الإنارة
  String generateProjectReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== تقرير متطلبات الإضاءة للمنزل (LUMCAL) ===');
    buffer.writeln('إجمالي عدد الغرف: $totalRoomsCount');
    buffer.writeln('إجمالي المساحة: $totalProjectArea م²');
    buffer.writeln('إجمالي اللومين: $totalProjectLumens لومين');
    buffer.writeln('إجمالي اللمبات: $totalProjectBulbs لمبة');
    buffer.writeln('إجمالي الاستهلاك الكهربائي: $totalProjectWattage واط');
    buffer.writeln('-------------------------------------------');
    for (final room in _projectRooms) {
      buffer.writeln('الغرفة: ${room.name} (${room.area} م²)');
      buffer.writeln('  - اللوكس المطلوب: ${room.requiredLux} Lux');
      buffer.writeln('  - اللومين الإجمالي: ${room.totalRequiredLumens} lm');
      buffer.writeln('  - اللمبات المقترحة: ${room.practicalBulbs} لمبة (${room.bulbWattage}W / ${room.bulbLumen}lm)');
      buffer.writeln('  - الاستهلاك: ${room.totalWattage} واط');
    }
    return buffer.toString();
  }
}
