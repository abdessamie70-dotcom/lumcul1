import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/lighting_provider.dart';
import '../providers/cable_sizing_provider.dart';
import '../widgets/room_card.dart';
import '../utils/app_theme.dart';
import '../utils/pdf_generator.dart';

class ProjectSummaryScreen extends StatelessWidget {
  final VoidCallback onAddRoom;

  const ProjectSummaryScreen({super.key, required this.onAddRoom});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LightingProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.home_work_outlined, color: AppTheme.primaryAmber),
            SizedBox(width: 8),
            Text('مشروع إضاءة المنزل'),
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
          if (provider.totalRoomsCount > 0) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryAmber),
              tooltip: 'تحميل تقرير PDF (عربي / English)',
              onPressed: () {
                PdfGenerator.showPdfOptionsModal(
                  context: context,
                  lightingProvider: provider,
                  cableProvider: context.read<CableSizingProvider>(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.copy_all_rounded),
              tooltip: 'نسخ تقرير المشروع',
              onPressed: () {
                final report = provider.generateProjectReport();
                Clipboard.setData(ClipboardData(text: report));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نسخ تقرير المشروع بالكامل إلى الحافظة'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.accentGreen,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              tooltip: 'مسح جميع الغرف',
              onPressed: () => _confirmClearAll(context),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: provider.totalRoomsCount == 0
            ? _buildEmptyState(context)
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // بطاقة الإحصائيات الإجمالية للمشروع
                        _buildGrandTotalCard(context, provider),
                        const SizedBox(height: 20),

                        // عنوان قائمة الغرف مع زر إضافة غرفة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'غرف المنزل المحسوبة (${provider.totalRoomsCount}):',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: onAddRoom,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('إضافة غرفة'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // بطاقات الغرف
                        ...provider.projectRooms.map((room) {
                          return RoomCard(room: room);
                        }),

                        // زر تحميل تقرير PDF ثنائي اللغة للمشروع
                        FilledButton.icon(
                          onPressed: () {
                            PdfGenerator.showPdfOptionsModal(
                              context: context,
                              lightingProvider: provider,
                              cableProvider: context.read<CableSizingProvider>(),
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf_rounded),
                          label: const Text(
                            'تحميل تقرير المشروع PDF (عربي / English)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryDarkAmber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // زر نسخ التقرير النصي
                        OutlinedButton.icon(
                          onPressed: () {
                            final report = provider.generateProjectReport();
                            Clipboard.setData(ClipboardData(text: report));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ تقرير المشروع بالكامل'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.accentGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('مشاركة أو نسخ التقرير الشامل'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButton: provider.totalRoomsCount > 0
          ? FloatingActionButton.extended(
              onPressed: onAddRoom,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة غرفة جديدة'),
              backgroundColor: AppTheme.primaryDarkAmber,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryAmber.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 64,
                color: AppTheme.primaryDarkAmber,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد غرف في المشروع حتى الآن',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بحساب متطلبات الإضاءة لأي غرفة من شاشة الحاسبة واضغط على "إضافة لمشروع المنزل" لجمع كل غرف بيتك وحساب إجمالي الاستهلاك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddRoom,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('ابدأ حساب غرفة جديدة الآن'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrandTotalCard(BuildContext context, LightingProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalKw = provider.totalProjectWattage / 1000.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFFEF3C7),
                  const Color(0xFFFFFBEB),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.primaryAmber.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAmber.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assessment_rounded, color: AppTheme.primaryDarkAmber),
              SizedBox(width: 8),
              Text(
                'الملخص الإجمالي للمشروع',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatBox(
                context,
                title: 'إجمالي الغرف',
                value: '${provider.totalRoomsCount}',
                unit: 'غرفة',
                icon: Icons.meeting_room_rounded,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 10),
              _buildStatBox(
                context,
                title: 'إجمالي المساحة',
                value: provider.totalProjectArea.toStringAsFixed(1),
                unit: 'م²',
                icon: Icons.square_foot_rounded,
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatBox(
                context,
                title: 'إجمالي اللمبات',
                value: '${provider.totalProjectBulbs}',
                unit: 'لمبة',
                icon: Icons.tips_and_updates_rounded,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 10),
              _buildStatBox(
                context,
                title: 'إجمالي الاستهلاك',
                value: provider.totalProjectWattage.toStringAsFixed(0),
                unit: 'واط (${totalKw.toStringAsFixed(2)} kW)',
                icon: Icons.bolt_rounded,
                color: const Color(0xFFEC4899),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : Colors.amber.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح جميع الغرف'),
        content: const Text('هل تريد بالتأكيد حذف كل الغرف المحفوظة في هذا المشروع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LightingProvider>().clearAllRooms();
            },
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }
}
