///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

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
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ar>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsAr _root = this; // ignore: unused_field

	@override 
	TranslationsAr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsAr(meta: meta ?? this.$meta);

	// Translations
	@override late final Translations$app$ar app = Translations$app$ar._(_root);
	@override late final Translations$welcome$ar welcome = Translations$welcome$ar._(_root);
	@override late final Translations$settings$ar settings = Translations$settings$ar._(_root);
	@override late final Translations$editor$ar editor = Translations$editor$ar._(_root);
	@override late final Translations$toolbar$ar toolbar = Translations$toolbar$ar._(_root);
	@override late final Translations$bookSettings$ar bookSettings = Translations$bookSettings$ar._(_root);
	@override late final Translations$history$ar history = Translations$history$ar._(_root);
	@override late final Translations$dialogs$ar dialogs = Translations$dialogs$ar._(_root);
}

// Path: app
class Translations$app$ar extends Translations$app$en {
	Translations$app$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get name => 'مارك ويفت';
	@override String get settings => 'إعدادات التطبيق';
	@override String get done => 'تم';
	@override String get save => 'حفظ';
	@override String get cancel => 'إلغاء';
	@override String get close => 'إغلاق';
	@override String get delete => 'حذف';
	@override String get restore => 'استعادة';
	@override String get refresh => 'تحديث';
	@override String get retry => 'إعادة المحاولة';
	@override String get loading => 'جارٍ التحميل...';
	@override String get saving => 'جارٍ الحفظ...';
	@override String get saved => 'تم الحفظ';
	@override String get saveFailed => 'فشل الحفظ';
	@override String get system => 'النظام';
	@override String get light => 'فاتح';
	@override String get dark => 'داكن';
	@override String get english => 'الإنجليزية';
	@override String get arabic => 'العربية';
	@override String get french => 'الفرنسية';
	@override String get german => 'الألمانية';
}

// Path: welcome
class Translations$welcome$ar extends Translations$welcome$en {
	Translations$welcome$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get localFirst => 'محلي أولاً';
	@override String get workspaceBadge => 'مساحة عمل لنشر Markdown';
	@override String get heroTitle => 'اكتب مرة واحدة.\nوانشر باحتراف.';
	@override String get heroDescription => 'أنشئ كتباً طويلة بفصول وسجل إصدارات وتخطيطات PDF وإخراج EPUB مرن.';
	@override String get newBook => 'كتاب جديد';
	@override String get openBook => 'فتح كتاب';
	@override String get createBook => 'إنشاء كتاب';
	@override String get createBookDescription => 'ابدأ مشروع .mdw منظماً جديداً.';
	@override String get openProject => 'فتح مشروع';
	@override String get openProjectDescription => 'تابع تحرير كتاب Markweft موجود.';
	@override String get importMarkdown => 'استيراد Markdown';
	@override String get importMarkdownDescription => 'حوّل مخطوطة Markdown إلى كتاب.';
	@override String get convertVersion => 'تحويل الإصدار';
	@override String get convertVersionDescription => 'أنشئ نسخة متوافقة بإصدار آخر من تنسيق MDW.';
	@override String get convertDialogTitle => 'تحويل إصدار الكتاب';
	@override String get convertDialogBody => 'سيتم إنشاء نسخة .mdw جديدة ولن يتم تعديل الكتاب الأصلي. الإصدار 1 هو التنسيق الأصلي بملف Markdown واحد، والإصدار 3 هو التنسيق الحالي المعتمد على الفصول.';
	@override String get convertToV1 => 'تحويل إلى v1';
	@override String get convertToV3 => 'تحويل إلى v3';
	@override String get convertedSaved => 'تم حفظ الكتاب المحول في {path}';
	@override String get convertFailed => 'تعذر تحويل الكتاب: {error}';
	@override String get recentBooks => 'الكتب الأخيرة';
	@override String get projects => '{count} مشاريع';
	@override String get noRecentBooks => 'ستظهر كتبك الأخيرة هنا.';
	@override String get openRecent => 'فتح الكتاب';
	@override String get removeRecent => 'إزالة من الكتب الأخيرة';
	@override String get oldBookmark => 'تم حفظ هذا الكتاب بواسطة إصدار أقدم من Markweft. استخدم فتح كتاب مرة واحدة واختره مجدداً حتى يتمكن macOS من حفظ صلاحية الوصول الدائمة.';
	@override String get bookmarkRestoreFailed => 'تعذر استعادة صلاحية macOS لهذا الكتاب. افتحه مرة واحدة باستخدام فتح كتاب لتحديث الصلاحية. ({error})';
	@override String get openFailed => 'تعذر فتح الكتاب: {error}';
}

