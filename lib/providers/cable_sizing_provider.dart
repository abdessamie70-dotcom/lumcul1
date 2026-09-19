import 'package:flutter/material.dart';
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
  double _correctionFactorK = 0.87;

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
  double get correctionFactorK => _correctionFactorK;
  CableCalculationResult? get result => _result;

  CableSizingProvider() {
    // حساب افتراضي أولي بالقيم الافتراضية
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
    );
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
    required double correctionFactorK,
  }) {
    _phase = phase;
    _voltage = voltage;
    _loadValue = loadValue;
    _loadType = loadType;
    _powerFactor = powerFactor;
    _length = length;
    _material = material;
    _maxDeltaVPct = maxDeltaVPct;
    _correctionFactorK = correctionFactorK;

    _result = CableCalculationResult.calculate(
      phase: phase,
      voltage: voltage,
      loadValue: loadValue,
      loadType: loadType,
      powerFactor: powerFactor,
      length: length,
      material: material,
      maxDeltaVPct: maxDeltaVPct,
      correctionFactorK: correctionFactorK,
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
    _correctionFactorK = 0.87;

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
    _correctionFactorK = 0.87;

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
    );
  }
}
