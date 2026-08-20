import 'package:markweft_template_simple/markweft_template_simple.dart';

final class TemplateDescriptor {
  const TemplateDescriptor({required this.template});

  final BookTemplate template;

  List<int> get supportedColumns => template.metadata.supportedColumns;

  List<String> get chapterLayouts => template.metadata.chapterLayouts;

  Set<TemplateOutputPlatform> get outputPlatforms =>
      template.metadata.outputPlatforms;

  Set<TemplateBookSetting> get supportedBookSettings =>
      template.metadata.supportedBookSettings;

  Set<TemplateToolbarAction> get toolbarActions =>
      template.metadata.toolbarActions;

  bool get supportsPdf => template.metadata.supportsPdf;

  bool get supportsEpub => template.metadata.supportsEpub;

  bool supportsSetting(TemplateBookSetting setting) {
    return supportedBookSettings.contains(setting);
  }
}

final class TemplateRegistry {
  const TemplateRegistry._();

  static const List<TemplateDescriptor> available = <TemplateDescriptor>[
    TemplateDescriptor(template: SimpleBookTemplate()),
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
