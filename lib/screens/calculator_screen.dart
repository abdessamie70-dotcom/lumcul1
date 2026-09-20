import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lighting_provider.dart';
import '../models/lighting_standard.dart';
import '../widgets/result_card.dart';
import '../utils/app_strings.dart';
import '../utils/app_theme.dart';
import 'cable_sizing_screen.dart';
import 'short_circuit_screen.dart';

class CalculatorScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProject;

  const CalculatorScreen({super.key, this.onNavigateToProject});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  int _activeInterfaceIndex = 0; // 0 = الإضاءة, 1 = مقطع الكابل, 2 = تيار القصر والفصل

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _luxController = TextEditingController();
  final TextEditingController _lumenController = TextEditingController();
  final TextEditingController _wattageController = TextEditingController();

  static const List<Map<String, String>> _roomPresets = [
    {'key': 'room_bedroom', 'lux': '150'},
    {'key': 'room_living', 'lux': '200'},
    {'key': 'room_kitchen', 'lux': '350'},
    {'key': 'room_office', 'lux': '450'},
    {'key': 'room_bath', 'lux': '250'},
    {'key': 'room_corridor', 'lux': '120'},
    {'key': 'room_dining', 'lux': '200'},
    {'key': 'room_other', 'lux': ''},
  ];

  String? _selectedRoomKey;
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
    _selectedRoomKey = null;
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
    final isAr = context.read<LightingProvider>().isArabic;
    setState(() {
      _selectedRoomKey = 'room_other';
      _isCustomRoomName = true;
      _nameController.text = standard.getRoomName(isAr);
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
      final isAr = context.read<LightingProvider>().isArabic;

      final roomName = _isCustomRoomName || _selectedRoomKey == null || _selectedRoomKey == 'room_other'
          ? (_nameController.text.trim().isEmpty ? (isAr ? 'غرفة بدون اسم' : 'Unnamed Room') : _nameController.text.trim())
          : AppStrings.get(_selectedRoomKey!, isAr);

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
      _luxController.clear();
      _lumenController.clear();
      _wattageController.clear();
      _nameController.clear();
      _selectedRoomKey = null;
      _isCustomRoomName = false;
    });
    context.read<LightingProvider>().clearCurrentCalculation();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LightingProvider>();
    final calculation = provider.currentCalculation;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = provider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _activeInterfaceIndex == 0
                      ? Icons.lightbulb_outline_rounded
                      : _activeInterfaceIndex == 1
                          ? Icons.cable_rounded
                          : Icons.shield_rounded,
                  color: _activeInterfaceIndex == 0
                      ? AppTheme.primaryAmber
                      : _activeInterfaceIndex == 1
                          ? AppTheme.accentBlue
                          : AppTheme.accentEmerald,
                ),
                const SizedBox(width: 8),
                Text(AppStrings.get('app_title', isArabic)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Text(
                AppStrings.get('app_subtitle', isArabic),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.primaryAmber : AppTheme.primaryDarkAmber,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // زر تبديل اللغة (عربي / EN)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton.icon(
              onPressed: () => provider.toggleLocale(),
              icon: const Icon(Icons.language_rounded, size: 16, color: AppTheme.primaryAmber),
              label: Text(
                isArabic ? 'EN' : 'عربي',
                style: const TextStyle(
                  color: AppTheme.primaryAmber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryAmber.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppTheme.primaryAmber,
            ),
            tooltip: isArabic ? 'تبديل المظهر' : 'Toggle Theme',
            onPressed: () => provider.toggleTheme(),
          ),
          if (_activeInterfaceIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: isArabic ? 'إعادة ضبط الحقول' : 'Reset Fields',
              onPressed: _resetForm,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // شريط التبديل العلوي بين الحاسبات الثلاث: إنارة | مقطع الكابل | تيار القصر والفصل
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 0,
                        label: Text(AppStrings.get('tab_lighting', isArabic)),
                        icon: const Icon(Icons.lightbulb_rounded),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text(AppStrings.get('tab_cable', isArabic)),
                        icon: const Icon(Icons.cable_rounded),
                      ),
                      ButtonSegment(
                        value: 2,
                        label: Text(AppStrings.get('tab_short_circuit', isArabic)),
                        icon: const Icon(Icons.shield_rounded),
                      ),
                    ],
                    selected: {_activeInterfaceIndex},
                    onSelectionChanged: (set) {
                      setState(() {
                        _activeInterfaceIndex = set.first;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: _activeInterfaceIndex == 0
                  ? _buildLightingContent(context, provider, calculation)
                  : _activeInterfaceIndex == 1
                      ? const CableSizingScreen()
                      : const ShortCircuitScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightingContent(
    BuildContext context,
    LightingProvider provider,
    dynamic calculation,
  ) {
    final isArabic = provider.isArabic;
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
                // بنر ترحيبي توضيحي
                _buildIntroBanner(context, isArabic),
                const SizedBox(height: 16),

                // قسم 1: بيانات الغرفة
                _buildSectionHeader(
                  context,
                  title: AppStrings.get('sec_room_data', isArabic),
                  icon: Icons.meeting_room_outlined,
                ),
                const SizedBox(height: 12),

                // اختيار الغرفة
                _buildRoomNameSelector(context, isArabic),
                const SizedBox(height: 14),

                // أبعاد الغرفة (الطول والعرض)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lengthController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: AppStrings.get('length_label', isArabic),
                          hintText: AppStrings.get('length_hint', isArabic),
                          prefixIcon: const Icon(Icons.straighten_rounded),
                          suffixText: AppStrings.get('meter_unit', isArabic),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.get('required_field', isArabic);
                          }
                          final val = double.tryParse(value);
                          if (val == null || val <= 0) {
                            return AppStrings.get('invalid_value', isArabic);
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
                        decoration: InputDecoration(
                          labelText: AppStrings.get('width_label', isArabic),
                          hintText: AppStrings.get('width_hint', isArabic),
                          prefixIcon: const Icon(Icons.square_foot_rounded),
                          suffixText: AppStrings.get('meter_unit', isArabic),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.get('required_field', isArabic);
                          }
                          final val = double.tryParse(value);
                          if (val == null || val <= 0) {
                            return AppStrings.get('invalid_value', isArabic);
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
                  title: AppStrings.get('sec_target_lux', isArabic),
                  icon: Icons.wb_incandescent_outlined,
                ),
                const SizedBox(height: 8),

                // حقل شدة الإضاءة
                TextFormField(
                  controller: _luxController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: AppStrings.get('lux_label', isArabic),
                    hintText: AppStrings.get('lux_hint', isArabic),
                    prefixIcon: const Icon(Icons.flash_on_rounded),
                    suffixText: AppStrings.get('lux_unit', isArabic),
                    helperText: AppStrings.get('lux_helper', isArabic),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.get('enter_lux', isArabic);
                    }
                    final val = double.tryParse(value);
                    if (val == null || val <= 0) {
                      return AppStrings.get('invalid_value', isArabic);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // شرائح اختيار شدة الإضاءة السريعة
                _buildLuxPresetChips(isArabic),

                const SizedBox(height: 20),

                // قسم 3: مواصفات اللمبة المقترحة
                _buildSectionHeader(
                  context,
                  title: AppStrings.get('sec_bulb_specs', isArabic),
                  icon: Icons.settings_suggest_outlined,
                ),
                const SizedBox(height: 8),

                // شرائح اختيار لمبات سريعة
                _buildBulbPresetChips(isArabic),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lumenController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: AppStrings.get('lumen_label', isArabic),
                          hintText: AppStrings.get('lumen_hint', isArabic),
                          prefixIcon: const Icon(Icons.sunny),
                          suffixText: AppStrings.get('lumen_unit', isArabic),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.get('required_field', isArabic);
                          }
                          final val = double.tryParse(value);
                          if (val == null || val <= 0) {
                            return AppStrings.get('invalid_value', isArabic);
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
                        decoration: InputDecoration(
                          labelText: AppStrings.get('watt_label', isArabic),
                          hintText: AppStrings.get('watt_hint', isArabic),
                          prefixIcon: const Icon(Icons.electric_bolt_rounded),
                          suffixText: AppStrings.get('watt_unit', isArabic),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.get('required_field', isArabic);
                          }
                          final val = double.tryParse(value);
                          if (val == null || val <= 0) {
                            return AppStrings.get('invalid_value', isArabic);
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
                  label: Text(
                    AppStrings.get('btn_calculate_lighting', isArabic),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                    onSwitchToCableSizing: () {
                      setState(() {
                        _activeInterfaceIndex = 1;
                      });
                    },
                  ),

                // شريط مختصر إذا كان هناك غرف مضافة في المشروع
                if (provider.totalRoomsCount > 0) ...[
                  const SizedBox(height: 20),
                  _buildProjectQuickBar(context, provider, isArabic),
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
              AppStrings.get('lighting_banner', isArabic),
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

  Widget _buildRoomNameSelector(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          key: ValueKey(_selectedRoomKey),
          value: _selectedRoomKey,
          decoration: InputDecoration(
            labelText: AppStrings.get('room_name_label', isArabic),
            prefixIcon: const Icon(Icons.door_front_door_outlined),
            hintText: isArabic ? 'اختر نوع الغرفة (اختياري)' : 'Select Room Type (Optional)',
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(isArabic ? '— تخصيص اسم يدوي —' : '— Custom Name —'),
            ),
            ..._roomPresets.map((room) {
              final key = room['key']!;
              return DropdownMenuItem<String?>(
                value: key,
                child: Text(AppStrings.get(key, isArabic)),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRoomKey = value;
              if (value == null || value == 'room_other') {
                _isCustomRoomName = true;
                _nameController.clear();
              } else {
                _isCustomRoomName = false;
                _nameController.text = AppStrings.get(value, isArabic);
                final found = _roomPresets.firstWhere((r) => r['key'] == value, orElse: () => {'lux': ''});
                if (found['lux'] != null && found['lux']!.isNotEmpty) {
                  _luxController.text = found['lux']!;
                }
              }
            });
          },
        ),
        if (_isCustomRoomName || _selectedRoomKey == null) ...[
          const SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppStrings.get('custom_room_label', isArabic),
              hintText: AppStrings.get('custom_room_hint', isArabic),
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
            validator: (value) {
              if ((value == null || value.trim().isEmpty) && _selectedRoomKey == null) {
                return AppStrings.get('enter_room_name', isArabic);
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLuxPresetChips(bool isArabic) {
    final presets = [
      {'label': isArabic ? '100 لوكس (ممرات)' : '100 Lux (Corridors)', 'val': '100'},
      {'label': isArabic ? '150 لوكس (نوم)' : '150 Lux (Bedroom)', 'val': '150'},
      {'label': isArabic ? '200 لوكس (معيشة/طعام)' : '200 Lux (Living)', 'val': '200'},
      {'label': isArabic ? '350 لوكس (مطبخ)' : '350 Lux (Kitchen)', 'val': '350'},
      {'label': isArabic ? '450 لوكس (مكتب)' : '450 Lux (Office)', 'val': '450'},
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

  Widget _buildBulbPresetChips(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('bulb_presets_label', isArabic),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildProjectQuickBar(BuildContext context, LightingProvider provider, bool isArabic) {
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
                  '${AppStrings.get('quick_project_bar_title', isArabic)} (${provider.totalRoomsCount} ${AppStrings.get('rooms_word', isArabic)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '${AppStrings.get('total_power', isArabic)} ${provider.totalProjectWattage.toStringAsFixed(0)} ${AppStrings.get('watt_word', isArabic)} | ${AppStrings.get('bulbs_word', isArabic)} ${provider.totalProjectBulbs}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: widget.onNavigateToProject,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(AppStrings.get('quick_project_bar_view', isArabic)),
          ),
        ],
      ),
    );
  }
}
