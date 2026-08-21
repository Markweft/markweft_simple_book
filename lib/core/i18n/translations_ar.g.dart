///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsAr extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsAr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ar,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <ar>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsAr _root = this; // ignore: unused_field

	@override 
	TranslationsAr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsAr(meta: meta ?? this.$meta);

	// Translations
	@override late final Translations$app$ar app = Translations$app$ar._(_root);
	@override late final Translations$bookSettings$ar bookSettings = Translations$bookSettings$ar._(_root);
	@override late final Translations$dialogs$ar dialogs = Translations$dialogs$ar._(_root);
	@override late final Translations$editor$ar editor = Translations$editor$ar._(_root);
	@override late final Translations$history$ar history = Translations$history$ar._(_root);
	@override late final Translations$language$ar language = Translations$language$ar._(_root);
	@override late final Translations$settings$ar settings = Translations$settings$ar._(_root);
	@override late final Translations$toolbar$ar toolbar = Translations$toolbar$ar._(_root);
	@override late final Translations$welcome$ar welcome = Translations$welcome$ar._(_root);
}

// Path: app
class Translations$app$ar extends Translations$app$en {
	Translations$app$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$app$identity$ar identity = Translations$app$identity$ar._(_root);
	@override late final Translations$app$actions$ar actions = Translations$app$actions$ar._(_root);
	@override late final Translations$app$status$ar status = Translations$app$status$ar._(_root);
	@override late final Translations$app$appearance$ar appearance = Translations$app$appearance$ar._(_root);
	@override String get save => _root.app.actions.save;
	@override String get cancel => _root.app.actions.cancel;
	@override String get delete => _root.app.actions.delete;
	@override String get restore => _root.app.actions.restore;
	@override String get retry => _root.app.actions.retry;
	@override String get loading => _root.app.status.loading;
	@override String get saving => _root.app.status.saving;
	@override String get saved => _root.app.status.saved;
	@override String get saveFailed => _root.app.status.saveFailed;
}

// Path: bookSettings
class Translations$bookSettings$ar extends Translations$bookSettings$en {
	Translations$bookSettings$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$bookSettings$page$ar page = Translations$bookSettings$page$ar._(_root);
	@override late final Translations$bookSettings$sections$ar sections = Translations$bookSettings$sections$ar._(_root);
}

// Path: dialogs
class Translations$dialogs$ar extends Translations$dialogs$en {
	Translations$dialogs$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$dialogs$bookTitle$ar bookTitle = Translations$dialogs$bookTitle$ar._(_root);
	@override late final Translations$dialogs$chapter$ar chapter = Translations$dialogs$chapter$ar._(_root);
	@override late final Translations$dialogs$version$ar version = Translations$dialogs$version$ar._(_root);
	@override String get chapterTitle => _root.dialogs.chapter.fieldLabel;
}

// Path: editor
class Translations$editor$ar extends Translations$editor$en {
	Translations$editor$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$editor$workspace$ar workspace = Translations$editor$workspace$ar._(_root);
	@override late final Translations$editor$sidebar$ar sidebar = Translations$editor$sidebar$ar._(_root);
	@override late final Translations$editor$chapterManager$ar chapterManager = Translations$editor$chapterManager$ar._(_root);
	@override late final Translations$editor$previewPanel$ar previewPanel = Translations$editor$previewPanel$ar._(_root);
	@override late final Translations$editor$export$ar export = Translations$editor$export$ar._(_root);
	@override late final Translations$editor$save$ar save = Translations$editor$save$ar._(_root);
	@override String get chapterOne => _root.editor.chapterManager.defaultFirst;
	@override String loadBookFailed({required Object error}) => _root.editor.save.errors.loadBook(error: error);
	@override String get automaticRecoveryCheckpoint => _root.editor.save.automaticRecovery;
	@override String saveChapterFailed({required Object error}) => _root.editor.save.errors.saveChapter(error: error);
	@override String mdwFlushFailed({required Object error}) => _root.editor.save.errors.flushProject(error: error);
	@override String openChapterFailed({required Object error}) => _root.editor.save.errors.openChapter(error: error);
	@override String get addChapter => _root.editor.chapterManager.add;
	@override String get renameChapter => _root.editor.chapterManager.renameTitle;
	@override String get atLeastOneChapter => _root.editor.chapterManager.atLeastOne;
	@override String get deleteChapterQuestion => _root.editor.chapterManager.deleteQuestion;
	@override String deleteChapterDescription({required Object title}) => _root.editor.chapterManager.deleteDescription(title: title);
	@override String beforeDeleting({required Object title}) => _root.editor.save.beforeDeleting(title: title);
	@override String get beforeChangingSettings => _root.editor.save.beforeChangingSettings;
	@override String saveSettingsFailed({required Object error}) => _root.editor.save.errors.saveSettings(error: error);
	@override String get pdf => _root.editor.previewPanel.format.pdf;
	@override String get epub => _root.editor.previewPanel.format.epub;
	@override String exported({required Object format, required Object path}) => _root.editor.export.success(format: format, path: path);
	@override String exportFailed({required Object format, required Object error}) => _root.editor.export.failure(format: format, error: error);
	@override String get closeBook => _root.editor.sidebar.close;
	@override String get loadingChapter => _root.editor.chapterManager.loading;
	@override String chapterIndex({required Object current, required Object total}) => _root.editor.chapterManager.index(current: current, total: total);
	@override String get edit => _root.editor.workspace.modes.edit;
	@override String get preview => _root.editor.workspace.modes.preview;
	@override String get versionHistory => _root.editor.sidebar.history.title;
	@override String get bookSettings => _root.editor.sidebar.settings.title;
	@override String get exportBook => _root.editor.export.menu;
	@override String get exportPdf => _root.editor.export.pdf;
	@override String get exportEpub => _root.editor.export.epub;
	@override String get saveNow => _root.editor.save.now;
	@override String get book => _root.editor.sidebar.title;
	@override String get bookSettingsSubtitle => _root.editor.sidebar.settings.subtitle;
	@override String get versionHistorySubtitle => _root.editor.sidebar.history.subtitle;
	@override String get chapters => _root.editor.chapterManager.title;
	@override String chapterNumber({required Object number}) => _root.editor.chapterManager.number(number: number);
	@override String get rename => _root.editor.chapterManager.rename;
	@override String get moveUp => _root.editor.chapterManager.moveUp;
	@override String get moveDown => _root.editor.chapterManager.moveDown;
	@override String get markdown => _root.editor.workspace.markdown.title;
	@override String markdownChapter({required Object title}) => _root.editor.workspace.markdown.chapterTitle(title: title);
	@override String get chapterOnlyLoaded => _root.editor.workspace.markdown.chapterOnlyLoaded;
	@override String get writeChapterHint => _root.editor.workspace.markdown.writeHint;
	@override String get largePreviewPaused => _root.editor.previewPanel.largeChapter.title;
	@override String characters({required Object count}) => _root.editor.previewPanel.largeChapter.characters(count: count);
	@override String get previewPausedDetails => _root.editor.previewPanel.largeChapter.description;
	@override String get renderOnce => _root.editor.previewPanel.largeChapter.renderOnce;
}

