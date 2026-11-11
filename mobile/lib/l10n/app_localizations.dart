import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name, shown in the app bar.
  ///
  /// In en, this message translates to:
  /// **'cbt'**
  String get appTitle;

  /// Tab holding thought records that have not been challenged yet.
  ///
  /// In en, this message translates to:
  /// **'To challenge'**
  String get tabToChallenge;

  /// Tab holding thought records that have been challenged.
  ///
  /// In en, this message translates to:
  /// **'Challenged'**
  String get tabChallenged;

  /// Tab holding maps of worry.
  ///
  /// In en, this message translates to:
  /// **'Maps of worry'**
  String get tabMaps;

  /// Tab holding behavioural experiments.
  ///
  /// In en, this message translates to:
  /// **'Experiments'**
  String get tabExperiments;

  /// Tab holding positive data logs.
  ///
  /// In en, this message translates to:
  /// **'Data logs'**
  String get tabDataLogs;

  /// Tab holding formulations of early life experiences to thoughts and behaviours.
  ///
  /// In en, this message translates to:
  /// **'Formulations'**
  String get tabFormulations;

  /// Overflow menu entry opening the bias list.
  ///
  /// In en, this message translates to:
  /// **'Cognitive biases'**
  String get menuBiases;

  /// Overflow menu entry opening the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// Shown when there are no unchallenged records.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting. Records you write appear here until you work through them.'**
  String get emptyToChallenge;

  /// Shown when there are no challenged records.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Records appear here once you have worked through them.'**
  String get emptyChallenged;

  /// Shown when there are no maps of worry.
  ///
  /// In en, this message translates to:
  /// **'No maps of worry yet.'**
  String get emptyMaps;

  /// Shown when there are no behavioural experiments.
  ///
  /// In en, this message translates to:
  /// **'No behavioural experiments yet.'**
  String get emptyExperiments;

  /// Title of the page creating a thought record.
  ///
  /// In en, this message translates to:
  /// **'New thought record'**
  String get newThoughtRecord;

  /// Title of the page editing a thought record.
  ///
  /// In en, this message translates to:
  /// **'Edit thought record'**
  String get editThoughtRecord;

  /// Title of the page creating a map of worry.
  ///
  /// In en, this message translates to:
  /// **'New map of worry'**
  String get newMapOfWorry;

  /// Title of the page editing a map of worry.
  ///
  /// In en, this message translates to:
  /// **'Edit map of worry'**
  String get editMapOfWorry;

  /// Title of the page creating a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'New behavioural experiment'**
  String get newExperiment;

  /// Title of the page editing a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'Edit behavioural experiment'**
  String get editExperiment;

  /// Label for the event column.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get fieldEvent;

  /// Hint for the event field.
  ///
  /// In en, this message translates to:
  /// **'The situation, as plainly as you can put it'**
  String get fieldEventHint;

  /// Label for the event time.
  ///
  /// In en, this message translates to:
  /// **'When it happened'**
  String get fieldWhen;

  /// Shown when no event time has been given.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get fieldWhenUnset;

  /// Fallback shown when the user did not say when the event happened.
  ///
  /// In en, this message translates to:
  /// **'Written {date}'**
  String fieldWhenWritten(String date);

  /// Label for the thoughts section.
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get fieldThoughts;

  /// Label for the feelings section.
  ///
  /// In en, this message translates to:
  /// **'Feelings'**
  String get fieldFeelings;

  /// Label for the alternative view column.
  ///
  /// In en, this message translates to:
  /// **'Another way to look at this'**
  String get fieldAlternativeView;

  /// Label for the evidence supporting the alternative view.
  ///
  /// In en, this message translates to:
  /// **'Evidence for it'**
  String get fieldEvidence;

  /// Label for the feelings-now column.
  ///
  /// In en, this message translates to:
  /// **'How I feel now'**
  String get fieldFeelingsNow;

  /// Label for the meaning column of a map of worry.
  ///
  /// In en, this message translates to:
  /// **'What these thoughts mean'**
  String get fieldMeaning;

  /// Label for the physical sensations column.
  ///
  /// In en, this message translates to:
  /// **'Physical sensations'**
  String get fieldSensations;

  /// Label for the resultant behaviour column.
  ///
  /// In en, this message translates to:
  /// **'What I did as a result'**
  String get fieldBehaviour;

  /// Label for the plan column of a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'What are you going to try?'**
  String get fieldPlan;

  /// Label for when a behavioural experiment takes place.
  ///
  /// In en, this message translates to:
  /// **'When you try it'**
  String get fieldExperimentWhen;

  /// Label for the prediction column of a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'What do you predict will happen and how will you feel?'**
  String get fieldPrediction;

  /// Label for the feelings rated before a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'Feelings you predict'**
  String get fieldPredictedFeelings;

  /// Label for the outcome column of a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'What actually happened?'**
  String get fieldOutcome;

  /// Label for the learning column of a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'What have you learned from this?'**
  String get fieldLearned;

  /// Label for the build-on column of a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'How can you build on this?'**
  String get fieldBuildOn;

  /// Button adding a negative thought.
  ///
  /// In en, this message translates to:
  /// **'Add a thought'**
  String get addThought;

  /// Button adding a feeling.
  ///
  /// In en, this message translates to:
  /// **'Add a feeling'**
  String get addFeeling;

  /// Hint for the thought field.
  ///
  /// In en, this message translates to:
  /// **'What went through your mind'**
  String get thoughtHint;

  /// Hint for the feeling name field.
  ///
  /// In en, this message translates to:
  /// **'Feeling'**
  String get feelingNameHint;

  /// Label for the feeling intensity slider.
  ///
  /// In en, this message translates to:
  /// **'How strongly: {rating}%'**
  String feelingRating(int rating);

  /// Shown for a feeling with no rating.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get feelingUnrated;

  /// Prompt for the evidence supporting a negative thought.
  ///
  /// In en, this message translates to:
  /// **'What evidence supports this thought?'**
  String get thoughtEvidence;

  /// The evidence supporting a thought, shown beneath it.
  ///
  /// In en, this message translates to:
  /// **'Evidence: {evidence}'**
  String thoughtEvidenceLabel(String evidence);

  /// Title of the dialog editing the evidence for a thought.
  ///
  /// In en, this message translates to:
  /// **'Evidence for this thought'**
  String get editThoughtEvidence;

  /// Toggle marking a thought as the strongest.
  ///
  /// In en, this message translates to:
  /// **'Strongest thought'**
  String get markStrongest;

  /// Badge on the strongest thought.
  ///
  /// In en, this message translates to:
  /// **'strongest'**
  String get strongest;

  /// Button opening the challenge flow.
  ///
  /// In en, this message translates to:
  /// **'Work through this'**
  String get challenge;

  /// Title of the challenge page.
  ///
  /// In en, this message translates to:
  /// **'Working through record {id}'**
  String challengeTitle(int id);

  /// Introduction shown above the frozen record on the challenge page.
  ///
  /// In en, this message translates to:
  /// **'This is what you wrote at the time. Read it back, then answer the questions that follow.'**
  String get challengeIntro;

  /// Prompt for naming the biases in a thought.
  ///
  /// In en, this message translates to:
  /// **'Which of these describes the thinking?'**
  String get challengeStepBiases;

  /// Toggle recording that a thought was an accurate reading of the situation rather than a distorted one.
  ///
  /// In en, this message translates to:
  /// **'This one was accurate'**
  String get thoughtIsFactual;

  /// Badge shown on a thought that was judged accurate.
  ///
  /// In en, this message translates to:
  /// **'accurate'**
  String get thoughtFactualBadge;

  /// Prompt for the alternative view.
  ///
  /// In en, this message translates to:
  /// **'Is there any other way you can look at this?'**
  String get challengeStepAlternative;

  /// Prompt for the evidence supporting the alternative view.
  ///
  /// In en, this message translates to:
  /// **'What evidence do you have to support this alternative view?'**
  String get challengeStepEvidence;

  /// Prompt for rating how much each thought is still believed.
  ///
  /// In en, this message translates to:
  /// **'How much do you still believe your initial thoughts?'**
  String get challengeStepBelief;

  /// How much a thought is still believed after the challenge.
  ///
  /// In en, this message translates to:
  /// **'Still believe {rating}%'**
  String thoughtBelief(int rating);

  /// Prompt for re-rating the feelings.
  ///
  /// In en, this message translates to:
  /// **'How strongly do you feel these now?'**
  String get challengeStepRerate;

  /// Prompt for the feelings-now column.
  ///
  /// In en, this message translates to:
  /// **'How do you feel now?'**
  String get challengeStepFeelingsNow;

  /// Header of the list of challenge questions.
  ///
  /// In en, this message translates to:
  /// **'Questions that may help'**
  String get challengeQuestionsTitle;

  /// Button saving the challenge.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get challengeSave;

  /// Shown on a record that has been challenged.
  ///
  /// In en, this message translates to:
  /// **'Worked through on {date}'**
  String challengedOn(String date);

  /// Shown on a record that has not been challenged.
  ///
  /// In en, this message translates to:
  /// **'Not worked through yet'**
  String get notYetChallenged;

  /// Button opening the page recording the outcome of a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'Write up how it went'**
  String get completeExperiment;

  /// Title of the page recording the outcome of a behavioural experiment.
  ///
  /// In en, this message translates to:
  /// **'Writing up experiment {id}'**
  String completeTitle(int id);

  /// Introduction shown above the frozen plan on the completion page.
  ///
  /// In en, this message translates to:
  /// **'This is what you planned and predicted. Read it back, then write down how it went.'**
  String get completeIntro;

  /// Prompt for rating the predicted feelings as they were actually felt.
  ///
  /// In en, this message translates to:
  /// **'How strongly did you actually feel these?'**
  String get completeStepRerate;

  /// Prompt for adding feelings that were felt but not predicted.
  ///
  /// In en, this message translates to:
  /// **'Did you feel anything you did not predict?'**
  String get completeStepNewFeelings;

  /// Shown on a behavioural experiment whose outcome has been recorded.
  ///
  /// In en, this message translates to:
  /// **'Written up on {date}'**
  String completedOn(String date);

  /// Shown on a behavioural experiment whose outcome has not been recorded.
  ///
  /// In en, this message translates to:
  /// **'Not written up yet'**
  String get notYetCompleted;

  /// Validation message when the plan of a behavioural experiment is blank.
  ///
  /// In en, this message translates to:
  /// **'Write down what you are going to try before saving.'**
  String get planRequired;

  /// Shown when there are no positive data logs.
  ///
  /// In en, this message translates to:
  /// **'No positive data logs yet.'**
  String get emptyDataLogs;

  /// Title of the page creating a positive data log.
  ///
  /// In en, this message translates to:
  /// **'New positive data log'**
  String get newDataLog;

  /// Title of the page editing a positive data log.
  ///
  /// In en, this message translates to:
  /// **'Edit positive data log'**
  String get editDataLog;

  /// Label for the self-critical belief of a positive data log.
  ///
  /// In en, this message translates to:
  /// **'Self-critical belief'**
  String get fieldBelief;

  /// Label for the alternative belief of a positive data log.
  ///
  /// In en, this message translates to:
  /// **'Alternative belief'**
  String get fieldAlternativeBelief;

  /// Label for the rating of the self-critical belief.
  ///
  /// In en, this message translates to:
  /// **'How strongly I believe the self-critical belief'**
  String get fieldBelieveBelief;

  /// Label for the rating of the alternative belief.
  ///
  /// In en, this message translates to:
  /// **'How strongly I believe the alternative belief'**
  String get fieldBelieveAlternative;

  /// Header above the dated ratings of a positive data log.
  ///
  /// In en, this message translates to:
  /// **'How strongly I believe this'**
  String get fieldBeliefRatings;

  /// Header above the evidence of a positive data log.
  ///
  /// In en, this message translates to:
  /// **'Evidence to support the alternative belief and weaken the old belief'**
  String get fieldDataLogEvidence;

  /// Label for when a row of evidence happened.
  ///
  /// In en, this message translates to:
  /// **'When it happened'**
  String get fieldEvidenceWhen;

  /// One dated rating of both beliefs of a positive data log.
  ///
  /// In en, this message translates to:
  /// **'Belief {belief} · alternative {alternative}'**
  String beliefRatingLine(String belief, String alternative);

  /// Button adding a row of evidence to a positive data log.
  ///
  /// In en, this message translates to:
  /// **'Add evidence'**
  String get addEvidence;

  /// Button adding a new rating of both beliefs of a positive data log.
  ///
  /// In en, this message translates to:
  /// **'Rate again'**
  String get rateAgain;

  /// Title of the dialog re-rating the beliefs of a positive data log.
  ///
  /// In en, this message translates to:
  /// **'How strongly do you believe each now?'**
  String get rateAgainTitle;

  /// Validation message when a re-rating rates neither belief.
  ///
  /// In en, this message translates to:
  /// **'Move at least one slider before saving.'**
  String get ratingRequired;

  /// Validation message when the belief of a positive data log is blank.
  ///
  /// In en, this message translates to:
  /// **'Write down the belief before saving.'**
  String get beliefRequired;

  /// Title of the dialog confirming deletion of a row of evidence.
  ///
  /// In en, this message translates to:
  /// **'Delete this evidence?'**
  String get deleteEvidenceTitle;

  /// Body of the dialog confirming deletion of a row of evidence.
  ///
  /// In en, this message translates to:
  /// **'There is no undo.'**
  String get deleteEvidenceBody;

  /// How many rows of evidence a positive data log has, shown in the listing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No evidence yet} =1{1 piece of evidence} other{{count} pieces of evidence}}'**
  String evidenceCount(int count);

  /// Shown when there are no formulations.
  ///
  /// In en, this message translates to:
  /// **'No formulations yet.'**
  String get emptyFormulations;

  /// Title of the page creating a formulation.
  ///
  /// In en, this message translates to:
  /// **'New formulation'**
  String get newFormulation;

  /// Title of the page editing a formulation.
  ///
  /// In en, this message translates to:
  /// **'Edit formulation'**
  String get editFormulation;

  /// Introduction above the fields of a formulation.
  ///
  /// In en, this message translates to:
  /// **'How early life experiences lead to thoughts and behaviours. Start from whichever column you can.'**
  String get formulationIntro;

  /// Label for the early life experiences column of a formulation.
  ///
  /// In en, this message translates to:
  /// **'Early life experiences'**
  String get fieldEarlyExperiences;

  /// Label for the beliefs column of a formulation.
  ///
  /// In en, this message translates to:
  /// **'Beliefs'**
  String get fieldBeliefs;

  /// Label for the assumptions column of a formulation.
  ///
  /// In en, this message translates to:
  /// **'Assumptions'**
  String get fieldAssumptions;

  /// Label for the rules for living column of a formulation.
  ///
  /// In en, this message translates to:
  /// **'Rules for living'**
  String get fieldRulesForLiving;

  /// Label for the events column of a formulation.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get fieldFormulationEvents;

  /// Label for the thoughts column of a formulation.
  ///
  /// In en, this message translates to:
  /// **'Negative thoughts maintaining the problem'**
  String get fieldMaintainingThoughts;

  /// Label for the behaviours column of a formulation.
  ///
  /// In en, this message translates to:
  /// **'Behaviours maintaining the problem'**
  String get fieldMaintainingBehaviours;

  /// Validation message when every column of a formulation is blank.
  ///
  /// In en, this message translates to:
  /// **'Write down at least one column before saving.'**
  String get formulationRequired;

  /// Header above a derived map of worry.
  ///
  /// In en, this message translates to:
  /// **'An alternative reading of the same event'**
  String get alternativeReading;

  /// Header above the map an alternative was derived from.
  ///
  /// In en, this message translates to:
  /// **'The map this reworks'**
  String get theMapThisReworks;

  /// Button creating an alternative map of worry.
  ///
  /// In en, this message translates to:
  /// **'Write an alternative reading'**
  String get createAlternative;

  /// Title of the bias list page.
  ///
  /// In en, this message translates to:
  /// **'Cognitive biases'**
  String get biasesTitle;

  /// Badge on a builtin bias.
  ///
  /// In en, this message translates to:
  /// **'Builtin'**
  String get biasBuiltin;

  /// Button adding a user defined bias.
  ///
  /// In en, this message translates to:
  /// **'Add a bias'**
  String get biasAdd;

  /// Explanation of why builtin biases are read only.
  ///
  /// In en, this message translates to:
  /// **'The builtin biases cannot be changed, so your past records always read the same way.'**
  String get biasBuiltinLocked;

  /// Title of the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label for the backend URL field.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get settingsBackendUrl;

  /// Help text under the backend URL field.
  ///
  /// In en, this message translates to:
  /// **'The address of your cbt server, reachable over your tailnet.'**
  String get settingsBackendUrlHelp;

  /// Label for the build commit.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// Statement of how records are stored.
  ///
  /// In en, this message translates to:
  /// **'Records are stored on your server and are not encrypted at rest.'**
  String get settingsPrivacy;

  /// Generic save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Generic add button.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Button retrying a failed load.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Title of the delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get deleteRecordTitle;

  /// Body of the delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This removes the record and everything on it. There is no undo.'**
  String get deleteRecordBody;

  /// Validation message when the event is blank.
  ///
  /// In en, this message translates to:
  /// **'Write down what happened before saving.'**
  String get eventRequired;

  /// Shown when a request fails.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server.'**
  String get loadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
