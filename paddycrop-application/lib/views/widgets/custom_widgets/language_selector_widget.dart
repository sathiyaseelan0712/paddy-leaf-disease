import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final List<String> _languages = ["English", "Tamil"];

  final Map<String, String> _languageLabels = {
    "English": "lang_eng",
    "Tamil": "lang_ta",
  };

  String _selectedLanguage = "English";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync dropdown with current locale
    final currentLocale = context.locale.languageCode;
    setState(() {
      _selectedLanguage = currentLocale == "ta" ? "Tamil" : "English";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(IconAssetConstants.languageChange, width: 24, height: 24),
        const ResponsiveSizedBox(width: 4),
        DropdownButton<String>(
          value: _selectedLanguage,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down, size: 32),
          dropdownColor: StyleConstants.lightGreenColor,
          items: _languages.map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: ResponsiveText(
                _languageLabels[language] ?? language,
                style: StyleConstants.customStyle(
                  16,
                  Colors.black,
                  FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLanguage = newValue;
              });

              if (newValue == "English") {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('ta'));
              }
            }
          },
        ),
      ],
    );
  }
}