// Path: history
class Translations$history$ar extends Translations$history$en {
	Translations$history$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$history$page$ar page = Translations$history$page$ar._(_root);
	@override late final Translations$history$create$ar create = Translations$history$create$ar._(_root);
	@override late final Translations$history$reasons$ar reasons = Translations$history$reasons$ar._(_root);
	@override late final Translations$history$restore$ar restore = Translations$history$restore$ar._(_root);
	@override late final Translations$history$delete$ar delete = Translations$history$delete$ar._(_root);
	@override late final Translations$history$metadata$ar metadata = Translations$history$metadata$ar._(_root);
}

// Path: language
class Translations$language$ar extends Translations$language$en {
	Translations$language$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$language$selector$ar selector = Translations$language$selector$ar._(_root);
	@override late final Translations$language$locales$ar locales = Translations$language$locales$ar._(_root);
}

// Path: settings
class Translations$settings$ar extends Translations$settings$en {
	Translations$settings$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$settings$page$ar page = Translations$settings$page$ar._(_root);
	@override late final Translations$settings$sections$ar sections = Translations$settings$sections$ar._(_root);
	@override String get bookSettingsNote => 'تبقى إعدادات الصفحة والطباعة والنشر الخاصة بالكتاب داخل كل ملف .mdw.';
}

// Path: toolbar
class Translations$toolbar$ar extends Translations$toolbar$en {
	Translations$toolbar$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$toolbar$headings$ar headings = Translations$toolbar$headings$ar._(_root);
	@override late final Translations$toolbar$formatting$ar formatting = Translations$toolbar$formatting$ar._(_root);
	@override late final Translations$toolbar$lists$ar lists = Translations$toolbar$lists$ar._(_root);
	@override late final Translations$toolbar$insert$ar insert = Translations$toolbar$insert$ar._(_root);
	@override late final Translations$toolbar$placeholders$ar placeholders = Translations$toolbar$placeholders$ar._(_root);
}

// Path: welcome
class Translations$welcome$ar extends Translations$welcome$en {
	Translations$welcome$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$welcome$topBar$ar topBar = Translations$welcome$topBar$ar._(_root);
	@override late final Translations$welcome$hero$ar hero = Translations$welcome$hero$ar._(_root);
	@override late final Translations$welcome$quickActions$ar quickActions = Translations$welcome$quickActions$ar._(_root);
	@override late final Translations$welcome$recent$ar recent = Translations$welcome$recent$ar._(_root);
	@override late final Translations$welcome$conversion$ar conversion = Translations$welcome$conversion$ar._(_root);
	@override late final Translations$welcome$errors$ar errors = Translations$welcome$errors$ar._(_root);
}

// Path: app.identity
class Translations$app$identity$ar extends Translations$app$identity$en {
	Translations$app$identity$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get name => 'مارك ويفت';
}

// Path: app.actions
class Translations$app$actions$ar extends Translations$app$actions$en {
	Translations$app$actions$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get done => 'تم';
	@override String get save => 'حفظ';
	@override String get cancel => 'إلغاء';
	@override String get close => 'إغلاق';
	@override String get delete => 'حذف';
	@override String get restore => 'استعادة';
	@override String get refresh => 'تحديث';
	@override String get retry => 'إعادة المحاولة';
}

