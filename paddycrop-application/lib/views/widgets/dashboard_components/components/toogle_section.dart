import 'package:flutter/material.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/widgets/dashboard_components/components/description.dart';
import 'package:paddycrop/views/widgets/dashboard_components/components/images.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class ToggleSectionComponent extends StatefulWidget {
  final Map<String, dynamic> data;
  const ToggleSectionComponent({super.key, required this.data});

  @override
  State<ToggleSectionComponent> createState() => _ToggleSectionComponentState();
}

class _ToggleSectionComponentState extends State<ToggleSectionComponent> {
  String _currentLabel = "disease_screen.toggle_section_A";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveContainer(
          width: 366,
          height: 39,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              _buildToggleButton(
                "disease_screen.toggle_section_A",
                _currentLabel == "disease_screen.toggle_section_A",
                () {
                  setState(
                    () => _currentLabel = "disease_screen.toggle_section_A",
                  );
                },
              ),
              _buildToggleButton(
                "disease_screen.toggle_section_B",
                _currentLabel == "disease_screen.toggle_section_B",
                () {
                  setState(
                    () => _currentLabel = "disease_screen.toggle_section_B",
                  );
                },
              ),
            ],
          ),
        ),
        const ResponsiveSizedBox(height: 20),
        Expanded(
          child: _currentLabel == "disease_screen.toggle_section_A"
              ? DescriptionSection(data: widget.data)
              : ImagesSection(data: widget.data),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 39,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? StyleConstants.greenColor : Colors.white,
            borderRadius: BorderRadius.circular(99),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: StyleConstants.customStyle(
                20,
                isSelected ? Colors.white : const Color(0xFF6C6F74),
                FontWeight.w500,
              ),
              child: ResponsiveText(
                title,
                style: StyleConstants.customStyle(
                  20,
                  isSelected ? Colors.white : const Color(0xFF6C6F74),
                  FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
