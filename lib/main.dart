import 'package:flutter/material.dart';
import 'package:markweft_simple_book/app/markweft_app.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  runApp(
    TranslationProvider(
      child: const MarkweftApp(),
    ),
  );
}
