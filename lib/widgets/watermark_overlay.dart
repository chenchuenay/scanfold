import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Overlays a subtle ScanFold watermark so screenshots clearly identify the app.
class WatermarkOverlay extends StatelessWidget {
  const WatermarkOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Transform.rotate(
            angle: -0.25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: ScanFoldColors.background.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ScanFoldColors.mint.withValues(alpha: 0.35),
                ),
              ),
              child: const Text(
                'ScanFold',
                style: TextStyle(
                  color: ScanFoldColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
