///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

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
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$app$en app = Translations$app$en.internal(_root);
	late final Translations$bookSettings$en bookSettings = Translations$bookSettings$en.internal(_root);
	late final Translations$dialogs$en dialogs = Translations$dialogs$en.internal(_root);
	late final Translations$editor$en editor = Translations$editor$en.internal(_root);
	late final Translations$history$en history = Translations$history$en.internal(_root);
	late final Translations$language$en language = Translations$language$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$toolbar$en toolbar = Translations$toolbar$en.internal(_root);
	late final Translations$welcome$en welcome = Translations$welcome$en.internal(_root);
}

// Path: app
class Translations$app$en {
	Translations$app$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$app$identity$en identity = Translations$app$identity$en.internal(_root);
	late final Translations$app$actions$en actions = Translations$app$actions$en.internal(_root);
	late final Translations$app$status$en status = Translations$app$status$en.internal(_root);
	late final Translations$app$appearance$en appearance = Translations$app$appearance$en.internal(_root);

	/// en: 'Save'
	String get save => _root.app.actions.save;

	/// en: 'Cancel'
	String get cancel => _root.app.actions.cancel;

	/// en: 'Delete'
	String get delete => _root.app.actions.delete;

	/// en: 'Restore'
	String get restore => _root.app.actions.restore;

	/// en: 'Retry'
	String get retry => _root.app.actions.retry;

	/// en: 'Loading...'
	String get loading => _root.app.status.loading;

	/// en: 'Saving...'
	String get saving => _root.app.status.saving;

	/// en: 'Saved'
	String get saved => _root.app.status.saved;

	/// en: 'Save failed'
	String get saveFailed => _root.app.status.saveFailed;
}

// Path: bookSettings
class Translations$bookSettings$en {
	Translations$bookSettings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$bookSettings$page$en page = Translations$bookSettings$page$en.internal(_root);
	late final Translations$bookSettings$sections$en sections = Translations$bookSettings$sections$en.internal(_root);
}

// Path: dialogs
class Translations$dialogs$en {
	Translations$dialogs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$dialogs$bookTitle$en bookTitle = Translations$dialogs$bookTitle$en.internal(_root);
	late final Translations$dialogs$chapter$en chapter = Translations$dialogs$chapter$en.internal(_root);
	late final Translations$dialogs$version$en version = Translations$dialogs$version$en.internal(_root);

	/// en: 'Chapter title'
	String get chapterTitle => _root.dialogs.chapter.fieldLabel;
}

// Path: editor
class Translations$editor$en {
	Translations$editor$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$editor$workspace$en workspace = Translations$editor$workspace$en.internal(_root);
	late final Translations$editor$sidebar$en sidebar = Translations$editor$sidebar$en.internal(_root);
	late final Translations$editor$chapterManager$en chapterManager = Translations$editor$chapterManager$en.internal(_root);
	late final Translations$editor$previewPanel$en previewPanel = Translations$editor$previewPanel$en.internal(_root);
	late final Translations$editor$export$en export = Translations$editor$export$en.internal(_root);
	late final Translations$editor$save$en save = Translations$editor$save$en.internal(_root);

	/// en: 'Chapter One'
	String get chapterOne => _root.editor.chapterManager.defaultFirst;

	/// en: 'Unable to load this book: {error}'
	String loadBookFailed({required Object error}) => _root.editor.save.errors.loadBook(error: error);

	/// en: 'Automatic recovery checkpoint'
	String get automaticRecoveryCheckpoint => _root.editor.save.automaticRecovery;

	/// en: 'Unable to save this chapter: {error}'
	String saveChapterFailed({required Object error}) => _root.editor.save.errors.saveChapter(error: error);

	/// en: 'Chapter saved locally, but .mdw update failed: {error}'
	String mdwFlushFailed({required Object error}) => _root.editor.save.errors.flushProject(error: error);

	/// en: 'Unable to open chapter: {error}'
	String openChapterFailed({required Object error}) => _root.editor.save.errors.openChapter(error: error);

	/// en: 'Add chapter'
	String get addChapter => _root.editor.chapterManager.add;

	/// en: 'Rename chapter'
	String get renameChapter => _root.editor.chapterManager.renameTitle;

	/// en: 'A book must contain at least one chapter.'
	String get atLeastOneChapter => _root.editor.chapterManager.atLeastOne;

	/// en: 'Delete chapter?'
	String get deleteChapterQuestion => _root.editor.chapterManager.deleteQuestion;

	/// en: 'Delete “{title}” and its Markdown file? A history checkpoint will be created first.'
	String deleteChapterDescription({required Object title}) => _root.editor.chapterManager.deleteDescription(title: title);

	/// en: 'Before deleting {title}'
	String beforeDeleting({required Object title}) => _root.editor.save.beforeDeleting(title: title);

	/// en: 'Before changing book settings'
	String get beforeChangingSettings => _root.editor.save.beforeChangingSettings;

	/// en: 'Unable to save book settings: {error}'
	String saveSettingsFailed({required Object error}) => _root.editor.save.errors.saveSettings(error: error);

	/// en: 'PDF'
	String get pdf => _root.editor.previewPanel.format.pdf;

	/// en: 'EPUB'
	String get epub => _root.editor.previewPanel.format.epub;

	/// en: '{format} exported to {path}'
	String exported({required Object format, required Object path}) => _root.editor.export.success(format: format, path: path);

