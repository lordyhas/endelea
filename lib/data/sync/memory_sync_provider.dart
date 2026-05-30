import 'cloud_sync_provider.dart';

/// Keeps files in memory, used by tests and when no cloud is available.
class MemorySyncProvider extends CloudSyncProvider {
  MemorySyncProvider({this.accountName = 'demo@endelea.app'});

  final String accountName;
  final Map<String, List<int>> files = {};
  String? _account;

  @override
  String get name => 'Memory';

  @override
  String? get account => _account;

  @override
  Future<void> signIn() async => _account = accountName;

  @override
  Future<void> signOut() async => _account = null;

  @override
  Future<void> upload(String fileName, List<int> bytes) async {
    _checkSignedIn();
    files[fileName] = List.of(bytes);
  }

  @override
  Future<List<int>?> download(String fileName) async {
    _checkSignedIn();
    return files[fileName];
  }

  @override
  Future<List<String>> listFiles() async {
    _checkSignedIn();
    return files.keys.toList();
  }

  void _checkSignedIn() {
    if (!isSignedIn) throw StateError('Not signed in');
  }
}
