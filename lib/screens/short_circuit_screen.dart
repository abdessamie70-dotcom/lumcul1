import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/short_circuit_model.dart';
import '../providers/short_circuit_provider.dart';
import '../providers/lighting_provider.dart';
import '../widgets/tripping_curve_painter.dart';
import '../utils/app_strings.dart';
import '../utils/app_theme.dart';

class ShortCircuitScreen extends StatefulWidget {
  const ShortCircuitScreen({super.key});

  @override
  State<ShortCircuitScreen> createState() => _ShortCircuitScreenState();
}

class _ShortCircuitScreenState extends State<ShortCircuitScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'غرفة المعيشة');
  final TextEditingController _sourceIscController = TextEditingController(text: '15');
  final TextEditingController _lenController = TextEditingController(text: '50');

  @override
  void initState() {
    super.initState();
    final scProvider = context.read<ShortCircuitProvider>();
    _nameController.text = scProvider.circuitName;
    _sourceIscController.text = scProvider.upstreamIscKa.toString();
    _lenController.text = scProvider.cableLength.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sourceIscController.dispose();
    _lenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scProvider = context.watch<ShortCircuitProvider>();
    final lightingProvider = context.watch<LightingProvider>();
    final isArabic = lightingProvider.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = scProvider.result;

    final List<double> standardSections = [
      1.5, 2.5, 4.0, 6.0, 10.0, 16.0, 25.0, 35.0, 50.0, 70.0, 95.0, 120.0, 150.0, 185.0, 240.0
    ];

    final List<double> standardBreakers = [
      6, 10, 16, 20, 25, 32, 40, 50, 63, 80, 100, 125, 160, 200, 250
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بنر تعريفي
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentEmerald.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: AppTheme.accentEmerald, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.get('sc_banner', isArabic),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF065F46),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // بطاقة المدخلات
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اسم الدائرة لربطها بالمشروع
                      Text(
                        AppStrings.get('sc_name', isArabic),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.bookmark_outline_rounded, size: 18),
                          hintText: isArabic ? 'مثلاً: غرفة المعيشة أو اللوحة الرئيسية' : 'e.g., Living Room or Main Feeder',
                        ),
                        onChanged: (val) => scProvider.setCircuitName(val),
                      ),
                      const SizedBox(height: 14),

                      // نظام الأطوار وتيار قصر المنبع
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('sc_phase', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<bool>(
                                  value: scProvider.isThreePhase,
                                  items: [
                                    DropdownMenuItem(value: true, child: Text(isArabic ? '3-Phase (400V)' : '3-Phase (400V)')),
                                    DropdownMenuItem(value: false, child: Text(isArabic ? '1-Phase (230V)' : '1-Phase (230V)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) scProvider.setPhaseSystem(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('upstream_isc', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _sourceIscController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(suffixText: 'kA'),
                                  onChanged: (val) {
                                    final d = double.tryParse(val) ?? 15.0;
                                    scProvider.setUpstreamIscKa(d);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // مقطع الكابل وطوله
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('cable_section_mm2', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<double>(
                                  value: standardSections.contains(scProvider.cableSection) ? scProvider.cableSection : 25.0,
                                  items: standardSections.map((s) => DropdownMenuItem(value: s, child: Text('$s mm²'))).toList(),
                                  onChanged: (val) {
                                    if (val != null) scProvider.setCableSection(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('sc_len', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _lenController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(suffixText: isArabic ? 'متر' : 'm'),
                                  onChanged: (val) {
                                    final d = double.tryParse(val) ?? 50.0;
                                    scProvider.setCableLength(d);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // مادة الموصل والعزل وزمن الفصل
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('sc_matins', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: '${scProvider.conductorMaterial}-${scProvider.insulationType}',
                                  items: [
                                    DropdownMenuItem(value: 'Copper-XLPE', child: Text(isArabic ? 'نحاس / XLPE (k=143)' : 'Copper / XLPE (k=143)')),
                                    DropdownMenuItem(value: 'Copper-PVC', child: Text(isArabic ? 'نحاس / PVC (k=115)' : 'Copper / PVC (k=115)')),
                                    DropdownMenuItem(value: 'Aluminum-XLPE', child: Text(isArabic ? 'ألمنيوم / XLPE (k=94)' : 'Aluminum / XLPE (k=94)')),
                                    DropdownMenuItem(value: 'Aluminum-PVC', child: Text(isArabic ? 'ألمنيوم / PVC (k=76)' : 'Aluminum / PVC (k=76)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      final parts = val.split('-');
                                      scProvider.setConductorMaterial(parts[0]);
                                      scProvider.setInsulationType(parts[1]);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('clearing_time_s', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<double>(
                                  value: scProvider.clearingTime,
                                  items: [
                                    DropdownMenuItem(value: 0.04, child: Text(isArabic ? '0.04s (لحظي سريع)' : '0.04s (Fast Trip)')),
                                    DropdownMenuItem(value: 0.10, child: Text(isArabic ? '0.10s (معياري MCB)' : '0.10s (Standard MCB)')),
                                    DropdownMenuItem(value: 0.20, child: Text(isArabic ? '0.20s (تأخير MCCB)' : '0.20s (MCCB Delayed)')),
                                    DropdownMenuItem(value: 0.40, child: Text(isArabic ? '0.40s (أقصى حد IEC)' : '0.40s (Max IEC Limit)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) scProvider.setClearingTime(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // مواصفات القاطع ومنحنى الفصل
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(AppStrings.get('cb_specs_title', isArabic), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkAmber)),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('rated_current_in', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<double>(
                                  value: standardBreakers.contains(scProvider.ratedCurrentIn) ? scProvider.ratedCurrentIn : 63.0,
                                  items: standardBreakers.map((b) => DropdownMenuItem(value: b, child: Text('${b.toInt()} A'))).toList(),
                                  onChanged: (val) {
                                    if (val != null) scProvider.setRatedCurrentIn(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.get('tripping_curve', isArabic), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<TrippingCurve>(
                                  value: scProvider.curve,
                                  items: TrippingCurve.values.map((c) {
                                    return DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        isArabic ? 'منحنى ${c.code} (${c.minMagneticMultiplier.toInt()}-${c.maxMagneticMultiplier.toInt()} In)' : 'Curve ${c.code} (${c.minMagneticMultiplier.toInt()}-${c.maxMagneticMultiplier.toInt()} In)',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) scProvider.setCurve(val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // شرح المنحنى المختار
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          scProvider.curve.description(isArabic),
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // بطاقة النتائج والفحص اللحظي
              if (result != null) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.get('sc_results_title', isArabic),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentEmerald),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: result.isThermallyProtected
                                    ? AppTheme.accentEmerald.withValues(alpha: 0.2)
                                    : Colors.redAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: result.isThermallyProtected
                                      ? AppTheme.accentEmerald
                                      : Colors.redAccent,
                                ),
                              ),
                              child: Text(
                                result.isThermallyProtected
                                    ? AppStrings.get('thermally_safe', isArabic)
                                    : AppStrings.get('thermally_unsafe', isArabic),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: result.isThermallyProtected ? AppTheme.accentEmerald : Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // شبكة النتائج
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppStrings.get('max_fault_current', isArabic), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text('${result.iscMaxKa.toStringAsFixed(1)} kA', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppStrings.get('min_fault_current', isArabic), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text('${result.iscMinA.round()} A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkAmber)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppStrings.get('thermal_withstand_smin', isArabic), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text('${result.thermalMinSectionReq.toStringAsFixed(2)} mm²', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentEmerald)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppStrings.get('max_permissible_length', isArabic), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text('${result.maxPermissibleLength.round()} ${isArabic ? "متر" : "m"}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // فحص الفصل اللحظي
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: result.isInstantaneousTripOk
                                ? AppTheme.accentEmerald.withValues(alpha: 0.15)
                                : Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: result.isInstantaneousTripOk
                                  ? AppTheme.accentEmerald.withValues(alpha: 0.4)
                                  : Colors.amber.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppStrings.get('mag_status_title', isArabic),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: result.isInstantaneousTripOk ? AppTheme.accentEmerald : Colors.amber.shade800,
                                    ),
                                  ),
                                  Text(
                                    result.isInstantaneousTripOk
                                        ? AppStrings.get('mag_safe_trip', isArabic)
                                        : AppStrings.get('mag_warning_trip', isArabic),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: result.isInstantaneousTripOk ? AppTheme.accentEmerald : Colors.amber.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                result.isInstantaneousTripOk
                                    ? (isArabic
                                        ? 'تيار القصر الأدنى (${result.iscMinA.round()} A) يتجاوز عتبة القاطع المغناطيسية (${result.magneticMaxThreshold.round()} A). يتم عزل الخط فوراً وبأمان كامل.'
                                        : 'Minimum fault current (${result.iscMinA.round()} A) exceeds magnetic trip threshold (${result.magneticMaxThreshold.round()} A). Instantaneous disconnection guaranteed.')
                                    : (isArabic
                                        ? 'تيار القصر الأدنى (${result.iscMinA.round()} A) أقل من عتبة القاطع (${result.magneticMaxThreshold.round()} A)! قد يتأخر الفصل. يُوصى بـ: استخدام منحنى B أو زيادة مقطع الكابل.'
                                        : 'Minimum fault current is below magnetic trip threshold. Delayed thermal trip risk. Consider Curve B or larger cable section.'),
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // الرسم البياني لمنحنى الفصل
                        Text(
                          AppStrings.get('sc_curve_chart', isArabic),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                          child: CustomPaint(
                            size: const Size(double.infinity, 160),
                            painter: TrippingCurvePainter(
                              curve: scProvider.curve,
                              ratedIn: scProvider.ratedCurrentIn,
                              iscMin: result.iscMinA,
                              isArabic: isArabic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // زر إضافة لمشروع المنزل
                        ElevatedButton.icon(
                          onPressed: () {
                            lightingProvider.addOrUpdateShortCircuitToProject(_nameController.text, result);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isArabic
                                      ? 'تم ربط حماية [${_nameController.text}] (${result.ratedCurrentIn.toInt()}A Curve ${result.curve.code}) بمشروع المنزل بنجاح!'
                                      : 'Protection for [${_nameController.text}] added to Home Project successfully!',
                                ),
                                backgroundColor: AppTheme.accentEmerald,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: Text(AppStrings.get('btn_add_to_project', isArabic)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentEmerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
