import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/widgets/custom_widgets/custom_button.dart';
import 'package:paddycrop/views/widgets/dashboard_components/components/toogle_section.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class DiseaseComponents extends StatefulWidget {
  final String imagePath;
  final Map<String,dynamic> data;
  const DiseaseComponents({super.key, required this.imagePath, required this.data});

  @override
  State<DiseaseComponents> createState() => DiseaseComponentsState();
}

class DiseaseComponentsState extends State<DiseaseComponents> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 414,
      height: 601,
      decoration: BoxDecoration(
        color: StyleConstants.sadBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(45.0),
          topRight: Radius.circular(45.0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeaderForDisease(),
            ResponsiveSizedBox(height: 16),
            _buildDiseaseName(),
            ResponsiveSizedBox(height: 16),
            ResponsiveContainer(
              width: 366,
              height: 320,
              child: ToggleSectionComponent(data : widget.data),
            ),
            ResponsiveSizedBox(height: 16),
            CustomButton(
              bgColor: StyleConstants.treatmentBgColor,
              text: 'disease_screen.treatment',
              textColor: Colors.black,
              onPressed: () {
                context.push(RouteConstants.treatmentScreen, extra: {'imagePath': widget.imagePath, 'data': widget.data});
              },
              iconPath: IconAssetConstants.arrowRight,
            ),
            ResponsiveSizedBox(height: 16),
            CustomButton(
              bgColor: StyleConstants.lightGreenColor,
              text: 'disease_screen.scan_again',
              textColor: Colors.white,
              onPressed: () {
                context.pop();
                context.push(RouteConstants.cameraScreen);
              },
              iconPath: IconAssetConstants.scanIcon2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderForDisease() {
    return ResponsiveContainer(
      height: 38,
      width: 366,
      padding: [10, 10, 10, 10],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(IconAssetConstants.tickRed, width: 30, height: 30),
          ResponsiveSizedBox(height: 10),
          ResponsiveText(
            "disease_screen.header",
            style: StyleConstants.customStyle(
              16,
              StyleConstants.darkRed,
              FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseName() {
  String diseaseName = widget.data['disease'];

  return ResponsiveContainer(
    height: 40,
    width: 366,
    child: Center(
      child: ResponsiveText(
        "diseases.$diseaseName.diseaseName",
        style: StyleConstants.customStyle(
          24, Colors.black, FontWeight.w400,
        ),
      ),
    ),
  );
}

}
