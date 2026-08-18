import 'package:markweft_template_simple/markweft_template_simple.dart';

final class TemplateDescriptor {
  const TemplateDescriptor({
    required this.template,
    required this.supportedColumns,
    required this.chapterLayouts,
  });

  final BookTemplate template;
  final List<int> supportedColumns;
  final List<String> chapterLayouts;
}

final class TemplateRegistry {
  const TemplateRegistry._();

  static const List<TemplateDescriptor> available = <TemplateDescriptor>[
    TemplateDescriptor(
      template: SimpleBookTemplate(),
      supportedColumns: <int>[1, 2, 3],
      chapterLayouts: <String>['chapter-first', 'default'],
    ),
  ];

  static TemplateDescriptor descriptor(String templateId) {
    for (final descriptor in available) {
      if (descriptor.template.metadata.id == templateId) return descriptor;
    }
    return available.first;
  }

  static BookTemplate resolve(String templateId) {
    return descriptor(templateId).template;
  }
}