// Path: app.status
class Translations$app$status$ar extends Translations$app$status$en {
	Translations$app$status$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get loading => 'جارٍ التحميل...';
	@override String get saving => 'جارٍ الحفظ...';
	@override String get saved => 'تم الحفظ';
	@override String get saveFailed => 'فشل الحفظ';
}

// Path: app.appearance
class Translations$app$appearance$ar extends Translations$app$appearance$en {
	Translations$app$appearance$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$app$appearance$themeMode$ar themeMode = Translations$app$appearance$themeMode$ar._(_root);
}

// Path: bookSettings.page
class Translations$bookSettings$page$ar extends Translations$bookSettings$page$en {
	Translations$bookSettings$page$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إعدادات الكتاب';
}

// Path: bookSettings.sections
class Translations$bookSettings$sections$ar extends Translations$bookSettings$sections$en {
	Translations$bookSettings$sections$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$bookSettings$sections$document$ar document = Translations$bookSettings$sections$document$ar._(_root);
	@override late final Translations$bookSettings$sections$appearance$ar appearance = Translations$bookSettings$sections$appearance$ar._(_root);
	@override late final Translations$bookSettings$sections$language$ar language = Translations$bookSettings$sections$language$ar._(_root);
	@override late final Translations$bookSettings$sections$typography$ar typography = Translations$bookSettings$sections$typography$ar._(_root);
	@override late final Translations$bookSettings$sections$toc$ar toc = Translations$bookSettings$sections$toc$ar._(_root);
	@override late final Translations$bookSettings$sections$templateBehavior$ar templateBehavior = Translations$bookSettings$sections$templateBehavior$ar._(_root);
}

// Path: dialogs.bookTitle
class Translations$dialogs$bookTitle$ar extends Translations$dialogs$bookTitle$en {
	Translations$dialogs$bookTitle$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$dialogs$bookTitle$create$ar create = Translations$dialogs$bookTitle$create$ar._(_root);
	@override late final Translations$dialogs$bookTitle$import$ar import = Translations$dialogs$bookTitle$import$ar._(_root);
	@override late final Translations$dialogs$bookTitle$field$ar field = Translations$dialogs$bookTitle$field$ar._(_root);
}

// Path: dialogs.chapter
class Translations$dialogs$chapter$ar extends Translations$dialogs$chapter$en {
	Translations$dialogs$chapter$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get fieldLabel => 'عنوان الفصل';
}

// Path: dialogs.version
class Translations$dialogs$version$ar extends Translations$dialogs$version$en {
	Translations$dialogs$version$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get messageLabel => 'رسالة الإصدار';
}

// Path: editor.workspace
class Translations$editor$workspace$ar extends Translations$editor$workspace$en {
	Translations$editor$workspace$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$editor$workspace$modes$ar modes = Translations$editor$workspace$modes$ar._(_root);
	@override late final Translations$editor$workspace$markdown$ar markdown = Translations$editor$workspace$markdown$ar._(_root);
}

// Path: editor.sidebar
class Translations$editor$sidebar$ar extends Translations$editor$sidebar$en {
	Translations$editor$sidebar$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'الكتاب';
	@override String get close => 'إغلاق الكتاب';
	@override String get appSettings => 'إعدادات التطبيق';
	@override late final Translations$editor$sidebar$settings$ar settings = Translations$editor$sidebar$settings$ar._(_root);
	@override late final Translations$editor$sidebar$history$ar history = Translations$editor$sidebar$history$ar._(_root);
}

// Path: editor.chapterManager
class Translations$editor$chapterManager$ar extends Translations$editor$chapterManager$en {
	Translations$editor$chapterManager$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'الفصول';
	@override String get add => 'إضافة فصل';
	@override String get addChild => 'إضافة فصل فرعي';
	@override String get rename => 'إعادة تسمية';
	@override String get renameTitle => 'إعادة تسمية الفصل';
	@override String get delete => 'حذف الفصل';
	@override String get deleteQuestion => 'حذف الفصل؟';
	@override String deleteDescription({required Object title}) => 'هل تريد حذف «${title}» وملف Markdown الخاص به؟ سيتم إنشاء نقطة حفظ في السجل أولاً.';
	@override String deleteTreeDescription({required Object title}) => 'هل تريد حذف «${title}» وجميع الفصول الفرعية التابعة له؟ سيتم إنشاء نقطة حفظ في السجل أولاً.';
	@override String get atLeastOne => 'يجب أن يحتوي الكتاب على فصل واحد على الأقل.';
	@override String get moveUp => 'تحريك للأعلى';
	@override String get moveDown => 'تحريك للأسفل';
	@override String index({required Object current, required Object total}) => 'الفصل ${current}/${total}';
	@override String number({required Object number}) => 'الفصل ${number}';
	@override String get defaultFirst => 'الفصل الأول';
	@override String get loading => 'جارٍ تحميل الفصل';
}

