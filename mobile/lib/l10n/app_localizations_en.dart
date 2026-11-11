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
  String get tabExperiments => 'Experiments';

  @override
  String get tabDataLogs => 'Data logs';

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
  String get emptyExperiments => 'No behavioural experiments yet.';

  @override
  String get newThoughtRecord => 'New thought record';

  @override
  String get editThoughtRecord => 'Edit thought record';

  @override
  String get newMapOfWorry => 'New map of worry';

  @override
  String get editMapOfWorry => 'Edit map of worry';

  @override
  String get newExperiment => 'New behavioural experiment';

  @override
  String get editExperiment => 'Edit behavioural experiment';

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
  String get fieldEvidence => 'Evidence for it';

  @override
  String get fieldFeelingsNow => 'How I feel now';

  @override
  String get fieldMeaning => 'What these thoughts mean';

  @override
  String get fieldSensations => 'Physical sensations';

  @override
  String get fieldBehaviour => 'What I did as a result';

  @override
  String get fieldPlan => 'What are you going to try?';

  @override
  String get fieldExperimentWhen => 'When you try it';

  @override
  String get fieldPrediction =>
      'What do you predict will happen and how will you feel?';

  @override
  String get fieldPredictedFeelings => 'Feelings you predict';

  @override
  String get fieldOutcome => 'What actually happened?';

  @override
  String get fieldLearned => 'What have you learned from this?';

  @override
  String get fieldBuildOn => 'How can you build on this?';

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
  String get thoughtEvidence => 'What evidence supports this thought?';

  @override
  String thoughtEvidenceLabel(String evidence) {
    return 'Evidence: $evidence';
  }

  @override
  String get editThoughtEvidence => 'Evidence for this thought';

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
  String get challengeStepEvidence =>
      'What evidence do you have to support this alternative view?';

  @override
  String get challengeStepBelief =>
      'How much do you still believe your initial thoughts?';

  @override
  String thoughtBelief(int rating) {
    return 'Still believe $rating%';
  }

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
  String get completeExperiment => 'Write up how it went';

  @override
  String completeTitle(int id) {
    return 'Writing up experiment $id';
  }

  @override
  String get completeIntro =>
      'This is what you planned and predicted. Read it back, then write down how it went.';

  @override
  String get completeStepRerate => 'How strongly did you actually feel these?';

  @override
  String get completeStepNewFeelings =>
      'Did you feel anything you did not predict?';

  @override
  String completedOn(String date) {
    return 'Written up on $date';
  }

  @override
  String get notYetCompleted => 'Not written up yet';

  @override
  String get planRequired =>
      'Write down what you are going to try before saving.';

  @override
  String get emptyDataLogs => 'No positive data logs yet.';

  @override
  String get newDataLog => 'New positive data log';

  @override
  String get editDataLog => 'Edit positive data log';

  @override
  String get fieldBelief => 'Self-critical belief';

  @override
  String get fieldAlternativeBelief => 'Alternative belief';

  @override
  String get fieldBelieveBelief =>
      'How strongly I believe the self-critical belief';

  @override
  String get fieldBelieveAlternative =>
      'How strongly I believe the alternative belief';

  @override
  String get fieldBeliefRatings => 'How strongly I believe this';

  @override
  String get fieldDataLogEvidence =>
      'Evidence to support the alternative belief and weaken the old belief';

  @override
  String get fieldEvidenceWhen => 'When it happened';

  @override
  String beliefRatingLine(String belief, String alternative) {
    return 'Belief $belief · alternative $alternative';
  }

  @override
  String get addEvidence => 'Add evidence';

  @override
  String get rateAgain => 'Rate again';

  @override
  String get rateAgainTitle => 'How strongly do you believe each now?';

  @override
  String get ratingRequired => 'Move at least one slider before saving.';

  @override
  String get beliefRequired => 'Write down the belief before saving.';

  @override
  String get deleteEvidenceTitle => 'Delete this evidence?';

  @override
  String get deleteEvidenceBody => 'There is no undo.';

  @override
  String evidenceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces of evidence',
      one: '1 piece of evidence',
      zero: 'No evidence yet',
    );
    return '$_temp0';
  }

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
