import 'package:flutter/material.dart';
import '../models/short_circuit_model.dart';

class ShortCircuitProvider extends ChangeNotifier {
  String _circuitName = '';
  bool _isThreePhase = true;
  double _voltage = 400.0;
  double _upstreamIscKa = 15.0;
  double _cableSection = 25.0;
  double _cableLength = 50.0;
  String _conductorMaterial = 'Copper';
  String _insulationType = 'XLPE';
  double _clearingTime = 0.10;
  double _ratedCurrentIn = 63.0;
  TrippingCurve _curve = TrippingCurve.c;

  ShortCircuitResult? _result;

  ShortCircuitProvider();

  // Getters
  String get circuitName => _circuitName;
  bool get isThreePhase => _isThreePhase;
  double get voltage => _voltage;
  double get upstreamIscKa => _upstreamIscKa;
  double get cableSection => _cableSection;
  double get cableLength => _cableLength;
  String get conductorMaterial => _conductorMaterial;
  String get insulationType => _insulationType;
  double get clearingTime => _clearingTime;
  double get ratedCurrentIn => _ratedCurrentIn;
  TrippingCurve get curve => _curve;
  ShortCircuitResult? get result => _result;

  void setCircuitName(String val) {
    _circuitName = val;
    notifyListeners();
  }

  void setPhaseSystem(bool is3Ph) {
    _isThreePhase = is3Ph;
    _voltage = is3Ph ? 400.0 : 230.0;
    calculate();
  }

  void setVoltage(double v) {
    _voltage = v;
    calculate();
  }

  void setUpstreamIscKa(double val) {
    _upstreamIscKa = val;
    calculate();
  }

  void setCableSection(double val) {
    _cableSection = val;
    calculate();
  }

  void setCableLength(double val) {
    _cableLength = val;
    calculate();
  }

  void setConductorMaterial(String val) {
    _conductorMaterial = val;
    calculate();
  }

  void setInsulationType(String val) {
    _insulationType = val;
    calculate();
  }

  void setClearingTime(double val) {
    _clearingTime = val;
    calculate();
  }

  void setRatedCurrentIn(double val) {
    _ratedCurrentIn = val;
    calculate();
  }

  void setCurve(TrippingCurve val) {
    _curve = val;
    calculate();
  }

  /// مزامنة القيم تلقائياً من حاسبة الكابلات
  void syncFromCable({
    required String name,
    required bool is3Ph,
    required double volt,
    required double sec,
    required double len,
    required String mat,
    required String ins,
    required double breakerIn,
  }) {
    _circuitName = name;
    _isThreePhase = is3Ph;
    _voltage = volt;
    _cableSection = sec;
    _cableLength = len;
    _conductorMaterial = mat;
    _insulationType = ins;
    _ratedCurrentIn = breakerIn;
    calculate();
  }

  void calculate() {
    _result = ShortCircuitResult.calculate(
      circuitName: _circuitName,
      isThreePhase: _isThreePhase,
      voltage: _voltage,
      upstreamIscKa: _upstreamIscKa,
      cableSection: _cableSection,
      cableLength: _cableLength,
      conductorMaterial: _conductorMaterial,
      insulationType: _insulationType,
      clearingTime: _clearingTime,
      ratedCurrentIn: _ratedCurrentIn,
      curve: _curve,
    );
    notifyListeners();
  }
}
