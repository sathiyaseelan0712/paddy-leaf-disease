import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';
import 'package:path_provider/path_provider.dart';

class ImagesSection extends StatefulWidget {
  final Map<String, dynamic> data;
  const ImagesSection({super.key, required this.data});

  @override
  State<ImagesSection> createState() => ImagesSectionState();
}

class ImagesSectionState extends State<ImagesSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustom("Confidence Comparison", "confidence_comparison.png"),
          ResponsiveSizedBox(height: 16),
          _buildCustom("Agreement Matrix", "agreement_matrix.png"),
          ResponsiveSizedBox(height: 16),
          _buildCustom("Multi Model Comparison", "multi_model_comparison.png"),
        ],
      ),
    );
  }


 Widget _buildCustom(String name, String imageKey) {
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ResponsiveText(
          name,
          style: StyleConstants.customStyle(
            20,
            Colors.black,
            FontWeight.w500,
          ),
        ),
        Row(
          children: [
            // 👁 VIEW
            InkWell(
              onTap: () => _viewImage(imageKey),
              child: Image.asset(
                IconAssetConstants.eyeIcon,
                width: 24,
                height: 24,
              ),
            ),
            ResponsiveSizedBox(width: 16),

            // ⬇️ DOWNLOAD
            InkWell(
              onTap: () => _downloadImage(imageKey),
              child: Image.asset(
                IconAssetConstants.downloadIcon,
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  void _viewImage(String imageKey) {
  final base64Str = widget.data['images'][imageKey];
  final Uint8List bytes = base64Decode(base64Str);

  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: InteractiveViewer(
        child: Image.memory(bytes, fit: BoxFit.contain),
      ),
    ),
  );
}

Future<void> _downloadImage(String imageKey) async {
  final base64Str = widget.data['images'][imageKey];
  final Uint8List bytes = base64Decode(base64Str);

  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/$imageKey");
  await file.writeAsBytes(bytes);

  // ✅ Save to gallery (optional)
  await GallerySaver.saveImage(file.path);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Downloaded $imageKey")),
  );
}


}
