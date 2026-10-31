/// Spaced order indexes (10, 20, 30…) let an item move without renumbering
/// the whole list (PLAN.md §4.2).
const orderStep = 10;

/// Index for an item appended after [last].
int nextOrderIndex(int? last) => (last ?? 0) + orderStep;

/// Moves the item at [oldIndex] to [newIndex] in a list whose current order
/// indexes are [indexes] (sorted ascending).
///
/// [newIndex] is the final position of the item. Returns the new order index
/// of every item whose index changes, keyed by position in the original list.
/// Usually only the moved item changes; when there is no gap left, the whole
/// list is renumbered.
Map<int, int> moveOrderIndex(List<int> indexes, int oldIndex, int newIndex) {
  if (oldIndex == newIndex) return const {};
  final positions = List<int>.generate(indexes.length, (i) => i)
    ..removeAt(oldIndex)
    ..insert(newIndex, oldIndex);
  final prev = newIndex > 0 ? indexes[positions[newIndex - 1]] : null;
  final next = newIndex < positions.length - 1
      ? indexes[positions[newIndex + 1]]
      : null;

  final int candidate;
  if (prev == null) {
    candidate = next! - orderStep;
  } else if (next == null) {
    candidate = prev + orderStep;
  } else {
    candidate = (prev + next) ~/ 2;
  }
  final fits =
      (prev == null || candidate > prev) && (next == null || candidate < next);
  if (fits) return {oldIndex: candidate};

  return {
    for (var i = 0; i < positions.length; i++)
      if (indexes[positions[i]] != (i + 1) * orderStep)
        positions[i]: (i + 1) * orderStep,
  };
}
