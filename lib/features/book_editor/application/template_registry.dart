import 'package:markweft_template_simple/markweft_template_simple.dart';

final class TemplateRegistry {
  const TemplateRegistry._();

  static const List<BookTemplate> available = <BookTemplate>[
    SimpleBookTemplate(),
  ];

  static BookTemplate resolve(String templateId) {
    for (final template in available) {
      if (template.metadata.id == templateId) return template;
    }
    return available.first;
  }

  static TemplateMetadata descriptor(String templateId) {
    return resolve(templateId).metadata;
  }

  static bool supports(
    String templateId,
    TemplateOutputPlatform platform,
  ) {
    return descriptor(templateId).outputPlatforms.contains(platform);
  }
}
