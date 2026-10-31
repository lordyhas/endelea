import 'package:drift/drift.dart';

extension WatchComposite on GeneratedDatabase {
  /// Emits [load] now and again after every change to [tables].
  ///
  /// Used for composite read models (joins of several tables).
  Stream<T> watchComposite<T>(
    Iterable<ResultSetImplementation<dynamic, dynamic>> tables,
    Future<T> Function() load,
  ) async* {
    yield await load();
    await for (final _ in tableUpdates(TableUpdateQuery.onAllTables(tables))) {
      yield await load();
    }
  }
}
