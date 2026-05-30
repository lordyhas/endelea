/// A place in the cloud where backup files can be kept.
abstract class CloudSyncProvider {
  Future<void> signIn();
  Future<void> upload(String fileName, List<int> bytes);

  /// Returns null when there is no file named [fileName].
  Future<List<int>?> download(String fileName);
  Future<List<String>> listFiles();
}
