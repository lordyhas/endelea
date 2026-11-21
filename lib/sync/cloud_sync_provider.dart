import 'package:equatable/equatable.dart';

/// The signed-in cloud account.
class CloudAccount extends Equatable {
  const CloudAccount({required this.email, this.displayName});

  final String email;
  final String? displayName;

  @override
  List<Object?> get props => [email, displayName];
}

/// A file in the app's private cloud folder.
class CloudFile extends Equatable {
  const CloudFile({required this.id, required this.name});

  final String id;

  /// Path-like name, e.g. `endelea/changes/<deviceId>/<epochMillis>.json.gz`.
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Thrown when the user cancels the sign-in.
class CloudSignInCancelled implements Exception {
  const CloudSignInCancelled();
}

/// The user's own cloud storage (PLAN.md §9.1): Google Drive first,
/// OneDrive later behind the same interface.
abstract class CloudSyncProvider {
  const CloudSyncProvider();

  /// `google_drive`, `onedrive`.
  String get id;

  /// The account signed in without user interaction, or null.
  Future<CloudAccount?> currentAccount();

  /// Interactive sign-in. Throws [CloudSignInCancelled] when cancelled.
  Future<CloudAccount> signIn();

  Future<void> signOut();

  /// Files whose name starts with [prefix] (all files when null).
  Future<List<CloudFile>> listFiles({String? prefix});

  Future<List<int>> download(String fileId);

  /// Creates a file, or replaces [existingFileId].
  Future<CloudFile> upload(
    String name,
    List<int> bytes, {
    String? existingFileId,
  });

  Future<void> delete(String fileId);
}

/// No cloud available (tests, platforms without Google Sign-In): signing in
/// fails, nothing is ever synced.
class NoCloudProvider extends CloudSyncProvider {
  const NoCloudProvider();

  @override
  String get id => 'none';

  @override
  Future<CloudAccount?> currentAccount() async => null;

  @override
  Future<CloudAccount> signIn() =>
      Future.error(UnsupportedError('No cloud provider'));

  @override
  Future<void> signOut() async {}

  @override
  Future<List<CloudFile>> listFiles({String? prefix}) async => const [];

  @override
  Future<List<int>> download(String fileId) =>
      Future.error(UnsupportedError('No cloud provider'));

  @override
  Future<CloudFile> upload(
    String name,
    List<int> bytes, {
    String? existingFileId,
  }) => Future.error(UnsupportedError('No cloud provider'));

  @override
  Future<void> delete(String fileId) async {}
}
