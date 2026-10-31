import 'package:flutter/widgets.dart';

/// A two-layer duotone glyph.
///
/// [IconData] is a `final class` in recent Flutter versions, so the duotone
/// variant holds both layers instead of extending it.
@immutable
class PhosphorDuotoneIconData {
  const PhosphorDuotoneIconData(this.primary, this.secondary);

  final IconData primary;
  final IconData secondary;
}
