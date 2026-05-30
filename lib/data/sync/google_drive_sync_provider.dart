import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'auth_headers_client.dart';
import 'cloud_sync_provider.dart';

/// Keeps backup files in the hidden app folder of the user's Google Drive.
///
/// The app only sees its own files there, and they do not show up in the
/// user's Drive.
class GoogleDriveSyncProvider extends CloudSyncProvider {
  static const _scopes = [drive.DriveApi.driveAppdataScope];
  static const _folder = 'appDataFolder';

  final GoogleSignIn _signIn = GoogleSignIn.instance;
  bool _initialized = false;
  GoogleSignInAccount? _user;

  @override
  String get name => 'Google Drive';

  @override
  String? get account => _user?.email;

  Future<void> _initialize() async {
    if (_initialized) return;
    await _signIn.initialize();
    _initialized = true;
  }

  @override
  Future<void> signIn() async {
    await _initialize();
    _user =
        await _signIn.attemptLightweightAuthentication() ??
        await _signIn.authenticate(scopeHint: _scopes);
  }

  @override
  Future<void> signOut() async {
    await _initialize();
    await _signIn.signOut();
    _user = null;
  }

  Future<drive.DriveApi> _api() async {
    final user = _user;
    if (user == null) throw StateError('Not signed in');
    final headers = await user.authorizationClient.authorizationHeaders(
      _scopes,
      promptIfNecessary: true,
    );
    return drive.DriveApi(AuthHeadersClient(headers!));
  }

  Future<List<drive.File>> _files(drive.DriveApi api, {String? name}) async {
    final list = await api.files.list(
      spaces: _folder,
      q: name == null ? null : "name = '$name'",
      $fields: 'files(id, name)',
    );
    return list.files ?? [];
  }

  @override
  Future<void> upload(String fileName, List<int> bytes) async {
    final api = await _api();
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: 'application/json',
    );
    final existing = await _files(api, name: fileName);
    if (existing.isEmpty) {
      await api.files.create(
        drive.File()
          ..name = fileName
          ..parents = [_folder],
        uploadMedia: media,
      );
    } else {
      await api.files.update(
        drive.File(),
        existing.first.id!,
        uploadMedia: media,
      );
    }
  }

  @override
  Future<List<int>?> download(String fileName) async {
    final api = await _api();
    final existing = await _files(api, name: fileName);
    if (existing.isEmpty) return null;
    final media = await api.files.get(
      existing.first.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final bytes = <int>[];
    await media.stream.forEach(bytes.addAll);
    return bytes;
  }

  @override
  Future<List<String>> listFiles() async {
    final api = await _api();
    return [for (final file in await _files(api)) ?file.name];
  }
}
