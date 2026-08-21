import 'package:flutter_test/flutter_test.dart';
import 'package:markweft_simple_book/features/book_editor/data/services/editor_workspace_state_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const store = EditorWorkspaceStateStore();
  const projectPath = '/tmp/markweft-test-book.mdw';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists workspace layout per project', () async {
    const state = EditorWorkspaceState(
      sidebarVisible: false,
      previewVisible: true,
      sidebarWidth: 340,
      previewWidth: 610,
      workspaceMode: 'edit',
      openChapterIds: <String>['chapter-1', 'chapter-2'],
      activeChapterId: 'chapter-2',
    );

    await store.save(projectPath, state);
    final restored = await store.load(projectPath);

    expect(restored, isNotNull);
    expect(restored!.sidebarVisible, isFalse);
    expect(restored.previewVisible, isTrue);
    expect(restored.sidebarWidth, 340);
    expect(restored.previewWidth, 610);
    expect(restored.workspaceMode, 'edit');
    expect(restored.openChapterIds, <String>['chapter-1', 'chapter-2']);
    expect(restored.activeChapterId, 'chapter-2');
  });

  test('keeps different books isolated', () async {
    await store.save(
      '/tmp/book-a.mdw',
      const EditorWorkspaceState(sidebarWidth: 260),
    );
    await store.save(
      '/tmp/book-b.mdw',
      const EditorWorkspaceState(sidebarWidth: 480),
    );

    expect((await store.load('/tmp/book-a.mdw'))!.sidebarWidth, 260);
    expect((await store.load('/tmp/book-b.mdw'))!.sidebarWidth, 480);
  });

  test('clear removes only the selected project workspace', () async {
    await store.save(projectPath, const EditorWorkspaceState());
    await store.clear(projectPath);

    expect(await store.load(projectPath), isNull);
  });
}
