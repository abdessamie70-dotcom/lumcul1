import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../providers/lighting_provider.dart';
import '../providers/cable_sizing_provider.dart';
import '../utils/app_strings.dart';
import '../utils/app_theme.dart';
import '../utils/pdf_generator.dart';

class ProjectSummaryScreen extends StatelessWidget {
  final VoidCallback onAddRoom;

  const ProjectSummaryScreen({super.key, required this.onAddRoom});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LightingProvider>();
    final isArabic = provider.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = provider.unifiedProjectItems;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.home_work_outlined, color: AppTheme.primaryAmber),
            const SizedBox(width: 8),
            Text(AppStrings.get('nav_project', isArabic)),
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
          if (items.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryAmber),
              tooltip: 'Download English PDF',
              onPressed: () {
                PdfGenerator.showPdfOptionsModal(
                  context: context,
                  lightingProvider: provider,
                  cableProvider: context.read<CableSizingProvider>(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              tooltip: isArabic ? 'مسح جميع العناصر' : 'Clear All',
              onPressed: () => _confirmClearAll(context, isArabic),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? _buildEmptyState(context, isArabic)
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // بطاقة الإحصائيات الإجمالية للمشروع
                        _buildGrandTotalCard(context, provider, isArabic),
                        const SizedBox(height: 16),

                        // عنوان قائمة العناصر مع زر الإضافة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppStrings.get('project_items_title', isArabic)} (${items.length})',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: onAddRoom,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(AppStrings.get('btn_add_another', isArabic)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // بطاقات العناصر الموحدة
                        ...items.map((item) => _buildUnifiedItemCard(context, item, provider, isArabic)),

                        const SizedBox(height: 16),

                        // زر تحميل تقرير PDF
                        FilledButton.icon(
                          onPressed: () {
                            PdfGenerator.showPdfOptionsModal(
                              context: context,
                              lightingProvider: provider,
                              cableProvider: context.read<CableSizingProvider>(),
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf_rounded),
                          label: Text(
                            AppStrings.get('btn_download_pdf', isArabic),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryAmber,
                            foregroundColor: const Color(0xFF1E293B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGrandTotalCard(BuildContext context, LightingProvider provider, bool isArabic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get('project_summary_title', isArabic),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.primaryAmber : AppTheme.primaryDarkAmber,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.totalUnifiedItemsCount} ${AppStrings.get('unified_items', isArabic)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.primaryAmber : AppTheme.primaryDarkAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: AppStrings.get('total_area', isArabic),
                  value: '${provider.totalProjectArea.toStringAsFixed(1)} m²',
                  icon: Icons.square_foot_rounded,
                  color: Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: AppStrings.get('total_load', isArabic),
                  value: '${provider.totalProjectWattage.toStringAsFixed(0)} W',
                  icon: Icons.power_rounded,
                  color: Colors.pinkAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: AppStrings.get('circuits_count', isArabic),
                  value: '${provider.totalCablesCount} ${isArabic ? "كابلات" : "Cables"}',
                  icon: Icons.cable_rounded,
                  color: AppTheme.accentBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: AppStrings.get('breakers_count', isArabic),
                  value: '${provider.totalBreakersCount} ${isArabic ? "قواطع" : "Breakers"}',
                  icon: Icons.shield_rounded,
                  color: AppTheme.accentEmerald,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, {required String label, required String value, required IconData icon, required Color color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), overflow: TextOverflow.ellipsis),
                Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedItemCard(BuildContext context, UnifiedProjectItem item, LightingProvider provider, bool isArabic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترويسة العنصر مع الشارات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bookmark_rounded, size: 18, color: AppTheme.primaryAmber),
                    const SizedBox(width: 6),
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (item.hasLighting)
                      _buildBadge('💡 ${isArabic ? "إنارة" : "Light"}', AppTheme.primaryAmber),
                    if (item.hasCable) ...[
                      const SizedBox(width: 4),
                      _buildBadge('⚡ ${isArabic ? "كابل" : "Cable"}', AppTheme.accentBlue),
                    ],
                    if (item.hasShortCircuit) ...[
                      const SizedBox(width: 4),
                      _buildBadge('🛡️ ${isArabic ? "قاطع" : "CB"}', AppTheme.accentEmerald),
                    ],
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      onPressed: () => provider.removeUnifiedItem(item.id),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),

            // تفاصيل الإنارة إن وجدت
            if (item.hasLighting) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppTheme.primaryAmber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${isArabic ? "الإنارة" : "Lighting"}: ${item.lighting!.area.toStringAsFixed(1)} m² • ${item.lighting!.requiredLux.toInt()} Lux • ${item.lighting!.practicalBulbs} ${isArabic ? "لمبات" : "Bulbs"} (${item.lighting!.totalWattage.toStringAsFixed(0)} W)',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ],

            // تفاصيل مقطع الكابل إن وجد
            if (item.hasCable) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cable_rounded, size: 16, color: AppTheme.accentBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${isArabic ? "الكابل" : "Cable"}: ${item.cable!.recommendedSection.toInt()} mm² (${item.cable!.conductorMaterial}/${item.cable!.insulation}) • Ib: ${item.cable!.designCurrentIb.toStringAsFixed(1)}A • Iz: ${item.cable!.finalCapacityIz.toStringAsFixed(1)}A • ΔV: ${item.cable!.actualDeltaVPct?.toStringAsFixed(2) ?? "0.00"}%',
                      style: const TextStyle(fontSize: 11, color: AppTheme.accentBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],

            // تفاصيل القاطع وتيار القصر إن وجد
            if (item.hasShortCircuit) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_rounded, size: 16, color: AppTheme.accentEmerald),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${isArabic ? "الحماية" : "Protection"}: ${item.shortCircuit!.ratedCurrentIn.toInt()}A Curve ${item.shortCircuit!.curve.code} • Isc min: ${item.shortCircuit!.iscMinA.round()}A (${item.shortCircuit!.isInstantaneousTripOk ? (isArabic ? "فصل آمن ✔" : "Trip OK ✔") : (isArabic ? "تأخير ⚠️" : "Delayed ⚠️")})',
                      style: const TextStyle(fontSize: 11, color: AppTheme.accentEmerald, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryAmber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_work_outlined, size: 56, color: AppTheme.primaryAmber),
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'مشروع المنزل فارغ حالياً' : 'Home Project is Currently Empty',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'يمكنك حساب الإنارة أو مقطع الكابل أو تيار القصر والضغط على "إضافة لمشروع المنزل" لدمجها هنا.'
                  : 'Calculate lighting, cable sizing, or short-circuit protection and tap "Add to Home Project" to unify them here.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddRoom,
              icon: const Icon(Icons.add_rounded),
              label: Text(isArabic ? 'بدء الحساب وإضافة عناصر' : 'Start Calculations'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'مسح جميع العناصر؟' : 'Clear All Items?'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من رغبتك في حذف جميع عناصر وغرف المشروع الموحدة؟'
              : 'Are you sure you want to delete all unified project items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<LightingProvider>().clearAllRooms();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(isArabic ? 'مسح الكل' : 'Clear All'),
          ),
        ],
      ),
    );
  }
}
