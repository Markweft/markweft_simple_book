import 'dart:convert';

import 'package:markweft_template_simple/markweft_template_simple.dart';

final class BookSettingsJson {
  const BookSettingsJson._();

  static String encode(BookSettings settings) {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'templateId': settings.templateId,
      'pageSize': settings.pageSize.name,
      'orientation': settings.orientation.name,
      'margin': settings.margin,
      'contentPadding': settings.contentPadding,
      'defaultColumns': settings.defaultColumns,
      'languageCode': settings.languageCode,
      'direction': settings.direction.name,
      'typography': <String, Object?>{
        'fontFamily': settings.typography.fontFamily,
        'fontSize': settings.typography.fontSize,
        'fontWeight': settings.typography.fontWeight,
        'lineHeight': settings.typography.lineHeight,
        'alignment': settings.typography.alignment.name,
      },
    });
  }

  static BookSettings decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Book settings must be a JSON object.');
    }

    final typographyJson = decoded['typography'];
    final typography = typographyJson is Map<String, dynamic>
        ? BookTypographySettings(
            fontFamily: _nullableString(typographyJson['fontFamily']),
            fontSize: _double(typographyJson['fontSize'], 12),
            fontWeight: _int(typographyJson['fontWeight'], 400),
            lineHeight: _double(typographyJson['lineHeight'], 1.5),
            alignment: _enumValue(
              BookTextAlignment.values,
              typographyJson['alignment'],
              BookTextAlignment.justify,
            ),
          )
        : const BookTypographySettings();

    return BookSettings(
      templateId: _string(decoded['templateId'], 'markweft.simple'),
      pageSize: _enumValue(
        BookPageSize.values,
        decoded['pageSize'],
        BookPageSize.a4,
      ),
      orientation: _enumValue(
        BookPageOrientation.values,
        decoded['orientation'],
        BookPageOrientation.portrait,
      ),
      margin: _double(decoded['margin'], 24),
      contentPadding: _double(decoded['contentPadding'], 48),
      defaultColumns: _columns(decoded['defaultColumns']),
      languageCode: _string(decoded['languageCode'], 'en'),
      direction: _enumValue(
        BookDirection.values,
        decoded['direction'],
        BookDirection.ltr,
      ),
      typography: typography,
    );
  }

  static String _string(Object? value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int _int(Object? value, int fallback) {
    return value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  }

  static int _columns(Object? value) {
    final parsed = _int(value, 1);
    if (parsed < 1) return 1;
    if (parsed > 3) return 3;
    return parsed;
  }

  static double _double(Object? value, double fallback) {
    return value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? fallback;
  }

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? raw,
    T fallback,
  ) {
    final name = raw?.toString();
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
