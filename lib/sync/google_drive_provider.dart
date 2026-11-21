import 'package:endelea/sync/cloud_sync_provider.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// Not authorized for the Drive scope any more: sign in again.
class CloudAuthorizationRequired implements Exception {
  const CloudAuthorizationRequired();
}

/// Google Drive, in the hidden `appDataFolder` (PLAN.md §9.6).
///
/// Only the `drive.appdata` scope is requested: the app sees nothing else of
/// the user's Drive.
///
/// Needs a Google Cloud project with the Drive API enabled and OAuth clients
/// (Android with the app's SHA-1, and a Web client whose id is passed as
/// [serverClientId], e.g. `--dart-define=GOOGLE_SERVER_CLIENT_ID=…`).
class GoogleDriveProvider extends CloudSyncProvider {
  GoogleDriveProvider({this.serverClientId});

  final String? serverClientId;

  static const String scope = drive.DriveApi.driveAppdataScope;
  static const _space = 'appDataFolder';

  final GoogleSignIn _signIn = GoogleSignIn.instance;
  Future<void>? _initialized;
  GoogleSignInAccount? _account;

  @override
  String get id => 'google_drive';

  Future<void> _init() => _initialized ??= _signIn.initialize(
    serverClientId: serverClientId == null || serverClientId!.isEmpty
        ? null
        : serverClientId,
  );

  CloudAccount _toAccount(GoogleSignInAccount account) =>
      CloudAccount(email: account.email, displayName: account.displayName);

  @override
  Future<CloudAccount?> currentAccount() async {
    await _init();
    _account ??= await _signIn.attemptLightweightAuthentication();
    final account = _account;
    return account == null ? null : _toAccount(account);
  }

  @override
  Future<CloudAccount> signIn() async {
    await _init();
    try {
      final account = await _signIn.authenticate(scopeHint: const [scope]);
      await account.authorizationClient.authorizeScopes(const [scope]);
      _account = account;
      return _toAccount(account);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const CloudSignInCancelled();
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _init();
    _account = null;
    // Revokes the Drive authorization as well.
    await _signIn.disconnect();
  }

  /// Runs [action] with an authorized Drive client.
  Future<T> _withApi<T>(Future<T> Function(drive.DriveApi api) action) async {
    await _init();
    final client = _account?.authorizationClient ?? _signIn.authorizationClient;
    final authorization = await client.authorizationForScopes(const [scope]);
    if (authorization == null) throw const CloudAuthorizationRequired();
    final http = authorization.authClient(scopes: const [scope]);
    try {
      return await action(drive.DriveApi(http));
    } finally {
      http.close();
    }
  }

  @override
  Future<List<CloudFile>> listFiles({String? prefix}) {
    return _withApi((api) async {
      final files = <CloudFile>[];
      String? pageToken;
      do {
        final page = await api.files.list(
          spaces: _space,
          pageSize: 1000,
          pageToken: pageToken,
          $fields: 'nextPageToken, files(id, name)',
        );
        for (final file in page.files ?? const <drive.File>[]) {
          final id = file.id;
          final name = file.name;
          if (id == null || name == null) continue;
          if (prefix != null && !name.startsWith(prefix)) continue;
          files.add(CloudFile(id: id, name: name));
        }
        pageToken = page.nextPageToken;
      } while (pageToken != null);
      return files;
    });
  }

  @override
  Future<List<int>> download(String fileId) {
    return _withApi((api) async {
      final media = await api.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final bytes = <int>[];
      await media.stream.forEach(bytes.addAll);
      return bytes;
    });
  }

  @override
  Future<CloudFile> upload(
    String name,
    List<int> bytes, {
    String? existingFileId,
  }) {
    return _withApi((api) async {
      final media = drive.Media(Stream.value(bytes), bytes.length);
      final file = existingFileId == null
          ? await api.files.create(
              drive.File()
                ..name = name
                ..parents = const [_space],
              uploadMedia: media,
              $fields: 'id, name',
            )
          : await api.files.update(
              drive.File(),
              existingFileId,
              uploadMedia: media,
              $fields: 'id, name',
            );
      return CloudFile(id: file.id!, name: file.name ?? name);
    });
  }

  @override
  Future<void> delete(String fileId) =>
      _withApi((api) => api.files.delete(fileId));
}