	/// en: 'Unable to export {format}: {error}'
	String exportFailed({required Object format, required Object error}) => _root.editor.export.failure(format: format, error: error);

	/// en: 'Close book'
	String get closeBook => _root.editor.sidebar.close;

	/// en: 'Loading chapter'
	String get loadingChapter => _root.editor.chapterManager.loading;

	/// en: 'Chapter {current}/{total}'
	String chapterIndex({required Object current, required Object total}) => _root.editor.chapterManager.index(current: current, total: total);

	/// en: 'Edit'
	String get edit => _root.editor.workspace.modes.edit;

	/// en: 'Preview'
	String get preview => _root.editor.workspace.modes.preview;

	/// en: 'Version history'
	String get versionHistory => _root.editor.sidebar.history.title;

	/// en: 'Book settings'
	String get bookSettings => _root.editor.sidebar.settings.title;

	/// en: 'Export book'
	String get exportBook => _root.editor.export.menu;

	/// en: 'Export PDF'
	String get exportPdf => _root.editor.export.pdf;

	/// en: 'Export EPUB'
	String get exportEpub => _root.editor.export.epub;

	/// en: 'Save now'
	String get saveNow => _root.editor.save.now;

	/// en: 'Book'
	String get book => _root.editor.sidebar.title;

	/// en: 'Page, language, typography'
	String get bookSettingsSubtitle => _root.editor.sidebar.settings.subtitle;

	/// en: 'Recovery, checkpoints, restore'
	String get versionHistorySubtitle => _root.editor.sidebar.history.subtitle;

	/// en: 'Chapters'
	String get chapters => _root.editor.chapterManager.title;

	/// en: 'Chapter {number}'
	String chapterNumber({required Object number}) => _root.editor.chapterManager.number(number: number);

	/// en: 'Rename'
	String get rename => _root.editor.chapterManager.rename;

	/// en: 'Move up'
	String get moveUp => _root.editor.chapterManager.moveUp;

	/// en: 'Move down'
	String get moveDown => _root.editor.chapterManager.moveDown;

	/// en: 'Markdown'
	String get markdown => _root.editor.workspace.markdown.title;

	/// en: 'Markdown · {title}'
	String markdownChapter({required Object title}) => _root.editor.workspace.markdown.chapterTitle(title: title);

	/// en: 'Only this chapter is loaded into the editor.'
	String get chapterOnlyLoaded => _root.editor.workspace.markdown.chapterOnlyLoaded;

	/// en: 'Write this chapter in Markdown...'
	String get writeChapterHint => _root.editor.workspace.markdown.writeHint;

	/// en: 'Live preview paused for this large chapter'
	String get largePreviewPaused => _root.editor.previewPanel.largeChapter.title;

	/// en: '{count} characters'
	String characters({required Object count}) => _root.editor.previewPanel.largeChapter.characters(count: count);

	/// en: 'Editing and autosave stay active; preview parsing is paused to keep the UI responsive.'
	String get previewPausedDetails => _root.editor.previewPanel.largeChapter.description;

	/// en: 'Render preview once'
	String get renderOnce => _root.editor.previewPanel.largeChapter.renderOnce;
}

// Path: history
class Translations$history$en {
	Translations$history$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$history$page$en page = Translations$history$page$en.internal(_root);
	late final Translations$history$create$en create = Translations$history$create$en.internal(_root);
	late final Translations$history$reasons$en reasons = Translations$history$reasons$en.internal(_root);
	late final Translations$history$restore$en restore = Translations$history$restore$en.internal(_root);
	late final Translations$history$delete$en delete = Translations$history$delete$en.internal(_root);
	late final Translations$history$metadata$en metadata = Translations$history$metadata$en.internal(_root);
}

// Path: language
class Translations$language$en {
	Translations$language$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$language$selector$en selector = Translations$language$selector$en.internal(_root);
	late final Translations$language$locales$en locales = Translations$language$locales$en.internal(_root);
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$page$en page = Translations$settings$page$en.internal(_root);
	late final Translations$settings$sections$en sections = Translations$settings$sections$en.internal(_root);

	/// en: 'Book-specific page, typography and publication settings remain inside each .mdw book.'
	String get bookSettingsNote => 'Book-specific page, typography and publication settings remain inside each .mdw book.';
}

// Path: toolbar
class Translations$toolbar$en {
	Translations$toolbar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$toolbar$headings$en headings = Translations$toolbar$headings$en.internal(_root);
	late final Translations$toolbar$formatting$en formatting = Translations$toolbar$formatting$en.internal(_root);
	late final Translations$toolbar$lists$en lists = Translations$toolbar$lists$en.internal(_root);
	late final Translations$toolbar$insert$en insert = Translations$toolbar$insert$en.internal(_root);
	late final Translations$toolbar$placeholders$en placeholders = Translations$toolbar$placeholders$en.internal(_root);
}

// Path: welcome
class Translations$welcome$en {
	Translations$welcome$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$welcome$topBar$en topBar = Translations$welcome$topBar$en.internal(_root);
	late final Translations$welcome$hero$en hero = Translations$welcome$hero$en.internal(_root);
	late final Translations$welcome$quickActions$en quickActions = Translations$welcome$quickActions$en.internal(_root);
	late final Translations$welcome$recent$en recent = Translations$welcome$recent$en.internal(_root);
	late final Translations$welcome$conversion$en conversion = Translations$welcome$conversion$en.internal(_root);
	late final Translations$welcome$errors$en errors = Translations$welcome$errors$en.internal(_root);
}

