import 'package:endelea/sync/cloud_sync_provider.dart';

/// An in-memory cloud folder shared by several fake devices.
class FakeCloud {
  final files = <String, ({String name, List<int> bytes})>{};
  var _nextId = 0;

  String newId() => 'file-${_nextId++}';
}

class FakeCloudProvider extends CloudSyncProvider {
  FakeCloudProvider(this.cloud, {this.email = 'user@example.com'});

  final FakeCloud cloud;
  final String email;
  bool signedIn = true;
  bool failNext = false;

  @override
  String get id => 'fake';

  void _maybeFail() {
    if (failNext) {
      failNext = false;
      throw Exception('network');
    }
  }

  @override
  Future<CloudAccount?> currentAccount() async =>
      signedIn ? CloudAccount(email: email) : null;

  @override
  Future<CloudAccount> signIn() async {
    signedIn = true;
    return CloudAccount(email: email);
  }

  @override
  Future<void> signOut() async => signedIn = false;

  @override
  Future<List<CloudFile>> listFiles({String? prefix}) async {
    _maybeFail();
    return [
      for (final MapEntry(key: id, value: file) in cloud.files.entries)
        if (prefix == null || file.name.startsWith(prefix))
          CloudFile(id: id, name: file.name),
    ];
  }

  @override
  Future<List<int>> download(String fileId) async {
    _maybeFail();
    return cloud.files[fileId]!.bytes;
  }

  @override
  Future<CloudFile> upload(
    String name,
    List<int> bytes, {
    String? existingFileId,
  }) async {
    _maybeFail();
    final id = existingFileId ?? cloud.newId();
    cloud.files[id] = (name: name, bytes: bytes);
    return CloudFile(id: id, name: name);
  }

  @override
  Future<void> delete(String fileId) async => cloud.files.remove(fileId);
}