// Path: editor.previewPanel
class Translations$editor$previewPanel$ar extends Translations$editor$previewPanel$en {
	Translations$editor$previewPanel$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$editor$previewPanel$format$ar format = Translations$editor$previewPanel$format$ar._(_root);
	@override late final Translations$editor$previewPanel$scope$ar scope = Translations$editor$previewPanel$scope$ar._(_root);
	@override String get refreshFullBook => 'تحديث معاينة الكتاب كاملاً';
	@override String get loadFullBookFailed => 'تعذر تحميل معاينة الكتاب كاملاً.';
	@override String get epubReflowable => 'EPUB · معاينة مرنة';
	@override late final Translations$editor$previewPanel$largeChapter$ar largeChapter = Translations$editor$previewPanel$largeChapter$ar._(_root);
}

// Path: editor.export
class Translations$editor$export$ar extends Translations$editor$export$en {
	Translations$editor$export$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get menu => 'تصدير الكتاب';
	@override String get pdf => 'تصدير PDF';
	@override String get epub => 'تصدير EPUB';
	@override String success({required Object format, required Object path}) => 'تم تصدير ${format} إلى ${path}';
	@override String failure({required Object format, required Object error}) => 'تعذر تصدير ${format}: ${error}';
}

// Path: editor.save
class Translations$editor$save$ar extends Translations$editor$save$en {
	Translations$editor$save$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get now => 'حفظ الآن';
	@override String get automaticRecovery => 'نقطة استعادة تلقائية';
	@override String beforeDeleting({required Object title}) => 'قبل حذف ${title}';
	@override String get beforeChangingSettings => 'قبل تغيير إعدادات الكتاب';
	@override late final Translations$editor$save$errors$ar errors = Translations$editor$save$errors$ar._(_root);
}

// Path: history.page
class Translations$history$page$ar extends Translations$history$page$en {
	Translations$history$page$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'سجل الإصدارات';
	@override String get empty => 'لا توجد إصدارات بعد. أنشئ إصداراً يدوياً أو واصل التحرير؛ يتم إنشاء نقاط الاستعادة تلقائياً.';
}

// Path: history.create
class Translations$history$create$ar extends Translations$history$create$en {
	Translations$history$create$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إنشاء إصدار';
	@override String get descriptionLabel => 'الوصف';
	@override String get descriptionHint => 'قبل إعادة كتابة الفصل الرابع';
	@override String get manualVersion => 'إصدار يدوي';
}

// Path: history.reasons
class Translations$history$reasons$ar extends Translations$history$reasons$en {
	Translations$history$reasons$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get manual => 'يدوي';
	@override String get recovery => 'استعادة';
	@override String get beforeDelete => 'قبل الحذف';
	@override String get beforeRestore => 'قبل الاستعادة';
	@override String get settingsChanged => 'تم تغيير الإعدادات';
}

// Path: history.restore
class Translations$history$restore$ar extends Translations$history$restore$en {
	Translations$history$restore$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get question => 'استعادة هذا الإصدار؟';
	@override String description({required Object date}) => 'سيتم حفظ حالة الكتاب الحالية تلقائياً قبل استعادة ${date}.';
	@override String get action => 'استعادة';
}

// Path: history.delete
class Translations$history$delete$ar extends Translations$history$delete$en {
	Translations$history$delete$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get question => 'حذف الإصدار اليدوي؟';
	@override String get description => 'سيؤدي هذا إلى إزالة نقطة الحفظ من سجل الإصدارات.';
	@override String get action => 'حذف';
}

// Path: history.metadata
class Translations$history$metadata$ar extends Translations$history$metadata$en {
	Translations$history$metadata$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String chapters({required Object count}) => '${count} فصول';
	@override String summary({required Object date, required Object chapters, required Object reason}) => '${date} · ${chapters} · ${reason}';
}

// Path: language.selector
class Translations$language$selector$ar extends Translations$language$selector$en {
	Translations$language$selector$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'اللغة';
	@override String get description => 'اختر اللغة المستخدمة في واجهة Markweft.';
}

// Path: language.locales
class Translations$language$locales$ar extends Translations$language$locales$en {
	Translations$language$locales$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get system => 'النظام';
	@override String get en => 'الإنجليزية';
	@override String get ar => 'العربية';
	@override String get fr => 'الفرنسية';
	@override String get de => 'الألمانية';
}

// Path: settings.page
class Translations$settings$page$ar extends Translations$settings$page$en {
	Translations$settings$page$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إعدادات التطبيق';
}

// Path: settings.sections
class Translations$settings$sections$ar extends Translations$settings$sections$en {
	Translations$settings$sections$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$settings$sections$appearance$ar appearance = Translations$settings$sections$appearance$ar._(_root);
	@override late final Translations$settings$sections$language$ar language = Translations$settings$sections$language$ar._(_root);
	@override late final Translations$settings$sections$privacy$ar privacy = Translations$settings$sections$privacy$ar._(_root);
	@override late final Translations$settings$sections$safety$ar safety = Translations$settings$sections$safety$ar._(_root);
}

// Path: toolbar.headings
class Translations$toolbar$headings$ar extends Translations$toolbar$headings$en {
	Translations$toolbar$headings$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get h1 => 'عنوان 1';
	@override String get h2 => 'عنوان 2';
	@override String get placeholder => 'عنوان';
}