// Path: app.identity
class Translations$app$identity$en {
	Translations$app$identity$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Markweft'
	String get name => 'Markweft';
}

// Path: app.actions
class Translations$app$actions$en {
	Translations$app$actions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

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
}

// Path: app.status
class Translations$app$status$en {
	Translations$app$status$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Saving...'
	String get saving => 'Saving...';

	/// en: 'Saved'
	String get saved => 'Saved';

	/// en: 'Save failed'
	String get saveFailed => 'Save failed';
}

// Path: app.appearance
class Translations$app$appearance$en {
	Translations$app$appearance$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$app$appearance$themeMode$en themeMode = Translations$app$appearance$themeMode$en.internal(_root);
}

// Path: bookSettings.page
class Translations$bookSettings$page$en {
	Translations$bookSettings$page$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Book settings'
	String get title => 'Book settings';
}

// Path: bookSettings.sections
class Translations$bookSettings$sections$en {
	Translations$bookSettings$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$bookSettings$sections$document$en document = Translations$bookSettings$sections$document$en.internal(_root);
	late final Translations$bookSettings$sections$appearance$en appearance = Translations$bookSettings$sections$appearance$en.internal(_root);
	late final Translations$bookSettings$sections$language$en language = Translations$bookSettings$sections$language$en.internal(_root);
	late final Translations$bookSettings$sections$typography$en typography = Translations$bookSettings$sections$typography$en.internal(_root);
	late final Translations$bookSettings$sections$toc$en toc = Translations$bookSettings$sections$toc$en.internal(_root);
	late final Translations$bookSettings$sections$templateBehavior$en templateBehavior = Translations$bookSettings$sections$templateBehavior$en.internal(_root);
}

// Path: dialogs.bookTitle
class Translations$dialogs$bookTitle$en {
	Translations$dialogs$bookTitle$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$dialogs$bookTitle$create$en create = Translations$dialogs$bookTitle$create$en.internal(_root);
	late final Translations$dialogs$bookTitle$import$en import = Translations$dialogs$bookTitle$import$en.internal(_root);
	late final Translations$dialogs$bookTitle$field$en field = Translations$dialogs$bookTitle$field$en.internal(_root);
}

// Path: dialogs.chapter
class Translations$dialogs$chapter$en {
	Translations$dialogs$chapter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chapter title'
	String get fieldLabel => 'Chapter title';
}

// Path: dialogs.version
class Translations$dialogs$version$en {
	Translations$dialogs$version$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Version message'
	String get messageLabel => 'Version message';
}

// Path: editor.workspace
class Translations$editor$workspace$en {
	Translations$editor$workspace$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$editor$workspace$modes$en modes = Translations$editor$workspace$modes$en.internal(_root);
	late final Translations$editor$workspace$markdown$en markdown = Translations$editor$workspace$markdown$en.internal(_root);
}

// Path: editor.sidebar
class Translations$editor$sidebar$en {
	Translations$editor$sidebar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Book'
	String get title => 'Book';

	/// en: 'Close book'
	String get close => 'Close book';

	/// en: 'App settings'
	String get appSettings => 'App settings';

	late final Translations$editor$sidebar$settings$en settings = Translations$editor$sidebar$settings$en.internal(_root);
	late final Translations$editor$sidebar$history$en history = Translations$editor$sidebar$history$en.internal(_root);
}

// Path: editor.chapterManager
class Translations$editor$chapterManager$en {
	Translations$editor$chapterManager$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chapters'
	String get title => 'Chapters';

	/// en: 'Add chapter'
	String get add => 'Add chapter';

	/// en: 'Add subchapter'
	String get addChild => 'Add subchapter';

	/// en: 'Rename'
	String get rename => 'Rename';

	/// en: 'Rename chapter'
	String get renameTitle => 'Rename chapter';

	/// en: 'Delete chapter'
	String get delete => 'Delete chapter';

	/// en: 'Delete chapter?'
	String get deleteQuestion => 'Delete chapter?';

	/// en: 'Delete “{title}” and its Markdown file? A history checkpoint will be created first.'
	String deleteDescription({required Object title}) => 'Delete “${title}” and its Markdown file? A history checkpoint will be created first.';

	/// en: 'Delete “{title}” and all of its nested subchapters? A history checkpoint will be created first.'
	String deleteTreeDescription({required Object title}) => 'Delete “${title}” and all of its nested subchapters? A history checkpoint will be created first.';

	/// en: 'A book must contain at least one chapter.'
	String get atLeastOne => 'A book must contain at least one chapter.';

	/// en: 'Move up'
	String get moveUp => 'Move up';

	/// en: 'Move down'
	String get moveDown => 'Move down';

	/// en: 'Chapter {current}/{total}'
	String index({required Object current, required Object total}) => 'Chapter ${current}/${total}';

	/// en: 'Chapter {number}'
	String number({required Object number}) => 'Chapter ${number}';

	/// en: 'Chapter One'
	String get defaultFirst => 'Chapter One';

	/// en: 'Loading chapter'
	String get loading => 'Loading chapter';
}

