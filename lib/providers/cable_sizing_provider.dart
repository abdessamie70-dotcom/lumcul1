import 'package:flutter/material.dart';
import '../models/cable_capacity.dart';
import '../models/cable_calculation_result.dart';

class CableSizingProvider extends ChangeNotifier {
  String _phase = '3-Phase';
  double _voltage = 400.0;
  double _loadValue = 45.0;
  String _loadType = 'kW';
  double _powerFactor = 0.85;
  double _length = 85.0;
  String _material = 'Copper';
  double _maxDeltaVPct = 3.0;

  // المعايير الإضافية المتقدمة
  String _insulation = 'XLPE'; // "XLPE" أو "PVC"
  String _installationMethod = 'In Conduit / Trunking'; // طريقة التمديد
  double _temperature = 30.0; // درجة حرارة الوسط أو التربة
  int _groupingCircuits = 1; // عدد الدوائر المتجاورة
  String _coreType = 'Multi-Core'; // نوع الكابل

  double _correctionFactorK = 0.87;
  bool _isManualK = false;

  CableCalculationResult? _result;

  // Getters
  String get phase => _phase;
  double get voltage => _voltage;
  double get loadValue => _loadValue;
  String get loadType => _loadType;
  double get powerFactor => _powerFactor;
  double get length => _length;
  String get material => _material;
  double get maxDeltaVPct => _maxDeltaVPct;
  String get insulation => _insulation;
  String get installationMethod => _installationMethod;
  double get temperature => _temperature;
  int get groupingCircuits => _groupingCircuits;
  String get coreType => _coreType;
  double get correctionFactorK => _correctionFactorK;
  bool get isManualK => _isManualK;
  CableCalculationResult? get result => _result;

  // معاملات التصحيح المحسوبة حالياً
  double get kTemp => CableCapacity.calculateTemperatureFactor(
        temperature: _temperature,
        insulation: _insulation,
        installationMethod: _installationMethod,
      );

  double get kGroup => CableCapacity.calculateGroupingFactor(
        circuitsCount: _groupingCircuits,
        coreType: _coreType,
        installationMethod: _installationMethod,
      );

  double get computedAutoK => double.parse((kTemp * kGroup).toStringAsFixed(3));

  CableSizingProvider() {
    _correctionFactorK = computedAutoK;
  }

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  void calculate({
    required String phase,
    required double voltage,
    required double loadValue,
    required String loadType,
    required double powerFactor,
    required double length,
    required String material,
    required double maxDeltaVPct,
    double? correctionFactorK,
    String? insulation,
    String? installationMethod,
    double? temperature,
    int? groupingCircuitsCount,
    String? coreType,
    bool isManualK = false,
  }) {
    _phase = phase;
    _voltage = voltage;
    _loadValue = loadValue;
    _loadType = loadType;
    _powerFactor = powerFactor;
    _length = length;
    _material = material;
    _maxDeltaVPct = maxDeltaVPct;

    if (insulation != null) _insulation = insulation;
    if (installationMethod != null) _installationMethod = installationMethod;
    if (temperature != null) _temperature = temperature;
    if (groupingCircuitsCount != null) _groupingCircuits = groupingCircuitsCount;
    if (coreType != null) _coreType = coreType;

    _isManualK = isManualK;
    if (isManualK && correctionFactorK != null) {
      _correctionFactorK = correctionFactorK;
    } else {
      _correctionFactorK = computedAutoK;
    }

    _result = CableCalculationResult.calculate(
      phase: _phase,
      voltage: _voltage,
      loadValue: _loadValue,
      loadType: _loadType,
      powerFactor: _powerFactor,
      length: _length,
      material: _material,
      maxDeltaVPct: _maxDeltaVPct,
      correctionFactorK: _correctionFactorK,
      insulation: _insulation,
      installationMethod: _installationMethod,
      temperature: _temperature,
      groupingCircuitsCount: _groupingCircuits,
      coreType: _coreType,
    );

    notifyListeners();
  }

  /// ملء بيانات حاسبة الكابلات تلقائياً من استهلاك الإنارة
  void prefillFromLighting(double totalWattage) {
    _phase = '1-Phase';
    _voltage = 230.0;
    _loadValue = totalWattage / 1000.0; // تحويل من واط إلى كيلوواط
    _loadType = 'kW';
    _powerFactor = 0.90;
    _length = 25.0; // طول تقديري لخط الإنارة 25 متر
    _material = 'Copper';
    _maxDeltaVPct = 3.0;
    _insulation = 'PVC'; // تمديدات الإنارة المنزلية الداخلية عادة PVC
    _installationMethod = 'In Conduit / Trunking';
    _temperature = 30.0;
    _groupingCircuits = 1;
    _coreType = 'Multi-Core';
    _isManualK = false;
    _correctionFactorK = computedAutoK;

    calculate(
      phase: _phase,
      voltage: _voltage,
      loadValue: _loadValue,
      loadType: _loadType,
      powerFactor: _powerFactor,
      length: _length,
      material: _material,
      maxDeltaVPct: _maxDeltaVPct,
      correctionFactorK: _correctionFactorK,
      insulation: _insulation,
      installationMethod: _installationMethod,
      temperature: _temperature,
      groupingCircuitsCount: _groupingCircuits,
      coreType: _coreType,
    );
  }

  void resetDefaults() {
    _phase = '3-Phase';
    _voltage = 400.0;
    _loadValue = 45.0;
    _loadType = 'kW';
    _powerFactor = 0.85;
    _length = 85.0;
    _material = 'Copper';
    _maxDeltaVPct = 3.0;
    _insulation = 'XLPE';
    _installationMethod = 'In Conduit / Trunking';
    _temperature = 30.0;
    _groupingCircuits = 1;
    _coreType = 'Multi-Core';
    _isManualK = false;
    _correctionFactorK = computedAutoK;

    calculate(
      phase: _phase,
      voltage: _voltage,
      loadValue: _loadValue,
      loadType: _loadType,
      powerFactor: _powerFactor,
      length: _length,
      material: _material,
      maxDeltaVPct: _maxDeltaVPct,
      correctionFactorK: _correctionFactorK,
      insulation: _insulation,
      installationMethod: _installationMethod,
      temperature: _temperature,
      groupingCircuitsCount: _groupingCircuits,
      coreType: _coreType,
    );
  }
}
