import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/widgets/custom_widgets/custom_button.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class TreatmentComponents extends StatefulWidget {
  final String name;
  const TreatmentComponents({super.key, required this.name});

  @override
  State<TreatmentComponents> createState() => TreatmentComponentsState();
}

class TreatmentComponentsState extends State<TreatmentComponents> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 414,
      height: 601,
      padding: [10, 10, 10, 20],  
      decoration: BoxDecoration(
        color: StyleConstants.treatmentBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(45.0),
          topRight: Radius.circular(45.0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResponsiveSizedBox(height: 4),
            _buildDiseaseName(),
            ResponsiveSizedBox(height: 16),
            _buildPrevention(),
            ResponsiveSizedBox(height: 16),
            _buildTreatment(),
            ResponsiveSizedBox(height: 16),
            CustomButton(
              bgColor: StyleConstants.lightGreenColor,
              text: 'happy_screen.scan_again',
              textColor: Colors.white,
              onPressed: () {
                context.pop();
                context.push(RouteConstants.cameraScreen);
              },
            ),
            ResponsiveSizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseName() {
    String diseaseName = widget.name;
    return ResponsiveContainer(
      height: 50,
      width: 366,
      child: Center(
        child: ResponsiveText(
          "diseases.$diseaseName.diseaseName",
          style: StyleConstants.customStyle(40, Colors.black, FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPrevention() {
    return ResponsiveContainer(
      width: 366,
      padding: [16, 10, 16, 10],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            "disease_screen.prevention_tips",
            style: StyleConstants.customStyle(
              20,
              Colors.black,
              FontWeight.bold,
            ),
          ),
          _buildSingleTextField("diseases.${widget.name}.prevention1"),
          _buildSingleTextField("diseases.${widget.name}.prevention2"),
          _buildSingleTextField("diseases.${widget.name}.prevention3"),
        ],
      ),
    );
  }

  Widget _buildTreatment() {
    return ResponsiveContainer(
      width: 366,
      padding: [16, 10, 16, 10],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            "disease_screen.treatment_tips",
            style: StyleConstants.customStyle(
              20,
              Colors.black,
              FontWeight.bold,
            ),
          ),
          _buildSingleTextField("diseases.${widget.name}.treatment1"),
          _buildSingleTextField("diseases.${widget.name}.treatment2"),
          _buildSingleTextField("diseases.${widget.name}.treatment3"),
        ],
      ),
    );
  }

  Widget _buildSingleTextField(String text) {
    return SizedBox(
      child: ResponsiveText(
        text,
        style: StyleConstants.customStyle(15, Colors.black, FontWeight.w400),
      ),
    );
  }
}
