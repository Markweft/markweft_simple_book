import 'package:flutter/material.dart';
import 'package:markweft_simple_book/app/markweft_app.dart';
import 'package:markweft_simple_book/i18n/strings.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  runApp(
    TranslationProvider(
      child: const MarkweftApp(),
    ),
  );
}