// Path: editor.previewPanel
class Translations$editor$previewPanel$en {
	Translations$editor$previewPanel$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$editor$previewPanel$format$en format = Translations$editor$previewPanel$format$en.internal(_root);
	late final Translations$editor$previewPanel$scope$en scope = Translations$editor$previewPanel$scope$en.internal(_root);

	/// en: 'Refresh full-book preview'
	String get refreshFullBook => 'Refresh full-book preview';

	/// en: 'Unable to load full-book preview.'
	String get loadFullBookFailed => 'Unable to load full-book preview.';

	/// en: 'EPUB · reflowable preview'
	String get epubReflowable => 'EPUB · reflowable preview';

	late final Translations$editor$previewPanel$largeChapter$en largeChapter = Translations$editor$previewPanel$largeChapter$en.internal(_root);
}

// Path: editor.export
class Translations$editor$export$en {
	Translations$editor$export$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Export book'
	String get menu => 'Export book';

	/// en: 'Export PDF'
	String get pdf => 'Export PDF';

	/// en: 'Export EPUB'
	String get epub => 'Export EPUB';

	/// en: '{format} exported to {path}'
	String success({required Object format, required Object path}) => '${format} exported to ${path}';

	/// en: 'Unable to export {format}: {error}'
	String failure({required Object format, required Object error}) => 'Unable to export ${format}: ${error}';
}

// Path: editor.save
class Translations$editor$save$en {
	Translations$editor$save$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save now'
	String get now => 'Save now';

	/// en: 'Automatic recovery checkpoint'
	String get automaticRecovery => 'Automatic recovery checkpoint';

	/// en: 'Before deleting {title}'
	String beforeDeleting({required Object title}) => 'Before deleting ${title}';

	/// en: 'Before changing book settings'
	String get beforeChangingSettings => 'Before changing book settings';

	late final Translations$editor$save$errors$en errors = Translations$editor$save$errors$en.internal(_root);
}

// Path: history.page
class Translations$history$page$en {
	Translations$history$page$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Version history'
	String get title => 'Version history';

	/// en: 'No versions yet. Create a manual version or keep editing; recovery checkpoints are created automatically.'
	String get empty => 'No versions yet. Create a manual version or keep editing; recovery checkpoints are created automatically.';
}

// Path: history.create
class Translations$history$create$en {
	Translations$history$create$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create version'
	String get title => 'Create version';

	/// en: 'Description'
	String get descriptionLabel => 'Description';

	/// en: 'Before rewriting chapter 4'
	String get descriptionHint => 'Before rewriting chapter 4';

	/// en: 'Manual version'
	String get manualVersion => 'Manual version';
}

// Path: history.reasons
class Translations$history$reasons$en {
	Translations$history$reasons$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Manual'
	String get manual => 'Manual';

	/// en: 'Recovery'
	String get recovery => 'Recovery';

	/// en: 'Before delete'
	String get beforeDelete => 'Before delete';

	/// en: 'Before restore'
	String get beforeRestore => 'Before restore';

	/// en: 'Settings changed'
	String get settingsChanged => 'Settings changed';
}

// Path: history.restore
class Translations$history$restore$en {
	Translations$history$restore$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Restore this version?'
	String get question => 'Restore this version?';

	/// en: 'The current book state will be saved automatically before restoring {date}.'
	String description({required Object date}) => 'The current book state will be saved automatically before restoring ${date}.';

	/// en: 'Restore'
	String get action => 'Restore';
}

// Path: history.delete
class Translations$history$delete$en {
	Translations$history$delete$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete manual version?'
	String get question => 'Delete manual version?';

	/// en: 'This removes the checkpoint from the history list.'
	String get description => 'This removes the checkpoint from the history list.';

	/// en: 'Delete'
	String get action => 'Delete';
}

// Path: history.metadata
class Translations$history$metadata$en {
	Translations$history$metadata$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{count} chapters'
	String chapters({required Object count}) => '${count} chapters';

	/// en: '{date} · {chapters} · {reason}'
	String summary({required Object date, required Object chapters, required Object reason}) => '${date} · ${chapters} · ${reason}';
}

// Path: language.selector
class Translations$language$selector$en {
	Translations$language$selector$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language'
	String get title => 'Language';

	/// en: 'Choose the language used by the Markweft interface.'
	String get description => 'Choose the language used by the Markweft interface.';
}

// Path: language.locales
class Translations$language$locales$en {
	Translations$language$locales$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'System'
	String get system => 'System';

	/// en: 'English'
	String get en => 'English';

	/// en: 'Arabic'
	String get ar => 'Arabic';

	/// en: 'French'
	String get fr => 'French';

	/// en: 'German'
	String get de => 'German';
}

// Path: settings.page
class Translations$settings$page$en {
	Translations$settings$page$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App settings'
	String get title => 'App settings';
}

// Path: settings.sections
class Translations$settings$sections$en {
	Translations$settings$sections$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$sections$appearance$en appearance = Translations$settings$sections$appearance$en.internal(_root);
	late final Translations$settings$sections$language$en language = Translations$settings$sections$language$en.internal(_root);
	late final Translations$settings$sections$privacy$en privacy = Translations$settings$sections$privacy$en.internal(_root);
	late final Translations$settings$sections$safety$en safety = Translations$settings$sections$safety$en.internal(_root);
}

