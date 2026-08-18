import 'dart:io';

final class MarkweftProject {
  const MarkweftProject({
    required this.file,
    required this.workspace,
    required this.title,
  });

  final File file;
  final Directory workspace;
  final String title;

  File get markdownFile => File(
        '${workspace.path}${Platform.pathSeparator}content'
        '${Platform.pathSeparator}book.md',
      );

  Directory get chaptersDirectory => Directory(
        '${workspace.path}${Platform.pathSeparator}content'
        '${Platform.pathSeparator}chapters',
      );

  File get chaptersIndexFile => File(
        '${chaptersDirectory.path}${Platform.pathSeparator}index.json',
      );

  File chapterFile(String fileName) => File(
        '${chaptersDirectory.path}${Platform.pathSeparator}$fileName',
      );

  File get settingsFile => File(
        '${workspace.path}${Platform.pathSeparator}settings.json',
      );

  Directory get assetsDirectory => Directory(
        '${workspace.path}${Platform.pathSeparator}assets',
      );

  Directory get imagesDirectory => Directory(
        '${assetsDirectory.path}${Platform.pathSeparator}images',
      );

  Directory get filesDirectory => Directory(
        '${workspace.path}${Platform.pathSeparator}files',
      );
}
