import 'dart:convert';

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
    final diseaseName = widget.data['disease'];
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

    final reportText = data['report'] ?? "No report available";
    final summary = data['summary'] ?? "{}";

    // Parse summary JSON if available
    Map<String, dynamic> summaryMap;
    try {
      summaryMap = jsonDecode(summary);
    } catch (_) {
      summaryMap = {};
    }

    final fontData = await rootBundle.load('assets/fonts/Sansation-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: ttf)),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(level: 0, text: "AI Analysis Report"),
            
            // Analysis Date
            if (summaryMap.containsKey("analysis_date"))
              pw.Text("Analysis Date: ${summaryMap['analysis_date']}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // Final Prediction
            if (summaryMap.containsKey("final_prediction"))
              pw.Text("Final Prediction: ${summaryMap['final_prediction']}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // Model Predictions Table
            if (summaryMap.containsKey("model_predictions"))
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Model Predictions:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  ...summaryMap['model_predictions'].entries.map<pw.Widget>((entry) {
                    final modelName = entry.key;
                    final prediction = entry.value;
                    final predictedClass = prediction['predicted_class'];
                    final confidence = prediction['confidence'];
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Text(
                        "$modelName: $predictedClass (${confidence.toStringAsFixed(2)}%)",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ],
              ),

            pw.SizedBox(height: 20),

            // Full Report Section (text from report key)
            pw.Text("Full Report:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: reportText
                  .split('\n')
                  .map<pw.Widget>((line) => pw.Text(line, style: pw.TextStyle(font: ttf)))
                  .toList(),
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