// Path: toolbar.formatting
class Translations$toolbar$formatting$ar extends Translations$toolbar$formatting$en {
	Translations$toolbar$formatting$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get bold => 'عريض';
	@override String get italic => 'مائل';
	@override String get quote => 'اقتباس';
	@override String get divider => 'فاصل';
	@override String get codeBlock => 'كتلة برمجية';
}

// Path: toolbar.lists
class Translations$toolbar$lists$ar extends Translations$toolbar$lists$en {
	Translations$toolbar$lists$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get bullet => 'قائمة نقطية';
	@override String get numbered => 'قائمة مرقمة';
	@override String get itemOne => 'العنصر الأول';
	@override String get itemTwo => 'العنصر الثاني';
	@override String get firstItem => 'العنصر الأول';
	@override String get secondItem => 'العنصر الثاني';
}

// Path: toolbar.insert
class Translations$toolbar$insert$ar extends Translations$toolbar$insert$en {
	Translations$toolbar$insert$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get link => 'رابط';
	@override String get image => 'صورة';
	@override String get table => 'جدول';
	@override String get newPage => 'صفحة جديدة';
	@override String get newPageWithSettings => 'صفحة جديدة مع إعدادات';
}

// Path: toolbar.placeholders
class Translations$toolbar$placeholders$ar extends Translations$toolbar$placeholders$en {
	Translations$toolbar$placeholders$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get boldText => 'نص عريض';
	@override String get italicText => 'نص مائل';
	@override String get quoteText => 'اقتباس';
	@override String get linkText => 'نص الرابط';
	@override String get imageDescription => 'وصف الصورة';
}

// Path: welcome.topBar
class Translations$welcome$topBar$ar extends Translations$welcome$topBar$en {
	Translations$welcome$topBar$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get localFirst => 'محلي أولاً';
	@override String get settingsTooltip => 'إعدادات التطبيق';
}

// Path: welcome.hero
class Translations$welcome$hero$ar extends Translations$welcome$hero$en {
	Translations$welcome$hero$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get badge => 'مساحة عمل لنشر Markdown';
	@override String get title => 'اكتب مرة واحدة.\nوانشر باحتراف.';
	@override String get description => 'أنشئ كتباً طويلة بفصول وسجل إصدارات وتخطيطات PDF وإخراج EPUB مرن.';
	@override late final Translations$welcome$hero$actions$ar actions = Translations$welcome$hero$actions$ar._(_root);
}

// Path: welcome.quickActions
class Translations$welcome$quickActions$ar extends Translations$welcome$quickActions$en {
	Translations$welcome$quickActions$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$welcome$quickActions$create$ar create = Translations$welcome$quickActions$create$ar._(_root);
	@override late final Translations$welcome$quickActions$open$ar open = Translations$welcome$quickActions$open$ar._(_root);
	@override late final Translations$welcome$quickActions$importMarkdown$ar importMarkdown = Translations$welcome$quickActions$importMarkdown$ar._(_root);
	@override late final Translations$welcome$quickActions$convertVersion$ar convertVersion = Translations$welcome$quickActions$convertVersion$ar._(_root);
}

// Path: welcome.recent
class Translations$welcome$recent$ar extends Translations$welcome$recent$en {
	Translations$welcome$recent$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'الكتب الأخيرة';
	@override String count({required Object count}) => '${count} مشاريع';
	@override String get empty => 'ستظهر كتبك الأخيرة هنا.';
	@override String get openTooltip => 'فتح الكتاب';
	@override String get removeTooltip => 'إزالة من الكتب الأخيرة';
	@override String version({required Object version}) => 'MDW v${version}';
	@override String get current => 'الحالي';
	@override String upgrade({required Object version}) => 'ترقية إلى v${version}';
	@override String get unknownVersion => 'الإصدار غير متاح';
}

// Path: welcome.conversion
class Translations$welcome$conversion$ar extends Translations$welcome$conversion$en {
	Translations$welcome$conversion$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final Translations$welcome$conversion$dialog$ar dialog = Translations$welcome$conversion$dialog$ar._(_root);
	@override String success({required Object path}) => 'تم حفظ الكتاب المحول في ${path}';
	@override String failure({required Object error}) => 'تعذر تحويل الكتاب: ${error}';
}

// Path: welcome.errors
class Translations$welcome$errors$ar extends Translations$welcome$errors$en {
	Translations$welcome$errors$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get legacyBookmark => 'تم حفظ هذا الكتاب بواسطة إصدار أقدم من Markweft. استخدم فتح كتاب مرة واحدة واختره مجدداً حتى يتمكن macOS من حفظ صلاحية الوصول الدائمة.';
	@override String bookmarkRestore({required Object error}) => 'تعذر استعادة صلاحية macOS لهذا الكتاب. افتحه مرة واحدة باستخدام فتح كتاب لتحديث الصلاحية. (${error})';
	@override String openBook({required Object error}) => 'تعذر فتح الكتاب: ${error}';
}

// Path: app.appearance.themeMode
class Translations$app$appearance$themeMode$ar extends Translations$app$appearance$themeMode$en {
	Translations$app$appearance$themeMode$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get system => 'النظام';
	@override String get light => 'فاتح';
	@override String get dark => 'داكن';
}

