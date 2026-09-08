import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

final class MacosSecurityScopedBookmarkService {
  const MacosSecurityScopedBookmarkService();

  static const MethodChannel _channel = MethodChannel(
    'markweft/security_scoped_bookmarks',
  );

  Future<String?> createBookmark(String filePath) async {
    if (!Platform.isMacOS) {
      return null;
    }

    final bytes = await _channel.invokeMethod<Uint8List>(
      'createBookmark',
      <String, Object?>{'path': filePath},
    );

    return bytes == null ? null : base64Encode(bytes);
  }

  Future<String> resolveBookmark(String bookmark) async {
    if (!Platform.isMacOS) {
      throw UnsupportedError('Security-scoped bookmarks are macOS-only.');
    }

    final bytes = base64Decode(bookmark);
    final path = await _channel.invokeMethod<String>(
      'resolveBookmark',
      <String, Object?>{'bookmark': Uint8List.fromList(bytes)},
    );

    if (path == null || path.isEmpty) {
      throw const FileSystemException(
        'Unable to resolve the saved macOS file permission.',
      );
    }

    return path;
  }

  Future<void> stopAccessing(String filePath) async {
    if (!Platform.isMacOS) {
      return;
    }

    await _channel.invokeMethod<void>(
      'stopAccessing',
      <String, Object?>{'path': filePath},
    );
  }
}
