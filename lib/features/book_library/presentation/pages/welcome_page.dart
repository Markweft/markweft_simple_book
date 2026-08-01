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
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
                  children: [
                    const _WelcomeHeader(),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        _ActionCard(
                          icon: Icons.add_circle_outline,
                          title: 'New book',
                          description:
                              'Create a new compressed Markweft project.',
                          onTap: isBusy ? null : onCreateBook,
                        ),
                        _ActionCard(
                          icon: Icons.folder_open_outlined,
                          title: 'Open book',
                          description: 'Open an existing .mdw project.',
                          onTap: isBusy ? null : onOpenBook,
                        ),
                        _ActionCard(
                          icon: Icons.file_upload_outlined,
                          title: 'Import Markdown',
                          description:
                              'Convert an existing .md file into a .mdw book.',
                          onTap: isBusy ? null : onImportMarkdown,
                        ),
                      ],
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline),
                            const SizedBox(width: 12),
                            Expanded(child: Text(errorMessage!)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 42),
                    Text(
                      'Recent books',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 14),
                    if (recentProjects.isEmpty)
                      const _EmptyRecentBooks()
                    else
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var index = 0;
                                index < recentProjects.length;
                                index++) ...[
                              _RecentBookTile(
                                projectPath: recentProjects[index],
                                onOpen: () =>
                                    onOpenRecent(recentProjects[index]),
                                onRemove: () =>
                                    onRemoveRecent(recentProjects[index]),
                              ),
                              if (index != recentProjects.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (isBusy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.menu_book_rounded, size: 38),
        ),
        const SizedBox(height: 20),
        Text(
          'Markweft',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create Markdown books, preview their pages, and keep everything in one .mdw file.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 348,
      height: 170,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(description),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentBookTile extends StatelessWidget {
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
    return ListTile(
      leading: const Icon(Icons.book_outlined),
      title: Text(path.basenameWithoutExtension(projectPath)),
      subtitle: Text(
        projectPath,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onOpen,
      trailing: IconButton(
        tooltip: 'Remove from recent books',
        onPressed: onRemove,
        icon: const Icon(Icons.close),
      ),
    );
  }
}

class _EmptyRecentBooks extends StatelessWidget {
  const _EmptyRecentBooks();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.history),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'No recent books. Create, open, or import your first project.',
            ),
          ),
        ],
      ),
    );
  }
}
