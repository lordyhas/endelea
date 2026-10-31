# phosphor_flutter (vendored)

Copy of [phosphor_flutter](https://pub.dev/packages/phosphor_flutter) 2.1.0
(MIT, see `LICENSE`), the latest published version.

Why vendored: since `IconData` became a `final class` in Flutter, the published
package no longer compiles (`PhosphorIconData extends IconData`). This copy:

- declares each glyph as a plain `const IconData` (icon tree shaking still works);
- keeps only the Regular, Fill and Duotone styles used by Endelea (PLAN.md §6.4);
- replaces `PhosphorIcon` with `PhosphorDuotoneIcon` for the duotone layers.

Drop this folder and go back to the pub.dev package once upstream is fixed.
