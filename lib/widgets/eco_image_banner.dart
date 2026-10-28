import 'package:flutter/material.dart';

class EcoImageBanner extends StatelessWidget {
  final String imageAsset;
  final String label;
  final double maxImageWidth;
  final bool showCaption;

  const EcoImageBanner({
    super.key,
    required this.imageAsset,
    required this.label,
    this.maxImageWidth = 460,
    this.showCaption = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxImageWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xFFF1F5F2)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 2,
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    semanticLabel: label,
                  ),
                ),
                if (showCaption)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF263238),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
