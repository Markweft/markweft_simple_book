///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$app$en app = Translations$app$en.internal(_root);
	late final Translations$welcome$en welcome = Translations$welcome$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$editor$en editor = Translations$editor$en.internal(_root);
	late final Translations$toolbar$en toolbar = Translations$toolbar$en.internal(_root);
	late final Translations$bookSettings$en bookSettings = Translations$bookSettings$en.internal(_root);
	late final Translations$history$en history = Translations$history$en.internal(_root);
	late final Translations$dialogs$en dialogs = Translations$dialogs$en.internal(_root);
}

// Path: app
class Translations$app$en {
	Translations$app$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Markweft'
	String get name => 'Markweft';

	/// en: 'App settings'
	String get settings => 'App settings';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Restore'
	String get restore => 'Restore';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Saving...'
	String get saving => 'Saving...';

	/// en: 'Saved'
	String get saved => 'Saved';

	/// en: 'Save failed'
	String get saveFailed => 'Save failed';

	/// en: 'System'
	String get system => 'System';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';

	/// en: 'English'
	String get english => 'English';

	/// en: 'Arabic'
	String get arabic => 'Arabic';

	/// en: 'French'
	String get french => 'French';

	/// en: 'German'
	String get german => 'German';
}

// Path: welcome
class Translations$welcome$en {
	Translations$welcome$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Local-first'
	String get localFirst => 'Local-first';

	/// en: 'Markdown publishing workspace'
	String get workspaceBadge => 'Markdown publishing workspace';

	/// en: 'Write once. Publish beautifully.'
	String get heroTitle => 'Write once.\nPublish beautifully.';

	/// en: 'Build long-form books with chapters, version history, PDF layouts and reflowable EPUB output.'
	String get heroDescription => 'Build long-form books with chapters, version history, PDF layouts and reflowable EPUB output.';

	/// en: 'New book'
	String get newBook => 'New book';

	/// en: 'Open book'
	String get openBook => 'Open book';

	/// en: 'Create book'
	String get createBook => 'Create book';

	/// en: 'Start a new structured .mdw project.'
	String get createBookDescription => 'Start a new structured .mdw project.';

	/// en: 'Open project'
	String get openProject => 'Open project';

	/// en: 'Continue an existing Markweft book.'
	String get openProjectDescription => 'Continue an existing Markweft book.';

	/// en: 'Import Markdown'
	String get importMarkdown => 'Import Markdown';

	/// en: 'Convert a Markdown manuscript into a book.'
	String get importMarkdownDescription => 'Convert a Markdown manuscript into a book.';

	/// en: 'Convert version'
	String get convertVersion => 'Convert version';

	/// en: 'Create a compatibility copy in another MDW format version.'
	String get convertVersionDescription => 'Create a compatibility copy in another MDW format version.';

	/// en: 'Convert book version'
	String get convertDialogTitle => 'Convert book version';

	/// en: 'A new .mdw copy will be created. The source book is never modified. Version 1 is the original single-Markdown format. Version 3 is the current chapter-based format.'
	String get convertDialogBody => 'A new .mdw copy will be created. The source book is never modified. Version 1 is the original single-Markdown format. Version 3 is the current chapter-based format.';

	/// en: 'Convert to v1'
	String get convertToV1 => 'Convert to v1';

	/// en: 'Convert to v3'
	String get convertToV3 => 'Convert to v3';

	/// en: 'Converted book saved to {path}'
	String get convertedSaved => 'Converted book saved to {path}';

	/// en: 'Unable to convert the book: {error}'
	String get convertFailed => 'Unable to convert the book: {error}';

	/// en: 'Recent books'
	String get recentBooks => 'Recent books';

	/// en: '{count} projects'
	String get projects => '{count} projects';

	/// en: 'Your recent books will appear here.'
	String get noRecentBooks => 'Your recent books will appear here.';

	/// en: 'Open book'
	String get openRecent => 'Open book';

	/// en: 'Remove from recent books'
	String get removeRecent => 'Remove from recent books';

	/// en: 'This recent book was saved by an older Markweft version. Use Open book once and select it again so macOS can save persistent access.'
	String get oldBookmark => 'This recent book was saved by an older Markweft version. Use Open book once and select it again so macOS can save persistent access.';

