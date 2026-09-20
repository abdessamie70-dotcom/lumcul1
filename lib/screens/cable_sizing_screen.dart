import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cable_sizing_provider.dart';
import '../providers/lighting_provider.dart';
import '../widgets/cable_result_card.dart';
import '../utils/app_strings.dart';
import '../utils/app_theme.dart';

class CableSizingScreen extends StatefulWidget {
  const CableSizingScreen({super.key});

  @override
  State<CableSizingScreen> createState() => _CableSizingScreenState();
}

class _CableSizingScreenState extends State<CableSizingScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedPhase;
  late TextEditingController _voltageController;
  late TextEditingController _loadValueController;
  late String _selectedLoadType;
  late TextEditingController _pfController;
  late TextEditingController _lengthController;
  late String _selectedMaterial;
  late TextEditingController _maxDeltaVController;

  // الحقول المتقدمة الجديدة
  late String _selectedInsulation;
  late String _selectedInstallationMethod;
  late double _selectedTemperature;
  late int _selectedGroupingCircuits;
  late String _selectedCoreType;
  late TextEditingController _kController;
  late TextEditingController _circuitNameController;
  bool _isManualK = false;

  final List<String> _installationMethods = const [
    'In Conduit / Trunking',
    'Direct Buried in Ground',
    'In Underground Duct',
    'In Air / Cable Tray',
    'Surface Mounted',
  ];

  String _getInstallationMethodLabel(String m, bool isArabic) {
    if (isArabic) {
      switch (m) {
        case 'In Conduit / Trunking':
          return 'داخل مجرى / مواسير (In Conduit)';
        case 'Direct Buried in Ground':
          return 'مدفون مباشرة بالتربة (Direct Buried)';
        case 'In Underground Duct':
          return 'مدفون داخل أنبوب بالتربة (In Duct)';
        case 'In Air / Cable Tray':
          return 'في الهواء / حامل كابلات (In Air/Tray)';
        case 'Surface Mounted':
          return 'مثبت على جدار (Surface Mounted)';
        default:
          return m;
      }
    } else {
      return m;
    }
  }

  @override
  void initState() {
    super.initState();
    _circuitNameController = TextEditingController();
    _selectedPhase = '3-Phase';
    _voltageController = TextEditingController();
    _loadValueController = TextEditingController();
    _selectedLoadType = 'kW';
    _pfController = TextEditingController();
    _lengthController = TextEditingController();
    _selectedMaterial = 'Copper';
    _maxDeltaVController = TextEditingController();

    _selectedInsulation = 'XLPE';
    _selectedInstallationMethod = 'In Conduit / Trunking';
    _selectedTemperature = 30.0;
    _selectedGroupingCircuits = 1;
    _selectedCoreType = 'Multi-Core';
    _isManualK = false;
    _kController = TextEditingController();
  }

  @override
  void dispose() {
    _circuitNameController.dispose();
    _voltageController.dispose();
    _loadValueController.dispose();
    _pfController.dispose();
    _lengthController.dispose();
    _maxDeltaVController.dispose();
    _kController.dispose();
    super.dispose();
  }

  void _onCalculate() {
    if (_formKey.currentState?.validate() ?? false) {
      final voltage = double.tryParse(_voltageController.text) ?? (_selectedPhase == '1-Phase' ? 230.0 : 400.0);
      final load = double.tryParse(_loadValueController.text) ?? 0.0;
      final pf = double.tryParse(_pfController.text) ?? 0.85;
      final length = double.tryParse(_lengthController.text) ?? 0.0;
      final maxDeltaV = double.tryParse(_maxDeltaVController.text) ?? 3.0;
      final k = double.tryParse(_kController.text);

      context.read<CableSizingProvider>().calculate(
            phase: _selectedPhase,
            voltage: voltage,
            loadValue: load,
            loadType: _selectedLoadType,
            powerFactor: pf,
            length: length,
            material: _selectedMaterial,
            maxDeltaVPct: maxDeltaV,
            correctionFactorK: k,
            insulation: _selectedInsulation,
            installationMethod: _selectedInstallationMethod,
            temperature: _selectedTemperature,
            groupingCircuitsCount: _selectedGroupingCircuits,
            coreType: _selectedCoreType,
            isManualK: _isManualK,
          );

      if (!_isManualK) {
        final newK = context.read<CableSizingProvider>().correctionFactorK;
        _kController.text = newK.toStringAsFixed(2);
      }
    }
  }

  void _resetDefaults() {
    final provider = context.read<CableSizingProvider>();
    provider.clearResult();
    setState(() {
      _circuitNameController.clear();
      _selectedPhase = '3-Phase';
      _voltageController.clear();
      _loadValueController.clear();
      _selectedLoadType = 'kW';
      _pfController.clear();
      _lengthController.clear();
      _selectedMaterial = 'Copper';
      _maxDeltaVController.clear();
      _selectedInsulation = 'XLPE';
      _selectedInstallationMethod = 'In Conduit / Trunking';
      _selectedTemperature = 30.0;
      _selectedGroupingCircuits = 1;
      _selectedCoreType = 'Multi-Core';
      _isManualK = false;
      _kController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CableSizingProvider>();
    final isArabic = context.watch<LightingProvider>().isArabic;
    final result = provider.result;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بنر توضيحي لحاسبة الكابلات
                _buildIntroBanner(context, isArabic),
                const SizedBox(height: 16),

                // اسم الدائرة لربطها بمشروع المنزل
                Text(
                  AppStrings.get('circuit_name_for_proj', isArabic),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _circuitNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.bookmark_outline_rounded, size: 18),
                    hintText: AppStrings.get('circuit_name_hint', isArabic),
                  ),
                ),
                const SizedBox(height: 16),

                // قسم 1: النظام والجهد
                _buildSectionTitle(AppStrings.get('sec_supply_system', isArabic), Icons.bolt_rounded),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_selectedPhase),
                        initialValue: _selectedPhase,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('phase_system_label', isArabic),
                          prefixIcon: const Icon(Icons.electrical_services_rounded),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: '1-Phase',
                            child: Text(isArabic ? '1-Phase (أحادي)' : '1-Phase (Single)'),
                          ),
                          DropdownMenuItem(
                            value: '3-Phase',
                            child: Text(isArabic ? '3-Phase (ثلاثي)' : '3-Phase (Three)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPhase = val;
                              if (val == '1-Phase' && _voltageController.text == '400') {
                                _voltageController.text = '230';
                              } else if (val == '3-Phase' && _voltageController.text == '230') {
                                _voltageController.text = '400';
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _voltageController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: AppStrings.get('voltage_label', isArabic),
                          hintText: _selectedPhase == '1-Phase' ? '230' : '400',
                          prefixIcon: const Icon(Icons.flash_on_rounded),
                          suffixText: 'V',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return AppStrings.get('required_field', isArabic);
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return AppStrings.get('invalid_value', isArabic);
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // قسم 2: بيانات الحمل الكهربائي
                _buildSectionTitle(AppStrings.get('sec_load_data', isArabic), Icons.power_rounded),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _loadValueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: AppStrings.get('load_value_label', isArabic),
                          hintText: '45',
                          prefixIcon: const Icon(Icons.speed_rounded),
                          suffixText: _selectedLoadType,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return AppStrings.get('required_field', isArabic);
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return AppStrings.get('invalid_value', isArabic);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_selectedLoadType),
                        initialValue: _selectedLoadType,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('load_type_label', isArabic),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'kW', child: Text('kW')),
                          DropdownMenuItem(value: 'kVA', child: Text('kVA')),
                          DropdownMenuItem(value: 'Amps', child: Text('Amps')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedLoadType = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // معامل القدرة cos φ (يظهر إذا كان نوع الحمل kW)
                if (_selectedLoadType == 'kW') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pfController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: AppStrings.get('power_factor_label', isArabic),
                      hintText: '0.85',
                      prefixIcon: const Icon(Icons.pie_chart_outline_rounded),
                      helperText: AppStrings.get('power_factor_helper', isArabic),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return AppStrings.get('required_field', isArabic);
                      final val = double.tryParse(v);
                      if (val == null || val < 0.5 || val > 1.0) {
                        return AppStrings.get('invalid_value', isArabic);
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 18),

                // قسم 3: مواصفات الكابل والعزل
                _buildSectionTitle(AppStrings.get('sec_cable_insulation', isArabic), Icons.cable_rounded),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // مادة الموصل
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_selectedMaterial),
                        initialValue: _selectedMaterial,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('material_label', isArabic),
                          prefixIcon: const Icon(Icons.category_rounded),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Copper',
                            child: Text(isArabic ? 'نحاس (Copper - γ=56)' : 'Copper (Cu - γ=56)'),
                          ),
                          DropdownMenuItem(
                            value: 'Aluminum',
                            child: Text(isArabic ? 'ألمنيوم (Al - γ=35)' : 'Aluminum (Al - γ=35)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedMaterial = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // نوع العزل
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_selectedInsulation),
                        initialValue: _selectedInsulation,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('insulation_label', isArabic),
                          prefixIcon: const Icon(Icons.shield_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'XLPE', child: Text('XLPE (90°C)')),
                          DropdownMenuItem(value: 'PVC', child: Text('PVC (70°C)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedInsulation = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // نوع الكابل (منفرد أو متعدد الأنوية)
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedCoreType),
                  initialValue: _selectedCoreType,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('core_type_label', isArabic),
                    prefixIcon: const Icon(Icons.view_agenda_rounded),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Multi-Core',
                      child: Text(isArabic ? 'كابل متعدد الأنوية (Multi-Core)' : 'Multi-Core Cable'),
                    ),
                    DropdownMenuItem(
                      value: 'Single-Core',
                      child: Text(isArabic ? 'كابلات أحادية النواة (Single-Core)' : 'Single-Core Cables'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCoreType = val);
                    }
                  },
                ),

                const SizedBox(height: 18),

                // قسم 4: طريقة التمديد والظروف البيئية
                _buildSectionTitle(AppStrings.get('sec_installation_ambient', isArabic), Icons.route_rounded),
                const SizedBox(height: 10),

                // طريقة التمديد
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedInstallationMethod),
                  initialValue: _selectedInstallationMethod,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('method_label', isArabic),
                    prefixIcon: const Icon(Icons.alt_route_rounded),
                  ),
                  items: _installationMethods.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(_getInstallationMethodLabel(m, isArabic)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedInstallationMethod = val;
                        final isBuried = val.toLowerCase().contains('buried') || val.toLowerCase().contains('duct');
                        if (isBuried && _selectedTemperature == 30.0) {
                          _selectedTemperature = 20.0;
                        } else if (!isBuried && _selectedTemperature == 20.0) {
                          _selectedTemperature = 30.0;
                        }
                      });
                    }
                  },
                ),

                const SizedBox(height: 12),

                // درجة الحرارة والتجاور
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // درجة الحرارة
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        key: ValueKey(_selectedTemperature),
                        initialValue: _selectedTemperature,
                        decoration: InputDecoration(
                          labelText: _selectedInstallationMethod.toLowerCase().contains('buried') ||
                                  _selectedInstallationMethod.toLowerCase().contains('duct')
                              ? AppStrings.get('soil_temp_label', isArabic)
                              : AppStrings.get('ambient_temp_label', isArabic),
                          prefixIcon: const Icon(Icons.thermostat_rounded),
                        ),
                        items: [
                          const DropdownMenuItem(value: 15.0, child: Text('15 °C')),
                          DropdownMenuItem(value: 20.0, child: Text(isArabic ? '20 °C (مرجع التربة)' : '20 °C (Soil Ref)')),
                          const DropdownMenuItem(value: 25.0, child: Text('25 °C')),
                          DropdownMenuItem(value: 30.0, child: Text(isArabic ? '30 °C (مرجع الهواء)' : '30 °C (Air Ref)')),
                          const DropdownMenuItem(value: 35.0, child: Text('35 °C')),
                          const DropdownMenuItem(value: 40.0, child: Text('40 °C')),
                          const DropdownMenuItem(value: 45.0, child: Text('45 °C')),
                          const DropdownMenuItem(value: 50.0, child: Text('50 °C')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedTemperature = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // عدد الدوائر المتجاورة (التجاور)
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        key: ValueKey(_selectedGroupingCircuits),
                        initialValue: _selectedGroupingCircuits,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('grouping_label', isArabic),
                          prefixIcon: const Icon(Icons.group_work_rounded),
                        ),
                        items: [
                          DropdownMenuItem(value: 1, child: Text(isArabic ? '1 (كابل منفرد)' : '1 (Single Cable)')),
                          DropdownMenuItem(value: 2, child: Text(isArabic ? '2 دوائر' : '2 Circuits')),
                          DropdownMenuItem(value: 3, child: Text(isArabic ? '3 دوائر' : '3 Circuits')),
                          DropdownMenuItem(value: 4, child: Text(isArabic ? '4 دوائر' : '4 Circuits')),
                          DropdownMenuItem(value: 5, child: Text(isArabic ? '5 دوائر' : '5 Circuits')),
                          DropdownMenuItem(value: 6, child: Text(isArabic ? '6 دوائر أو أكثر' : '6+ Circuits')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedGroupingCircuits = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // قسم 5: طول الخط وهبوط الجهد المسموح
                _buildSectionTitle(AppStrings.get('sec_length_drop', isArabic), Icons.straighten_rounded),
                const SizedBox(height: 10),

                // طول الكابل وأقصى هبوط جهد
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lengthController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: AppStrings.get('cable_length_label', isArabic),
                          hintText: '85',
                          prefixIcon: const Icon(Icons.straighten_rounded),
                          suffixText: AppStrings.get('meter_unit', isArabic),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return AppStrings.get('required_field', isArabic);
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return AppStrings.get('invalid_value', isArabic);
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxDeltaVController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: AppStrings.get('max_deltav_label', isArabic),
                          hintText: '3',
                          prefixIcon: const Icon(Icons.arrow_downward_rounded),
                          suffixText: '%',
                          helperText: isArabic ? 'المعيار القياسي 3% أو 5%' : 'Standard limit 3% or 5%',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return AppStrings.get('required_field', isArabic);
                          final val = double.tryParse(v);
                          if (val == null || val <= 0 || val > 20) return AppStrings.get('invalid_value', isArabic);
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // بطاقة معامل التصحيح الإجمالي K وتفصيله
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'معامل التصحيح الكلي (K Factor):' : 'Total Correction Factor (K):',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                'K_temp (${provider.kTemp.toStringAsFixed(2)}) × K_group (${provider.kGroup.toStringAsFixed(2)}) = ${provider.computedAutoK.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _isManualK
                                    ? (isArabic ? 'يدوي' : 'Manual')
                                    : (isArabic ? 'آلي IEC' : 'Auto IEC'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isManualK ? Colors.amber.shade800 : AppTheme.accentGreen,
                                ),
                              ),
                              Switch(
                                value: _isManualK,
                                activeColor: AppTheme.accentBlue,
                                onChanged: (val) {
                                  setState(() {
                                    _isManualK = val;
                                    if (!val) {
                                      _kController.text = provider.computedAutoK.toStringAsFixed(2);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_isManualK) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _kController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: isArabic ? 'قيمة معامل التصحيح المخصصة (K)' : 'Custom Correction Factor (K)',
                            hintText: '0.87',
                            prefixIcon: const Icon(Icons.tune_rounded),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // أزرار الحساب وإعادة الضبط
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onCalculate,
                        icon: const Icon(Icons.calculate_rounded),
                        label: Text(
                          AppStrings.get('btn_calculate_cable', isArabic),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _resetDefaults,
                      tooltip: AppStrings.get('btn_reset_defaults', isArabic),
                      icon: const Icon(Icons.restart_alt_rounded),
                    ),
                  ],
                ),

                // بطاقة عرض نتائج حساب الكابل
                if (result != null) ...[
                  CableResultCard(result: result),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final name = _circuitNameController.text.trim().isEmpty 
                          ? (isArabic ? 'كابل التغذية' : 'Feeder Cable') 
                          : _circuitNameController.text.trim();
                      context.read<LightingProvider>().addOrUpdateCableToProject(name, result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic
                                ? 'تم ربط كابل [$name] (${result.recommendedSection.toInt()} mm²) بمشروع المنزل بنجاح!'
                                : 'Cable for [$name] (${result.recommendedSection.toInt()} mm²) added to Home Project successfully!',
                          ),
                          backgroundColor: AppTheme.accentBlue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(AppStrings.get('btn_add_to_project', isArabic)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroBanner(BuildContext context, bool isArabic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accentBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.electrical_services_rounded, color: AppTheme.accentBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.get('cable_banner', isArabic),
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.grey.shade300 : const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accentBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
