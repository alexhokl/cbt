import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const RecordList(),
    );
  }
}