	/// en: 'Unable to restore macOS permission for this book. Open it once with Open book to refresh access. ({error})'
	String get bookmarkRestoreFailed => 'Unable to restore macOS permission for this book. Open it once with Open book to refresh access. ({error})';

	/// en: 'Unable to open the book: {error}'
	String get openFailed => 'Unable to open the book: {error}';
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App settings'
	String get title => 'App settings';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Choose how Markweft looks on this device.'
	String get appearanceDescription => 'Choose how Markweft looks on this device.';

	/// en: 'Theme mode'
	String get themeMode => 'Theme mode';

	/// en: 'Follow the system or use a fixed appearance.'
	String get themeModeDescription => 'Follow the system or use a fixed appearance.';

	/// en: 'Language & region'
	String get languageRegion => 'Language & region';

	/// en: 'Set the application interface language.'
	String get languageRegionDescription => 'Set the application interface language.';

	/// en: 'App language'
	String get appLanguage => 'App language';

	/// en: 'System uses the language selected in macOS.'
	String get appLanguageDescription => 'System uses the language selected in macOS.';

	/// en: 'Privacy & workspace'
	String get privacyWorkspace => 'Privacy & workspace';

	/// en: 'Control what is shown on the welcome screen.'
	String get privacyWorkspaceDescription => 'Control what is shown on the welcome screen.';

	/// en: 'Show recent book paths'
	String get showRecentPaths => 'Show recent book paths';

	/// en: 'Display full local file paths in Recent books.'
	String get showRecentPathsDescription => 'Display full local file paths in Recent books.';

	/// en: 'Safety'
	String get safety => 'Safety';

	/// en: 'Protect destructive actions while editing books.'
	String get safetyDescription => 'Protect destructive actions while editing books.';

	/// en: 'Confirm destructive actions'
	String get confirmDestructive => 'Confirm destructive actions';

	/// en: 'Ask before deleting chapters or history versions.'
	String get confirmDestructiveDescription => 'Ask before deleting chapters or history versions.';

	/// en: 'Book-specific page, typography and publication settings remain inside each .mdw book.'
	String get bookSettingsNote => 'Book-specific page, typography and publication settings remain inside each .mdw book.';
}

// Path: editor
class Translations$editor$en {
	Translations$editor$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Markdown'
	String get markdown => 'Markdown';

	/// en: 'Book'
	String get book => 'Book';

	/// en: 'Book settings'
	String get bookSettings => 'Book settings';

	/// en: 'Page, language, typography'
	String get bookSettingsSubtitle => 'Page, language, typography';

	/// en: 'Version history'
	String get versionHistory => 'Version history';

	/// en: 'Recovery, checkpoints, restore'
	String get versionHistorySubtitle => 'Recovery, checkpoints, restore';

	/// en: 'Chapters'
	String get chapters => 'Chapters';

	/// en: 'Add chapter'
	String get addChapter => 'Add chapter';

	/// en: 'Rename chapter'
	String get renameChapter => 'Rename chapter';

	/// en: 'Rename'
	String get rename => 'Rename';

	/// en: 'Delete chapter'
	String get deleteChapter => 'Delete chapter';

	/// en: 'Delete chapter?'
	String get deleteChapterQuestion => 'Delete chapter?';

	/// en: 'Delete “{title}” and its Markdown file? A history checkpoint will be created first.'
	String get deleteChapterDescription => 'Delete “{title}” and its Markdown file? A history checkpoint will be created first.';

	/// en: 'A book must contain at least one chapter.'
	String get atLeastOneChapter => 'A book must contain at least one chapter.';

	/// en: 'Move up'
	String get moveUp => 'Move up';

	/// en: 'Move down'
	String get moveDown => 'Move down';

	/// en: 'Export'
	String get export => 'Export';

	/// en: 'Export book'
	String get exportBook => 'Export book';

	/// en: 'Export PDF'
	String get exportPdf => 'Export PDF';

	/// en: 'Export EPUB'
	String get exportEpub => 'Export EPUB';

	/// en: '{format} exported to {path}'
	String get exported => '{format} exported to {path}';

	/// en: 'Unable to export {format}: {error}'
	String get exportFailed => 'Unable to export {format}: {error}';

	/// en: 'PDF'
	String get pdf => 'PDF';

	/// en: 'EPUB'
	String get epub => 'EPUB';

