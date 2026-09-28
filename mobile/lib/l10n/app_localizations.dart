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