// Path: toolbar.headings
class Translations$toolbar$headings$en {
	Translations$toolbar$headings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Heading 1'
	String get h1 => 'Heading 1';

	/// en: 'Heading 2'
	String get h2 => 'Heading 2';

	/// en: 'Heading'
	String get placeholder => 'Heading';
}

// Path: toolbar.formatting
class Translations$toolbar$formatting$en {
	Translations$toolbar$formatting$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bold'
	String get bold => 'Bold';

	/// en: 'Italic'
	String get italic => 'Italic';

	/// en: 'Quote'
	String get quote => 'Quote';

	/// en: 'Divider'
	String get divider => 'Divider';

	/// en: 'Code block'
	String get codeBlock => 'Code block';
}

// Path: toolbar.lists
class Translations$toolbar$lists$en {
	Translations$toolbar$lists$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bullet list'
	String get bullet => 'Bullet list';

	/// en: 'Numbered list'
	String get numbered => 'Numbered list';

	/// en: 'Item one'
	String get itemOne => 'Item one';

	/// en: 'Item two'
	String get itemTwo => 'Item two';

	/// en: 'First item'
	String get firstItem => 'First item';

	/// en: 'Second item'
	String get secondItem => 'Second item';
}

// Path: toolbar.insert
class Translations$toolbar$insert$en {
	Translations$toolbar$insert$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Link'
	String get link => 'Link';

	/// en: 'Image'
	String get image => 'Image';

	/// en: 'Table'
	String get table => 'Table';

	/// en: 'New page'
	String get newPage => 'New page';

	/// en: 'New page with settings'
	String get newPageWithSettings => 'New page with settings';
}

// Path: toolbar.placeholders
class Translations$toolbar$placeholders$en {
	Translations$toolbar$placeholders$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'bold text'
	String get boldText => 'bold text';

	/// en: 'italic text'
	String get italicText => 'italic text';

	/// en: 'Quote'
	String get quoteText => 'Quote';

	/// en: 'Link text'
	String get linkText => 'Link text';

	/// en: 'Image description'
	String get imageDescription => 'Image description';
}

// Path: welcome.topBar
class Translations$welcome$topBar$en {
	Translations$welcome$topBar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Local-first'
	String get localFirst => 'Local-first';

	/// en: 'App settings'
	String get settingsTooltip => 'App settings';
}

// Path: welcome.hero
class Translations$welcome$hero$en {
	Translations$welcome$hero$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Markdown publishing workspace'
	String get badge => 'Markdown publishing workspace';

	/// en: 'Write once. Publish beautifully.'
	String get title => 'Write once.\nPublish beautifully.';

	/// en: 'Build long-form books with chapters, version history, PDF layouts and reflowable EPUB output.'
	String get description => 'Build long-form books with chapters, version history, PDF layouts and reflowable EPUB output.';

	late final Translations$welcome$hero$actions$en actions = Translations$welcome$hero$actions$en.internal(_root);
}

// Path: welcome.quickActions
class Translations$welcome$quickActions$en {
	Translations$welcome$quickActions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$welcome$quickActions$create$en create = Translations$welcome$quickActions$create$en.internal(_root);
	late final Translations$welcome$quickActions$open$en open = Translations$welcome$quickActions$open$en.internal(_root);
	late final Translations$welcome$quickActions$importMarkdown$en importMarkdown = Translations$welcome$quickActions$importMarkdown$en.internal(_root);
	late final Translations$welcome$quickActions$convertVersion$en convertVersion = Translations$welcome$quickActions$convertVersion$en.internal(_root);
}

// Path: welcome.recent
class Translations$welcome$recent$en {
	Translations$welcome$recent$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recent books'
	String get title => 'Recent books';

	/// en: '{count} projects'
	String count({required Object count}) => '${count} projects';

	/// en: 'Your recent books will appear here.'
	String get empty => 'Your recent books will appear here.';

	/// en: 'Open book'
	String get openTooltip => 'Open book';

	/// en: 'Remove from recent books'
	String get removeTooltip => 'Remove from recent books';

	/// en: 'MDW v{version}'
	String version({required Object version}) => 'MDW v${version}';

	/// en: 'Current'
	String get current => 'Current';

	/// en: 'Upgrade to v{version}'
	String upgrade({required Object version}) => 'Upgrade to v${version}';

	/// en: 'Version unavailable'
	String get unknownVersion => 'Version unavailable';
}

// Path: welcome.conversion
class Translations$welcome$conversion$en {
	Translations$welcome$conversion$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$welcome$conversion$dialog$en dialog = Translations$welcome$conversion$dialog$en.internal(_root);

	/// en: 'Converted book saved to {path}'
	String success({required Object path}) => 'Converted book saved to ${path}';

	/// en: 'Unable to convert the book: {error}'
	String failure({required Object error}) => 'Unable to convert the book: ${error}';
}

// Path: welcome.errors
class Translations$welcome$errors$en {
	Translations$welcome$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This recent book was saved by an older Markweft version. Use Open book once and select it again so macOS can save persistent access.'
	String get legacyBookmark => 'This recent book was saved by an older Markweft version. Use Open book once and select it again so macOS can save persistent access.';

	/// en: 'Unable to restore macOS permission for this book. Open it once with Open book to refresh access. ({error})'
	String bookmarkRestore({required Object error}) => 'Unable to restore macOS permission for this book. Open it once with Open book to refresh access. (${error})';

