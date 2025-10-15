import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DescriptionSection extends StatefulWidget {
  final Map<String, dynamic> data;
  const DescriptionSection({super.key, required this.data});

  @override
  State<DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection> {
  @override
  Widget build(BuildContext context) {
    final diseaseName = widget.data['final_prediction'] ?? 'Unknown';
    return SingleChildScrollView(
      child: Column(
        children: [
          ResponsiveContainer(
            width: 366,
            child: ResponsiveText(
              "diseases.$diseaseName.description",
              style: StyleConstants.customStyle(
                20,
                Colors.black,
                FontWeight.w500,
              ),
            ),
          ),
          ResponsiveSizedBox(height: 16),
          _buildCustom("disease_screen.summary"),
        ],
      ),
    );
  }

  Widget _buildCustom(String name) {
    return ResponsiveContainer(
      width: 366,
      height: 54,
      padding: [16, 16, 16, 16],
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ResponsiveText(
            name,
            style: StyleConstants.customStyle(
              20,
              Colors.black,
              FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: () => PdfReport.generateAndView(widget.data),
            child: Image.asset(
              IconAssetConstants.downloadIcon,
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}


class PdfReport {
  static Future<void> generateAndView(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // --- CORRECTED DATA ACCESS ---
    // Access data directly from the map with null-safety
    final String finalPrediction = data['final_prediction'] ?? 'N/A';
    final double confidence = data['confidence'] ?? 0.0;
    final String reportPath = data['report_path'] ?? '';

    // Read the content from the text file specified in the report_path
    String reportText;
    try {
      if (reportPath.isNotEmpty) {
        final file = File(reportPath);
        reportText = await file.readAsString();
      } else {
        reportText = "Report file path was not provided.";
      }
    } catch (e) {
      reportText = "Error reading report file: $e";
    }

    // Load custom font
    final fontData = await rootBundle.load('assets/fonts/Sansation-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final boldTtf = pw.Font.ttf(await rootBundle.load('assets/fonts/Sansation-Bold.ttf'));

    final pw.TextStyle boldStyle = pw.TextStyle(font: boldTtf, fontSize: 14);
    final pw.TextStyle regularStyle = pw.TextStyle(font: ttf, fontSize: 11);
    final pw.TextStyle headerStyle = pw.TextStyle(font: boldTtf, fontSize: 24);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf, bold: boldTtf),
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey700)),
            ),
            child: pw.Text('Paddy Leaf AI Analysis Report', style: boldStyle.copyWith(fontSize: 16)),
          );
        },
        build: (pw.Context context) {
          return <pw.Widget>[
            // --- RESTRUCTURED PDF CONTENT ---
            pw.Header(
              level: 1,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Analysis Summary', style: headerStyle),
                  pw.Text(DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()), style: regularStyle),
                ],
              ),
            ),
            
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 15),

            // Final Prediction Section
            pw.Text('Final Diagnosis:', style: boldStyle),
            pw.Paragraph(
              text: finalPrediction,
              style: regularStyle.copyWith(fontSize: 16, color: PdfColors.blueGrey800),
            ),
            pw.SizedBox(height: 5),
            pw.Text('Confidence Level:', style: boldStyle),
            pw.Paragraph(
              text: '${confidence.toStringAsFixed(2)}%',
              style: regularStyle.copyWith(fontSize: 14),
            ),
            pw.SizedBox(height: 20),

           
            // Full Report Section (from text file)
            pw.Text('Detailed Log:', style: boldStyle),
            pw.SizedBox(height: 5),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Text(reportText, style: regularStyle.copyWith(lineSpacing: 2)),
            ),
          ];
        },
      ),
    );

    // Preview PDF inside the app
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}