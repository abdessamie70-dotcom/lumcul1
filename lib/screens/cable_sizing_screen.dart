import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cable_sizing_provider.dart';
import '../widgets/cable_result_card.dart';
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
  late TextEditingController _kController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CableSizingProvider>();
    _selectedPhase = provider.phase;
    _voltageController = TextEditingController(text: provider.voltage.toInt().toString());
    _loadValueController = TextEditingController(text: '${provider.loadValue}');
    _selectedLoadType = provider.loadType;
    _pfController = TextEditingController(text: '${provider.powerFactor}');
    _lengthController = TextEditingController(text: '${provider.length.toInt()}');
    _selectedMaterial = provider.material;
    _maxDeltaVController = TextEditingController(text: '${provider.maxDeltaVPct.toInt()}');
    _kController = TextEditingController(text: '${provider.correctionFactorK}');
  }

  @override
  void dispose() {
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
      final k = double.tryParse(_kController.text) ?? 0.87;

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
          );
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
                              // اقتراح الجهد المناسب تلقائياً
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

                // قسم 3: مسار الكابل والظروف
                _buildSectionTitle('3. خصائص ومسار الكابل', Icons.route_rounded),
                const SizedBox(height: 10),
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
                            setState(() {
                              _selectedMaterial = val;
                            });
                            _onCalculate();
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          if (val == null || val <= 0 || val > 20) return 'قيمة غير صالحة';
                          return null;
                        },
                        onChanged: (_) => _onCalculate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _kController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'معامل التصحيح (K)',
                          hintText: '0.87',
                          prefixIcon: Icon(Icons.tune_rounded),
                          helperText: 'عوامل الحرارة والتمديد (افتراضي: 0.87)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'مطلوب';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0 || val > 1.5) return 'قيمة غير صالحة';
                          return null;
                        },
                        onChanged: (_) => _onCalculate(),
                      ),
                    ),
                  ],
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
                if (result != null) CableResultCard(result: result),

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
              'حساب المقاطع المعيارية للكابلات والأسلاك الكهربائية بناءً على تيار التصميم (Ib)، وهبوط الجهد (ΔV)، وسعة التحمل المصححة (Iz).',
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
