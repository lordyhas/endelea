import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/src/phosphor_icon_data.dart';

/// Renders a [PhosphorDuotoneIconData]: the secondary layer is drawn
/// translucent under the primary one.
class PhosphorDuotoneIcon extends StatelessWidget {
  const PhosphorDuotoneIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.secondaryColor,
    this.secondaryOpacity = 0.20,
    this.semanticLabel,
  });

  final PhosphorDuotoneIconData icon;
  final double? size;
  final Color? color;
  final Color? secondaryColor;
  final double secondaryOpacity;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: secondaryOpacity,
          child: Icon(
            icon.secondary,
            size: size,
            color: secondaryColor ?? color,
          ),
        ),
        Icon(
          icon.primary,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
        ),
      ],
    );
  }
}