// Path: bookSettings.sections.document
class Translations$bookSettings$sections$document$ar extends Translations$bookSettings$sections$document$en {
	Translations$bookSettings$sections$document$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'المستند';
	@override String get template => 'القالب';
	@override String get pageSize => 'حجم الصفحة';
	@override String get orientation => 'الاتجاه';
	@override late final Translations$bookSettings$sections$document$orientationValues$ar orientationValues = Translations$bookSettings$sections$document$orientationValues$ar._(_root);
	@override String get pageMargin => 'هامش الصفحة';
	@override String get contentPadding => 'حشو المحتوى';
	@override late final Translations$bookSettings$sections$document$columns$ar columns = Translations$bookSettings$sections$document$columns$ar._(_root);
	@override String get platforms => 'مخرجات القالب';
	@override String get pdf => 'PDF';
	@override String get epub => 'EPUB';
}

// Path: bookSettings.sections.appearance
class Translations$bookSettings$sections$appearance$ar extends Translations$bookSettings$sections$appearance$en {
	Translations$bookSettings$sections$appearance$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'مظهر النشر';
	@override String get colorMode => 'نمط ألوان الكتاب';
	@override String get light => 'صفحات فاتحة';
	@override String get dark => 'صفحات داكنة';
	@override String get description => 'يتحكم هذا بمظهر الكتاب الناتج بشكل مستقل عن مظهر تطبيق Markweft.';
}

// Path: bookSettings.sections.language
class Translations$bookSettings$sections$language$ar extends Translations$bookSettings$sections$language$en {
	Translations$bookSettings$sections$language$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'اللغة واتجاه النص';
	@override String get bookLanguage => 'لغة الكتاب';
	@override String get direction => 'اتجاه النص';
	@override late final Translations$bookSettings$sections$language$directionValues$ar directionValues = Translations$bookSettings$sections$language$directionValues$ar._(_root);
}

// Path: bookSettings.sections.typography
class Translations$bookSettings$sections$typography$ar extends Translations$bookSettings$sections$typography$en {
	Translations$bookSettings$sections$typography$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إعدادات الطباعة';
	@override String get fontFamily => 'نوع الخط';
	@override late final Translations$bookSettings$sections$typography$fontFamilies$ar fontFamilies = Translations$bookSettings$sections$typography$fontFamilies$ar._(_root);
	@override String get fontSize => 'حجم الخط';
	@override String get fontWeight => 'سماكة الخط';
	@override String get lineHeight => 'ارتفاع السطر';
	@override String get alignment => 'المحاذاة';
	@override late final Translations$bookSettings$sections$typography$alignmentValues$ar alignmentValues = Translations$bookSettings$sections$typography$alignmentValues$ar._(_root);
}

// Path: bookSettings.sections.toc
class Translations$bookSettings$sections$toc$ar extends Translations$bookSettings$sections$toc$en {
	Translations$bookSettings$sections$toc$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'جدول المحتويات';
	@override String get enabled => 'إضافة صفحة جدول المحتويات';
	@override String get pageTitle => 'عنوان الصفحة';
	@override String get maxDepth => 'أقصى عمق للفصول';
	@override String get startOnNewPage => 'البدء في صفحة جديدة';
	@override String get pageNumbers => 'إظهار أرقام الصفحات';
	@override String get pageNumbersHint => 'أرقام الصفحات محفوظة لمرحلة ترقيم لاحقة؛ EPUB يملك تنقلاً أصلياً دائماً.';
	@override String get preview => 'معاينة جدول المحتويات';
}

// Path: bookSettings.sections.templateBehavior
class Translations$bookSettings$sections$templateBehavior$ar extends Translations$bookSettings$sections$templateBehavior$en {
	Translations$bookSettings$sections$templateBehavior$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'سلوك القالب';
	@override String chapterOpeningLayout({required Object layout}) => 'تستخدم صفحات افتتاح الفصل تخطيط القالب ${layout} بشكل افتراضي.';
}

// Path: dialogs.bookTitle.create
class Translations$dialogs$bookTitle$create$ar extends Translations$dialogs$bookTitle$create$en {
	Translations$dialogs$bookTitle$create$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إنشاء كتاب جديد';
	@override String get action => 'إنشاء';
}

// Path: dialogs.bookTitle.import
class Translations$dialogs$bookTitle$import$ar extends Translations$dialogs$bookTitle$import$en {
	Translations$dialogs$bookTitle$import$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'استيراد كتاب Markdown';
	@override String get action => 'استيراد';
}

// Path: dialogs.bookTitle.field
class Translations$dialogs$bookTitle$field$ar extends Translations$dialogs$bookTitle$field$en {
	Translations$dialogs$bookTitle$field$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get label => 'عنوان الكتاب';
	@override String get hint => 'كتابي الجديد';
}

// Path: editor.workspace.modes
class Translations$editor$workspace$modes$ar extends Translations$editor$workspace$modes$en {
	Translations$editor$workspace$modes$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get edit => 'تحرير';
	@override String get preview => 'معاينة';
}

// Path: editor.workspace.markdown
class Translations$editor$workspace$markdown$ar extends Translations$editor$workspace$markdown$en {
	Translations$editor$workspace$markdown$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Markdown';
	@override String chapterTitle({required Object title}) => 'Markdown · ${title}';
	@override String get chapterOnlyLoaded => 'يتم تحميل هذا الفصل فقط داخل المحرر.';
	@override String get writeHint => 'اكتب هذا الفصل بصيغة Markdown...';
}

