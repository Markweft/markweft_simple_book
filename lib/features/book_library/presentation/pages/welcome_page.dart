import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

final class WelcomePage extends StatelessWidget {
  const WelcomePage({
    required this.isBusy,
    required this.errorMessage,
    required this.recentProjects,
    required this.showRecentBookPaths,
    required this.onOpenAppSettings,
    required this.onCreateBook,
    required this.onOpenBook,
    required this.onImportMarkdown,
    required this.onConvertBookVersion,
    required this.onOpenRecent,
    required this.onRemoveRecent,
    super.key,
  });

  final bool isBusy;
  final String? errorMessage;
  final List<String> recentProjects;
  final bool showRecentBookPaths;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onCreateBook;
  final VoidCallback onOpenBook;
  final VoidCallback onImportMarkdown;
  final VoidCallback onConvertBookVersion;
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
                _TopBar(onOpenSettings: onOpenAppSettings),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 44),
                        children: [
                          _Hero(
                            onCreateBook: isBusy ? null : onCreateBook,
                            onOpenBook: isBusy ? null : onOpenBook,
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 20),
                            _ErrorBanner(message: errorMessage!),
                          ],
                          const SizedBox(height: 24),
                          _QuickActions(
                            onCreateBook: isBusy ? null : onCreateBook,
                            onOpenBook: isBusy ? null : onOpenBook,
                            onImportMarkdown:
                                isBusy ? null : onImportMarkdown,
                            onConvertBookVersion:
                                isBusy ? null : onConvertBookVersion,
                          ),
                          const SizedBox(height: 34),
                          _RecentSection(
                            recentProjects: recentProjects,
                            showPaths: showRecentBookPaths,
                            onOpenRecent: onOpenRecent,
                            onRemoveRecent: onRemoveRecent,
                          ),
                        ],
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
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

final class _TopBar extends StatelessWidget {
  const _TopBar({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

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
          Text('Markweft', style: Theme.of(context).textTheme.titleLarge),
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
                const Text('Local-first'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'App settings',
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

final class _Hero extends StatelessWidget {
  const _Hero({required this.onCreateBook, required this.onOpenBook});

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
                child: const Text('Markdown publishing workspace'),
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
              Text(
                'Build long-form books with chapters, version history, PDF layouts and reflowable EPUB output.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onCreateBook,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New book'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenBook,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Open book'),
                  ),
                ],
              ),
            ],
          );

          if (compact) return copy;

          return Row(
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 30),
              Expanded(
                flex: 4,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 74,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onCreateBook,
    required this.onOpenBook,
    required this.onImportMarkdown,
    required this.onConvertBookVersion,
  });

  final VoidCallback? onCreateBook;
  final VoidCallback? onOpenBook;
  final VoidCallback? onImportMarkdown;
  final VoidCallback? onConvertBookVersion;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        const gap = 12.0;
        final width =
            (constraints.maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _ActionCard(
              width: width,
              icon: Icons.add_rounded,
              title: 'Create book',
              subtitle: 'Start a new structured .mdw project.',
              onTap: onCreateBook,
            ),
            _ActionCard(
              width: width,
              icon: Icons.folder_open_rounded,
              title: 'Open project',
              subtitle: 'Continue an existing Markweft book.',
              onTap: onOpenBook,
            ),
            _ActionCard(
              width: width,
              icon: Icons.upload_file_rounded,
              title: 'Import Markdown',
              subtitle: 'Convert a Markdown manuscript into a book.',
              onTap: onImportMarkdown,
            ),
            _ActionCard(
              width: width,
              icon: Icons.swap_horiz_rounded,
              title: 'Convert version',
              subtitle: 'Create a compatible MDW v1 or v3 copy.',
              onTap: onConvertBookVersion,
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
    required this.subtitle,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
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
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 18),
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
    required this.showPaths,
    required this.onOpenRecent,
    required this.onRemoveRecent,
  });

  final List<String> recentProjects;
  final bool showPaths;
  final ValueChanged<String> onOpenRecent;
  final ValueChanged<String> onRemoveRecent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent books', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            Text('${recentProjects.length} projects'),
          ],
        ),
        const SizedBox(height: 12),
        if (recentProjects.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.history_rounded),
                  SizedBox(width: 12),
                  Text('Your recent books will appear here.'),
                ],
              ),
            ),
          )
        else
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < recentProjects.length; i++) ...[
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(
                      path.basenameWithoutExtension(recentProjects[i]),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: showPaths
                        ? Text(
                            recentProjects[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => onOpenRecent(recentProjects[i]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Open book',
                          onPressed: () => onOpenRecent(recentProjects[i]),
                          icon: const Icon(Icons.arrow_forward_rounded),
                        ),
                        IconButton(
                          tooltip: 'Remove from recent books',
                          onPressed: () => onRemoveRecent(recentProjects[i]),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  if (i != recentProjects.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
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