// Path: settings
class Translations$settings$ar extends Translations$settings$en {
	Translations$settings$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إعدادات التطبيق';
	@override String get appearance => 'المظهر';
	@override String get appearanceDescription => 'اختر كيفية ظهور Markweft على هذا الجهاز.';
	@override String get themeMode => 'نمط المظهر';
	@override String get themeModeDescription => 'اتبع إعداد النظام أو استخدم مظهراً ثابتاً.';
	@override String get languageRegion => 'اللغة والمنطقة';
	@override String get languageRegionDescription => 'حدد لغة واجهة التطبيق.';
	@override String get appLanguage => 'لغة التطبيق';
	@override String get appLanguageDescription => 'خيار النظام يستخدم اللغة المحددة في macOS.';
	@override String get privacyWorkspace => 'الخصوصية ومساحة العمل';
	@override String get privacyWorkspaceDescription => 'تحكم فيما يظهر في شاشة الترحيب.';
	@override String get showRecentPaths => 'إظهار مسارات الكتب الأخيرة';
	@override String get showRecentPathsDescription => 'إظهار مسارات الملفات المحلية كاملة في الكتب الأخيرة.';
	@override String get safety => 'الأمان';
	@override String get safetyDescription => 'حماية الإجراءات الحساسة أثناء تحرير الكتب.';
	@override String get confirmDestructive => 'تأكيد الإجراءات الحذفية';
	@override String get confirmDestructiveDescription => 'اطلب التأكيد قبل حذف الفصول أو إصدارات السجل.';
	@override String get bookSettingsNote => 'تبقى إعدادات الصفحة والطباعة والنشر الخاصة بالكتاب داخل كل ملف .mdw.';
}

