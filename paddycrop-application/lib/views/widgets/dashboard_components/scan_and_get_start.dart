import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class ScanImageComponents extends StatelessWidget {
  const ScanImageComponents({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 320,
      height: 320,
      child: Center(child: Image.asset(ImageAssetConstants.scanImage)),
    );
  }
}

class GetStartButton extends StatefulWidget {
  const GetStartButton({super.key});

  @override
  State<GetStartButton> createState() => _GetStartButtonState();
}

class _GetStartButtonState extends State<GetStartButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(RouteConstants.homeScreen);
        },
        onHover: (hovering) {
          setState(() {
            _hovered = hovering;
          });
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fade + scale animation for text
              AnimatedScale(
                scale: _hovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: _hovered ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 300),
                  child: ResponsiveText(
                    'starting.get_start',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Sansation',
                      color: Colors.black,
                      height: 1.21,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Slide animation for arrow icon
              AnimatedSlide(
                offset: _hovered ? const Offset(0.2, 0) : Offset.zero,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Image.asset(
                  IconAssetConstants.greaterhanIcon,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