	/// en: 'Chapter'
	String get chapter => 'Chapter';

	/// en: 'Chapter {current}/{total}'
	String get chapterIndex => 'Chapter {current}/{total}';

	/// en: 'Chapter {number}'
	String get chapterNumber => 'Chapter {number}';

	/// en: 'Chapter One'
	String get chapterOne => 'Chapter One';

	/// en: 'Loading chapter'
	String get loadingChapter => 'Loading chapter';

	/// en: 'Close book'
	String get closeBook => 'Close book';

	/// en: 'Save now'
	String get saveNow => 'Save now';

	/// en: 'Full book'
	String get fullBook => 'Full book';

	/// en: 'Refresh full-book preview'
	String get refreshFullBook => 'Refresh full-book preview';

	/// en: 'Live preview paused for this large chapter'
	String get largePreviewPaused => 'Live preview paused for this large chapter';

	/// en: 'Render preview once'
	String get renderOnce => 'Render preview once';

	/// en: 'Unable to load full-book preview.'
	String get fullBookLoadFailed => 'Unable to load full-book preview.';

	/// en: 'EPUB · reflowable preview'
	String get epubReflowablePreview => 'EPUB · reflowable preview';

	/// en: '{count} characters'
	String get characters => '{count} characters';

	/// en: 'Editing and autosave stay active; preview parsing is paused to keep the UI responsive.'
	String get previewPausedDetails => 'Editing and autosave stay active; preview parsing is paused to keep the UI responsive.';

	/// en: 'Only this chapter is loaded into the editor.'
	String get chapterOnlyLoaded => 'Only this chapter is loaded into the editor.';

	/// en: 'Write this chapter in Markdown...'
	String get writeChapterHint => 'Write this chapter in Markdown...';

	/// en: 'Markdown · {title}'
	String get markdownChapter => 'Markdown · {title}';

	/// en: 'Unable to load this book: {error}'
	String get loadBookFailed => 'Unable to load this book: {error}';

	/// en: 'Unable to save this chapter: {error}'
	String get saveChapterFailed => 'Unable to save this chapter: {error}';

	/// en: 'Chapter saved locally, but .mdw update failed: {error}'
	String get mdwFlushFailed => 'Chapter saved locally, but .mdw update failed: {error}';

	/// en: 'Unable to open chapter: {error}'
	String get openChapterFailed => 'Unable to open chapter: {error}';

	/// en: 'Unable to save book settings: {error}'
	String get saveSettingsFailed => 'Unable to save book settings: {error}';

	/// en: 'Automatic recovery checkpoint'
	String get automaticRecoveryCheckpoint => 'Automatic recovery checkpoint';

	/// en: 'Before deleting {title}'
	String get beforeDeleting => 'Before deleting {title}';

	/// en: 'Before changing book settings'
	String get beforeChangingSettings => 'Before changing book settings';
}

// Path: toolbar
class Translations$toolbar$en {
	Translations$toolbar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Heading 1'
	String get heading1 => 'Heading 1';

	/// en: 'Heading 2'
	String get heading2 => 'Heading 2';

	/// en: 'Bold'
	String get bold => 'Bold';

	/// en: 'Italic'
	String get italic => 'Italic';

	/// en: 'Bullet list'
	String get bulletList => 'Bullet list';

	/// en: 'Numbered list'
	String get numberedList => 'Numbered list';

	/// en: 'Quote'
	String get quote => 'Quote';

	/// en: 'Link'
	String get link => 'Link';

	/// en: 'Image'
	String get image => 'Image';

	/// en: 'Table'
	String get table => 'Table';

	/// en: 'Code block'
	String get codeBlock => 'Code block';

	/// en: 'Divider'
	String get divider => 'Divider';

	/// en: 'New page'
	String get newPage => 'New page';

	/// en: 'New page with settings'
	String get newPageSettings => 'New page with settings';

	/// en: 'Heading'
	String get heading => 'Heading';

	/// en: 'bold text'
	String get boldText => 'bold text';

	/// en: 'italic text'
	String get italicText => 'italic text';

	/// en: 'Item one'
	String get itemOne => 'Item one';

	/// en: 'Item two'
	String get itemTwo => 'Item two';

	/// en: 'First item'
	String get firstItem => 'First item';

	/// en: 'Second item'
	String get secondItem => 'Second item';