// Path: editor
class Translations$editor$ar extends Translations$editor$en {
	Translations$editor$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get edit => 'تحرير';
	@override String get preview => 'معاينة';
	@override String get markdown => 'Markdown';
	@override String get book => 'الكتاب';
	@override String get bookSettings => 'إعدادات الكتاب';
	@override String get bookSettingsSubtitle => 'الصفحة واللغة والطباعة';
	@override String get versionHistory => 'سجل الإصدارات';
	@override String get versionHistorySubtitle => 'الاستعادة ونقاط الحفظ والرجوع';
	@override String get chapters => 'الفصول';
	@override String get addChapter => 'إضافة فصل';
	@override String get renameChapter => 'إعادة تسمية الفصل';
	@override String get rename => 'إعادة تسمية';
	@override String get deleteChapter => 'حذف الفصل';
	@override String get deleteChapterQuestion => 'حذف الفصل؟';
	@override String get deleteChapterDescription => 'هل تريد حذف «{title}» وملف Markdown الخاص به؟ سيتم إنشاء نقطة حفظ في السجل أولاً.';
	@override String get atLeastOneChapter => 'يجب أن يحتوي الكتاب على فصل واحد على الأقل.';
	@override String get moveUp => 'تحريك للأعلى';
	@override String get moveDown => 'تحريك للأسفل';
	@override String get export => 'تصدير';
	@override String get exportBook => 'تصدير الكتاب';
	@override String get exportPdf => 'تصدير PDF';
	@override String get exportEpub => 'تصدير EPUB';
	@override String get exported => 'تم تصدير {format} إلى {path}';
	@override String get exportFailed => 'تعذر تصدير {format}: {error}';
	@override String get pdf => 'PDF';
	@override String get epub => 'EPUB';
	@override String get chapter => 'الفصل';
	@override String get chapterIndex => 'الفصل {current}/{total}';
	@override String get chapterNumber => 'الفصل {number}';
	@override String get chapterOne => 'الفصل الأول';
	@override String get loadingChapter => 'جارٍ تحميل الفصل';
	@override String get closeBook => 'إغلاق الكتاب';
	@override String get saveNow => 'حفظ الآن';
	@override String get fullBook => 'الكتاب كاملاً';
	@override String get refreshFullBook => 'تحديث معاينة الكتاب كاملاً';
	@override String get largePreviewPaused => 'تم إيقاف المعاينة الحية لهذا الفصل الكبير';
	@override String get renderOnce => 'إنشاء المعاينة مرة واحدة';
	@override String get fullBookLoadFailed => 'تعذر تحميل معاينة الكتاب كاملاً.';
	@override String get epubReflowablePreview => 'EPUB · معاينة مرنة';
	@override String get characters => '{count} حرفاً';
	@override String get previewPausedDetails => 'يبقى التحرير والحفظ التلقائي فعالين؛ تم إيقاف تحليل المعاينة للحفاظ على استجابة الواجهة.';
	@override String get chapterOnlyLoaded => 'يتم تحميل هذا الفصل فقط داخل المحرر.';
	@override String get writeChapterHint => 'اكتب هذا الفصل بصيغة Markdown...';
	@override String get markdownChapter => 'Markdown · {title}';
	@override String get loadBookFailed => 'تعذر تحميل هذا الكتاب: {error}';
	@override String get saveChapterFailed => 'تعذر حفظ هذا الفصل: {error}';
	@override String get mdwFlushFailed => 'تم حفظ الفصل محلياً، لكن تحديث ملف .mdw فشل: {error}';
	@override String get openChapterFailed => 'تعذر فتح الفصل: {error}';
	@override String get saveSettingsFailed => 'تعذر حفظ إعدادات الكتاب: {error}';
	@override String get automaticRecoveryCheckpoint => 'نقطة استعادة تلقائية';
	@override String get beforeDeleting => 'قبل حذف {title}';
	@override String get beforeChangingSettings => 'قبل تغيير إعدادات الكتاب';
}

// Path: toolbar
class Translations$toolbar$ar extends Translations$toolbar$en {
	Translations$toolbar$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get heading1 => 'عنوان 1';
	@override String get heading2 => 'عنوان 2';
	@override String get bold => 'عريض';
	@override String get italic => 'مائل';
	@override String get bulletList => 'قائمة نقطية';
	@override String get numberedList => 'قائمة مرقمة';
	@override String get quote => 'اقتباس';
	@override String get link => 'رابط';
	@override String get image => 'صورة';
	@override String get table => 'جدول';
	@override String get codeBlock => 'كتلة برمجية';
	@override String get divider => 'فاصل';
	@override String get newPage => 'صفحة جديدة';
	@override String get newPageSettings => 'صفحة جديدة مع إعدادات';
	@override String get heading => 'عنوان';
	@override String get boldText => 'نص عريض';
	@override String get italicText => 'نص مائل';
	@override String get itemOne => 'العنصر الأول';
	@override String get itemTwo => 'العنصر الثاني';
	@override String get firstItem => 'العنصر الأول';
	@override String get secondItem => 'العنصر الثاني';
	@override String get quoteText => 'اقتباس';
	@override String get linkText => 'نص الرابط';
	@override String get imageDescription => 'وصف الصورة';
}

