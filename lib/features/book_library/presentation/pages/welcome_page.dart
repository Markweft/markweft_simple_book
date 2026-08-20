import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

final class WelcomePage extends StatelessWidget {
  const WelcomePage({
    required this.isBusy,
    required this.errorMessage,
    required this.recentProjects,
    required this.onCreateBook,
    required this.onOpenBook,
    required this.onImportMarkdown,
    required this.onOpenRecent,
    required this.onRemoveRecent,
    super.key,
  });

  final bool isBusy;
  final String? errorMessage;
  final List<String> recentProjects;
  final VoidCallback onCreateBook;
  final VoidCallback onOpenBook;
  final VoidCallback onImportMarkdown;
  final ValueChanged<String> onOpenRecent;
  final ValueChanged<String> onRemoveRecent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surface,
                    scheme.surfaceContainerLow.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return ListView(
                            padding: EdgeInsets.fromLTRB(
                              constraints.maxWidth < 760 ? 20 : 36,
                              26,
                              constraints.maxWidth < 760 ? 20 : 36,
                              42,
                            ),
                            children: [
                              _Hero(
                                onCreateBook: isBusy ? null : onCreateBook,
                                onOpenBook: isBusy ? null : onOpenBook,
                              ),
                              const SizedBox(height: 28),
                              if (errorMessage != null) ...[
                                _ErrorBanner(message: errorMessage!),
                                const SizedBox(height: 24),
                              ],
                              _QuickActions(
                                onCreateBook: isBusy ? null : onCreateBook,
                                onOpenBook: isBusy ? null : onOpenBook,
                                onImportMarkdown:
                                    isBusy ? null : onImportMarkdown,
                              ),
                              const SizedBox(height: 34),
                              _RecentSection(
                                recentProjects: recentProjects,
                                onOpenRecent: onOpenRecent,
                                onRemoveRecent: onRemoveRecent,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isBusy)
            Positioned.fill(
              child: ColoredBox(
                color: scheme.scrim.withValues(alpha: 0.28),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                          SizedBox(width: 12),
                          Text('Opening book...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 20,
              color: scheme.onPrimary,
            ),
          ),
          const SizedBox(width: 11),
          Text(
            'Markweft',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 15,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Local-first',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _Hero extends StatelessWidget {
  const _Hero({
    required this.onCreateBook,
    required this.onOpenBook,
  });

  final VoidCallback? onCreateBook;
  final VoidCallback? onOpenBook;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Markdown publishing workspace',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Write once.\nPublish beautifully.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: compact ? 38 : 46,
                      height: 1.04,
                    ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 610),
                child: Text(
                  'Build long-form books with chapters, version history, '
                  'PDF layouts and reflowable EPUB output — all inside one .mdw project.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onCreateBook,
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: const Text('New book'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenBook,
                    icon: const Icon(Icons.folder_open_rounded, size: 19),
                    label: const Text('Open book'),
                  ),
                ],
              ),
            ],
          );

          final visual = Container(
            constraints: const BoxConstraints(minHeight: 220),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: const _BookVisual(),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: 24),
                visual,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 30),
              Expanded(flex: 4, child: visual),
            ],
          );
        },
      ),
    );
  }
}

final class _BookVisual extends StatelessWidget {
  const _BookVisual();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget page({required bool front}) {
      return Expanded(
        child: Container(
          height: 178,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: front ? 78 : 52,
                height: 7,
                decoration: BoxDecoration(
                  color: front ? scheme.primary : scheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 11),
              for (final width in [0.92, 0.78, 0.86, 0.68]) ...[
                FractionallySizedBox(
                  widthFactor: width,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
              ],
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  front ? 'PDF' : 'EPUB',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        page(front: true),
        Transform.translate(
          offset: const Offset(-8, 12),
          child: SizedBox(width: 122, child: page(front: false)),
        ),
      ],
    );
  }
}

final class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onCreateBook,
    required this.onOpenBook,
    required this.onImportMarkdown,
  });

  final VoidCallback? onCreateBook;
  final VoidCallback? onOpenBook;
  final VoidCallback? onImportMarkdown;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900 ? 3 : width >= 620 ? 2 : 1;
        final gap = 12.0;
        final cardWidth = (width - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _ActionCard(
              width: cardWidth,
              icon: Icons.add_rounded,
              title: 'Create book',
              description: 'Start a new structured .mdw project.',
              onTap: onCreateBook,
            ),
            _ActionCard(
              width: cardWidth,
              icon: Icons.folder_open_rounded,
              title: 'Open project',
              description: 'Continue editing an existing Markweft book.',
              onTap: onOpenBook,
            ),
            _ActionCard(
              width: cardWidth,
              icon: Icons.upload_file_rounded,
              title: 'Import Markdown',
              description: 'Convert a Markdown manuscript into chapters.',
              onTap: onImportMarkdown,
            ),
          ],
        );
      },
    );
  }
}

final class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: scheme.onPrimaryContainer, size: 21),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _RecentSection extends StatelessWidget {
  const _RecentSection({
    required this.recentProjects,
    required this.onOpenRecent,
    required this.onRemoveRecent,
  });

  final List<String> recentProjects;
  final ValueChanged<String> onOpenRecent;
  final ValueChanged<String> onRemoveRecent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent books', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            if (recentProjects.isNotEmpty)
              Text(
                '${recentProjects.length} project${recentProjects.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentProjects.isEmpty)
          const _EmptyRecentBooks()
        else
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < recentProjects.length; index++) ...[
                  _RecentBookTile(
                    projectPath: recentProjects[index],
                    onOpen: () => onOpenRecent(recentProjects[index]),
                    onRemove: () => onRemoveRecent(recentProjects[index]),
                  ),
                  if (index != recentProjects.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

final class _RecentBookTile extends StatelessWidget {
  const _RecentBookTile({
    required this.projectPath,
    required this.onOpen,
    required this.onRemove,
  });

  final String projectPath;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.menu_book_outlined, size: 20),
      ),
      title: Text(
        path.basenameWithoutExtension(projectPath),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        projectPath,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onOpen,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Open book',
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          ),
          IconButton(
            tooltip: 'Remove from recent books',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

final class _EmptyRecentBooks extends StatelessWidget {
  const _EmptyRecentBooks();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your recent books will appear here.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.error.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