	/// en: 'Quote'
	String get quoteText => 'Quote';

	/// en: 'Link text'
	String get linkText => 'Link text';

	/// en: 'Image description'
	String get imageDescription => 'Image description';
}

// Path: bookSettings
class Translations$bookSettings$en {
	Translations$bookSettings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Book settings'
	String get title => 'Book settings';

	/// en: 'Document'
	String get document => 'Document';

	/// en: 'Template'
	String get template => 'Template';

	/// en: 'Page size'
	String get pageSize => 'Page size';

	/// en: 'Orientation'
	String get orientation => 'Orientation';

	/// en: 'Portrait'
	String get portrait => 'Portrait';

	/// en: 'Landscape'
	String get landscape => 'Landscape';

	/// en: 'Margin'
	String get margin => 'Margin';

	/// en: 'Page margin'
	String get pageMargin => 'Page margin';

	/// en: 'Content padding'
	String get contentPadding => 'Content padding';

	/// en: 'Default columns'
	String get columns => 'Default columns';

	/// en: 'Available column counts are defined by the selected template.'
	String get columnsHelper => 'Available column counts are defined by the selected template.';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Language & direction'
	String get languageDirection => 'Language & direction';

	/// en: 'Book language'
	String get bookLanguage => 'Book language';

	/// en: 'Direction'
	String get direction => 'Direction';

	/// en: 'Left to right (LTR)'
	String get ltr => 'Left to right (LTR)';

	/// en: 'Right to left (RTL)'
	String get rtl => 'Right to left (RTL)';

	/// en: 'Typography'
	String get typography => 'Typography';

	/// en: 'Font family'
	String get fontFamily => 'Font family';

	/// en: 'System default'
	String get systemDefault => 'System default';

	/// en: 'Serif'
	String get serif => 'Serif';

	/// en: 'Sans serif'
	String get sansSerif => 'Sans serif';

	/// en: 'Monospace'
	String get monospace => 'Monospace';

	/// en: 'Font size'
	String get fontSize => 'Font size';

	/// en: 'Weight'
	String get fontWeight => 'Weight';

	/// en: 'Line height'
	String get lineHeight => 'Line height';

	/// en: 'Alignment'
	String get alignment => 'Alignment';

	/// en: 'Start'
	String get start => 'Start';

	/// en: 'Left'
	String get left => 'Left';

	/// en: 'Center'
	String get center => 'Center';

	/// en: 'Right'
	String get right => 'Right';

	/// en: 'Justify'
	String get justify => 'Justify';

	/// en: 'Template behavior'
	String get templateBehavior => 'Template behavior';

	/// en: 'Chapter opening pages use the template-specific {layout} layout by default.'
	String get chapterOpeningLayout => 'Chapter opening pages use the template-specific {layout} layout by default.';
}

// Path: history
class Translations$history$en {
	Translations$history$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Version history'
	String get title => 'Version history';

	/// en: 'Create version'
	String get createVersion => 'Create version';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Before rewriting chapter 4'
	String get descriptionHint => 'Before rewriting chapter 4';

	/// en: 'Manual version'
	String get manualVersion => 'Manual version';

	/// en: 'Manual'
	String get manual => 'Manual';

	/// en: 'Automatic recovery'
	String get automaticRecovery => 'Automatic recovery';

	/// en: 'Recovery'
	String get recovery => 'Recovery';

	/// en: 'Before delete'
	String get beforeDelete => 'Before delete';

	/// en: 'Before restore'
	String get beforeRestore => 'Before restore';

	/// en: 'Settings changed'
	String get settingsChanged => 'Settings changed';

	/// en: 'Restore version'
	String get restoreVersion => 'Restore version';

	/// en: 'Restore this version?'
	String get restoreQuestion => 'Restore this version?';

	/// en: 'The current book state will be saved automatically before restoring {date}.'
	String get restoreDescription => 'The current book state will be saved automatically before restoring {date}.';

	/// en: 'Delete version'
	String get deleteVersion => 'Delete version';

	/// en: 'Delete manual version?'
	String get deleteManualQuestion => 'Delete manual version?';

	/// en: 'This removes the checkpoint from the history list.'
	String get deleteManualDescription => 'This removes the checkpoint from the history list.';

