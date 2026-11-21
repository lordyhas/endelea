import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Shares and opens files through the platform (`endelea/files` channel,
/// implemented in `MainActivity.kt` and `AppDelegate.swift`).
class FilesBridge {
  const FilesBridge();

  static const _channel = MethodChannel('endelea/files');

  /// Writes [content] to a temporary file and opens the share sheet.
  Future<void> shareText({
    required String fileName,
    required String content,
    String mimeType = 'application/json',
    String? title,
  }) async {
    final directory = Directory(
      '${(await getTemporaryDirectory()).path}/exports',
    );
    await directory.create(recursive: true);
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    await _channel.invokeMethod<void>('shareFile', {
      'path': file.path,
      'mimeType': mimeType,
      'title': title,
    });
  }

  /// Lets the user pick a document; returns its text, or null if cancelled.
  Future<String?> openText() => _channel.invokeMethod<String>('openDocument');
}
