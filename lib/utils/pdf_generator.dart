import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cable_calculation_result.dart';
import '../models/room_model.dart';
import '../providers/cable_sizing_provider.dart';
import '../providers/lighting_provider.dart';

/// فئة مسؤولة عن إنشاء وتوليد تقارير PDF هندسية ثنائية اللغة (عربي / إنجليزي)
class PdfGenerator {
  /// توليد ملف PDF شامل لمشروع الإنارة وتمديدات الكابلات (Bilingual: Arabic & English)
  static Future<Uint8List> generateProjectPdf({
    required LightingProvider lightingProvider,
    CableSizingProvider? cableProvider,
  }) async {
    final pdf = pw.Document(
      title: 'Lighting & Electrical Cable Sizing Engineering Report',
      author: 'BOUGHABA ABDESSAMIE',
      subject: 'Home Lighting & Cable Sizing Bilingual Engineering Report',
    );

    // تحميل خط Cairo العربي الذي يدعم العربية والإنجليزية بتناسق
    final cairoRegular = await PdfGoogleFonts.cairoRegular();
    final cairoBold = await PdfGoogleFonts.cairoBold();

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

    const primaryAmber = PdfColor.fromInt(0xFFD97706);
    const primaryDark = PdfColor.fromInt(0xFFB45309);
    const slateDark = PdfColor.fromInt(0xFF1E293B);
    const slateLight = PdfColor.fromInt(0xFFF8FAFC);
    const slateBorder = PdfColor.fromInt(0xFFCBD5E1);
    const accentGreen = PdfColor.fromInt(0xFF059669);
    const accentBlue = PdfColor.fromInt(0xFF2563EB);

    final totalKw = lightingProvider.totalProjectWattage / 1000.0;

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(26),
      theme: pw.ThemeData.withFont(
        base: cairoRegular,
        bold: cairoBold,
      ),
      textDirection: pw.TextDirection.rtl,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (pw.Context context) => _buildPdfHeader(
          context,
          formattedDate,
          cairoRegular,
          cairoBold,
        ),
        footer: (pw.Context context) => _buildPdfFooter(
          context,
          cairoRegular,
          cairoBold,
        ),
        build: (pw.Context context) {
          return [
            // بطاقة الملخص التنفيذي الثنائي اللغة (Executive Summary Card)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: slateLight,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                border: pw.Border.all(color: primaryAmber, width: 1.2),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'الملخص العام للمشروع / Executive Project Summary',
                            style: pw.TextStyle(
                              font: cairoBold,
                              fontSize: 13,
                              color: primaryDark,
                            ),
                          ),
                        ],
                      ),
                      pw.Text(
                        'إجمالي الغرف / Total Rooms: ${lightingProvider.totalRoomsCount}',
                        style: pw.TextStyle(
                          font: cairoBold,
                          fontSize: 10,
                          color: slateDark,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      _buildSummaryStat(
                        titleAr: 'إجمالي المساحة',
                        titleEn: 'Total Area',
                        value: '${lightingProvider.totalProjectArea.toStringAsFixed(1)} m²',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: accentBlue,
                      ),
                      pw.SizedBox(width: 6),
                      _buildSummaryStat(
                        titleAr: 'إجمالي اللومين',
                        titleEn: 'Total Lumens',
                        value: '${lightingProvider.totalProjectLumens.toStringAsFixed(0)} lm',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: primaryDark,
                      ),
                      pw.SizedBox(width: 6),
                      _buildSummaryStat(
                        titleAr: 'إجمالي اللمبات',
                        titleEn: 'Total Bulbs',
                        value: '${lightingProvider.totalProjectBulbs} Qty',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: accentGreen,
                      ),
                      pw.SizedBox(width: 6),
                      _buildSummaryStat(
                        titleAr: 'إجمالي الاستهلاك',
                        titleEn: 'Total Load',
                        value: '${lightingProvider.totalProjectWattage.toStringAsFixed(0)} W (${totalKw.toStringAsFixed(2)} kW)',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: slateDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // عنوان جدول تفاصيل الغرف
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'جدول تفاصيل الغرف ومواصفات الإنارة والأسلاك / Room Lighting & Wiring Schedule',
                  style: pw.TextStyle(
                    font: cairoBold,
                    fontSize: 11,
                    color: slateDark,
                  ),
                ),
                pw.Text(
                  'CIBSE / EN 12464 Standards',
                  style: pw.TextStyle(
                    font: cairoRegular,
                    fontSize: 8.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),

            // جدول الغرف ثنائي اللغة
            _buildRoomsTable(
              rooms: lightingProvider.projectRooms,
              cairoRegular: cairoRegular,
              cairoBold: cairoBold,
              primaryAmber: primaryAmber,
              slateBorder: slateBorder,
            ),

            pw.SizedBox(height: 14),

            // قسم حساب الكابل إذا كان متوفراً (Bilingual Cable Sizing Section)
            if (cableProvider?.result != null) ...[
              _buildCableSection(
                cableProvider: cableProvider!,
                cairoRegular: cairoRegular,
                cairoBold: cairoBold,
                accentBlue: accentBlue,
                slateBorder: slateBorder,
              ),
              pw.SizedBox(height: 14),
            ],

            // بطاقة التوصيات والملاحظات الهندسية ثنائية اللغة
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFFFFBEB),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: primaryAmber, width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'التوصيات الهندسية والمعايير المعتمدة / Technical & Engineering Standards:',
                    style: pw.TextStyle(
                      font: cairoBold,
                      fontSize: 9.5,
                      color: primaryDark,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '- تم احتساب اللومين المطلوب بمعامل فواقد وامتصاص (Loss & Utilization Factor = 2) لضمان تحقيق شدة الإضاءة الفعلية.\n  Total required lumens calculated with Loss & Utilization factor = 2 (CIBSE / EN 12464).',
                    style: pw.TextStyle(font: cairoRegular, fontSize: 8),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '- دوائر الإنارة المنزلية القياسية تنفذ بأسلاك نحاسية مقطع 1.5 مم² مع قاطع حماية 10A MCB.\n  Standard residential lighting circuits use 1.5 mm² Copper conductors protected by 10A MCB.',
                    style: pw.TextStyle(font: cairoRegular, fontSize: 8),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '- حساب مقطع الكابل يعتمد على هبوط الجهد الأقصى المسموح به وسعة التيار الحرارية مع معاملات التصحيح (IEC).\n  Cable sizing is verified against maximum allowable voltage drop and thermal ampacity with correction factors (IEC).',
                    style: pw.TextStyle(font: cairoRegular, fontSize: 8),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// توليد تقرير PDF مخصص لحساب مقطع السلك والكابل الكهربائي ثنائي اللغة
  static Future<Uint8List> generateCableReportPdf({
    required CableCalculationResult result,
    required CableSizingProvider provider,
  }) async {
    final pdf = pw.Document(
      title: 'Electrical Cable & Wire Sizing Engineering Report',
      author: 'BOUGHABA ABDESSAMIE',
      subject: 'Bilingual Electrical Cable Sizing Engineering Report',
    );

    final cairoRegular = await PdfGoogleFonts.cairoRegular();
    final cairoBold = await PdfGoogleFonts.cairoBold();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

    const primaryAmber = PdfColor.fromInt(0xFFD97706);
    const slateDark = PdfColor.fromInt(0xFF1E293B);
    const accentBlue = PdfColor.fromInt(0xFF2563EB);
    const accentGreen = PdfColor.fromInt(0xFF059669);
    const slateBorder = PdfColor.fromInt(0xFFCBD5E1);

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(26),
      theme: pw.ThemeData.withFont(
        base: cairoRegular,
        bold: cairoBold,
      ),
      textDirection: pw.TextDirection.rtl,
    );

    final sectionStr = result.selectedCable != null
        ? (result.selectedCable!.section == result.selectedCable!.section.roundToDouble()
            ? '${result.selectedCable!.section.toInt()}'
            : '${result.selectedCable!.section}')
        : 'Parallel';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (pw.Context context) => _buildPdfHeader(
          context,
          formattedDate,
          cairoRegular,
          cairoBold,
        ),
        footer: (pw.Context context) => _buildPdfFooter(
          context,
          cairoRegular,
          cairoBold,
        ),
        build: (pw.Context context) {
          return [
            pw.Text(
              'تقرير الحساب الهندسي لمقطع السلك والكابل الكهربائي',
              style: pw.TextStyle(font: cairoBold, fontSize: 15, color: accentBlue),
            ),
            pw.Text(
              'Electrical Cable & Wire Sizing Engineering Calculation Report',
              style: pw.TextStyle(font: cairoBold, fontSize: 11, color: slateDark),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'وفقاً لمعايير هبوط الجهد وسعة التحمل الحرارية / According to IEC Voltage Drop & Ampacity Standards',
              style: pw.TextStyle(font: cairoRegular, fontSize: 8.5, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),

            // جدول المدخلات الهندسية ثنائي اللغة
            pw.Text(
              '1. معطيات ومدخلات الحساب / Input Engineering Parameters:',
              style: pw.TextStyle(font: cairoBold, fontSize: 11, color: slateDark),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: slateBorder, width: 0.8),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
                  children: [
                    _buildTableCell('نظام التغذية\nPhase System', isHeader: true, font: cairoBold),
                    _buildTableCell(provider.phase, font: cairoRegular),
                    _buildTableCell('الجهد الاسمي\nVoltage (V)', isHeader: true, font: cairoBold),
                    _buildTableCell('${provider.voltage.toStringAsFixed(0)} V', font: cairoRegular),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('قيمة الحمل\nLoad Value', isHeader: true, font: cairoBold),
                    _buildTableCell('${provider.loadValue} ${provider.loadType}', font: cairoRegular),
                    _buildTableCell('معامل القدرة\nPower Factor (cos φ)', isHeader: true, font: cairoBold),
                    _buildTableCell(provider.loadType == 'kW' ? provider.powerFactor.toStringAsFixed(2) : '-', font: cairoRegular),
                  ],
                ),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
                  children: [
                    _buildTableCell('طول الخط\nLine Length (m)', isHeader: true, font: cairoBold),
                    _buildTableCell('${provider.length.toStringAsFixed(0)} m', font: cairoRegular),
                    _buildTableCell('مادة الموصل\nConductor Material', isHeader: true, font: cairoBold),
                    _buildTableCell(provider.material == 'Copper' ? 'نحاس (Copper)' : 'ألمنيوم (Aluminum)', font: cairoRegular),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('أقصى هبوط مسموح\nMax ΔV (%)', isHeader: true, font: cairoBold),
                    _buildTableCell('${provider.maxDeltaVPct}% (${(provider.voltage * provider.maxDeltaVPct / 100).toStringAsFixed(1)} V)', font: cairoRegular),
                    _buildTableCell('معامل التصحيح\nCorrection Factor (K)', isHeader: true, font: cairoBold),
                    _buildTableCell(provider.correctionFactorK.toStringAsFixed(2), font: cairoRegular),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 14),

            // بطاقة النتائج الهندسية المعتمدة
            pw.Text(
              '2. النتائج الهندسية المعتمدة / Approved Engineering Results:',
              style: pw.TextStyle(font: cairoBold, fontSize: 11, color: slateDark),
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFF0FDF4),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                border: pw.Border.all(color: accentGreen, width: 1.2),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    children: [
                      _buildBilingualResultBox(
                        titleAr: 'تيار التصميم (Ib)',
                        titleEn: 'Design Current',
                        value: '${result.designCurrentIb.toStringAsFixed(2)} A',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: accentBlue,
                      ),
                      pw.SizedBox(width: 8),
                      _buildBilingualResultBox(
                        titleAr: 'الحد الأدنى لمقطع السلك (Min S)',
                        titleEn: 'Min Section (ΔV)',
                        value: '${result.minSectionForVoltageDropMinS.toStringAsFixed(2)} mm²',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: primaryAmber,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      _buildBilingualResultBox(
                        titleAr: 'المقطع الموصى به (Recommended)',
                        titleEn: 'Recommended Cable Cross-Section',
                        value: result.selectedCable != null ? '$sectionStr mm²' : 'يتطلب كابلات توازي / Parallel',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: accentGreen,
                        isLarge: true,
                      ),
                      pw.SizedBox(width: 8),
                      _buildBilingualResultBox(
                        titleAr: 'السعة النهائية للكابل (Iz)',
                        titleEn: 'Final Cable Capacity (Raw × K)',
                        value: result.finalCableCapacityIz != null ? '${result.finalCableCapacityIz!.toStringAsFixed(2)} A' : '-',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: slateDark,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      _buildBilingualResultBox(
                        titleAr: 'هبوط الجهد الفعلي (Actual ΔV)',
                        titleEn: 'Actual Voltage Drop',
                        value: result.actualDeltaVPct != null
                            ? '${result.actualDeltaVPct!.toStringAsFixed(2)}% (${result.actualDeltaVVolts?.toStringAsFixed(2)} V)'
                            : '-',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: slateDark,
                      ),
                      pw.SizedBox(width: 8),
                      _buildBilingualResultBox(
                        titleAr: 'القاطع الموصى به (Breaker)',
                        titleEn: 'Recommended Circuit Breaker',
                        value: result.suggestedBreakerAmps != null ? '${result.suggestedBreakerAmps} A MCB/MCCB' : '-',
                        font: cairoRegular,
                        boldFont: cairoBold,
                        color: primaryAmber,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // المعادلات الهندسية المستخدمة ثنائية اللغة
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFF8FAFC),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: slateBorder, width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'المعادلات الرياضية المطبقة في الحساب / Mathematical Formulas Applied:',
                    style: pw.TextStyle(font: cairoBold, fontSize: 9.5, color: slateDark),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    provider.phase == '1-Phase'
                        ? '- 1-Phase Design Current: Ib = (P × 1000) / (V × cos φ)'
                        : '- 3-Phase Design Current: Ib = (P × 1000) / (√3 × V × cos φ)',
                    style: pw.TextStyle(font: cairoRegular, fontSize: 8),
                  ),
                  pw.Text(
                    '- Required Nominal Ampacity: Iz_required = Ib / K',
                    style: pw.TextStyle(font: cairoRegular, fontSize: 8),
                  ),
                  pw.Text(
                    provider.phase == '1-Phase'
                        ? '- 1-Phase Min Cross-Section: Min S = (2 × L × Ib × cos φ) / (γ × Max ΔV)'
                        : '- 3-Phase Min Cross-Section: Min S = (√3 × L × Ib × cos φ) / (γ × Max ΔV)',
                    style: pw.TextStyle(font: cairoRegular, fontSize: 8),
                  ),
                  pw.Text(
                    '- Electrical Conductivity γ: Copper = 56 m/(Ohm·mm²) | Aluminum = 35 m/(Ohm·mm²)',
                    style: pw.TextStyle(font: cairoRegular, fontSize: 8),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// معاينة وطباعة أو حفظ ملف PDF للمشروع
  static Future<void> previewAndSaveProjectPdf({
    required BuildContext context,
    required LightingProvider lightingProvider,
    CableSizingProvider? cableProvider,
  }) async {
    final pdfBytes = await generateProjectPdf(
      lightingProvider: lightingProvider,
      cableProvider: cableProvider,
    );

    await Printing.layoutPdf(
      name: 'تقرير_مشروع_الإنارة_والكهرباء.pdf',
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// مشاركة ملف PDF مباشرة للمشروع (Share Sheet)
  static Future<void> shareProjectPdf({
    required BuildContext context,
    required LightingProvider lightingProvider,
    CableSizingProvider? cableProvider,
  }) async {
    final pdfBytes = await generateProjectPdf(
      lightingProvider: lightingProvider,
      cableProvider: cableProvider,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'تقرير_مشروع_الإنارة_والكهرباء.pdf',
    );
  }

  /// معاينة وطباعة تقرير الكابل المنفصل
  static Future<void> previewAndSaveCablePdf({
    required BuildContext context,
    required CableCalculationResult result,
    required CableSizingProvider provider,
  }) async {
    final pdfBytes = await generateCableReportPdf(
      result: result,
      provider: provider,
    );

    final sectionStr = result.selectedCable != null
        ? (result.selectedCable!.section == result.selectedCable!.section.roundToDouble()
            ? '${result.selectedCable!.section.toInt()}'
            : '${result.selectedCable!.section}')
        : 'parallel';

    await Printing.layoutPdf(
      name: 'تقرير_حساب_مقطع_الكابل_${sectionStr}mm2.pdf',
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// مشاركة ملف تقرير الكابل المنفصل
  static Future<void> shareCablePdf({
    required BuildContext context,
    required CableCalculationResult result,
    required CableSizingProvider provider,
  }) async {
    final pdfBytes = await generateCableReportPdf(
      result: result,
      provider: provider,
    );

    final sectionStr = result.selectedCable != null
        ? (result.selectedCable!.section == result.selectedCable!.section.roundToDouble()
            ? '${result.selectedCable!.section.toInt()}'
            : '${result.selectedCable!.section}')
        : 'parallel';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'تقرير_حساب_مقطع_الكابل_${sectionStr}mm2.pdf',
    );
  }

  /// عرض نافذة خيارات تحميل ومشاركة ملف الـ PDF (Bottom Sheet)
  static void showPdfOptionsModal({
    required BuildContext context,
    required LightingProvider lightingProvider,
    CableSizingProvider? cableProvider,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFD97706),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تحميل تقرير المشروع (PDF)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'تقرير هندسي ثنائي اللغة (عربي / English)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.print_rounded, color: Color(0xFFD97706)),
                  title: const Text('معاينة وحفظ / طباعة PDF'),
                  subtitle: const Text('Preview, Save or Print PDF'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.amber.withValues(alpha: 0.08),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    previewAndSaveProjectPdf(
                      context: context,
                      lightingProvider: lightingProvider,
                      cableProvider: cableProvider,
                    );
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: Color(0xFF2563EB)),
                  title: const Text('مشاركة ملف PDF مباشرة'),
                  subtitle: const Text('Share PDF via WhatsApp, Email, etc.'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.blue.withValues(alpha: 0.08),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    shareProjectPdf(
                      context: context,
                      lightingProvider: lightingProvider,
                      cableProvider: cableProvider,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- دوال البناء المساعدة للـ PDF ---

  static pw.Widget _buildPdfHeader(
    pw.Context context,
    String formattedDate,
    pw.Font cairoRegular,
    pw.Font cairoBold,
  ) {
    const primaryDark = PdfColor.fromInt(0xFFB45309);
    const primaryAmber = PdfColor.fromInt(0xFFD97706);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: primaryAmber, width: 2),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'حاسبة الإضاءة وتمديدات الكابلات الكهربائية',
                style: pw.TextStyle(
                  font: cairoBold,
                  fontSize: 15,
                  color: primaryDark,
                ),
              ),
              pw.Text(
                'Home Lighting & Electrical Cable Sizing Report',
                style: pw.TextStyle(
                  font: cairoBold,
                  fontSize: 10.5,
                  color: const PdfColor.fromInt(0xFF334155),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'by BOUGHABA ABDESSAMIE',
                style: pw.TextStyle(
                  font: cairoBold,
                  fontSize: 9.5,
                  color: primaryAmber,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'تاريخ التقرير / Date: $formattedDate',
                style: pw.TextStyle(
                  font: cairoRegular,
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                'Standards: CIBSE / EN 12464 / IEC',
                style: pw.TextStyle(
                  font: cairoRegular,
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(
    pw.Context context,
    pw.Font cairoRegular,
    pw.Font cairoBold,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
        ),
      ),
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'حاسبة الإنارة وتمديدات الكابلات - Developed by BOUGHABA ABDESSAMIE',
            style: pw.TextStyle(
              font: cairoRegular,
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'صفحة ${context.pageNumber} من ${context.pagesCount} | Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: cairoRegular,
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryStat({
    required String titleAr,
    required String titleEn,
    required String value,
    required pw.Font font,
    required pw.Font boldFont,
    required PdfColor color,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              titleAr,
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey800),
            ),
            pw.Text(
              titleEn,
              style: pw.TextStyle(font: font, fontSize: 6.5, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 9.5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildRoomsTable({
    required List<RoomCalculation> rooms,
    required pw.Font cairoRegular,
    required pw.Font cairoBold,
    required PdfColor primaryAmber,
    required PdfColor slateBorder,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: slateBorder, width: 0.8),
      children: [
        // صف العناوين ثنائي اللغة
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFD97706)),
          children: [
            _buildTableHeader('#', cairoBold),
            _buildTableHeader('الغرفة\nRoom', cairoBold),
            _buildTableHeader('الأبعاد والمساحة\nDim. & Area', cairoBold),
            _buildTableHeader('اللوكس\nLux', cairoBold),
            _buildTableHeader('اللومين\nLumens', cairoBold),
            _buildTableHeader('اللمبة\nLamp', cairoBold),
            _buildTableHeader('العدد\nQty', cairoBold),
            _buildTableHeader('الواط\nPower', cairoBold),
            _buildTableHeader('السلك والقاطع\nWire & Breaker', cairoBold),
          ],
        ),
        // صفوف الغرف
        ...rooms.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final r = entry.value;
          final isEven = entry.key % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : const PdfColor.fromInt(0xFFF8FAFC),
            ),
            children: [
              _buildTableCell('$i', font: cairoBold, align: pw.TextAlign.center),
              _buildTableCell(r.name, font: cairoBold),
              _buildTableCell('${r.length}×${r.width} (${r.area.toStringAsFixed(1)} m²)', font: cairoRegular),
              _buildTableCell('${r.requiredLux.toInt()} lx', font: cairoRegular, align: pw.TextAlign.center),
              _buildTableCell('${r.totalRequiredLumens.toStringAsFixed(0)} lm', font: cairoRegular, align: pw.TextAlign.center),
              _buildTableCell('${r.bulbWattage.toInt()}W (${r.bulbLumen.toInt()}lm)', font: cairoRegular),
              _buildTableCell('${r.practicalBulbs}', font: cairoBold, align: pw.TextAlign.center),
              _buildTableCell('${r.totalWattage.toStringAsFixed(0)}W', font: cairoBold, align: pw.TextAlign.center),
              _buildTableCell('1.5 mm² / 10A', font: cairoRegular, align: pw.TextAlign.center),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: 7.5,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    required pw.Font font,
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.start,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: 7.5,
          color: isHeader ? const PdfColor.fromInt(0xFF334155) : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildCableSection({
    required CableSizingProvider cableProvider,
    required pw.Font cairoRegular,
    required pw.Font cairoBold,
    required PdfColor accentBlue,
    required PdfColor slateBorder,
  }) {
    final res = cableProvider.result!;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'حساب مقطع السلك والكابل الكهربائي المرتبط / Associated Cable Sizing Calculation:',
          style: pw.TextStyle(font: cairoBold, fontSize: 11, color: accentBlue),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: slateBorder, width: 0.8),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFF6FF)),
              children: [
                _buildTableCell('النظام والجهد\nPhase & Voltage', isHeader: true, font: cairoBold),
                _buildTableCell('${cableProvider.phase} / ${cableProvider.voltage.toInt()}V', font: cairoRegular),
                _buildTableCell('الحمل ومعامل القدرة\nLoad & Power Factor', isHeader: true, font: cairoBold),
                _buildTableCell('${cableProvider.loadValue} ${cableProvider.loadType} (cos φ: ${cableProvider.powerFactor.toStringAsFixed(2)})', font: cairoRegular),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('طول الخط والمادة\nLength & Material', isHeader: true, font: cairoBold),
                _buildTableCell('${cableProvider.length.toInt()}m / ${cableProvider.material == "Copper" ? "Copper" : "Aluminum"}', font: cairoRegular),
                _buildTableCell('أقصى هبوط ومعامل K\nMax ΔV% & K', isHeader: true, font: cairoBold),
                _buildTableCell('${cableProvider.maxDeltaVPct}% / K=${cableProvider.correctionFactorK}', font: cairoRegular),
              ],
            ),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFEF3C7)),
              children: [
                _buildTableCell('تيار التصميم (Ib)\nDesign Current', isHeader: true, font: cairoBold),
                _buildTableCell('${res.designCurrentIb.toStringAsFixed(2)} A', font: cairoBold),
                _buildTableCell('مقطع هبوط الجهد (Min S)\nMin Section (ΔV)', isHeader: true, font: cairoBold),
                _buildTableCell('${res.minSectionForVoltageDropMinS.toStringAsFixed(2)} mm²', font: cairoBold),
              ],
            ),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFDCFCE7)),
              children: [
                _buildTableCell('المقطع الموصى به\nRecommended Section', isHeader: true, font: cairoBold),
                _buildTableCell(
                  res.selectedCable != null
                      ? '${res.selectedCable!.section == res.selectedCable!.section.roundToDouble() ? res.selectedCable!.section.toInt() : res.selectedCable!.section} mm²'
                      : 'Parallel Cables',
                  font: cairoBold,
                ),
                _buildTableCell('السعة النهائية (Iz)\nFinal Ampacity (Raw × K)', isHeader: true, font: cairoBold),
                _buildTableCell(
                  '${res.finalCableCapacityIz != null ? res.finalCableCapacityIz!.toStringAsFixed(2) : '-'} A (Breaker: ${res.suggestedBreakerAmps ?? '-'}A)',
                  font: cairoBold,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBilingualResultBox({
    required String titleAr,
    required String titleEn,
    required String value,
    required pw.Font font,
    required pw.Font boldFont,
    required PdfColor color,
    bool isLarge = false,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              titleAr,
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey800),
            ),
            pw.Text(
              titleEn,
              style: pw.TextStyle(font: font, fontSize: 6.5, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: isLarge ? 12 : 9.5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
