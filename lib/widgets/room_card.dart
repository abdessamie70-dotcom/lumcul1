import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../providers/lighting_provider.dart';
import '../utils/app_theme.dart';

class RoomCard extends StatelessWidget {
  final RoomCalculation room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترويسة بطاقة الغرفة مع زر الحذف
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.meeting_room_rounded,
                    color: AppTheme.primaryDarkAmber,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${room.length}م × ${room.width}م (${room.area.toStringAsFixed(1)} م²)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'حذف الغرفة',
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),

            const Divider(height: 20),

            // تفاصيل الحسابات الهندسية للغرفة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  context,
                  label: 'شدة الإضاءة',
                  value: '${room.requiredLux.toInt()} Lux',
                  icon: Icons.light_mode_outlined,
                ),
                _buildMiniStat(
                  context,
                  label: 'اللومين الكلي',
                  value: '${room.totalRequiredLumens.toStringAsFixed(0)} lm',
                  icon: Icons.wb_sunny_outlined,
                ),
                _buildMiniStat(
                  context,
                  label: 'عدد اللمبات',
                  value: '${room.practicalBulbs} لمبات',
                  icon: Icons.tips_and_updates_rounded,
                  highlight: true,
                ),
                _buildMiniStat(
                  context,
                  label: 'الاستهلاك',
                  value: '${room.totalWattage.toStringAsFixed(0)} واط',
                  icon: Icons.bolt_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: highlight ? AppTheme.primaryDarkAmber : Colors.grey.shade500,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: highlight ? AppTheme.primaryDarkAmber : null,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الغرفة'),
        content: Text('هل تريد بالتأكيد حذف "${room.name}" من مشروع المنزل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LightingProvider>().removeRoom(room.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف "${room.name}" من المشروع'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
