import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../theme/app_theme.dart';

class AspectPreset {
  final CropAspectRatio ratio;
  final String label;
  final String reference;

  const AspectPreset({
    required this.ratio,
    required this.label,
    required this.reference,
  });
}

/// Common aspect-ratio presets with real-world usage references.
const resizePresets = [
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 1, ratioY: 1),
    label: 'Square · 1:1',
    reference: 'WhatsApp & Instagram profile, avatars',
  ),
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 4, ratioY: 5),
    label: 'Portrait · 4:5',
    reference: 'Instagram portrait post',
  ),
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 4, ratioY: 3),
    label: 'Classic · 4:3',
    reference: 'Standard camera photo',
  ),
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 3, ratioY: 2),
    label: 'Print · 3:2',
    reference: 'Classic 6×4 photo print',
  ),
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 16, ratioY: 9),
    label: 'Wide · 16:9',
    reference: 'YouTube thumbnail, IG landscape',
  ),
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 9, ratioY: 16),
    label: 'Story · 9:16',
    reference: 'IG story, WhatsApp status',
  ),
];

const passportPresets = [
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 35, ratioY: 45),
    label: '35×45 mm',
    reference: 'Passport (EU, India)',
  ),
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 1, ratioY: 1),
    label: '2×2 inch',
    reference: 'US passport & visa',
  ),
  AspectPreset(
    ratio: CropAspectRatio(ratioX: 33, ratioY: 48),
    label: '33×48 mm',
    reference: 'Schengen visa',
  ),
];

/// Selectable list of aspect-ratio presets shown before upload so users know
/// their intended output exists. Renders label + usage reference.
class AspectPresetPicker extends StatelessWidget {
  final List<AspectPreset> presets;
  final AspectPreset selected;
  final ValueChanged<AspectPreset> onSelected;

  const AspectPresetPicker({
    super.key,
    required this.presets,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: presets
          .map(
            (preset) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: preset == selected
                        ? ScanFoldColors.mint
                        : ScanFoldColors.border,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelected(preset),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          preset == selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: preset == selected
                              ? ScanFoldColors.mint
                              : ScanFoldColors.muted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                preset.reference,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ScanFoldColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
