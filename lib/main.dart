import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  runApp(const MarkweftSimpleBookApp());
}

class MarkweftSimpleBookApp extends StatelessWidget {
  const MarkweftSimpleBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markweft Simple Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A4036)),
        scaffoldBackgroundColor: const Color(0xFFE8E3DB),
        useMaterial3: true,
      ),
      home: const SimpleBookPage(),
    );
  }
}

class SimpleBookPage extends StatefulWidget {
  const SimpleBookPage({super.key});

  @override
  State<SimpleBookPage> createState() => _SimpleBookPageState();
}

class _SimpleBookPageState extends State<SimpleBookPage> {
  static const String _initialMarkdown = '''
# The Lost Kingdom

Welcome to **The Lost Kingdom**, a forgotten land filled with ancient ruins,
mysterious creatures, and powerful artifacts.

## Your Journey

Every traveler must prepare before entering the kingdom.

- Choose your character
- Prepare your equipment
- Study the ancient map
- Enter the forgotten gate

## Important Rule

> Courage is valuable, but preparation keeps you alive.

The journey begins here.
''';

  late final TextEditingController _controller;
  late String _markdown;

  @override
  void initState() {
    super.initState();

    _markdown = _initialMarkdown;
    _controller = TextEditingController(text: _initialMarkdown);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateMarkdown(String value) {
    setState(() {
      _markdown = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markweft Simple Book')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              children: [
                Expanded(
                  child: _MarkdownEditor(
                    controller: _controller,
                    onChanged: _updateMarkdown,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _BookPreview(markdown: _markdown)),
              ],
            );
          }

          return Column(
            children: [
              Expanded(
                child: _MarkdownEditor(
                  controller: _controller,
                  onChanged: _updateMarkdown,
                ),
              ),
              const Divider(height: 1),
              Expanded(child: _BookPreview(markdown: _markdown)),
            ],
          );
        },
      ),
    );
  }
}

class _MarkdownEditor extends StatelessWidget {
  const _MarkdownEditor({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Markdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: 'Write Markdown here...',
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookPreview extends StatelessWidget {
  const _BookPreview({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE8E3DB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 794),
            child: AspectRatio(
              aspectRatio: 210 / 297,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      color: Color(0x33000000),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 64,
                    vertical: 72,
                  ),
                  child: MarkdownWidget(
                    data: markdown,
                    shrinkWrap: true,
                    config: MarkdownConfig(
                      configs: [
                        H1Config(
                          style: const TextStyle(
                            color: Color(0xFF2B2520),
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        H2Config(
                          style: const TextStyle(
                            color: Color(0xFF4A4036),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        PConfig(
                          textStyle: const TextStyle(
                            color: Color(0xFF302C28),
                            fontSize: 17,
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
