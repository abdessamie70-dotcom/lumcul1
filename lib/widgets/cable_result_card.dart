import 'package:flutter/material.dart';
import '../models/cable_calculation_result.dart';
import '../utils/app_theme.dart';

class CableResultCard extends StatelessWidget {
  final CableCalculationResult result;

  const CableResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            const Text(
              'الحمل يتجاوز سعة أكبر كابل مفرد في الجدول (240 mm²)',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'تيار التصميم المطلوب: ${result.designCurrentIb.toStringAsFixed(1)} A | تيار Iz المطلوب: ${result.requiredIz.toStringAsFixed(1)} A.\nيُنصح بتمديد كابلين أو أكثر على التوازي (Parallel Cables) لتوزيع الحمل.',
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
                      const Text(
                        'مقطع الكابل الموصى به هندسياً:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
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
                            '(${result.material} - ${result.phase})',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24, thickness: 1),

            // شبكة القياسات الهندسية
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatTile(
                  context,
                  title: 'تيار التصميم (Ib)',
                  value: result.designCurrentIb.toStringAsFixed(1),
                  unit: 'أمبير (A)',
                  icon: Icons.electric_meter_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                _buildStatTile(
                  context,
                  title: 'التيار المصحح (Iz المطلوب)',
                  value: result.requiredIz.toStringAsFixed(1),
                  unit: 'أمبير (A)',
                  subtitle: 'سعة الكابل: ${result.cableCapacity?.toStringAsFixed(1)} A',
                  icon: Icons.speed_rounded,
                  color: const Color(0xFF10B981),
                  highlight: true,
                ),
                _buildStatTile(
                  context,
                  title: 'هبوط الجهد الفعلي (ΔV)',
                  value: '${result.actualDeltaVPct?.toStringAsFixed(2)} %',
                  unit: '(${result.actualDeltaVVolts?.toStringAsFixed(1)} V)',
                  subtitle: 'الأقصى المسموح: ${result.maxDeltaVPct}% (${result.maxDeltaVLimitVolts.toStringAsFixed(1)}V)',
                  icon: Icons.trending_down_rounded,
                  color: (result.actualDeltaVPct ?? 0) <= result.maxDeltaVPct
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                _buildStatTile(
                  context,
                  title: 'القاطع المناسب (Breaker)',
                  value: '${result.suggestedBreakerAmps}',
                  unit: 'أمبير (A)',
                  subtitle: 'قاطع قياسي (MCB/MCCB)',
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
                    label: 'التحمل الحراري للتيار:',
                    detail: 'سعة الكابل (${result.cableCapacity?.toStringAsFixed(1)} A) ≥ Iz المطلوب (${result.requiredIz.toStringAsFixed(1)} A)',
                    isValid: (result.cableCapacity ?? 0) >= result.requiredIz,
                  ),
                  const SizedBox(height: 6),
                  _buildCheckRow(
                    label: 'هبوط الجهد المسموح به:',
                    detail: 'مقطع الكابل ($sectionStr mm²) ≥ أقل مقطع مطلوب (${result.minSectionForVoltageDropMinS.toStringAsFixed(2)} mm²)',
                    isValid: cable.section >= result.minSectionForVoltageDropMinS,
                  ),
                ],
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
