import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

final class EditorWorkspaceState {
  const EditorWorkspaceState({
    this.sidebarVisible = true,
    this.previewVisible = true,
    this.sidebarWidth = 286,
    this.previewWidth = 520,
    this.workspaceMode = 'edit',
    this.openChapterIds = const <String>[],
    this.activeChapterId,
  });

  final bool sidebarVisible;
  final bool previewVisible;
  final double sidebarWidth;
  final double previewWidth;
  final String workspaceMode;
  final List<String> openChapterIds;
  final String? activeChapterId;

  factory EditorWorkspaceState.fromJson(Map<String, dynamic> json) {
    final rawOpenChapterIds = json['openChapterIds'];

    return EditorWorkspaceState(
      sidebarVisible: json['sidebarVisible'] as bool? ?? true,
      previewVisible: json['previewVisible'] as bool? ?? true,
      sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 286,
      previewWidth: (json['previewWidth'] as num?)?.toDouble() ?? 520,
      workspaceMode: json['workspaceMode']?.toString() ?? 'edit',
      openChapterIds: rawOpenChapterIds is List
          ? rawOpenChapterIds
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList(growable: false)
          : const <String>[],
      activeChapterId: json['activeChapterId']?.toString(),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'version': 1,
        'sidebarVisible': sidebarVisible,
        'previewVisible': previewVisible,
        'sidebarWidth': sidebarWidth,
        'previewWidth': previewWidth,
        'workspaceMode': workspaceMode,
        'openChapterIds': openChapterIds,
        if (activeChapterId != null) 'activeChapterId': activeChapterId,
      };
}

final class EditorWorkspaceStateStore {
  const EditorWorkspaceStateStore();

  static const String _keyPrefix = 'markweft_editor_workspace_v1:';

  Future<EditorWorkspaceState?> load(String projectPath) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_keyFor(projectPath));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return EditorWorkspaceState.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> save(
    String projectPath,
    EditorWorkspaceState state,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _keyFor(projectPath),
      jsonEncode(state.toJson()),
    );
  }

  Future<void> clear(String projectPath) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_keyFor(projectPath));
  }

  String _keyFor(String projectPath) {
    final encodedPath = base64Url.encode(utf8.encode(projectPath));
    return '$_keyPrefix$encodedPath';
  }
}