	/// en: 'Unable to open the book: {error}'
	String openBook({required Object error}) => 'Unable to open the book: ${error}';
}

// Path: app.appearance.themeMode
class Translations$app$appearance$themeMode$en {
	Translations$app$appearance$themeMode$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'System'
	String get system => 'System';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';
}

// Path: bookSettings.sections.document
class Translations$bookSettings$sections$document$en {
	Translations$bookSettings$sections$document$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Document'
	String get title => 'Document';

	/// en: 'Template'
	String get template => 'Template';

	/// en: 'Page size'
	String get pageSize => 'Page size';

	/// en: 'Orientation'
	String get orientation => 'Orientation';

	late final Translations$bookSettings$sections$document$orientationValues$en orientationValues = Translations$bookSettings$sections$document$orientationValues$en.internal(_root);

	/// en: 'Page margin'
	String get pageMargin => 'Page margin';

	/// en: 'Content padding'
	String get contentPadding => 'Content padding';

	late final Translations$bookSettings$sections$document$columns$en columns = Translations$bookSettings$sections$document$columns$en.internal(_root);

	/// en: 'Template output'
	String get platforms => 'Template output';

	/// en: 'PDF'
	String get pdf => 'PDF';

	/// en: 'EPUB'
	String get epub => 'EPUB';
}

// Path: bookSettings.sections.appearance
class Translations$bookSettings$sections$appearance$en {
	Translations$bookSettings$sections$appearance$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Publication appearance'
	String get title => 'Publication appearance';

	/// en: 'Book color mode'
	String get colorMode => 'Book color mode';

	/// en: 'Light pages'
	String get light => 'Light pages';

	/// en: 'Dark pages'
	String get dark => 'Dark pages';

	/// en: 'This controls the rendered book theme independently from the Markweft application theme.'
	String get description => 'This controls the rendered book theme independently from the Markweft application theme.';
}

// Path: bookSettings.sections.language
class Translations$bookSettings$sections$language$en {
	Translations$bookSettings$sections$language$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language & direction'
	String get title => 'Language & direction';

	/// en: 'Book language'
	String get bookLanguage => 'Book language';

	/// en: 'Direction'
	String get direction => 'Direction';

	late final Translations$bookSettings$sections$language$directionValues$en directionValues = Translations$bookSettings$sections$language$directionValues$en.internal(_root);
}

// Path: bookSettings.sections.typography
class Translations$bookSettings$sections$typography$en {
	Translations$bookSettings$sections$typography$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Typography'
	String get title => 'Typography';

	/// en: 'Font family'
	String get fontFamily => 'Font family';

	late final Translations$bookSettings$sections$typography$fontFamilies$en fontFamilies = Translations$bookSettings$sections$typography$fontFamilies$en.internal(_root);

	/// en: 'Font size'
	String get fontSize => 'Font size';

	/// en: 'Weight'
	String get fontWeight => 'Weight';

	/// en: 'Line height'
	String get lineHeight => 'Line height';

	/// en: 'Alignment'
	String get alignment => 'Alignment';

	late final Translations$bookSettings$sections$typography$alignmentValues$en alignmentValues = Translations$bookSettings$sections$typography$alignmentValues$en.internal(_root);
}

// Path: bookSettings.sections.toc
class Translations$bookSettings$sections$toc$en {
	Translations$bookSettings$sections$toc$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Table of contents'
	String get title => 'Table of contents';

	/// en: 'Add table of contents page'
	String get enabled => 'Add table of contents page';

	/// en: 'Page title'
	String get pageTitle => 'Page title';

	/// en: 'Maximum chapter depth'
	String get maxDepth => 'Maximum chapter depth';

	/// en: 'Start on a new page'
	String get startOnNewPage => 'Start on a new page';

	/// en: 'Include page numbers'
	String get pageNumbers => 'Include page numbers';

	/// en: 'Page numbers are reserved for a later pagination pass; EPUB always has native navigation.'
	String get pageNumbersHint => 'Page numbers are reserved for a later pagination pass; EPUB always has native navigation.';

	/// en: 'Preview TOC'
	String get preview => 'Preview TOC';
}

// Path: bookSettings.sections.templateBehavior
class Translations$bookSettings$sections$templateBehavior$en {
	Translations$bookSettings$sections$templateBehavior$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Template behavior'
	String get title => 'Template behavior';

	/// en: 'Chapter opening pages use the template-specific {layout} layout by default.'
	String chapterOpeningLayout({required Object layout}) => 'Chapter opening pages use the template-specific ${layout} layout by default.';
}

// Path: dialogs.bookTitle.create
class Translations$dialogs$bookTitle$create$en {
	Translations$dialogs$bookTitle$create$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create new book'
	String get title => 'Create new book';

	/// en: 'Create'
	String get action => 'Create';
}

// Path: dialogs.bookTitle.import
class Translations$dialogs$bookTitle$import$en {
	Translations$dialogs$bookTitle$import$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Import Markdown book'
	String get title => 'Import Markdown book';

	/// en: 'Import'
	String get action => 'Import';
}

// Path: dialogs.bookTitle.field
class Translations$dialogs$bookTitle$field$en {
	Translations$dialogs$bookTitle$field$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Book title'
	String get label => 'Book title';

	/// en: 'My new book'
	String get hint => 'My new book';
}