	/// en: 'No versions yet. Create a manual version or keep editing; recovery checkpoints are created automatically.'
	String get empty => 'No versions yet. Create a manual version or keep editing; recovery checkpoints are created automatically.';

	/// en: '{count} chapters'
	String get chaptersCount => '{count} chapters';

	/// en: '{date} · {chapters} · {reason}'
	String get metadata => '{date} · {chapters} · {reason}';
}

// Path: dialogs
class Translations$dialogs$en {
	Translations$dialogs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create new book'
	String get createNewBook => 'Create new book';

	/// en: 'Import Markdown book'
	String get importMarkdownBook => 'Import Markdown book';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Import'
	String get import => 'Import';

	/// en: 'Chapter title'
	String get chapterTitle => 'Chapter title';

	/// en: 'Version message'
	String get versionMessage => 'Version message';

	/// en: 'Book title'
	String get bookTitle => 'Book title';

	/// en: 'My new book'
	String get bookTitleHint => 'My new book';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Markweft',
			'app.settings' => 'App settings',
			'app.done' => 'Done',
			'app.save' => 'Save',
			'app.cancel' => 'Cancel',
			'app.close' => 'Close',
			'app.delete' => 'Delete',
			'app.restore' => 'Restore',
			'app.refresh' => 'Refresh',
			'app.retry' => 'Retry',
			'app.loading' => 'Loading...',
			'app.saving' => 'Saving...',
			'app.saved' => 'Saved',
			'app.saveFailed' => 'Save failed',
			'app.system' => 'System',
			'app.light' => 'Light',
			'app.dark' => 'Dark',
			'app.english' => 'English',
			'app.arabic' => 'Arabic',
			'app.french' => 'French',
			'app.german' => 'German',
			'welcome.localFirst' => 'Local-first',
			'welcome.workspaceBadge' => 'Markdown publishing workspace',
			'welcome.heroTitle' => 'Write once.\nPublish beautifully.',
			'welcome.heroDescription' => 'Build long-form books with chapters, version history, PDF layouts and reflowable EPUB output.',
			'welcome.newBook' => 'New book',
			'welcome.openBook' => 'Open book',
			'welcome.createBook' => 'Create book',
			'welcome.createBookDescription' => 'Start a new structured .mdw project.',
			'welcome.openProject' => 'Open project',
			'welcome.openProjectDescription' => 'Continue an existing Markweft book.',
			'welcome.importMarkdown' => 'Import Markdown',
			'welcome.importMarkdownDescription' => 'Convert a Markdown manuscript into a book.',
			'welcome.convertVersion' => 'Convert version',
			'welcome.convertVersionDescription' => 'Create a compatibility copy in another MDW format version.',
			'welcome.convertDialogTitle' => 'Convert book version',
			'welcome.convertDialogBody' => 'A new .mdw copy will be created. The source book is never modified. Version 1 is the original single-Markdown format. Version 3 is the current chapter-based format.',
			'welcome.convertToV1' => 'Convert to v1',
			'welcome.convertToV3' => 'Convert to v3',
			'welcome.convertedSaved' => 'Converted book saved to {path}',
			'welcome.convertFailed' => 'Unable to convert the book: {error}',
			'welcome.recentBooks' => 'Recent books',
			'welcome.projects' => '{count} projects',
			'welcome.noRecentBooks' => 'Your recent books will appear here.',
			'welcome.openRecent' => 'Open book',
			'welcome.removeRecent' => 'Remove from recent books',
			'welcome.oldBookmark' => 'This recent book was saved by an older Markweft version. Use Open book once and select it again so macOS can save persistent access.',
			'welcome.bookmarkRestoreFailed' => 'Unable to restore macOS permission for this book. Open it once with Open book to refresh access. ({error})',
			'welcome.openFailed' => 'Unable to open the book: {error}',
			'settings.title' => 'App settings',
			'settings.appearance' => 'Appearance',
			'settings.appearanceDescription' => 'Choose how Markweft looks on this device.',
			'settings.themeMode' => 'Theme mode',
			'settings.themeModeDescription' => 'Follow the system or use a fixed appearance.',
			'settings.languageRegion' => 'Language & region',
			'settings.languageRegionDescription' => 'Set the application interface language.',
			'settings.appLanguage' => 'App language',
			'settings.appLanguageDescription' => 'System uses the language selected in macOS.',
			'settings.privacyWorkspace' => 'Privacy & workspace',
			'settings.privacyWorkspaceDescription' => 'Control what is shown on the welcome screen.',
			'settings.showRecentPaths' => 'Show recent book paths',
			'settings.showRecentPathsDescription' => 'Display full local file paths in Recent books.',
			'settings.safety' => 'Safety',
			'settings.safetyDescription' => 'Protect destructive actions while editing books.',
			'settings.confirmDestructive' => 'Confirm destructive actions',
			'settings.confirmDestructiveDescription' => 'Ask before deleting chapters or history versions.',
			'settings.bookSettingsNote' => 'Book-specific page, typography and publication settings remain inside each .mdw book.',
			'editor.edit' => 'Edit',
			'editor.preview' => 'Preview',
			'editor.markdown' => 'Markdown',
			'editor.book' => 'Book',
			'editor.bookSettings' => 'Book settings',
			'editor.bookSettingsSubtitle' => 'Page, language, typography',
			'editor.versionHistory' => 'Version history',
			'editor.versionHistorySubtitle' => 'Recovery, checkpoints, restore',
			'editor.chapters' => 'Chapters',
			'editor.addChapter' => 'Add chapter',
			'editor.renameChapter' => 'Rename chapter',
			'editor.rename' => 'Rename',
			'editor.deleteChapter' => 'Delete chapter',
			'editor.deleteChapterQuestion' => 'Delete chapter?',
			'editor.deleteChapterDescription' => 'Delete “{title}” and its Markdown file? A history checkpoint will be created first.',
			'editor.atLeastOneChapter' => 'A book must contain at least one chapter.',
			'editor.moveUp' => 'Move up',
			'editor.moveDown' => 'Move down',
			'editor.export' => 'Export',
			'editor.exportBook' => 'Export book',
			'editor.exportPdf' => 'Export PDF',
			'editor.exportEpub' => 'Export EPUB',
			'editor.exported' => '{format} exported to {path}',
			'editor.exportFailed' => 'Unable to export {format}: {error}',
			'editor.pdf' => 'PDF',
			'editor.epub' => 'EPUB',
			'editor.chapter' => 'Chapter',
			'editor.chapterIndex' => 'Chapter {current}/{total}',
			'editor.chapterNumber' => 'Chapter {number}',
			'editor.chapterOne' => 'Chapter One',
			'editor.loadingChapter' => 'Loading chapter',
			'editor.closeBook' => 'Close book',
			'editor.saveNow' => 'Save now',
			'editor.fullBook' => 'Full book',
			'editor.refreshFullBook' => 'Refresh full-book preview',
			'editor.largePreviewPaused' => 'Live preview paused for this large chapter',
			'editor.renderOnce' => 'Render preview once',
			'editor.fullBookLoadFailed' => 'Unable to load full-book preview.',
			'editor.epubReflowablePreview' => 'EPUB · reflowable preview',
			'editor.characters' => '{count} characters',
			'editor.previewPausedDetails' => 'Editing and autosave stay active; preview parsing is paused to keep the UI responsive.',
			'editor.chapterOnlyLoaded' => 'Only this chapter is loaded into the editor.',
			'editor.writeChapterHint' => 'Write this chapter in Markdown...',
			'editor.markdownChapter' => 'Markdown · {title}',
			'editor.loadBookFailed' => 'Unable to load this book: {error}',
			'editor.saveChapterFailed' => 'Unable to save this chapter: {error}',
			'editor.mdwFlushFailed' => 'Chapter saved locally, but .mdw update failed: {error}',
			'editor.openChapterFailed' => 'Unable to open chapter: {error}',
			'editor.saveSettingsFailed' => 'Unable to save book settings: {error}',
			'editor.automaticRecoveryCheckpoint' => 'Automatic recovery checkpoint',
			'editor.beforeDeleting' => 'Before deleting {title}',
			'editor.beforeChangingSettings' => 'Before changing book settings',
			'toolbar.heading1' => 'Heading 1',
			'toolbar.heading2' => 'Heading 2',
			'toolbar.bold' => 'Bold',
			'toolbar.italic' => 'Italic',
			'toolbar.bulletList' => 'Bullet list',
			'toolbar.numberedList' => 'Numbered list',
			'toolbar.quote' => 'Quote',
			'toolbar.link' => 'Link',
			'toolbar.image' => 'Image',
			'toolbar.table' => 'Table',
			'toolbar.codeBlock' => 'Code block',
			'toolbar.divider' => 'Divider',
			'toolbar.newPage' => 'New page',
			'toolbar.newPageSettings' => 'New page with settings',
			'toolbar.heading' => 'Heading',
			'toolbar.boldText' => 'bold text',
			'toolbar.italicText' => 'italic text',
			'toolbar.itemOne' => 'Item one',
			'toolbar.itemTwo' => 'Item two',
			'toolbar.firstItem' => 'First item',
			'toolbar.secondItem' => 'Second item',
			'toolbar.quoteText' => 'Quote',
			'toolbar.linkText' => 'Link text',
			'toolbar.imageDescription' => 'Image description',
			'bookSettings.title' => 'Book settings',
			'bookSettings.document' => 'Document',
			'bookSettings.template' => 'Template',
			'bookSettings.pageSize' => 'Page size',
			'bookSettings.orientation' => 'Orientation',
			'bookSettings.portrait' => 'Portrait',
			'bookSettings.landscape' => 'Landscape',
			'bookSettings.margin' => 'Margin',
			'bookSettings.pageMargin' => 'Page margin',
			'bookSettings.contentPadding' => 'Content padding',
			'bookSettings.columns' => 'Default columns',
			'bookSettings.columnsHelper' => 'Available column counts are defined by the selected template.',
			'bookSettings.language' => 'Language',
			'bookSettings.languageDirection' => 'Language & direction',
			'bookSettings.bookLanguage' => 'Book language',
			'bookSettings.direction' => 'Direction',
			'bookSettings.ltr' => 'Left to right (LTR)',
			'bookSettings.rtl' => 'Right to left (RTL)',
			'bookSettings.typography' => 'Typography',
			'bookSettings.fontFamily' => 'Font family',
			'bookSettings.systemDefault' => 'System default',
			'bookSettings.serif' => 'Serif',
			'bookSettings.sansSerif' => 'Sans serif',
			'bookSettings.monospace' => 'Monospace',
			'bookSettings.fontSize' => 'Font size',
			'bookSettings.fontWeight' => 'Weight',
			'bookSettings.lineHeight' => 'Line height',
			'bookSettings.alignment' => 'Alignment',
			'bookSettings.start' => 'Start',
			'bookSettings.left' => 'Left',
			'bookSettings.center' => 'Center',
			'bookSettings.right' => 'Right',
			'bookSettings.justify' => 'Justify',
			'bookSettings.templateBehavior' => 'Template behavior',
			'bookSettings.chapterOpeningLayout' => 'Chapter opening pages use the template-specific {layout} layout by default.',
			'history.title' => 'Version history',
			'history.createVersion' => 'Create version',
			'history.description' => 'Description',
			'history.descriptionHint' => 'Before rewriting chapter 4',
			'history.manualVersion' => 'Manual version',
			'history.manual' => 'Manual',
			'history.automaticRecovery' => 'Automatic recovery',
			'history.recovery' => 'Recovery',
			'history.beforeDelete' => 'Before delete',
			'history.beforeRestore' => 'Before restore',
			'history.settingsChanged' => 'Settings changed',
			'history.restoreVersion' => 'Restore version',
			'history.restoreQuestion' => 'Restore this version?',
			'history.restoreDescription' => 'The current book state will be saved automatically before restoring {date}.',
			'history.deleteVersion' => 'Delete version',
			'history.deleteManualQuestion' => 'Delete manual version?',
			'history.deleteManualDescription' => 'This removes the checkpoint from the history list.',
			'history.empty' => 'No versions yet. Create a manual version or keep editing; recovery checkpoints are created automatically.',
			'history.chaptersCount' => '{count} chapters',
			'history.metadata' => '{date} · {chapters} · {reason}',
			'dialogs.createNewBook' => 'Create new book',
			'dialogs.importMarkdownBook' => 'Import Markdown book',
			'dialogs.create' => 'Create',
			'dialogs.import' => 'Import',
			'dialogs.chapterTitle' => 'Chapter title',
			'dialogs.versionMessage' => 'Version message',
			'dialogs.bookTitle' => 'Book title',
			'dialogs.bookTitleHint' => 'My new book',
			_ => null,
		};
	}
}