// Path: editor.sidebar.settings
class Translations$editor$sidebar$settings$ar extends Translations$editor$sidebar$settings$en {
	Translations$editor$sidebar$settings$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إعدادات الكتاب';
	@override String get subtitle => 'الصفحة واللغة والطباعة';
}

// Path: editor.sidebar.history
class Translations$editor$sidebar$history$ar extends Translations$editor$sidebar$history$en {
	Translations$editor$sidebar$history$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'سجل الإصدارات';
	@override String get subtitle => 'الاستعادة ونقاط الحفظ والرجوع';
}

// Path: editor.previewPanel.format
class Translations$editor$previewPanel$format$ar extends Translations$editor$previewPanel$format$en {
	Translations$editor$previewPanel$format$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get pdf => 'PDF';
	@override String get epub => 'EPUB';
}

// Path: editor.previewPanel.scope
class Translations$editor$previewPanel$scope$ar extends Translations$editor$previewPanel$scope$en {
	Translations$editor$previewPanel$scope$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get chapter => 'الفصل';
	@override String get fullBook => 'الكتاب كاملاً';
}

// Path: editor.previewPanel.largeChapter
class Translations$editor$previewPanel$largeChapter$ar extends Translations$editor$previewPanel$largeChapter$en {
	Translations$editor$previewPanel$largeChapter$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'تم إيقاف المعاينة الحية لهذا الفصل الكبير';
	@override String characters({required Object count}) => '${count} حرفاً';
	@override String get description => 'يبقى التحرير والحفظ التلقائي فعالين؛ تم إيقاف تحليل المعاينة للحفاظ على استجابة الواجهة.';
	@override String get renderOnce => 'إنشاء المعاينة مرة واحدة';
}

// Path: editor.save.errors
class Translations$editor$save$errors$ar extends Translations$editor$save$errors$en {
	Translations$editor$save$errors$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String loadBook({required Object error}) => 'تعذر تحميل هذا الكتاب: ${error}';
	@override String saveChapter({required Object error}) => 'تعذر حفظ هذا الفصل: ${error}';
	@override String flushProject({required Object error}) => 'تم حفظ الفصل محلياً، لكن تحديث ملف .mdw فشل: ${error}';
	@override String openChapter({required Object error}) => 'تعذر فتح الفصل: ${error}';
	@override String saveSettings({required Object error}) => 'تعذر حفظ إعدادات الكتاب: ${error}';
}

// Path: settings.sections.appearance
class Translations$settings$sections$appearance$ar extends Translations$settings$sections$appearance$en {
	Translations$settings$sections$appearance$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'المظهر';
	@override String get description => 'اختر كيفية ظهور Markweft على هذا الجهاز.';
	@override late final Translations$settings$sections$appearance$themeMode$ar themeMode = Translations$settings$sections$appearance$themeMode$ar._(_root);
}

// Path: settings.sections.language
class Translations$settings$sections$language$ar extends Translations$settings$sections$language$en {
	Translations$settings$sections$language$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'اللغة والمنطقة';
	@override String get description => 'حدد لغة واجهة التطبيق.';
	@override late final Translations$settings$sections$language$appLanguage$ar appLanguage = Translations$settings$sections$language$appLanguage$ar._(_root);
}

// Path: settings.sections.privacy
class Translations$settings$sections$privacy$ar extends Translations$settings$sections$privacy$en {
	Translations$settings$sections$privacy$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'الخصوصية ومساحة العمل';
	@override String get description => 'تحكم فيما يظهر في شاشة الترحيب.';
	@override late final Translations$settings$sections$privacy$recentPaths$ar recentPaths = Translations$settings$sections$privacy$recentPaths$ar._(_root);
}

// Path: settings.sections.safety
class Translations$settings$sections$safety$ar extends Translations$settings$sections$safety$en {
	Translations$settings$sections$safety$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'الأمان';
	@override String get description => 'حماية الإجراءات الحساسة أثناء تحرير الكتب.';
	@override late final Translations$settings$sections$safety$confirmDestructive$ar confirmDestructive = Translations$settings$sections$safety$confirmDestructive$ar._(_root);
}

// Path: welcome.hero.actions
class Translations$welcome$hero$actions$ar extends Translations$welcome$hero$actions$en {
	Translations$welcome$hero$actions$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get newBook => 'كتاب جديد';
	@override String get openBook => 'فتح كتاب';
}

// Path: welcome.quickActions.create
class Translations$welcome$quickActions$create$ar extends Translations$welcome$quickActions$create$en {
	Translations$welcome$quickActions$create$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إنشاء كتاب';
	@override String get description => 'ابدأ مشروع .mdw جديداً باستخدام أحدث إصدار من التنسيق.';
}

// Path: welcome.quickActions.open
class Translations$welcome$quickActions$open$ar extends Translations$welcome$quickActions$open$en {
	Translations$welcome$quickActions$open$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'فتح مشروع';
	@override String get description => 'تابع تحرير كتاب Markweft موجود.';
}