// Path: editor.workspace.modes
class Translations$editor$workspace$modes$en {
	Translations$editor$workspace$modes$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Preview'
	String get preview => 'Preview';
}

// Path: editor.workspace.markdown
class Translations$editor$workspace$markdown$en {
	Translations$editor$workspace$markdown$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Markdown'
	String get title => 'Markdown';

	/// en: 'Markdown · {title}'
	String chapterTitle({required Object title}) => 'Markdown · ${title}';

	/// en: 'Only this chapter is loaded into the editor.'
	String get chapterOnlyLoaded => 'Only this chapter is loaded into the editor.';

	/// en: 'Write this chapter in Markdown...'
	String get writeHint => 'Write this chapter in Markdown...';
}

// Path: editor.sidebar.settings
class Translations$editor$sidebar$settings$en {
	Translations$editor$sidebar$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Book settings'
	String get title => 'Book settings';

	/// en: 'Page, language, typography'
	String get subtitle => 'Page, language, typography';
}

// Path: editor.sidebar.history
class Translations$editor$sidebar$history$en {
	Translations$editor$sidebar$history$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Version history'
	String get title => 'Version history';

	/// en: 'Recovery, checkpoints, restore'
	String get subtitle => 'Recovery, checkpoints, restore';
}

// Path: editor.previewPanel.format
class Translations$editor$previewPanel$format$en {
	Translations$editor$previewPanel$format$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'PDF'
	String get pdf => 'PDF';

	/// en: 'EPUB'
	String get epub => 'EPUB';
}

// Path: editor.previewPanel.scope
class Translations$editor$previewPanel$scope$en {
	Translations$editor$previewPanel$scope$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chapter'
	String get chapter => 'Chapter';

	/// en: 'Full book'
	String get fullBook => 'Full book';
}

// Path: editor.previewPanel.largeChapter
class Translations$editor$previewPanel$largeChapter$en {
	Translations$editor$previewPanel$largeChapter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Live preview paused for this large chapter'
	String get title => 'Live preview paused for this large chapter';

	/// en: '{count} characters'
	String characters({required Object count}) => '${count} characters';

	/// en: 'Editing and autosave stay active; preview parsing is paused to keep the UI responsive.'
	String get description => 'Editing and autosave stay active; preview parsing is paused to keep the UI responsive.';

	/// en: 'Render preview once'
	String get renderOnce => 'Render preview once';
}

// Path: editor.save.errors
class Translations$editor$save$errors$en {
	Translations$editor$save$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unable to load this book: {error}'
	String loadBook({required Object error}) => 'Unable to load this book: ${error}';

	/// en: 'Unable to save this chapter: {error}'
	String saveChapter({required Object error}) => 'Unable to save this chapter: ${error}';

	/// en: 'Chapter saved locally, but .mdw update failed: {error}'
	String flushProject({required Object error}) => 'Chapter saved locally, but .mdw update failed: ${error}';

	/// en: 'Unable to open chapter: {error}'
	String openChapter({required Object error}) => 'Unable to open chapter: ${error}';

	/// en: 'Unable to save book settings: {error}'
	String saveSettings({required Object error}) => 'Unable to save book settings: ${error}';
}

// Path: settings.sections.appearance
class Translations$settings$sections$appearance$en {
	Translations$settings$sections$appearance$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Appearance'
	String get title => 'Appearance';

	/// en: 'Choose how Markweft looks on this device.'
	String get description => 'Choose how Markweft looks on this device.';

	late final Translations$settings$sections$appearance$themeMode$en themeMode = Translations$settings$sections$appearance$themeMode$en.internal(_root);
}

// Path: settings.sections.language
class Translations$settings$sections$language$en {
	Translations$settings$sections$language$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language & region'
	String get title => 'Language & region';

	/// en: 'Set the application interface language.'
	String get description => 'Set the application interface language.';

	late final Translations$settings$sections$language$appLanguage$en appLanguage = Translations$settings$sections$language$appLanguage$en.internal(_root);
}

// Path: settings.sections.privacy
class Translations$settings$sections$privacy$en {
	Translations$settings$sections$privacy$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Privacy & workspace'
	String get title => 'Privacy & workspace';

	/// en: 'Control what is shown on the welcome screen.'
	String get description => 'Control what is shown on the welcome screen.';

	late final Translations$settings$sections$privacy$recentPaths$en recentPaths = Translations$settings$sections$privacy$recentPaths$en.internal(_root);
}

// Path: settings.sections.safety
class Translations$settings$sections$safety$en {
	Translations$settings$sections$safety$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Safety'
	String get title => 'Safety';

	/// en: 'Protect destructive actions while editing books.'
	String get description => 'Protect destructive actions while editing books.';

	late final Translations$settings$sections$safety$confirmDestructive$en confirmDestructive = Translations$settings$sections$safety$confirmDestructive$en.internal(_root);
}

// Path: welcome.hero.actions
class Translations$welcome$hero$actions$en {
	Translations$welcome$hero$actions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New book'
	String get newBook => 'New book';

	/// en: 'Open book'
	String get openBook => 'Open book';
}

// Path: welcome.quickActions.create
class Translations$welcome$quickActions$create$en {
	Translations$welcome$quickActions$create$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create book'
	String get title => 'Create book';

	/// en: 'Start a new structured .mdw project using the latest format.'
	String get description => 'Start a new structured .mdw project using the latest format.';
}

