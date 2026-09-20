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

  final Map<String, String> _installationMethodLabels = const {
    'In Conduit / Trunking': 'داخل مجرى / مواسير (In Conduit)',
    'Direct Buried in Ground': 'مدفون مباشرة بالتربة (Direct Buried)',
    'In Underground Duct': 'مدفون داخل أنبوب بالتربة (In Duct)',
    'In Air / Cable Tray': 'في الهواء / حامل كابلات (In Air/Tray)',
    'Surface Mounted': 'مثبت على جدار (Surface Mounted)',
  };

  @override
  void initState() {
    super.initState();
    final provider = context.read<CableSizingProvider>();
    _circuitNameController = TextEditingController(text: 'غرفة المعيشة');
    _selectedPhase = provider.phase;
    _voltageController = TextEditingController(text: provider.voltage.toInt().toString());
    _loadValueController = TextEditingController(text: '${provider.loadValue}');
    _selectedLoadType = provider.loadType;
    _pfController = TextEditingController(text: '${provider.powerFactor}');
    _lengthController = TextEditingController(text: '${provider.length.toInt()}');
    _selectedMaterial = provider.material;
    _maxDeltaVController = TextEditingController(text: '${provider.maxDeltaVPct.toInt()}');

    _selectedInsulation = provider.insulation;
    _selectedInstallationMethod = provider.installationMethod;
    _selectedTemperature = provider.temperature;
    _selectedGroupingCircuits = provider.groupingCircuits;
    _selectedCoreType = provider.coreType;
    _isManualK = provider.isManualK;
    _kController = TextEditingController(text: '${provider.correctionFactorK}');
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
      final voltage = double.tryParse(_voltageController.text) ?? 400.0;
      final load = double.tryParse(_loadValueController.text) ?? 45.0;
      final pf = double.tryParse(_pfController.text) ?? 0.85;
      final length = double.tryParse(_lengthController.text) ?? 85.0;
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
    provider.resetDefaults();
    setState(() {
      _selectedPhase = provider.phase;
      _voltageController.text = provider.voltage.toInt().toString();
      _loadValueController.text = '${provider.loadValue}';
      _selectedLoadType = provider.loadType;
      _pfController.text = '${provider.powerFactor}';
      _lengthController.text = '${provider.length.toInt()}';
      _selectedMaterial = provider.material;
      _maxDeltaVController.text = '${provider.maxDeltaVPct.toInt()}';
      _selectedInsulation = provider.insulation;
      _selectedInstallationMethod = provider.installationMethod;
      _selectedTemperature = provider.temperature;
      _selectedGroupingCircuits = provider.groupingCircuits;
      _selectedCoreType = provider.coreType;
      _isManualK = false;
      _kController.text = '${provider.correctionFactorK}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CableSizingProvider>();
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
                _buildIntroBanner(context),
                const SizedBox(height: 16),

                // اسم الدائرة لربطها بمشروع المنزل
                Text(
                  AppStrings.get('circuit_name_for_proj', context.watch<LightingProvider>().isArabic),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _circuitNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.bookmark_outline_rounded, size: 18),
                    hintText: context.watch<LightingProvider>().isArabic ? 'مثلاً: غرفة المعيشة أو اللوحة الرئيسية' : 'e.g., Living Room or Main Feeder',
                  ),
                ),
                const SizedBox(height: 16),

                // قسم 1: النظام والجهد
                _buildSectionTitle('1. نظام التغذية والجهد الكهربائي', Icons.bolt_rounded),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_selectedPhase),
                        initialValue: _selectedPhase,
                        decoration: const InputDecoration(
                          labelText: 'نظام الأطوار (Phase)',
                          prefixIcon: Icon(Icons.electrical_services_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1-Phase', child: Text('1-Phase (أحادي)')),
                          DropdownMenuItem(value: '3-Phase', child: Text('3-Phase (ثلاثي)')),
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
                            _onCalculate();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _voltageController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'الجهد (Voltage)',
                          hintText: '400',
                          prefixIcon: Icon(Icons.flash_on_rounded),
                          suffixText: 'V',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'مطلوب';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'غير صالح';
                          return null;
                        },
                        onChanged: (_) => _onCalculate(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // قسم 2: بيانات الحمل الكهربائي
                _buildSectionTitle('2. بيانات الحمل الكهربائي', Icons.power_rounded),
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
                          labelText: 'قيمة الحمل',
                          hintText: '45',
                          prefixIcon: const Icon(Icons.speed_rounded),
                          suffixText: _selectedLoadType,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'مطلوب';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'غير صالح';
                          return null;
                        },
                        onChanged: (_) => _onCalculate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_selectedLoadType),
                        initialValue: _selectedLoadType,
                        decoration: const InputDecoration(
                          labelText: 'نوع الحمل',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'kW', child: Text('kW (كيلوواط)')),
                          DropdownMenuItem(value: 'kVA', child: Text('kVA')),
                          DropdownMenuItem(value: 'Amps', child: Text('Amps (أمبير)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedLoadType = val;
                            });
                            _onCalculate();
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
                    decoration: const InputDecoration(
                      labelText: 'معامل القدرة (Power Factor - cos φ)',
                      hintText: '0.85',
                      prefixIcon: Icon(Icons.pie_chart_outline_rounded),
                      helperText: 'قيمة بين 0.70 إلى 1.00 (افتراضي: 0.85)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'مطلوب';
                      final val = double.tryParse(v);
                      if (val == null || val < 0.5 || val > 1.0) {
                        return 'يجب أن يكون بين 0.70 و 1.00';
                      }
                      return null;
                    },
                    onChanged: (_) => _onCalculate(),
                  ),
                ],

                const SizedBox(height: 18),

                // قسم 3: مواصفات الكابل والعزل
                _buildSectionTitle('3. مواصفات الكابل ونوع العزل (IEC Standards)', Icons.cable_rounded),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // مادة الموصل
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(_selectedMaterial),
                        initialValue: _selectedMaterial,
                        decoration: const InputDecoration(
                          labelText: 'مادة الموصل',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Copper', child: Text('نحاس (Copper - γ=56)')),
                          DropdownMenuItem(value: 'Aluminum', child: Text('ألمنيوم (Al - γ=35)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedMaterial = val);
                            _onCalculate();
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
                        decoration: const InputDecoration(
                          labelText: 'نوع العزل (Insulation)',
                          prefixIcon: Icon(Icons.shield_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'XLPE', child: Text('XLPE (90°C)')),
                          DropdownMenuItem(value: 'PVC', child: Text('PVC (70°C)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedInsulation = val);
                            _onCalculate();
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
                  decoration: const InputDecoration(
                    labelText: 'بنية الكابل (Core Type)',
                    prefixIcon: Icon(Icons.view_agenda_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Multi-Core', child: Text('كابل متعدد الأنوية (Multi-Core Cable)')),
                    DropdownMenuItem(value: 'Single-Core', child: Text('كابلات أحادية النواة (Single-Core Cables)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCoreType = val);
                      _onCalculate();
                    }
                  },
                ),

                const SizedBox(height: 18),

                // قسم 4: طريقة التمديد وظروف التشغيل
                _buildSectionTitle('4. طريقة التمديد والظروف البيئية', Icons.route_rounded),
                const SizedBox(height: 10),

                // طريقة التمديد
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedInstallationMethod),
                  initialValue: _selectedInstallationMethod,
                  decoration: const InputDecoration(
                    labelText: 'طريقة التمديد (Installation Method)',
                    prefixIcon: Icon(Icons.alt_route_rounded),
                  ),
                  items: _installationMethods.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(_installationMethodLabels[m] ?? m),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedInstallationMethod = val;
                        // ضبط حرارة مرجعية تلقائية (20 للتربة أو 30 للهواء)
                        final isBuried = val.toLowerCase().contains('buried') || val.toLowerCase().contains('duct');
                        if (isBuried && _selectedTemperature == 30.0) {
                          _selectedTemperature = 20.0;
                        } else if (!isBuried && _selectedTemperature == 20.0) {
                          _selectedTemperature = 30.0;
                        }
                      });
                      _onCalculate();
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
                              ? 'حرارة التربة (Soil Temp)'
                              : 'حرارة المحيط (Ambient Temp)',
                          prefixIcon: const Icon(Icons.thermostat_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: 15.0, child: Text('15 °C')),
                          DropdownMenuItem(value: 20.0, child: Text('20 °C (مرجع التربة)')),
                          DropdownMenuItem(value: 25.0, child: Text('25 °C')),
                          DropdownMenuItem(value: 30.0, child: Text('30 °C (مرجع الهواء)')),
                          DropdownMenuItem(value: 35.0, child: Text('35 °C')),
                          DropdownMenuItem(value: 40.0, child: Text('40 °C')),
                          DropdownMenuItem(value: 45.0, child: Text('45 °C')),
                          DropdownMenuItem(value: 50.0, child: Text('50 °C')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedTemperature = val);
                            _onCalculate();
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
                        decoration: const InputDecoration(
                          labelText: 'التجاور (Circuits)',
                          prefixIcon: Icon(Icons.group_work_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 (كابل منفرد)')),
                          DropdownMenuItem(value: 2, child: Text('2 دوائر')),
                          DropdownMenuItem(value: 3, child: Text('3 دوائر')),
                          DropdownMenuItem(value: 4, child: Text('4 دوائر')),
                          DropdownMenuItem(value: 5, child: Text('5 دوائر')),
                          DropdownMenuItem(value: 6, child: Text('6 دوائر أو أكثر')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedGroupingCircuits = val);
                            _onCalculate();
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // طول الكابل وأقصى هبوط جهد
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lengthController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'طول الكابل (Length)',
                          hintText: '85',
                          prefixIcon: Icon(Icons.straighten_rounded),
                          suffixText: 'متر',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'مطلوب';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'غير صالح';
                          return null;
                        },
                        onChanged: (_) => _onCalculate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxDeltaVController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'أقصى هبوط جهد مسموح',
                          hintText: '3',
                          prefixIcon: Icon(Icons.arrow_downward_rounded),
                          suffixText: '%',
                          helperText: 'المعيار القياسي 3% أو 5%',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'مطلوب';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0 || val > 20) return 'غير صالح';
                          return null;
                        },
                        onChanged: (_) => _onCalculate(),
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
                              const Text(
                                'معامل التصحيح الكلي (K Factor):',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                                _isManualK ? 'يدوي' : 'آلي IEC',
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
                                  _onCalculate();
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
                          decoration: const InputDecoration(
                            labelText: 'قيمة معامل التصحيح المخصصة (K)',
                            hintText: '0.87',
                            prefixIcon: Icon(Icons.tune_rounded),
                          ),
                          onChanged: (_) => _onCalculate(),
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
                        label: const Text(
                          'حساب مقطع الكابل',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      tooltip: 'استعادة القيم الافتراضية',
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
                      final isArabic = context.read<LightingProvider>().isArabic;
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
                    label: Text(AppStrings.get('btn_add_to_project', context.watch<LightingProvider>().isArabic)),
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

  Widget _buildIntroBanner(BuildContext context) {
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
              'حساب دقيق لمقاطع الكابلات وفق معايير IEC 60364-5-52 بناءً على تيار التصميم (Ib)، هبوط الجهد (ΔV)، طريقة التمديد، نوع العزل، والحرارة والتجاور.',
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
