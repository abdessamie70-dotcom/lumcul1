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

/// Professional English-only PDF Generator according to IEC 60364-5-52 and CIBSE standards
class PdfGenerator {
  /// Generate comprehensive English Project PDF Report
  static Future<Uint8List> generateProjectPdf({
    required LightingProvider lightingProvider,
    CableSizingProvider? cableProvider,
  }) async {
    final pdf = pw.Document(
      title: 'Electrical Installation and Cable Sizing Engineering Report',
      author: 'BOUGHABA ABDESSAMIE',
      subject: 'Lighting and Cable Sizing Engineering Report',
    );

    // Standard high-quality fonts for English engineering reports
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

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
        base: regularFont,
        bold: boldFont,
      ),
      textDirection: pw.TextDirection.ltr,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (pw.Context context) => _buildPdfHeader(
          context,
          formattedDate,
          regularFont,
          boldFont,
        ),
        footer: (pw.Context context) => _buildPdfFooter(
          context,
          regularFont,
          boldFont,
        ),
        build: (pw.Context context) {
          return [
            // Executive Project Summary Card
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
                      pw.Text(
                        'EXECUTIVE PROJECT SUMMARY',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 12,
                          color: primaryDark,
                        ),
                      ),
                      pw.Text(
                        'Total Rooms: ${lightingProvider.totalRoomsCount}',
                        style: pw.TextStyle(
                          font: boldFont,
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
                        title: 'Total Area',
                        value: '${lightingProvider.totalProjectArea.toStringAsFixed(1)} m²',
                        font: regularFont,
                        boldFont: boldFont,
                        color: accentBlue,
                      ),
                      pw.SizedBox(width: 6),
                      _buildSummaryStat(
                        title: 'Total Lumens',
                        value: '${lightingProvider.totalProjectLumens.toStringAsFixed(0)} lm',
                        font: regularFont,
                        boldFont: boldFont,
                        color: primaryDark,
                      ),
                      pw.SizedBox(width: 6),
                      _buildSummaryStat(
                        title: 'Total Bulbs',
                        value: '${lightingProvider.totalProjectBulbs} Qty',
                        font: regularFont,
                        boldFont: boldFont,
                        color: accentGreen,
                      ),
                      pw.SizedBox(width: 6),
                      _buildSummaryStat(
                        title: 'Total Load',
                        value: '${lightingProvider.totalProjectWattage.toStringAsFixed(0)} W (${totalKw.toStringAsFixed(2)} kW)',
                        font: regularFont,
                        boldFont: boldFont,
                        color: slateDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // Room Lighting & Wiring Schedule Table
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'ROOM LIGHTING & WIRING SCHEDULE',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 11,
                    color: slateDark,
                  ),
                ),
                pw.Text(
                  'Standards: CIBSE / EN 12464',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),

            _buildRoomsTable(
              rooms: lightingProvider.projectRooms,
              regularFont: regularFont,
              boldFont: boldFont,
              primaryAmber: primaryAmber,
              slateBorder: slateBorder,
            ),

            pw.SizedBox(height: 14),

            // Associated Cable Sizing Section (IEC 60364-5-52)
            if (cableProvider?.result != null) ...[
              _buildCableSection(
                cableProvider: cableProvider!,
                regularFont: regularFont,
                boldFont: boldFont,
                accentBlue: accentBlue,
                slateBorder: slateBorder,
              ),
              pw.SizedBox(height: 14),
            ],

            // Technical & Engineering Recommendations
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
                    'TECHNICAL & ENGINEERING STANDARDS COMPLIANCE:',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 9.5,
                      color: primaryDark,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '- Total required lumens calculated with Loss & Utilization factor = 2 (CIBSE / EN 12464).',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '- Standard residential lighting circuits use 1.5 mm² Copper conductors protected by 10A MCB.',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '- Cable sizing verified against permissible voltage drop and thermal ampacity with IEC 60364-5-52 correction factors.',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
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

  /// Generate standalone English Cable Sizing Engineering Report
  static Future<Uint8List> generateCableReportPdf({
    required CableCalculationResult result,
    required CableSizingProvider provider,
  }) async {
    final pdf = pw.Document(
      title: 'Electrical Cable and Wire Sizing Engineering Report',
      author: 'BOUGHABA ABDESSAMIE',
      subject: 'Cable Sizing Engineering Calculation Report',
    );

    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();
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
        base: regularFont,
        bold: boldFont,
      ),
      textDirection: pw.TextDirection.ltr,
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
          regularFont,
          boldFont,
        ),
        footer: (pw.Context context) => _buildPdfFooter(
          context,
          regularFont,
          boldFont,
        ),
        build: (pw.Context context) {
          return [
            pw.Text(
              'ELECTRICAL CABLE & WIRE SIZING ENGINEERING REPORT',
              style: pw.TextStyle(font: boldFont, fontSize: 14, color: accentBlue),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Calculation according to IEC 60364-5-52 Voltage Drop & Thermal Ampacity Standards',
              style: pw.TextStyle(font: regularFont, fontSize: 8.5, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),

            // 1. Input Engineering Parameters Table
            pw.Text(
              '1. INPUT ENGINEERING PARAMETERS:',
              style: pw.TextStyle(font: boldFont, fontSize: 10.5, color: slateDark),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: slateBorder, width: 0.8),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
                  children: [
                    _buildTableCell('Phase System', isHeader: true, font: boldFont),
                    _buildTableCell(provider.phase, font: regularFont),
                    _buildTableCell('Nominal Voltage (V)', isHeader: true, font: boldFont),
                    _buildTableCell('${provider.voltage.toStringAsFixed(0)} V', font: regularFont),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Load Value', isHeader: true, font: boldFont),
                    _buildTableCell('${provider.loadValue} ${provider.loadType}', font: regularFont),
                    _buildTableCell('Power Factor (cos phi)', isHeader: true, font: boldFont),
                    _buildTableCell(provider.loadType == 'kW' ? provider.powerFactor.toStringAsFixed(2) : '-', font: regularFont),
                  ],
                ),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
                  children: [
                    _buildTableCell('Conductor Material', isHeader: true, font: boldFont),
                    _buildTableCell('${provider.material} (gamma = ${provider.material == "Copper" ? 56 : 35})', font: regularFont),
                    _buildTableCell('Insulation Type', isHeader: true, font: boldFont),
                    _buildTableCell('${result.insulation} (${result.insulation == "XLPE" ? "90°C" : "70°C"})', font: regularFont),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Installation Method', isHeader: true, font: boldFont),
                    _buildTableCell(result.installationMethod, font: regularFont),
                    _buildTableCell('Cable Core Structure', isHeader: true, font: boldFont),
                    _buildTableCell(result.coreType, font: regularFont),
                  ],
                ),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
                  children: [
                    _buildTableCell('Operating Temperature', isHeader: true, font: boldFont),
                    _buildTableCell('${result.temperature.toStringAsFixed(0)} °C (K_temp = ${result.temperatureFactorKtemp.toStringAsFixed(2)})', font: regularFont),
                    _buildTableCell('Adjacent Circuits (Grouping)', isHeader: true, font: boldFont),
                    _buildTableCell('${result.groupingCircuitsCount} Circuit(s) (K_group = ${result.groupingFactorKgroup.toStringAsFixed(2)})', font: regularFont),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Line Length (m)', isHeader: true, font: boldFont),
                    _buildTableCell('${provider.length.toStringAsFixed(0)} m', font: regularFont),
                    _buildTableCell('Max Allowable Delta V (%)', isHeader: true, font: boldFont),
                    _buildTableCell('${provider.maxDeltaVPct}% (${(provider.voltage * provider.maxDeltaVPct / 100).toStringAsFixed(1)} V)', font: regularFont),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 14),

            // 2. Approved Engineering Results
            pw.Text(
              '2. APPROVED ENGINEERING RESULTS:',
              style: pw.TextStyle(font: boldFont, fontSize: 10.5, color: slateDark),
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
                      _buildEnglishResultBox(
                        title: 'Design Current (Ib)',
                        subtitle: 'Operating Load Current',
                        value: '${result.designCurrentIb.toStringAsFixed(2)} A',
                        font: regularFont,
                        boldFont: boldFont,
                        color: accentBlue,
                      ),
                      pw.SizedBox(width: 8),
                      _buildEnglishResultBox(
                        title: 'Min Section for Delta V (Min S)',
                        subtitle: 'To satisfy ${provider.maxDeltaVPct}% drop limit',
                        value: '${result.minSectionForVoltageDropMinS.toStringAsFixed(2)} mm²',
                        font: regularFont,
                        boldFont: boldFont,
                        color: primaryAmber,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      _buildEnglishResultBox(
                        title: 'RECOMMENDED CROSS-SECTION',
                        subtitle: 'Selected from IEC standard table',
                        value: result.selectedCable != null ? '$sectionStr mm²' : 'Requires Parallel Cables',
                        font: regularFont,
                        boldFont: boldFont,
                        color: accentGreen,
                        isLarge: true,
                      ),
                      pw.SizedBox(width: 8),
                      _buildEnglishResultBox(
                        title: 'Final Cable Capacity (Iz)',
                        subtitle: 'Raw Capacity (${result.cableCapacity?.toStringAsFixed(1)}A) x K (${result.correctionFactorK.toStringAsFixed(2)})',
                        value: result.finalCableCapacityIz != null ? '${result.finalCableCapacityIz!.toStringAsFixed(2)} A' : '-',
                        font: regularFont,
                        boldFont: boldFont,
                        color: slateDark,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      _buildEnglishResultBox(
                        title: 'Actual Voltage Drop',
                        subtitle: 'Max limit: ${provider.maxDeltaVPct}%',
                        value: result.actualDeltaVPct != null
                            ? '${result.actualDeltaVPct!.toStringAsFixed(2)}% (${result.actualDeltaVVolts?.toStringAsFixed(2)} V)'
                            : '-',
                        font: regularFont,
                        boldFont: boldFont,
                        color: slateDark,
                      ),
                      pw.SizedBox(width: 8),
                      _buildEnglishResultBox(
                        title: 'Recommended Circuit Breaker',
                        subtitle: 'Standard MCB / MCCB Rating',
                        value: result.suggestedBreakerAmps != null ? '${result.suggestedBreakerAmps} A' : '-',
                        font: regularFont,
                        boldFont: boldFont,
                        color: primaryAmber,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // 3. Mathematical Formulas Applied (IEC 60364-5-52)
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
                    'MATHEMATICAL FORMULAS APPLIED (IEC 60364-5-52):',
                    style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: slateDark),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    provider.phase == '1-Phase'
                        ? '- Design Current: Ib = (P x 1000) / (V x cos phi)'
                        : '- Design Current: Ib = (P x 1000) / (sqrt(3) x V x cos phi)',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                  pw.Text(
                    '- Total Correction Factor: Total K = K_temp x K_group = ${result.temperatureFactorKtemp.toStringAsFixed(2)} x ${result.groupingFactorKgroup.toStringAsFixed(2)} = ${result.correctionFactorK.toStringAsFixed(2)}',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                  pw.Text(
                    '- Required Nominal Ampacity: Iz_required = Ib / Total K',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                  pw.Text(
                    provider.phase == '1-Phase'
                        ? '- Voltage Drop Min Section: Min S = (2 x L x Ib x cos phi) / (gamma x Max Delta V)'
                        : '- Voltage Drop Min Section: Min S = (sqrt(3) x L x Ib x cos phi) / (gamma x Max Delta V)',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
                  ),
                  pw.Text(
                    '- Conductivity gamma: Copper = 56 m/(Ohm.mm²) | Aluminum = 35 m/(Ohm.mm²)',
                    style: pw.TextStyle(font: regularFont, fontSize: 8),
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

  /// Preview, print or save Project PDF
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
      name: 'Electrical_Project_Report.pdf',
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Share Project PDF directly
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
      filename: 'Electrical_Project_Report.pdf',
    );
  }

  /// Preview, print or save standalone Cable PDF
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
      name: 'Cable_Sizing_Report_${sectionStr}mm2.pdf',
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Share standalone Cable PDF directly
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
      filename: 'Cable_Sizing_Report_${sectionStr}mm2.pdf',
    );
  }

  /// Show PDF download options modal
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
                            'Download Project Report (PDF)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'English Engineering Report • CIBSE & IEC Standards',
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
                  title: const Text('Preview, Save or Print PDF'),
                  subtitle: const Text('Direct print preview and save to device'),
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
                  title: const Text('Share PDF File'),
                  subtitle: const Text('Share PDF via WhatsApp, Email, or Files'),
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

  // --- Helper Layout Widgets ---

  static pw.Widget _buildPdfHeader(
    pw.Context context,
    String formattedDate,
    pw.Font regularFont,
    pw.Font boldFont,
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
                'ELECTRICAL INSTALLATION & CABLE SIZING ENGINEERING REPORT',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 13,
                  color: primaryDark,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'by BOUGHABA ABDESSAMIE',
                style: pw.TextStyle(
                  font: boldFont,
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
                'Date: $formattedDate',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                'Standards: IEC 60364-5-52 / CIBSE',
                style: pw.TextStyle(
                  font: regularFont,
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
    pw.Font regularFont,
    pw.Font boldFont,
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
            'Electrical Installation & Cable Sizing Calculator - Developed by BOUGHABA ABDESSAMIE',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryStat({
    required String title,
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
              title,
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey700),
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
    required pw.Font regularFont,
    required pw.Font boldFont,
    required PdfColor primaryAmber,
    required PdfColor slateBorder,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: slateBorder, width: 0.8),
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFD97706)),
          children: [
            _buildTableHeader('#', boldFont),
            _buildTableHeader('Room Name', boldFont),
            _buildTableHeader('Dim. & Area', boldFont),
            _buildTableHeader('Lux', boldFont),
            _buildTableHeader('Lumens', boldFont),
            _buildTableHeader('Lamp Type', boldFont),
            _buildTableHeader('Qty', boldFont),
            _buildTableHeader('Power', boldFont),
            _buildTableHeader('Wire & Breaker', boldFont),
          ],
        ),
        // Room Rows
        ...rooms.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final r = entry.value;
          final isEven = entry.key % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : const PdfColor.fromInt(0xFFF8FAFC),
            ),
            children: [
              _buildTableCell('$i', font: boldFont, align: pw.TextAlign.center),
              _buildTableCell(r.name, font: boldFont),
              _buildTableCell('${r.length}x${r.width} (${r.area.toStringAsFixed(1)} m²)', font: regularFont),
              _buildTableCell('${r.requiredLux.toInt()} lx', font: regularFont, align: pw.TextAlign.center),
              _buildTableCell('${r.totalRequiredLumens.toStringAsFixed(0)} lm', font: regularFont, align: pw.TextAlign.center),
              _buildTableCell('${r.bulbWattage.toInt()}W (${r.bulbLumen.toInt()}lm)', font: regularFont),
              _buildTableCell('${r.practicalBulbs}', font: boldFont, align: pw.TextAlign.center),
              _buildTableCell('${r.totalWattage.toStringAsFixed(0)} W', font: boldFont, align: pw.TextAlign.center),
              _buildTableCell('1.5 mm² / 10A MCB', font: regularFont, align: pw.TextAlign.center),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
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
    required pw.Font regularFont,
    required pw.Font boldFont,
    required PdfColor accentBlue,
    required PdfColor slateBorder,
  }) {
    final res = cableProvider.result!;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ASSOCIATED ELECTRICAL CABLE SIZING (IEC 60364-5-52):',
          style: pw.TextStyle(font: boldFont, fontSize: 10.5, color: accentBlue),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: slateBorder, width: 0.8),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFF6FF)),
              children: [
                _buildTableCell('System & Voltage', isHeader: true, font: boldFont),
                _buildTableCell('${cableProvider.phase} / ${cableProvider.voltage.toInt()}V', font: regularFont),
                _buildTableCell('Load & Power Factor', isHeader: true, font: boldFont),
                _buildTableCell('${cableProvider.loadValue} ${cableProvider.loadType} (cos phi: ${cableProvider.powerFactor.toStringAsFixed(2)})', font: regularFont),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Length & Conductor', isHeader: true, font: boldFont),
                _buildTableCell('${cableProvider.length.toInt()}m / ${cableProvider.material}', font: regularFont),
                _buildTableCell('Insulation & Structure', isHeader: true, font: boldFont),
                _buildTableCell('${res.insulation} (${res.insulation == "XLPE" ? "90°C" : "70°C"}) / ${res.coreType}', font: regularFont),
              ],
            ),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFF6FF)),
              children: [
                _buildTableCell('Installation Method', isHeader: true, font: boldFont),
                _buildTableCell(res.installationMethod, font: regularFont),
                _buildTableCell('Temp & Grouping K', isHeader: true, font: boldFont),
                _buildTableCell('${res.temperature.toInt()}°C (K_temp: ${res.temperatureFactorKtemp.toStringAsFixed(2)}) / ${res.groupingCircuitsCount} Ckts (K_grp: ${res.groupingFactorKgroup.toStringAsFixed(2)})', font: regularFont),
              ],
            ),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFEF3C7)),
              children: [
                _buildTableCell('Design Current (Ib)', isHeader: true, font: boldFont),
                _buildTableCell('${res.designCurrentIb.toStringAsFixed(2)} A', font: boldFont),
                _buildTableCell('Min Section for Delta V (Min S)', isHeader: true, font: boldFont),
                _buildTableCell('${res.minSectionForVoltageDropMinS.toStringAsFixed(2)} mm²', font: boldFont),
              ],
            ),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFDCFCE7)),
              children: [
                _buildTableCell('RECOMMENDED SECTION', isHeader: true, font: boldFont),
                _buildTableCell(
                  res.selectedCable != null
                      ? '${res.selectedCable!.section == res.selectedCable!.section.roundToDouble() ? res.selectedCable!.section.toInt() : res.selectedCable!.section} mm²'
                      : 'Parallel Cables Required',
                  font: boldFont,
                ),
                _buildTableCell('Final Capacity (Iz)', isHeader: true, font: boldFont),
                _buildTableCell(
                  '${res.finalCableCapacityIz != null ? res.finalCableCapacityIz!.toStringAsFixed(2) : '-'} A (Breaker: ${res.suggestedBreakerAmps ?? '-'}A)',
                  font: boldFont,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildEnglishResultBox({
    required String title,
    required String subtitle,
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
              title,
              style: pw.TextStyle(font: boldFont, fontSize: 8, color: PdfColors.grey800),
            ),
            pw.Text(
              subtitle,
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