// Path: bookSettings
class Translations$bookSettings$ar extends Translations$bookSettings$en {
	Translations$bookSettings$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إعدادات الكتاب';
	@override String get document => 'المستند';
	@override String get template => 'القالب';
	@override String get pageSize => 'حجم الصفحة';
	@override String get orientation => 'الاتجاه';
	@override String get portrait => 'عمودي';
	@override String get landscape => 'أفقي';
	@override String get margin => 'الهامش';
	@override String get pageMargin => 'هامش الصفحة';
	@override String get contentPadding => 'حشو المحتوى';
	@override String get columns => 'عدد الأعمدة الافتراضي';
	@override String get columnsHelper => 'أعداد الأعمدة المتاحة يحددها القالب المختار.';
	@override String get language => 'اللغة';
	@override String get languageDirection => 'اللغة واتجاه النص';
	@override String get bookLanguage => 'لغة الكتاب';
	@override String get direction => 'اتجاه النص';
	@override String get ltr => 'من اليسار إلى اليمين (LTR)';
	@override String get rtl => 'من اليمين إلى اليسار (RTL)';
	@override String get typography => 'إعدادات الطباعة';
	@override String get fontFamily => 'نوع الخط';
	@override String get systemDefault => 'خط النظام الافتراضي';
	@override String get serif => 'Serif';
	@override String get sansSerif => 'Sans serif';
	@override String get monospace => 'Monospace';
	@override String get fontSize => 'حجم الخط';
	@override String get fontWeight => 'سماكة الخط';
	@override String get lineHeight => 'ارتفاع السطر';
	@override String get alignment => 'المحاذاة';
	@override String get start => 'البداية';
	@override String get left => 'يسار';
	@override String get center => 'وسط';
	@override String get right => 'يمين';
	@override String get justify => 'ضبط';
	@override String get templateBehavior => 'سلوك القالب';
	@override String get chapterOpeningLayout => 'تستخدم صفحات افتتاح الفصل تخطيط القالب {layout} بشكل افتراضي.';
}

// Path: history
class Translations$history$ar extends Translations$history$en {
	Translations$history$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'سجل الإصدارات';
	@override String get createVersion => 'إنشاء إصدار';
	@override String get description => 'الوصف';
	@override String get descriptionHint => 'قبل إعادة كتابة الفصل الرابع';
	@override String get manualVersion => 'إصدار يدوي';
	@override String get manual => 'يدوي';
	@override String get automaticRecovery => 'استعادة تلقائية';
	@override String get recovery => 'استعادة';
	@override String get beforeDelete => 'قبل الحذف';
	@override String get beforeRestore => 'قبل الاستعادة';
	@override String get settingsChanged => 'تم تغيير الإعدادات';
	@override String get restoreVersion => 'استعادة الإصدار';
	@override String get restoreQuestion => 'استعادة هذا الإصدار؟';
	@override String get restoreDescription => 'سيتم حفظ حالة الكتاب الحالية تلقائياً قبل استعادة {date}.';
	@override String get deleteVersion => 'حذف الإصدار';
	@override String get deleteManualQuestion => 'حذف الإصدار اليدوي؟';
	@override String get deleteManualDescription => 'سيؤدي هذا إلى إزالة نقطة الحفظ من سجل الإصدارات.';
	@override String get empty => 'لا توجد إصدارات بعد. أنشئ إصداراً يدوياً أو واصل التحرير؛ يتم إنشاء نقاط الاستعادة تلقائياً.';
	@override String get chaptersCount => '{count} فصول';
	@override String get metadata => '{date} · {chapters} · {reason}';
}

