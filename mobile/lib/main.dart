import 'package:flutter/material.dart';
import 'package:flutter_helper/ui.dart';

import 'l10n/app_localizations.dart';
import 'widgets/record_list.dart';

void main() {
  runApp(const CbtApp());
}

/// CbtApp is a journal for cognitive behavioural therapy thought records.
///
/// It records what you write and shows it back to you. It never interprets an
/// entry, scores it, or offers advice: the questions it shows during the
/// challenge flow are quotations from the method, not the application forming
/// a view about what you wrote.
class CbtApp extends StatelessWidget {
  const CbtApp({super.key});

  static final _themes = themesFromSeed(Colors.teal);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _themes.light,
      darkTheme: _themes.dark,
      home: const RecordList(),
    );
  }
}
