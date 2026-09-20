import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lighting_standard.dart';
import '../providers/lighting_provider.dart';
import '../utils/app_theme.dart';

class StandardInfoCard extends StatelessWidget {
  final LightingStandard standard;
  final VoidCallback onApply;

  const StandardInfoCard({
    super.key,
    required this.standard,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.watch<LightingProvider>().isArabic;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترويسة البطاقة
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: standard.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    standard.icon,
                    color: standard.accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        standard.getRoomName(isArabic),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isArabic ? 'المعيار الدولي: CIBSE / EN 12464' : 'Standard: CIBSE / EN 12464',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // شارة شدة الإضاءة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: standard.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: standard.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    standard.luxRange,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: standard.accentColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // تفاصيل حرارة اللون (Kelvin) ونوع الإضاءة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.thermostat_rounded,
                    size: 18,
                    color: AppTheme.primaryDarkAmber,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'حرارة اللون:' : 'Color Temp:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${standard.kelvin} (${standard.getColorDescription(isArabic)})',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // الوصف والتوصية الهندسية
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    standard.getNotes(isArabic),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // زر تطبيق المعيار مباشرة في الحاسبة
            Align(
              alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.calculate_outlined, size: 18),
                label: Text(isArabic ? 'تطبيق هذا المعيار في الحاسبة' : 'Apply Standard to Calculator'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: standard.accentColor,
                  side: BorderSide(color: standard.accentColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
