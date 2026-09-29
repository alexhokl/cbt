// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'cbt';

  @override
  String get tabToChallenge => 'To challenge';

  @override
  String get tabChallenged => 'Challenged';

  @override
  String get tabMaps => 'Maps of worry';

  @override
  String get menuBiases => 'Cognitive biases';

  @override
  String get menuSettings => 'Settings';

  @override
  String get emptyToChallenge =>
      'Nothing waiting. Records you write appear here until you work through them.';

  @override
  String get emptyChallenged =>
      'Nothing here yet. Records appear here once you have worked through them.';

  @override
  String get emptyMaps => 'No maps of worry yet.';

  @override
  String get newThoughtRecord => 'New thought record';

  @override
  String get editThoughtRecord => 'Edit thought record';

  @override
  String get newMapOfWorry => 'New map of worry';

  @override
  String get editMapOfWorry => 'Edit map of worry';

  @override
  String get fieldEvent => 'What happened';

  @override
  String get fieldEventHint => 'The situation, as plainly as you can put it';

  @override
  String get fieldWhen => 'When it happened';

  @override
  String get fieldWhenUnset => 'Not set';

  @override
  String fieldWhenWritten(String date) {
    return 'Written $date';
  }

  @override
  String get fieldThoughts => 'Thoughts';

  @override
  String get fieldFeelings => 'Feelings';

  @override
  String get fieldAlternativeView => 'Another way to look at this';

  @override
  String get fieldFeelingsNow => 'How I feel now';

  @override
  String get fieldMeaning => 'What these thoughts mean';

  @override
  String get fieldSensations => 'Physical sensations';

  @override
  String get fieldBehaviour => 'What I did as a result';

  @override
  String get addThought => 'Add a thought';

  @override
  String get addFeeling => 'Add a feeling';

  @override
  String get thoughtHint => 'What went through your mind';

  @override
  String get feelingNameHint => 'Feeling';

  @override
  String feelingRating(int rating) {
    return 'How strongly: $rating%';
  }

  @override
  String get feelingUnrated => 'Not rated';

  @override
  String get markStrongest => 'Strongest thought';

  @override
  String get strongest => 'strongest';

  @override
  String get challenge => 'Work through this';

  @override
  String challengeTitle(int id) {
    return 'Working through record $id';
  }

  @override
  String get challengeIntro =>
      'This is what you wrote at the time. Read it back, then answer the questions that follow.';

  @override
  String get challengeStepBiases => 'Which of these describes the thinking?';

  @override
  String get thoughtIsFactual => 'This one was accurate';

  @override
  String get thoughtFactualBadge => 'accurate';

  @override
  String get challengeStepAlternative =>
      'Is there any other way you can look at this?';

  @override
  String get challengeStepRerate => 'How strongly do you feel these now?';

  @override
  String get challengeStepFeelingsNow => 'How do you feel now?';

  @override
  String get challengeQuestionsTitle => 'Questions that may help';

  @override
  String get challengeSave => 'Save';

  @override
  String challengedOn(String date) {
    return 'Worked through on $date';
  }

  @override
  String get notYetChallenged => 'Not worked through yet';

  @override
  String get alternativeReading => 'An alternative reading of the same event';

  @override
  String get theMapThisReworks => 'The map this reworks';

  @override
  String get createAlternative => 'Write an alternative reading';

  @override
  String get biasesTitle => 'Cognitive biases';

  @override
  String get biasBuiltin => 'Builtin';

  @override
  String get biasAdd => 'Add a bias';

  @override
  String get biasBuiltinLocked =>
      'The builtin biases cannot be changed, so your past records always read the same way.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBackendUrl => 'Server address';

  @override
  String get settingsBackendUrlHelp =>
      'The address of your cbt server, reachable over your tailnet.';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacy =>
      'Records are stored on your server and are not encrypted at rest.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get retry => 'Try again';

  @override
  String get deleteRecordTitle => 'Delete this record?';

  @override
  String get deleteRecordBody =>
      'This removes the record and everything on it. There is no undo.';

  @override
  String get eventRequired => 'Write down what happened before saving.';

  @override
  String get loadFailed => 'Could not reach the server.';
}
