import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../providers/lighting_provider.dart';
import '../utils/app_theme.dart';

import '../providers/cable_sizing_provider.dart';

class CalculationResultCard extends StatelessWidget {
  final RoomCalculation calculation;
  final VoidCallback? onAddedToProject;
  final VoidCallback? onSwitchToCableSizing;

  const CalculationResultCard({
    super.key,
    required this.calculation,
    this.onAddedToProject,
    this.onSwitchToCableSizing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isArabic = context.watch<LightingProvider>().isArabic;

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFFFFBEB),
                  Colors.white,
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: AppTheme.primaryAmber.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAmber.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ترويسة البطاقة مع اسم الغرفة وأيقونة مشعة
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAmber.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: AppTheme.primaryDarkAmber,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isArabic ? "نتائج الحساب" : "Results"}: ${calculation.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${isArabic ? "الأبعاد" : "Dimensions"}: ${calculation.length}${isArabic ? "م" : "m"} × ${calculation.width}${isArabic ? "م" : "m"} | ${isArabic ? "شدة الإضاءة" : "Illuminance"}: ${calculation.requiredLux.toInt()} Lux',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 28, thickness: 1),

            // شبكة المقاييس والنتائج الرئيسية
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMetricTile(
                  context,
                  title: isArabic ? 'المساحة الكلية' : 'Total Area',
                  value: calculation.area.toStringAsFixed(1),
                  unit: isArabic ? 'متر²' : 'm²',
                  icon: Icons.square_foot_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                _buildMetricTile(
                  context,
                  title: isArabic ? 'إجمالي اللومين المطلوب' : 'Total Required Lumens',
                  value: calculation.totalRequiredLumens.toStringAsFixed(0),
                  unit: isArabic ? 'لومين (lm)' : 'lm',
                  icon: Icons.wb_sunny_rounded,
                  color: const Color(0xFFF59E0B),
                  highlight: true,
                ),
                _buildMetricTile(
                  context,
                  title: isArabic ? 'عدد اللمبات المقترح' : 'Recommended Bulbs',
                  value: '${calculation.practicalBulbs}',
                  unit: isArabic ? 'لمبات (عملي)' : 'Bulbs (practical)',
                  subtitle: '${isArabic ? "العدد النظري:" : "Theoretical:"} ${calculation.nominalBulbs.toStringAsFixed(2)}',
                  icon: Icons.tips_and_updates_rounded,
                  color: const Color(0xFF10B981),
                  badge: isArabic ? 'موصى به' : 'Recommended',
                ),
                _buildMetricTile(
                  context,
                  title: isArabic ? 'إجمالي الاستهلاك' : 'Total Power Load',
                  value: calculation.totalWattage.toStringAsFixed(0),
                  unit: isArabic ? 'واط (Watt)' : 'W',
                  subtitle: '${isArabic ? "بمعدل" : "At"} ${calculation.bulbWattage.toInt()}W / ${isArabic ? "لمبة" : "bulb"}',
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFFEC4899),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ملاحظة توضيحية للمعادلة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryAmber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppTheme.primaryDarkAmber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'تم اعتماد معامل الفواقد والاستخدام (×2) لضمان إضاءة فعلية كافية بعد امتصاص الجدران والأثاث.'
                          : 'Utilization & maintenance factor (×2.0) applied to ensure adequate illuminance after surface absorption.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade300 : Colors.brown.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // قسم اقتراح السلك والقاطع الكهربائي المناسب لخط الإنارة
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cable_rounded, color: AppTheme.accentBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'التوصيل الكهربائي المقترح لخط الإنارة:' : 'Recommended Feeder & Protection:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isArabic ? "مقطع السلك:" : "Wire Section:"} ${calculation.totalWattage > 1500 ? "2.5" : "1.5"} mm² (${isArabic ? "نحاس" : "Cu"}) | ${isArabic ? "قاطع:" : "MCB:"} ${calculation.totalWattage > 1500 ? "16A" : "10A"} MCB | Ib: ${(calculation.totalWattage / (230 * 0.9)).toStringAsFixed(2)} A',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onSwitchToCableSizing != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: AppTheme.accentBlue.withValues(alpha: 0.5)),
                      ),
                      onPressed: () {
                        context.read<CableSizingProvider>().prefillFromLighting(calculation.totalWattage);
                        onSwitchToCableSizing?.call();
                      },
                      child: Text(isArabic ? 'تفاصيل السلك ⚡' : 'Size Cable ⚡', style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final provider = context.read<LightingProvider>();
                      final success = provider.addCurrentToProject();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isArabic
                                  ? 'تمت إضافة "${calculation.name}" إلى قائمة مشروع المنزل بنجاح'
                                  : 'Added "${calculation.name}" to Home Project successfully',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.accentGreen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        onAddedToProject?.call();
                      }
                    },
                    icon: const Icon(Icons.bookmark_add_rounded),
                    label: Text(isArabic ? 'إضافة لمشروع المنزل' : 'Add to Home Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDarkAmber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () {
                    context.read<LightingProvider>().clearCurrentCalculation();
                  },
                  tooltip: isArabic ? 'إخفاء النتيجة' : 'Dismiss',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    String? subtitle,
    required IconData icon,
    required Color color,
    bool highlight = false,
    String? badge,
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
          color: highlight
              ? color.withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF334155) : Colors.grey.shade200),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: highlight ? color : (isDark ? Colors.white : Colors.grey.shade900),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  unit,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
