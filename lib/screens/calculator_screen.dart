import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lighting_provider.dart';
import '../models/lighting_standard.dart';
import '../widgets/result_card.dart';
import '../utils/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProject;

  const CalculatorScreen({super.key, this.onNavigateToProject});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _luxController = TextEditingController(text: '150');
  final TextEditingController _lumenController = TextEditingController(text: '806');
  final TextEditingController _wattageController = TextEditingController(text: '9');

  final List<String> _commonRooms = [
    'غرفة النوم',
    'غرفة المعيشة',
    'المطبخ',
    'المكتب / الدراسة',
    'الحمامات',
    'الممرات والمداخل',
    'غرفة الطعام',
    'أخرى (مخصص)',
  ];

  String _selectedRoomPreset = 'غرفة النوم';
  bool _isCustomRoomName = false;

  // أمثلة شائعة للمبات LED لتسهيل الإدخال السريع
  final List<Map<String, dynamic>> _bulbPresets = [
    {'name': 'LED 9W (806 lm)', 'watt': 9.0, 'lumen': 806.0},
    {'name': 'LED 12W (1050 lm)', 'watt': 12.0, 'lumen': 1050.0},
    {'name': 'LED 15W (1500 lm)', 'watt': 15.0, 'lumen': 1500.0},
    {'name': 'Spotlight 7W (600 lm)', 'watt': 7.0, 'lumen': 600.0},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = _selectedRoomPreset;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // التحقق مما إذا كان المستخدم قد اختار معياراً من شاشة دليل المعايير
    final provider = context.read<LightingProvider>();
    final preset = provider.activePresetStandard;
    if (preset != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyStandardDirectly(preset);
        provider.clearPresetStandard();
      });
    }
  }

  void _applyStandardDirectly(LightingStandard standard) {
    setState(() {
      _selectedRoomPreset = standard.roomName;
      _nameController.text = standard.roomName;
      _isCustomRoomName = !_commonRooms.contains(standard.roomName);
      _luxController.text = standard.defaultLux.toInt().toString();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _luxController.dispose();
    _lumenController.dispose();
    _wattageController.dispose();
    super.dispose();
  }

  void _onCalculate() {
    if (_formKey.currentState?.validate() ?? false) {
      final length = double.tryParse(_lengthController.text) ?? 0.0;
      final width = double.tryParse(_widthController.text) ?? 0.0;
      final lux = double.tryParse(_luxController.text) ?? 150.0;
      final lumen = double.tryParse(_lumenController.text) ?? 806.0;
      final wattage = double.tryParse(_wattageController.text) ?? 9.0;

      final roomName = _isCustomRoomName
          ? _nameController.text
          : _selectedRoomPreset;

      context.read<LightingProvider>().calculate(
            roomName: roomName,
            length: length,
            width: width,
            requiredLux: lux,
            bulbLumen: lumen,
            bulbWattage: wattage,
          );
    }
  }

  void _resetForm() {
    setState(() {
      _lengthController.clear();
      _widthController.clear();
      _selectedRoomPreset = 'غرفة النوم';
      _nameController.text = 'غرفة النوم';
      _isCustomRoomName = false;
      _luxController.text = '150';
      _lumenController.text = '806';
      _wattageController.text = '9';
    });
    context.read<LightingProvider>().clearCurrentCalculation();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LightingProvider>();
    final calculation = provider.currentCalculation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryAmber),
            SizedBox(width: 8),
            Text('حاسبة الإضاءة المنزلية'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppTheme.primaryAmber,
            ),
            tooltip: 'تبديل المظهر',
            onPressed: () => provider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'إعادة ضبط الحقول',
            onPressed: _resetForm,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // بنر ترحيبي توضيحي
                    _buildIntroBanner(context),
                    const SizedBox(height: 16),

                    // قسم 1: بيانات الغرفة
                    _buildSectionHeader(
                      context,
                      title: '1. بيانات الغرفة والأبعاد',
                      icon: Icons.meeting_room_outlined,
                    ),
                    const SizedBox(height: 12),

                    // اختيار الغرفة
                    _buildRoomNameSelector(context),
                    const SizedBox(height: 14),

                    // أبعاد الغرفة (الطول والعرض)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lengthController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'الطول (بالمتر)',
                              hintText: 'مثال: 5.0',
                              prefixIcon: Icon(Icons.straighten_rounded),
                              suffixText: 'م',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              final val = double.tryParse(value);
                              if (val == null || val <= 0) {
                                return 'قيمة غير صالحة';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _widthController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'العرض (بالمتر)',
                              hintText: 'مثال: 4.0',
                              prefixIcon: Icon(Icons.square_foot_rounded),
                              suffixText: 'م',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              final val = double.tryParse(value);
                              if (val == null || val <= 0) {
                                return 'قيمة غير صالحة';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // قسم 2: شدة الإضاءة المطلوبة
                    _buildSectionHeader(
                      context,
                      title: '2. شدة الإضاءة المطلوبة (Lux)',
                      icon: Icons.wb_incandescent_outlined,
                    ),
                    const SizedBox(height: 8),

                    // حقل شدة الإضاءة
                    TextFormField(
                      controller: _luxController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'شدة الإضاءة (Lux)',
                        hintText: 'مثال: 150',
                        prefixIcon: Icon(Icons.flash_on_rounded),
                        suffixText: 'لوكس',
                        helperText: 'يمكنك الاختيار السريع من المعايير الشائعة أدناه',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال شدة الإضاءة';
                        }
                        final val = double.tryParse(value);
                        if (val == null || val <= 0) {
                          return 'قيمة غير صحيحة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // شرائح اختيار شدة الإضاءة السريعة
                    _buildLuxPresetChips(),

                    const SizedBox(height: 20),

                    // قسم 3: مواصفات اللمبة المقترحة
                    _buildSectionHeader(
                      context,
                      title: '3. خصائص اللمبة المختارة',
                      icon: Icons.settings_suggest_outlined,
                    ),
                    const SizedBox(height: 8),

                    // شرائح اختيار لمبات سريعة
                    _buildBulbPresetChips(),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lumenController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'تدفق اللمبة (Lumen)',
                              hintText: '806',
                              prefixIcon: Icon(Icons.sunny),
                              suffixText: 'lm',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              final val = double.tryParse(value);
                              if (val == null || val <= 0) {
                                return 'قيمة غير صالحة';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _wattageController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'قدرة اللمبة (Watt)',
                              hintText: '9',
                              prefixIcon: Icon(Icons.electric_bolt_rounded),
                              suffixText: 'W',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              final val = double.tryParse(value);
                              if (val == null || val <= 0) {
                                return 'قيمة غير صالحة';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // زر الحساب الرئيسي
                    ElevatedButton.icon(
                      onPressed: _onCalculate,
                      icon: const Icon(Icons.calculate_rounded, size: 22),
                      label: const Text(
                        'احسب الإضاءة المطلوبة',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                      ),
                    ),

                    // عرض بطاقة النتائج عند إتمام الحساب
                    if (calculation != null)
                      CalculationResultCard(
                        calculation: calculation,
                        onAddedToProject: widget.onNavigateToProject,
                      ),

                    // شريط مختصر إذا كان هناك غرف مضافة في المشروع
                    if (provider.totalRoomsCount > 0) ...[
                      const SizedBox(height: 20),
                      _buildProjectQuickBar(context, provider),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
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
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryAmber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryAmber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded, color: AppTheme.primaryDarkAmber, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'أدخل أبعاد الغرفة وشدة الإضاءة لحساب عدد اللمبات المناسب عملياً وإجمالي استهلاك الطاقة بدقة.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.grey.shade300 : const Color(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryDarkAmber),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomNameSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedRoomPreset),
          initialValue: _selectedRoomPreset,
          decoration: const InputDecoration(
            labelText: 'اسم الغرفة',
            prefixIcon: Icon(Icons.door_front_door_outlined),
          ),
          items: _commonRooms.map((room) {
            return DropdownMenuItem(
              value: room,
              child: Text(room),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedRoomPreset = value;
                _isCustomRoomName = (value == 'أخرى (مخصص)');
                if (!_isCustomRoomName) {
                  _nameController.text = value;
                  // اقتراح لوكس تلقائي حسب المعيار
                  _autoSuggestLux(value);
                } else {
                  _nameController.clear();
                }
              });
            }
          },
        ),
        if (_isCustomRoomName) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'اكتب اسم الغرفة المخصص',
              hintText: 'مثال: صالة الاستقبال',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال اسم الغرفة';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  void _autoSuggestLux(String room) {
    switch (room) {
      case 'غرفة النوم':
        _luxController.text = '150';
        break;
      case 'غرفة المعيشة':
        _luxController.text = '200';
        break;
      case 'المطبخ':
        _luxController.text = '350';
        break;
      case 'المكتب / الدراسة':
        _luxController.text = '450';
        break;
      case 'الحمامات':
        _luxController.text = '250';
        break;
      case 'الممرات والمداخل':
        _luxController.text = '120';
        break;
      case 'غرفة الطعام':
        _luxController.text = '200';
        break;
    }
  }

  Widget _buildLuxPresetChips() {
    final presets = [
      {'label': '100 Lux (ممرات)', 'val': '100'},
      {'label': '150 Lux (نوم)', 'val': '150'},
      {'label': '200 Lux (معيشة/طعام)', 'val': '200'},
      {'label': '350 Lux (مطبخ)', 'val': '350'},
      {'label': '450 Lux (مكتب)', 'val': '450'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((p) {
        final isSelected = _luxController.text == p['val'];
        return ChoiceChip(
          label: Text(p['label']!),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _luxController.text = p['val']!;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildBulbPresetChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خيارات لمبات LED جاهزة:',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _bulbPresets.map((preset) {
            final double watt = preset['watt'];
            final double lumen = preset['lumen'];
            final isSelected = _wattageController.text == watt.toInt().toString() &&
                _lumenController.text == lumen.toInt().toString();

            return ActionChip(
              avatar: const Icon(Icons.bolt, size: 16),
              label: Text(preset['name']),
              backgroundColor: isSelected
                  ? AppTheme.primaryAmber.withValues(alpha: 0.25)
                  : null,
              onPressed: () {
                setState(() {
                  _wattageController.text = watt.toInt().toString();
                  _lumenController.text = lumen.toInt().toString();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProjectQuickBar(BuildContext context, LightingProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_special_rounded, color: AppTheme.accentGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مشروع المنزل الحالي (${provider.totalRoomsCount} غرف)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'إجمالي القدرة: ${provider.totalProjectWattage.toStringAsFixed(0)} واط | اللمبات: ${provider.totalProjectBulbs}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: widget.onNavigateToProject,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('عرض المشروع'),
          ),
        ],
      ),
    );
  }
}
