import 'dart:async';

import 'package:drift/drift.dart';

extension WatchComposite on GeneratedDatabase {
  /// Emits [load] now and again after every change to [tables].
  ///
  /// Used for composite read models (joins of several tables). Loads run one
  /// after the other, so results arrive in order. (An `async*` generator
  /// would never finish cancelling while it waits for the next update.)
  Stream<T> watchComposite<T>(
    Iterable<ResultSetImplementation<dynamic, dynamic>> tables,
    Future<T> Function() load,
  ) {
    StreamSubscription<void>? updates;
    late final StreamController<void> triggers;
    triggers = StreamController<void>(
      onListen: () {
        triggers.add(null);
        updates = tableUpdates(TableUpdateQuery.onAllTables(tables))
            .listen(triggers.add);
      },
      onCancel: () => updates?.cancel(),
    );
    return triggers.stream.asyncMap((_) => load());
  }
}
