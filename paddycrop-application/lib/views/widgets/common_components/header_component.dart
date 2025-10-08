import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/views/widgets/custom_widgets/language_selector_widget.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';

class HeaderComponent extends StatelessWidget {
  final bool isStartingScreen;
  final bool canChangeLanguage;
  const HeaderComponent({
    super.key,
    this.isStartingScreen = false,
    this.canChangeLanguage = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 366,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isStartingScreen) _buildArrowClose(context),
          if (canChangeLanguage) LanguageSelector(),
        ],
      ),
    );
  }

  Widget _buildArrowClose(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pop();
      },
      child: CircleAvatar(
        radius: 20,
        // ignore: deprecated_member_use
        backgroundColor: Colors.black.withOpacity(0.2),
        child: Image.asset(
          IconAssetConstants.lesserThanIcon,
          width: 14,
          height: 14,
        ),
      ),
    );
  }
}
