import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cable_calculation_result.dart';
import '../providers/cable_sizing_provider.dart';
import '../providers/lighting_provider.dart';
import '../utils/app_theme.dart';
import '../utils/pdf_generator.dart';

class CableResultCard extends StatelessWidget {
  final CableCalculationResult result;

  const CableResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.watch<LightingProvider>().isArabic;

    if (result.isOverCapacity) {
      return Container(
        margin: const EdgeInsets.only(top: 20, bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 36),
            const SizedBox(height: 10),
            Text(
              isArabic
                  ? 'الحمل يتجاوز سعة أكبر كابل مفرد في الجدول (240 mm²)'
                  : 'Load exceeds single cable maximum in table (240 mm²)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'تيار التصميم المطلوب: ${result.designCurrentIb.toStringAsFixed(1)} A | تيار Iz المطلوب: ${result.requiredIz.toStringAsFixed(1)} A.\nيُنصح بتمديد كابلين أو أكثر على التوازي (Parallel Cables) لتوزيع الحمل.'
                  : 'Required Design Current Ib: ${result.designCurrentIb.toStringAsFixed(1)} A | Required Iz: ${result.requiredIz.toStringAsFixed(1)} A.\nMultiple parallel cables are recommended to distribute the load.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final cable = result.selectedCable!;
    final sectionStr = cable.section == cable.section.roundToDouble()
        ? '${cable.section.toInt()}'
        : '${cable.section}';

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: AppTheme.accentBlue.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الترويسة الرئيسية مع مقطع الكابل المختار
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cable_rounded,
                    color: AppTheme.accentBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'مقطع الكابل الموصى به هندسياً:' : 'Recommended Standard Section:',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$sectionStr mm²',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${result.material} / ${result.insulation} • ${result.phase})',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.installationMethod} • ${result.temperature.toInt()}°C • ${result.coreType}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 20, thickness: 1),

            // شريط تفصيل معاملات التصحيح K
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'K_temp: ${result.temperatureFactorKtemp.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const Text('×', style: TextStyle(color: Colors.grey)),
                  Text(
                    'K_group: ${result.groupingFactorKgroup.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const Text('=', style: TextStyle(color: Colors.grey)),
                  Text(
                    'Total K: ${result.correctionFactorK.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),
            ),

            // شبكة القياسات الهندسية الأربعة الأساسية
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatTile(
                  context,
                  title: isArabic ? 'تيار التصميم (Ib)' : 'Design Current (Ib)',
                  value: result.designCurrentIb.toStringAsFixed(2),
                  unit: 'A',
                  icon: Icons.electric_meter_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                _buildStatTile(
                  context,
                  title: isArabic ? 'أقل مقطع لهبوط الجهد (Min S)' : 'Min Section for ΔV (Min S)',
                  value: result.minSectionForVoltageDropMinS.toStringAsFixed(2),
                  unit: 'mm²',
                  icon: Icons.trending_down_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
                _buildStatTile(
                  context,
                  title: isArabic ? 'المقطع الموصى به' : 'Recommended Cross-Section',
                  value: sectionStr,
                  unit: 'mm²',
                  subtitle: isArabic ? 'المقطع المختار من الجدول' : 'Selected standard size',
                  icon: Icons.cable_rounded,
                  color: AppTheme.accentBlue,
                  highlight: true,
                ),
                _buildStatTile(
                  context,
                  title: isArabic ? 'السعة النهائية (Iz)' : 'Cable Ampacity (Iz)',
                  value: result.finalCableCapacityIz?.toStringAsFixed(2) ?? '-',
                  unit: 'A',
                  subtitle: 'Raw: ${result.cableCapacity?.toStringAsFixed(1)}A × K: ${result.correctionFactorK}',
                  icon: Icons.speed_rounded,
                  color: const Color(0xFF10B981),
                  highlight: true,
                ),
                _buildStatTile(
                  context,
                  title: isArabic ? 'هبوط الجهد الفعلي (ΔV)' : 'Actual Voltage Drop (ΔV)',
                  value: '${result.actualDeltaVPct?.toStringAsFixed(2)} %',
                  unit: '(${result.actualDeltaVVolts?.toStringAsFixed(2)} V)',
                  subtitle: '${isArabic ? "الحد الأقصى:" : "Max limit:"} ${result.maxDeltaVPct}% (${result.maxDeltaVLimitVolts.toStringAsFixed(2)} V)',
                  icon: Icons.electric_bolt_rounded,
                  color: (result.actualDeltaVPct ?? 0) <= result.maxDeltaVPct
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                _buildStatTile(
                  context,
                  title: isArabic ? 'القاطع المناسب' : 'Recommended Breaker',
                  value: '${result.suggestedBreakerAmps}',
                  unit: 'A',
                  subtitle: isArabic ? 'قاطع قياسي مناسب (MCB)' : 'Standard MCB / MCCB',
                  icon: Icons.toggle_on_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ملخص التحقق الهندسي
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  _buildCheckRow(
                    label: isArabic ? 'التحمل الحراري للتيار:' : 'Thermal Capacity:',
                    detail: 'Iz (${result.finalCableCapacityIz?.toStringAsFixed(1) ?? "-"} A) ≥ Ib (${result.designCurrentIb.toStringAsFixed(1)} A)',
                    isValid: (result.finalCableCapacityIz ?? 0) >= result.designCurrentIb,
                  ),
                  const SizedBox(height: 6),
                  _buildCheckRow(
                    label: isArabic ? 'هبوط الجهد المسموح به:' : 'Voltage Drop Compliance:',
                    detail: 'S ($sectionStr mm²) ≥ Min S (${result.minSectionForVoltageDropMinS.toStringAsFixed(2)} mm²)',
                    isValid: cable.section >= result.minSectionForVoltageDropMinS,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // زر تحميل تقرير الكابل PDF
            OutlinedButton.icon(
              onPressed: () {
                PdfGenerator.previewAndSaveCablePdf(
                  context: context,
                  result: result,
                  provider: context.read<CableSizingProvider>(),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.accentBlue),
              label: Text(
                isArabic ? 'تحميل تقرير الحساب الهندسي للكابل (PDF بالإنجليزية)' : 'Download English Cable Sizing Report (PDF)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppTheme.accentBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow({
    required String label,
    required String detail,
    required bool isValid,
  }) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: isValid ? AppTheme.accentGreen : Colors.redAccent,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: detail),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    String? subtitle,
    required IconData icon,
    required Color color,
    bool highlight = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth > 600 ? (screenWidth - 100) / 4 : (screenWidth - 76) / 2;

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? color.withValues(alpha: 0.5) : (isDark ? const Color(0xFF334155) : Colors.grey.shade200),
          width: highlight ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: highlight ? color : (isDark ? Colors.white : Colors.grey.shade900),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  unit,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
