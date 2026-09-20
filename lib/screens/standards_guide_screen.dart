import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lighting_standard.dart';
import '../providers/lighting_provider.dart';
import '../widgets/standard_card.dart';
import '../utils/app_strings.dart';
import '../utils/app_theme.dart';

class StandardsGuideScreen extends StatelessWidget {
  final VoidCallback onSelectStandard;

  const StandardsGuideScreen({
    super.key,
    required this.onSelectStandard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<LightingProvider>();
    final isArabic = provider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_stories_rounded, color: AppTheme.primaryAmber),
            const SizedBox(width: 8),
            Text(AppStrings.get('standards_title', isArabic)),
          ],
        ),
        actions: [
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
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بطاقة تقديمية تشرح معايير الكود الدولي
                  _buildIntroCard(context),
                  const SizedBox(height: 16),

                  // كارت إرشادي سريع لحرارة اللون (Kelvin)
                  _buildKelvinExplainerCard(context),
                  const SizedBox(height: 20),

                  // عنوان القائمة
                  const Text(
                    'المعايير الموصى بها لكل فراغ منزلي:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // قائمة الكروت المستخرجة من جدول البيانات
                  ...LightingStandard.standards.map((standard) {
                    return StandardInfoCard(
                      standard: standard,
                      onApply: () {
                        context.read<LightingProvider>().setPresetStandard(standard);
                        onSelectStandard();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم تطبيق معايير "${standard.roomName}" في الحاسبة'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.primaryDarkAmber,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppTheme.accentBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المواصفات القياسية (CIBSE / EN 12464)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تحدد هذه المعايير الهندسية كمية الإضاءة (Lux = لومين لكل م²) وحرارة اللون المناسبة لضمان الراحة البصرية، الحفاظ على سلامة العين، وترشيد استهلاك الطاقة.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelvinExplainerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryAmber.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.palette_outlined, size: 18, color: AppTheme.primaryDarkAmber),
              SizedBox(width: 8),
              Text(
                'دليل درجات حرارة اللون (Kelvin):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildKelvinIndicator(
                context,
                title: '2700K - 3000K',
                desc: 'أصفر دافئ (استرخاء)',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _buildKelvinIndicator(
                context,
                title: '4000K',
                desc: 'أبيض طبيعي (توازن)',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _buildKelvinIndicator(
                context,
                title: '5000K+',
                desc: 'أبيض نهاري (تركيز)',
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKelvinIndicator(
    BuildContext context, {
    required String title,
    required String desc,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