// Path: dialogs
class Translations$dialogs$ar extends Translations$dialogs$en {
	Translations$dialogs$ar._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get createNewBook => 'إنشاء كتاب جديد';
	@override String get importMarkdownBook => 'استيراد كتاب Markdown';
	@override String get create => 'إنشاء';
	@override String get import => 'استيراد';
	@override String get chapterTitle => 'عنوان الفصل';
	@override String get versionMessage => 'رسالة الإصدار';
	@override String get bookTitle => 'عنوان الكتاب';
	@override String get bookTitleHint => 'كتابي الجديد';
}

/// The flat map containing all translations for locale <ar>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsAr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'مارك ويفت',
			'app.settings' => 'إعدادات التطبيق',
			'app.done' => 'تم',
			'app.save' => 'حفظ',
			'app.cancel' => 'إلغاء',
			'app.close' => 'إغلاق',
			'app.delete' => 'حذف',
			'app.restore' => 'استعادة',
			'app.refresh' => 'تحديث',
			'app.retry' => 'إعادة المحاولة',
			'app.loading' => 'جارٍ التحميل...',
			'app.saving' => 'جارٍ الحفظ...',
			'app.saved' => 'تم الحفظ',
			'app.saveFailed' => 'فشل الحفظ',
			'app.system' => 'النظام',
			'app.light' => 'فاتح',
			'app.dark' => 'داكن',
			'app.english' => 'الإنجليزية',
			'app.arabic' => 'العربية',
			'app.french' => 'الفرنسية',
			'app.german' => 'الألمانية',
			'welcome.localFirst' => 'محلي أولاً',
			'welcome.workspaceBadge' => 'مساحة عمل لنشر Markdown',
			'welcome.heroTitle' => 'اكتب مرة واحدة.\nوانشر باحتراف.',
			'welcome.heroDescription' => 'أنشئ كتباً طويلة بفصول وسجل إصدارات وتخطيطات PDF وإخراج EPUB مرن.',
			'welcome.newBook' => 'كتاب جديد',
			'welcome.openBook' => 'فتح كتاب',
			'welcome.createBook' => 'إنشاء كتاب',
			'welcome.createBookDescription' => 'ابدأ مشروع .mdw منظماً جديداً.',
			'welcome.openProject' => 'فتح مشروع',
			'welcome.openProjectDescription' => 'تابع تحرير كتاب Markweft موجود.',
			'welcome.importMarkdown' => 'استيراد Markdown',
			'welcome.importMarkdownDescription' => 'حوّل مخطوطة Markdown إلى كتاب.',
			'welcome.convertVersion' => 'تحويل الإصدار',
			'welcome.convertVersionDescription' => 'أنشئ نسخة متوافقة بإصدار آخر من تنسيق MDW.',
			'welcome.convertDialogTitle' => 'تحويل إصدار الكتاب',
			'welcome.convertDialogBody' => 'سيتم إنشاء نسخة .mdw جديدة ولن يتم تعديل الكتاب الأصلي. الإصدار 1 هو التنسيق الأصلي بملف Markdown واحد، والإصدار 3 هو التنسيق الحالي المعتمد على الفصول.',
			'welcome.convertToV1' => 'تحويل إلى v1',
			'welcome.convertToV3' => 'تحويل إلى v3',
			'welcome.convertedSaved' => 'تم حفظ الكتاب المحول في {path}',
			'welcome.convertFailed' => 'تعذر تحويل الكتاب: {error}',
			'welcome.recentBooks' => 'الكتب الأخيرة',
			'welcome.projects' => '{count} مشاريع',
			'welcome.noRecentBooks' => 'ستظهر كتبك الأخيرة هنا.',
			'welcome.openRecent' => 'فتح الكتاب',
			'welcome.removeRecent' => 'إزالة من الكتب الأخيرة',
			'welcome.oldBookmark' => 'تم حفظ هذا الكتاب بواسطة إصدار أقدم من Markweft. استخدم فتح كتاب مرة واحدة واختره مجدداً حتى يتمكن macOS من حفظ صلاحية الوصول الدائمة.',
			'welcome.bookmarkRestoreFailed' => 'تعذر استعادة صلاحية macOS لهذا الكتاب. افتحه مرة واحدة باستخدام فتح كتاب لتحديث الصلاحية. ({error})',
			'welcome.openFailed' => 'تعذر فتح الكتاب: {error}',
			'settings.title' => 'إعدادات التطبيق',
			'settings.appearance' => 'المظهر',
			'settings.appearanceDescription' => 'اختر كيفية ظهور Markweft على هذا الجهاز.',
			'settings.themeMode' => 'نمط المظهر',
			'settings.themeModeDescription' => 'اتبع إعداد النظام أو استخدم مظهراً ثابتاً.',
			'settings.languageRegion' => 'اللغة والمنطقة',
			'settings.languageRegionDescription' => 'حدد لغة واجهة التطبيق.',
			'settings.appLanguage' => 'لغة التطبيق',
			'settings.appLanguageDescription' => 'خيار النظام يستخدم اللغة المحددة في macOS.',
			'settings.privacyWorkspace' => 'الخصوصية ومساحة العمل',
			'settings.privacyWorkspaceDescription' => 'تحكم فيما يظهر في شاشة الترحيب.',
			'settings.showRecentPaths' => 'إظهار مسارات الكتب الأخيرة',
			'settings.showRecentPathsDescription' => 'إظهار مسارات الملفات المحلية كاملة في الكتب الأخيرة.',
			'settings.safety' => 'الأمان',
			'settings.safetyDescription' => 'حماية الإجراءات الحساسة أثناء تحرير الكتب.',
			'settings.confirmDestructive' => 'تأكيد الإجراءات الحذفية',
			'settings.confirmDestructiveDescription' => 'اطلب التأكيد قبل حذف الفصول أو إصدارات السجل.',
			'settings.bookSettingsNote' => 'تبقى إعدادات الصفحة والطباعة والنشر الخاصة بالكتاب داخل كل ملف .mdw.',
			'editor.edit' => 'تحرير',
			'editor.preview' => 'معاينة',
			'editor.markdown' => 'Markdown',
			'editor.book' => 'الكتاب',
			'editor.bookSettings' => 'إعدادات الكتاب',
			'editor.bookSettingsSubtitle' => 'الصفحة واللغة والطباعة',
			'editor.versionHistory' => 'سجل الإصدارات',
			'editor.versionHistorySubtitle' => 'الاستعادة ونقاط الحفظ والرجوع',
			'editor.chapters' => 'الفصول',
			'editor.addChapter' => 'إضافة فصل',
			'editor.renameChapter' => 'إعادة تسمية الفصل',
			'editor.rename' => 'إعادة تسمية',
			'editor.deleteChapter' => 'حذف الفصل',
			'editor.deleteChapterQuestion' => 'حذف الفصل؟',
			'editor.deleteChapterDescription' => 'هل تريد حذف «{title}» وملف Markdown الخاص به؟ سيتم إنشاء نقطة حفظ في السجل أولاً.',
			'editor.atLeastOneChapter' => 'يجب أن يحتوي الكتاب على فصل واحد على الأقل.',
			'editor.moveUp' => 'تحريك للأعلى',
			'editor.moveDown' => 'تحريك للأسفل',
			'editor.export' => 'تصدير',
			'editor.exportBook' => 'تصدير الكتاب',
			'editor.exportPdf' => 'تصدير PDF',
			'editor.exportEpub' => 'تصدير EPUB',
			'editor.exported' => 'تم تصدير {format} إلى {path}',
			'editor.exportFailed' => 'تعذر تصدير {format}: {error}',
			'editor.pdf' => 'PDF',
			'editor.epub' => 'EPUB',
			'editor.chapter' => 'الفصل',
			'editor.chapterIndex' => 'الفصل {current}/{total}',
			'editor.chapterNumber' => 'الفصل {number}',
			'editor.chapterOne' => 'الفصل الأول',
			'editor.loadingChapter' => 'جارٍ تحميل الفصل',
			'editor.closeBook' => 'إغلاق الكتاب',
			'editor.saveNow' => 'حفظ الآن',
			'editor.fullBook' => 'الكتاب كاملاً',
			'editor.refreshFullBook' => 'تحديث معاينة الكتاب كاملاً',
			'editor.largePreviewPaused' => 'تم إيقاف المعاينة الحية لهذا الفصل الكبير',
			'editor.renderOnce' => 'إنشاء المعاينة مرة واحدة',
			'editor.fullBookLoadFailed' => 'تعذر تحميل معاينة الكتاب كاملاً.',
			'editor.epubReflowablePreview' => 'EPUB · معاينة مرنة',
			'editor.characters' => '{count} حرفاً',
			'editor.previewPausedDetails' => 'يبقى التحرير والحفظ التلقائي فعالين؛ تم إيقاف تحليل المعاينة للحفاظ على استجابة الواجهة.',
			'editor.chapterOnlyLoaded' => 'يتم تحميل هذا الفصل فقط داخل المحرر.',
			'editor.writeChapterHint' => 'اكتب هذا الفصل بصيغة Markdown...',
			'editor.markdownChapter' => 'Markdown · {title}',
			'editor.loadBookFailed' => 'تعذر تحميل هذا الكتاب: {error}',
			'editor.saveChapterFailed' => 'تعذر حفظ هذا الفصل: {error}',
			'editor.mdwFlushFailed' => 'تم حفظ الفصل محلياً، لكن تحديث ملف .mdw فشل: {error}',
			'editor.openChapterFailed' => 'تعذر فتح الفصل: {error}',
			'editor.saveSettingsFailed' => 'تعذر حفظ إعدادات الكتاب: {error}',
			'editor.automaticRecoveryCheckpoint' => 'نقطة استعادة تلقائية',
			'editor.beforeDeleting' => 'قبل حذف {title}',
			'editor.beforeChangingSettings' => 'قبل تغيير إعدادات الكتاب',
			'toolbar.heading1' => 'عنوان 1',
			'toolbar.heading2' => 'عنوان 2',
			'toolbar.bold' => 'عريض',
			'toolbar.italic' => 'مائل',
			'toolbar.bulletList' => 'قائمة نقطية',
			'toolbar.numberedList' => 'قائمة مرقمة',
			'toolbar.quote' => 'اقتباس',
			'toolbar.link' => 'رابط',
			'toolbar.image' => 'صورة',
			'toolbar.table' => 'جدول',
			'toolbar.codeBlock' => 'كتلة برمجية',
			'toolbar.divider' => 'فاصل',
			'toolbar.newPage' => 'صفحة جديدة',
			'toolbar.newPageSettings' => 'صفحة جديدة مع إعدادات',
			'toolbar.heading' => 'عنوان',
			'toolbar.boldText' => 'نص عريض',
			'toolbar.italicText' => 'نص مائل',
			'toolbar.itemOne' => 'العنصر الأول',
			'toolbar.itemTwo' => 'العنصر الثاني',
			'toolbar.firstItem' => 'العنصر الأول',
			'toolbar.secondItem' => 'العنصر الثاني',
			'toolbar.quoteText' => 'اقتباس',
			'toolbar.linkText' => 'نص الرابط',
			'toolbar.imageDescription' => 'وصف الصورة',
			'bookSettings.title' => 'إعدادات الكتاب',
			'bookSettings.document' => 'المستند',
			'bookSettings.template' => 'القالب',
			'bookSettings.pageSize' => 'حجم الصفحة',
			'bookSettings.orientation' => 'الاتجاه',
			'bookSettings.portrait' => 'عمودي',
			'bookSettings.landscape' => 'أفقي',
			'bookSettings.margin' => 'الهامش',
			'bookSettings.pageMargin' => 'هامش الصفحة',
			'bookSettings.contentPadding' => 'حشو المحتوى',
			'bookSettings.columns' => 'عدد الأعمدة الافتراضي',
			'bookSettings.columnsHelper' => 'أعداد الأعمدة المتاحة يحددها القالب المختار.',
			'bookSettings.language' => 'اللغة',
			'bookSettings.languageDirection' => 'اللغة واتجاه النص',
			'bookSettings.bookLanguage' => 'لغة الكتاب',
			'bookSettings.direction' => 'اتجاه النص',
			'bookSettings.ltr' => 'من اليسار إلى اليمين (LTR)',
			'bookSettings.rtl' => 'من اليمين إلى اليسار (RTL)',
			'bookSettings.typography' => 'إعدادات الطباعة',
			'bookSettings.fontFamily' => 'نوع الخط',
			'bookSettings.systemDefault' => 'خط النظام الافتراضي',
			'bookSettings.serif' => 'Serif',
			'bookSettings.sansSerif' => 'Sans serif',
			'bookSettings.monospace' => 'Monospace',
			'bookSettings.fontSize' => 'حجم الخط',
			'bookSettings.fontWeight' => 'سماكة الخط',
			'bookSettings.lineHeight' => 'ارتفاع السطر',
			'bookSettings.alignment' => 'المحاذاة',
			'bookSettings.start' => 'البداية',
			'bookSettings.left' => 'يسار',
			'bookSettings.center' => 'وسط',
			'bookSettings.right' => 'يمين',
			'bookSettings.justify' => 'ضبط',
			'bookSettings.templateBehavior' => 'سلوك القالب',
			'bookSettings.chapterOpeningLayout' => 'تستخدم صفحات افتتاح الفصل تخطيط القالب {layout} بشكل افتراضي.',
			'history.title' => 'سجل الإصدارات',
			'history.createVersion' => 'إنشاء إصدار',
			'history.description' => 'الوصف',
			'history.descriptionHint' => 'قبل إعادة كتابة الفصل الرابع',
			'history.manualVersion' => 'إصدار يدوي',
			'history.manual' => 'يدوي',
			'history.automaticRecovery' => 'استعادة تلقائية',
			'history.recovery' => 'استعادة',
			'history.beforeDelete' => 'قبل الحذف',
			'history.beforeRestore' => 'قبل الاستعادة',
			'history.settingsChanged' => 'تم تغيير الإعدادات',
			'history.restoreVersion' => 'استعادة الإصدار',
			'history.restoreQuestion' => 'استعادة هذا الإصدار؟',
			'history.restoreDescription' => 'سيتم حفظ حالة الكتاب الحالية تلقائياً قبل استعادة {date}.',
			'history.deleteVersion' => 'حذف الإصدار',
			'history.deleteManualQuestion' => 'حذف الإصدار اليدوي؟',
			'history.deleteManualDescription' => 'سيؤدي هذا إلى إزالة نقطة الحفظ من سجل الإصدارات.',
			'history.empty' => 'لا توجد إصدارات بعد. أنشئ إصداراً يدوياً أو واصل التحرير؛ يتم إنشاء نقاط الاستعادة تلقائياً.',
			'history.chaptersCount' => '{count} فصول',
			'history.metadata' => '{date} · {chapters} · {reason}',
			'dialogs.createNewBook' => 'إنشاء كتاب جديد',
			'dialogs.importMarkdownBook' => 'استيراد كتاب Markdown',
			'dialogs.create' => 'إنشاء',
			'dialogs.import' => 'استيراد',
			'dialogs.chapterTitle' => 'عنوان الفصل',
			'dialogs.versionMessage' => 'رسالة الإصدار',
			'dialogs.bookTitle' => 'عنوان الكتاب',
			'dialogs.bookTitleHint' => 'كتابي الجديد',
			_ => null,
		};
	}
}
