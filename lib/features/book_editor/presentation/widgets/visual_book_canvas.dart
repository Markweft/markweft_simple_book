import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

final class VisualBookCanvas extends StatefulWidget {
  const VisualBookCanvas({
    required this.template,
    required this.settings,
    required this.markdown,
    required this.chapterTitle,
    super.key,
  });

  final BookTemplate template;
  final BookSettings settings;
  final String markdown;
  final String? chapterTitle;

  @override
  State<VisualBookCanvas> createState() => _VisualBookCanvasState();
}

final class _VisualBookCanvasState extends State<VisualBookCanvas> {
  static const double _minZoom = 0.25;
  static const double _maxZoom = 2;
  static const double _zoomStep = 0.125;
  static const double _canvasPadding = 36;

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  BookDocument? _document;
  Object? _parseError;
  List<GlobalKey> _pageKeys = <GlobalKey>[];
  int _selectedPageIndex = 0;
  double _zoom = 1;
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _parseDocument();
  }

  @override
  void didUpdateWidget(covariant VisualBookCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markdown != widget.markdown ||
        oldWidget.settings != widget.settings ||
        oldWidget.template.metadata.id != widget.template.metadata.id) {
      _parseDocument();
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _parseDocument() {
    try {
      final document = widget.template.parse(
        widget.markdown,
        settings: widget.settings,
      );
      _document = document;
      _parseError = null;
      _syncPageKeys(document.pages.length);
    } on Object catch (error) {
      _document = null;
      _parseError = error;
      _pageKeys = <GlobalKey>[];
      _selectedPageIndex = 0;
    }
  }

  void _syncPageKeys(int count) {
    if (_pageKeys.length != count) {
      _pageKeys = List<GlobalKey>.generate(
        count,
        (index) => GlobalKey(debugLabel: 'canvas-page-$index'),
      );
    }
    if (count == 0) {
      _selectedPageIndex = 0;
    } else {
      _selectedPageIndex = math.min(_selectedPageIndex, count - 1);
    }
  }

  void _setZoom(double value) {
    final next = value.clamp(_minZoom, _maxZoom).toDouble();
    if ((next - _zoom).abs() < 0.001) return;
    setState(() => _zoom = next);
  }

  void _fitWidth() {
    final document = _document;
    if (document == null || document.pages.isEmpty || _viewportSize.width <= 0) {
      return;
    }
    final widestPage = document.pages
        .map((page) => page.settings.previewWidth)
        .reduce(math.max);
    final availableWidth = math.max(
      120.0,
      _viewportSize.width - (_canvasPadding * 2),
    );
    _setZoom(availableWidth / widestPage);
  }

  void _fitPage() {
    final document = _document;
    if (document == null || document.pages.isEmpty || _viewportSize.isEmpty) {
      return;
    }
    final page = document.pages[_selectedPageIndex];
    final baseWidth = page.settings.previewWidth;
    final baseHeight = baseWidth / page.settings.aspectRatio;
    final availableWidth = math.max(
      120.0,
      _viewportSize.width - (_canvasPadding * 2),
    );
    final availableHeight = math.max(
      120.0,
      _viewportSize.height - (_canvasPadding * 2),
    );
    _setZoom(
      math.min(
        availableWidth / baseWidth,
        availableHeight / baseHeight,
      ),
    );
  }

  void _goToPage(int index) {
    final document = _document;
    if (document == null || document.pages.isEmpty) return;
    final target = index.clamp(0, document.pages.length - 1);
    if (_selectedPageIndex != target) {
      setState(() => _selectedPageIndex = target);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _pageKeys[target].currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: 0.04,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final document = _document;
    final pageCount = document?.pages.length ?? 0;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          _CanvasToolbar(
            title: tr.editor.workspace.canvasTitle,
            chapterTitle: widget.chapterTitle,
            pageLabel: pageCount == 0
                ? tr.editor.workspace.canvasEmpty
                : tr.editor.workspace.canvasPage(
                    current: _selectedPageIndex + 1,
                    total: pageCount,
                  ),
            zoom: _zoom,
            canGoPrevious: _selectedPageIndex > 0,
            canGoNext: _selectedPageIndex + 1 < pageCount,
            onPrevious: () => _goToPage(_selectedPageIndex - 1),
            onNext: () => _goToPage(_selectedPageIndex + 1),
            onZoomOut: () => _setZoom(_zoom - _zoomStep),
            onZoomIn: () => _setZoom(_zoom + _zoomStep),
            onResetZoom: () => _setZoom(1),
            onFitWidth: _fitWidth,
            onFitPage: _fitPage,
          ),
          const Divider(height: 1),
          Expanded(
            child: switch ((_parseError, document)) {
              (final error?, _) => _CanvasError(error: error),
              (_, null) => const SizedBox.shrink(),
              (_, final value) when value.pages.isEmpty => Center(
                  child: Text(tr.editor.workspace.canvasEmpty),
                ),
              (_, final value) => LayoutBuilder(
                  builder: (context, constraints) {
                    final showNavigator = constraints.maxWidth >= 640;
                    return Row(
                      children: [
                        if (showNavigator) ...[
                          SizedBox(
                            width: 82,
                            child: _PageNavigator(
                              pages: value.pages,
                              selectedIndex: _selectedPageIndex,
                              title: tr.editor.workspace.canvasPages,
                              onSelected: _goToPage,
                            ),
                          ),
                          const VerticalDivider(width: 1),
                        ],
                        Expanded(
                          child: _CanvasViewport(
                            template: widget.template,
                            settings: widget.settings,
                            pages: value.pages,
                            pageKeys: _pageKeys,
                            zoom: _zoom,
                            verticalController: _verticalController,
                            horizontalController: _horizontalController,
                            onViewportSizeChanged: (value) =>
                                _viewportSize = value,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}

final class _CanvasToolbar extends StatelessWidget {
  const _CanvasToolbar({
    required this.title,
    required this.chapterTitle,
    required this.pageLabel,
    required this.zoom,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onResetZoom,
    required this.onFitWidth,
    required this.onFitPage,
  });

  final String title;
  final String? chapterTitle;
  final String pageLabel;
  final double zoom;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onResetZoom;
  final VoidCallback onFitWidth;
  final VoidCallback onFitPage;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final percentage = '${(zoom * 100).round()}%';

    return Material(
      color: scheme.surfaceContainerLowest,
      child: SizedBox(
        height: 44,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.dashboard_customize_outlined, size: 17, color: scheme.primary),
              const SizedBox(width: 7),
              Text(
                chapterTitle == null ? title : '$title · $chapterTitle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 16),
              IconButton(
                tooltip: tr.editor.workspace.canvasPagePrevious,
                onPressed: canGoPrevious ? onPrevious : null,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left_rounded, size: 19),
              ),
              Text(pageLabel, style: Theme.of(context).textTheme.labelMedium),
              IconButton(
                tooltip: tr.editor.workspace.canvasPageNext,
                onPressed: canGoNext ? onNext : null,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right_rounded, size: 19),
              ),
              const SizedBox(width: 8),
              const SizedBox(height: 22, child: VerticalDivider(width: 1)),
              const SizedBox(width: 8),
              IconButton(
                tooltip: tr.editor.workspace.canvasZoomOut,
                onPressed: onZoomOut,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_rounded, size: 18),
              ),
              TextButton(
                onPressed: onResetZoom,
                child: Text(percentage),
              ),
              IconButton(
                tooltip: tr.editor.workspace.canvasZoomIn,
                onPressed: onZoomIn,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_rounded, size: 18),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: onFitWidth,
                icon: const Icon(Icons.fit_screen_outlined, size: 17),
                label: Text(tr.editor.workspace.canvasFitWidth),
              ),
              TextButton.icon(
                onPressed: onFitPage,
                icon: const Icon(Icons.crop_portrait_outlined, size: 17),
                label: Text(tr.editor.workspace.canvasFitPage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PageNavigator extends StatelessWidget {
  const _PageNavigator({
    required this.pages,
    required this.selectedIndex,
    required this.title,
    required this.onSelected,
  });

  final List<BookPage> pages;
  final int selectedIndex;
  final String title;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                final selected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: selected
                            ? scheme.primaryContainer.withValues(alpha: 0.55)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? scheme.primary : scheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: page.settings.aspectRatio,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: scheme.outlineVariant),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: selected
                                            ? scheme.primary
                                            : scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _CanvasViewport extends StatelessWidget {
  const _CanvasViewport({
    required this.template,
    required this.settings,
    required this.pages,
    required this.pageKeys,
    required this.zoom,
    required this.verticalController,
    required this.horizontalController,
    required this.onViewportSizeChanged,
  });

  final BookTemplate template;
  final BookSettings settings;
  final List<BookPage> pages;
  final List<GlobalKey> pageKeys;
  final double zoom;
  final ScrollController verticalController;
  final ScrollController horizontalController;
  final ValueChanged<Size> onViewportSizeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        onViewportSizeChanged(Size(constraints.maxWidth, constraints.maxHeight));
        return Scrollbar(
          controller: verticalController,
          child: SingleChildScrollView(
            controller: verticalController,
            child: SingleChildScrollView(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(_VisualBookCanvasState._canvasPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var index = 0; index < pages.length; index++) ...[
                        _CanvasPage(
                          key: pageKeys[index],
                          template: template,
                          settings: settings,
                          page: pages[index],
                          zoom: zoom,
                        ),
                        if (index < pages.length - 1) const SizedBox(height: 28),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _CanvasPage extends StatelessWidget {
  const _CanvasPage({
    required this.template,
    required this.settings,
    required this.page,
    required this.zoom,
    super.key,
  });

  final BookTemplate template;
  final BookSettings settings;
  final BookPage page;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final baseWidth = page.settings.previewWidth;
    final baseHeight = baseWidth / page.settings.aspectRatio;
    final width = baseWidth * zoom;
    final height = baseHeight * zoom;

    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 7),
                color: Color(0x24000000),
              ),
            ],
          ),
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: baseWidth,
                height: baseHeight,
                child: template.buildPage(page, settings: settings),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _CanvasError extends StatelessWidget {
  const _CanvasError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 42, color: scheme.error),
              const SizedBox(height: 12),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