// Path: welcome.quickActions.importMarkdown
class Translations$welcome$quickActions$importMarkdown$ar extends Translations$welcome$quickActions$importMarkdown$en {
	Translations$welcome$quickActions$importMarkdown$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'استيراد Markdown';
	@override String get description => 'حوّل مخطوطة Markdown إلى كتاب.';
}

// Path: welcome.quickActions.convertVersion
class Translations$welcome$quickActions$convertVersion$ar extends Translations$welcome$quickActions$convertVersion$en {
	Translations$welcome$quickActions$convertVersion$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'تحويل الإصدار';
	@override String get description => 'رقِّ الكتاب أو أنشئ نسخة متوافقة بإصدار آخر من MDW.';
}

// Path: welcome.conversion.dialog
class Translations$welcome$conversion$dialog$ar extends Translations$welcome$conversion$dialog$en {
	Translations$welcome$conversion$dialog$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'تحويل إصدار الكتاب';
	@override String get description => 'اختر إصدار MDW الهدف، ثم حدد إن كنت تريد تحديث الملف نفسه أو حفظ نسخة مستقلة.';
	@override String get toV1 => 'تحويل إلى v1';
	@override String get toV3 => 'تحويل إلى v3';
	@override String get storageTitle => 'أين تريد حفظ الكتاب المحول؟';
	@override String get sameFile => 'تحديث الملف نفسه';
	@override String get sameFileDescription => 'استبدال ملف .mdw المحدد بعد نجاح عملية التحويل.';
	@override String get saveCopy => 'حفظ ملف آخر';
	@override String get saveCopyDescription => 'الإبقاء على الكتاب الأصلي وإنشاء ملف .mdw مستقل.';
	@override String get openAfter => 'فتح الكتاب المحول';
	@override String get openAfterDescription => 'فتح الكتاب المحول مباشرة بعد انتهاء العملية.';
}

// Path: bookSettings.sections.document.orientationValues
class Translations$bookSettings$sections$document$orientationValues$ar extends Translations$bookSettings$sections$document$orientationValues$en {
	Translations$bookSettings$sections$document$orientationValues$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get portrait => 'عمودي';
	@override String get landscape => 'أفقي';
}

// Path: bookSettings.sections.document.columns
class Translations$bookSettings$sections$document$columns$ar extends Translations$bookSettings$sections$document$columns$en {
	Translations$bookSettings$sections$document$columns$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'عدد الأعمدة الافتراضي';
	@override String get helper => 'أعداد الأعمدة المتاحة يحددها القالب المختار.';
}

// Path: bookSettings.sections.language.directionValues
class Translations$bookSettings$sections$language$directionValues$ar extends Translations$bookSettings$sections$language$directionValues$en {
	Translations$bookSettings$sections$language$directionValues$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get ltr => 'من اليسار إلى اليمين (LTR)';
	@override String get rtl => 'من اليمين إلى اليسار (RTL)';
}

// Path: bookSettings.sections.typography.fontFamilies
class Translations$bookSettings$sections$typography$fontFamilies$ar extends Translations$bookSettings$sections$typography$fontFamilies$en {
	Translations$bookSettings$sections$typography$fontFamilies$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get system => 'خط النظام الافتراضي';
	@override String get serif => 'Serif';
	@override String get sansSerif => 'Sans serif';
	@override String get monospace => 'Monospace';
}

// Path: bookSettings.sections.typography.alignmentValues
class Translations$bookSettings$sections$typography$alignmentValues$ar extends Translations$bookSettings$sections$typography$alignmentValues$en {
	Translations$bookSettings$sections$typography$alignmentValues$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get start => 'البداية';
	@override String get left => 'يسار';
	@override String get center => 'وسط';
	@override String get right => 'يمين';
	@override String get justify => 'ضبط';
}

// Path: settings.sections.appearance.themeMode
class Translations$settings$sections$appearance$themeMode$ar extends Translations$settings$sections$appearance$themeMode$en {
	Translations$settings$sections$appearance$themeMode$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'نمط المظهر';
	@override String get description => 'اتبع إعداد النظام أو استخدم مظهراً ثابتاً.';
}

// Path: settings.sections.language.appLanguage
class Translations$settings$sections$language$appLanguage$ar extends Translations$settings$sections$language$appLanguage$en {
	Translations$settings$sections$language$appLanguage$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'لغة التطبيق';
	@override String get description => 'خيار النظام يستخدم اللغة المحددة في macOS.';
}

// Path: settings.sections.privacy.recentPaths
class Translations$settings$sections$privacy$recentPaths$ar extends Translations$settings$sections$privacy$recentPaths$en {
	Translations$settings$sections$privacy$recentPaths$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إظهار مسارات الكتب الأخيرة';
	@override String get description => 'إظهار مسارات الملفات المحلية كاملة في الكتب الأخيرة.';
}

// Path: settings.sections.safety.confirmDestructive
class Translations$settings$sections$safety$confirmDestructive$ar extends Translations$settings$sections$safety$confirmDestructive$en {
	Translations$settings$sections$safety$confirmDestructive$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'تأكيد الإجراءات الحذفية';
	@override String get description => 'اطلب التأكيد قبل حذف الفصول أو إصدارات السجل.';
}