// Path: welcome.quickActions.open
class Translations$welcome$quickActions$open$en {
	Translations$welcome$quickActions$open$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Open project'
	String get title => 'Open project';

	/// en: 'Continue an existing Markweft book.'
	String get description => 'Continue an existing Markweft book.';
}

// Path: welcome.quickActions.importMarkdown
class Translations$welcome$quickActions$importMarkdown$en {
	Translations$welcome$quickActions$importMarkdown$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Import Markdown'
	String get title => 'Import Markdown';

	/// en: 'Convert a Markdown manuscript into a book.'
	String get description => 'Convert a Markdown manuscript into a book.';
}

// Path: welcome.quickActions.convertVersion
class Translations$welcome$quickActions$convertVersion$en {
	Translations$welcome$quickActions$convertVersion$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Convert version'
	String get title => 'Convert version';

	/// en: 'Upgrade or create a compatibility copy in another MDW format version.'
	String get description => 'Upgrade or create a compatibility copy in another MDW format version.';
}

// Path: welcome.conversion.dialog
class Translations$welcome$conversion$dialog$en {
	Translations$welcome$conversion$dialog$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Convert book version'
	String get title => 'Convert book version';

	/// en: 'Choose the target MDW version, then decide whether to update the same file or save a separate copy.'
	String get description => 'Choose the target MDW version, then decide whether to update the same file or save a separate copy.';

	/// en: 'Convert to v1'
	String get toV1 => 'Convert to v1';

	/// en: 'Convert to v3'
	String get toV3 => 'Convert to v3';

	/// en: 'Where should the converted book be saved?'
	String get storageTitle => 'Where should the converted book be saved?';

	/// en: 'Update same file'
	String get sameFile => 'Update same file';

	/// en: 'Replace the selected .mdw file after a successful conversion.'
	String get sameFileDescription => 'Replace the selected .mdw file after a successful conversion.';

	/// en: 'Save another file'
	String get saveCopy => 'Save another file';

	/// en: 'Keep the source book unchanged and create a separate .mdw file.'
	String get saveCopyDescription => 'Keep the source book unchanged and create a separate .mdw file.';

	/// en: 'Open converted book'
	String get openAfter => 'Open converted book';

	/// en: 'Open the converted book immediately after conversion.'
	String get openAfterDescription => 'Open the converted book immediately after conversion.';
}

// Path: bookSettings.sections.document.orientationValues
class Translations$bookSettings$sections$document$orientationValues$en {
	Translations$bookSettings$sections$document$orientationValues$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Portrait'
	String get portrait => 'Portrait';

	/// en: 'Landscape'
	String get landscape => 'Landscape';
}

// Path: bookSettings.sections.document.columns
class Translations$bookSettings$sections$document$columns$en {
	Translations$bookSettings$sections$document$columns$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Default columns'
	String get title => 'Default columns';

	/// en: 'Available column counts are defined by the selected template.'
	String get helper => 'Available column counts are defined by the selected template.';
}

// Path: bookSettings.sections.language.directionValues
class Translations$bookSettings$sections$language$directionValues$en {
	Translations$bookSettings$sections$language$directionValues$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Left to right (LTR)'
	String get ltr => 'Left to right (LTR)';

	/// en: 'Right to left (RTL)'
	String get rtl => 'Right to left (RTL)';
}

// Path: bookSettings.sections.typography.fontFamilies
class Translations$bookSettings$sections$typography$fontFamilies$en {
	Translations$bookSettings$sections$typography$fontFamilies$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'System default'
	String get system => 'System default';

	/// en: 'Serif'
	String get serif => 'Serif';

	/// en: 'Sans serif'
	String get sansSerif => 'Sans serif';

	/// en: 'Monospace'
	String get monospace => 'Monospace';
}

// Path: bookSettings.sections.typography.alignmentValues
class Translations$bookSettings$sections$typography$alignmentValues$en {
	Translations$bookSettings$sections$typography$alignmentValues$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

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
}

// Path: settings.sections.appearance.themeMode
class Translations$settings$sections$appearance$themeMode$en {
	Translations$settings$sections$appearance$themeMode$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Theme mode'
	String get title => 'Theme mode';

	/// en: 'Follow the system or use a fixed appearance.'
	String get description => 'Follow the system or use a fixed appearance.';
}

// Path: settings.sections.language.appLanguage
class Translations$settings$sections$language$appLanguage$en {
	Translations$settings$sections$language$appLanguage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App language'
	String get title => 'App language';

	/// en: 'System uses the language selected in macOS.'
	String get description => 'System uses the language selected in macOS.';
}

// Path: settings.sections.privacy.recentPaths
class Translations$settings$sections$privacy$recentPaths$en {
	Translations$settings$sections$privacy$recentPaths$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Show recent book paths'
	String get title => 'Show recent book paths';

	/// en: 'Display full local file paths in Recent books.'
	String get description => 'Display full local file paths in Recent books.';
}

// Path: settings.sections.safety.confirmDestructive
class Translations$settings$sections$safety$confirmDestructive$en {
	Translations$settings$sections$safety$confirmDestructive$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Confirm destructive actions'
	String get title => 'Confirm destructive actions';

	/// en: 'Ask before deleting chapters or history versions.'
	String get description => 'Ask before deleting chapters or history versions.';
}
