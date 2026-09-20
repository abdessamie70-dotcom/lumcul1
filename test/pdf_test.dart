import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  test('PDF package compilation test', () async {
    final pdf = pw.Document();
    
    // Load Cairo font for Arabic support
    final cairoFont = await PdfGoogleFonts.cairoRegular();
    final cairoBold = await PdfGoogleFonts.cairoBold();

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(
        base: cairoFont,
        bold: cairoBold,
      ),
      textDirection: pw.TextDirection.rtl,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (pw.Context context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Container(
            alignment: pw.Alignment.centerLeft,
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              'حاسبة الإنارة - by BOUGHABA ABDESSAMIE',
              style: pw.TextStyle(font: cairoBold, fontSize: 10),
            ),
          ),
        ),
        footer: (pw.Context context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: pw.TextStyle(font: cairoFont, fontSize: 9),
            ),
          ),
        ),
        build: (pw.Context context) {
          return [
            pw.Text(
              'تقرير مشروع الإنارة وحساب مقطع الأسلاك',
              style: pw.TextStyle(font: cairoBold, fontSize: 18),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['الغرفة', 'المساحة', 'اللومين', 'اللمبات', 'السلك المقترح'],
              data: [
                ['غرفة النوم', '20 م²', '6000 lm', '8 لمبات', '1.5 mm² / 10A'],
                ['المطبخ', '16 م²', '11200 lm', '14 لمبة', '1.5 mm² / 10A'],
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    expect(bytes.isNotEmpty, true);
  });
}
