import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EcoTrack AI'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart waste management'**
  String get appSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your username or institutional email.'**
  String get loginSubtitle;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get userLabel;

  /// No description provided for @userHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. jperez or jperez@ufpso.edu.co'**
  String get userHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidUser.
  ///
  /// In en, this message translates to:
  /// **'Use 3 to 50 characters (letters, numbers, . _ -) or a valid email'**
  String get invalidUser;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'The password must be 6 to 72 characters with no spaces'**
  String get invalidPassword;

  /// No description provided for @completeAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all the fields'**
  String get completeAllFields;

  /// No description provided for @checkFields.
  ///
  /// In en, this message translates to:
  /// **'Check the fields marked in red'**
  String get checkFields;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Try again in {seconds} s.'**
  String tooManyAttempts(int seconds);

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get errorNoConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The connection is too slow. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get errorServer;

  /// Aviso al pulsar atrás en Inicio: la segunda pulsación cierra la app.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit the app.'**
  String get pressBackAgainToExit;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to see this.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @checkingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking your session…'**
  String get checkingSession;

  /// No description provided for @sessionCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify your session.'**
  String get sessionCheckFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get goToLogin;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to enter your credentials again.'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @apiServer.
  ///
  /// In en, this message translates to:
  /// **'Server: {url}'**
  String apiServer(String url);

  /// No description provided for @slowConnection.
  ///
  /// In en, this message translates to:
  /// **'The connection is slow. Still loading…'**
  String get slowConnection;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet.'**
  String get emptyList;

  /// No description provided for @actionError.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Please try again.'**
  String get actionError;

  /// No description provided for @savedOk.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get savedOk;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get selectOption;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @roleAdministrador.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdministrador;

  /// No description provided for @roleRecolector.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get roleRecolector;

  /// No description provided for @roleInteresado.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get roleInteresado;

  /// No description provided for @roleDesconocido.
  ///
  /// In en, this message translates to:
  /// **'No profile'**
  String get roleDesconocido;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @moduleContainers.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get moduleContainers;

  /// No description provided for @moduleAlerts.
  ///
  /// In en, this message translates to:
  /// **'Fill alerts'**
  String get moduleAlerts;

  /// No description provided for @moduleRoute.
  ///
  /// In en, this message translates to:
  /// **'Collection route'**
  String get moduleRoute;

  /// No description provided for @moduleCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get moduleCollections;

  /// No description provided for @moduleEcoPoints.
  ///
  /// In en, this message translates to:
  /// **'Eco points'**
  String get moduleEcoPoints;

  /// No description provided for @moduleUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get moduleUsers;

  /// No description provided for @moduleReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get moduleReports;

  /// No description provided for @moduleEvents.
  ///
  /// In en, this message translates to:
  /// **'Event log'**
  String get moduleEvents;

  /// No description provided for @moduleProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get moduleProfile;

  /// No description provided for @titleContainerDetail.
  ///
  /// In en, this message translates to:
  /// **'Container details'**
  String get titleContainerDetail;

  /// No description provided for @titleFillHistory.
  ///
  /// In en, this message translates to:
  /// **'Fill history'**
  String get titleFillHistory;

  /// No description provided for @titleNewContainer.
  ///
  /// In en, this message translates to:
  /// **'New container'**
  String get titleNewContainer;

  /// No description provided for @titleEditContainer.
  ///
  /// In en, this message translates to:
  /// **'Edit container'**
  String get titleEditContainer;

  /// No description provided for @titleNewUser.
  ///
  /// In en, this message translates to:
  /// **'New user'**
  String get titleNewUser;

  /// No description provided for @titleEditUser.
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get titleEditUser;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(String name);

  /// No description provided for @homeAdminDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor containers, eco points, users and campus reports.'**
  String get homeAdminDescription;

  /// No description provided for @homeCollectorDescription.
  ///
  /// In en, this message translates to:
  /// **'Check which containers need collection and log your routes.'**
  String get homeCollectorDescription;

  /// No description provided for @homeInterestedDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse the reports and the impact of recycling on campus.'**
  String get homeInterestedDescription;

  /// No description provided for @homeUnknownDescription.
  ///
  /// In en, this message translates to:
  /// **'Your profile has no modules assigned yet.'**
  String get homeUnknownDescription;

  /// No description provided for @sessionValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Session valid until {time}'**
  String sessionValidUntil(String time);

  /// No description provided for @modulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your modules'**
  String get modulesTitle;

  /// No description provided for @homeTodaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s summary'**
  String get homeTodaySummary;

  /// No description provided for @homeEcoPoints.
  ///
  /// In en, this message translates to:
  /// **'Active eco points'**
  String get homeEcoPoints;

  /// No description provided for @homeEcoPointsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no active eco points.'**
  String get homeEcoPointsEmpty;

  /// No description provided for @pointActiveContainers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active container} other{{count} active containers}}'**
  String pointActiveContainers(int count);

  /// No description provided for @homeRouteCard.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Your route is empty} =1{1 container in your route} other{{count} containers in your route}}'**
  String homeRouteCard(int count);

  /// No description provided for @homeAlertsCard.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No containers need collection} =1{1 container needs collection} other{{count} containers need collection}}'**
  String homeAlertsCard(int count);

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @kpiToday.
  ///
  /// In en, this message translates to:
  /// **'Classified today'**
  String get kpiToday;

  /// No description provided for @kpiActiveContainers.
  ///
  /// In en, this message translates to:
  /// **'Active containers'**
  String get kpiActiveContainers;

  /// No description provided for @kpiAttention.
  ///
  /// In en, this message translates to:
  /// **'Need attention'**
  String get kpiAttention;

  /// No description provided for @kpiFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get kpiFull;

  /// No description provided for @kpiAverageFill.
  ///
  /// In en, this message translates to:
  /// **'Average fill'**
  String get kpiAverageFill;

  /// No description provided for @kpiCollectionsToday.
  ///
  /// In en, this message translates to:
  /// **'Collections today'**
  String get kpiCollectionsToday;

  /// No description provided for @categoryRecyclable.
  ///
  /// In en, this message translates to:
  /// **'Recyclable'**
  String get categoryRecyclable;

  /// No description provided for @categoryOrganic.
  ///
  /// In en, this message translates to:
  /// **'Organic (recyclable)'**
  String get categoryOrganic;

  /// No description provided for @categoryOrganicShort.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get categoryOrganicShort;

  /// No description provided for @categoryNonRecyclable.
  ///
  /// In en, this message translates to:
  /// **'Non-recyclable'**
  String get categoryNonRecyclable;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @statusAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get statusAttention;

  /// No description provided for @statusFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get statusFull;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @searchEcoPoints.
  ///
  /// In en, this message translates to:
  /// **'Search by name, zone or description'**
  String get searchEcoPoints;

  /// No description provided for @searchContainers.
  ///
  /// In en, this message translates to:
  /// **'Search by name or code'**
  String get searchContainers;

  /// No description provided for @showRetired.
  ///
  /// In en, this message translates to:
  /// **'Show retired'**
  String get showRetired;

  /// No description provided for @containerUnits.
  ///
  /// In en, this message translates to:
  /// **'{count} of {capacity} items'**
  String containerUnits(int count, int capacity);

  /// No description provided for @ecoPointFilter.
  ///
  /// In en, this message translates to:
  /// **'Point: {name}'**
  String ecoPointFilter(String name);

  /// No description provided for @containersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No containers match these filters.'**
  String get containersEmpty;

  /// No description provided for @menuViewDetail.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get menuViewDetail;

  /// No description provided for @menuFillHistory.
  ///
  /// In en, this message translates to:
  /// **'Fill history'**
  String get menuFillHistory;

  /// No description provided for @menuAddToRoute.
  ///
  /// In en, this message translates to:
  /// **'Add to my route'**
  String get menuAddToRoute;

  /// No description provided for @menuRemoveFromRoute.
  ///
  /// In en, this message translates to:
  /// **'Remove from my route'**
  String get menuRemoveFromRoute;

  /// No description provided for @menuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// No description provided for @menuRetire.
  ///
  /// In en, this message translates to:
  /// **'Retire'**
  String get menuRetire;

  /// No description provided for @menuReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get menuReactivate;

  /// No description provided for @retireTitle.
  ///
  /// In en, this message translates to:
  /// **'Retire this container?'**
  String get retireTitle;

  /// No description provided for @retireMessage.
  ///
  /// In en, this message translates to:
  /// **'It will stop receiving waste. Its history is kept.'**
  String get retireMessage;

  /// No description provided for @retiredBadge.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get retiredBadge;

  /// No description provided for @addedToRoute.
  ///
  /// In en, this message translates to:
  /// **'{name} was added to your route'**
  String addedToRoute(String name);

  /// No description provided for @removedFromRoute.
  ///
  /// In en, this message translates to:
  /// **'{name} was removed from your route'**
  String removedFromRoute(String name);

  /// No description provided for @inRouteBadge.
  ///
  /// In en, this message translates to:
  /// **'In route'**
  String get inRouteBadge;

  /// No description provided for @detailCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get detailCapacity;

  /// No description provided for @detailThreshold.
  ///
  /// In en, this message translates to:
  /// **'Alert threshold'**
  String get detailThreshold;

  /// No description provided for @detailThresholdGlobal.
  ///
  /// In en, this message translates to:
  /// **'{value} (global)'**
  String detailThresholdGlobal(String value);

  /// No description provided for @detailCurrentCount.
  ///
  /// In en, this message translates to:
  /// **'Current items'**
  String get detailCurrentCount;

  /// No description provided for @detailLastCollection.
  ///
  /// In en, this message translates to:
  /// **'Last collection'**
  String get detailLastCollection;

  /// No description provided for @detailSinceCollection.
  ///
  /// In en, this message translates to:
  /// **'Since last collection'**
  String get detailSinceCollection;

  /// No description provided for @detailLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get detailLowConfidence;

  /// No description provided for @detailTotalClassifications.
  ///
  /// In en, this message translates to:
  /// **'Total classified'**
  String get detailTotalClassifications;

  /// No description provided for @detailRecentClassifications.
  ///
  /// In en, this message translates to:
  /// **'Latest classifications'**
  String get detailRecentClassifications;

  /// No description provided for @detailRecentCollections.
  ///
  /// In en, this message translates to:
  /// **'Recent collections'**
  String get detailRecentCollections;

  /// No description provided for @detailNoCollections.
  ///
  /// In en, this message translates to:
  /// **'No collections yet.'**
  String get detailNoCollections;

  /// No description provided for @confidenceValue.
  ///
  /// In en, this message translates to:
  /// **'Confidence {value}'**
  String confidenceValue(String value);

  /// No description provided for @registerCollection.
  ///
  /// In en, this message translates to:
  /// **'Register collection'**
  String get registerCollection;

  /// No description provided for @registerCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Register collection of {code}'**
  String registerCollectionTitle(String code);

  /// No description provided for @registerCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'The container count will go back to zero.'**
  String get registerCollectionMessage;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesLabel;

  /// No description provided for @notesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Up to 500 characters'**
  String get notesTooLong;

  /// No description provided for @collectionRegistered.
  ///
  /// In en, this message translates to:
  /// **'Collection registered: {units} items. The count was reset.'**
  String collectionRegistered(int units);

  /// No description provided for @fillHistoryPeriod.
  ///
  /// In en, this message translates to:
  /// **'Last 14 days'**
  String get fillHistoryPeriod;

  /// No description provided for @fillHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity in this period.'**
  String get fillHistoryEmpty;

  /// No description provided for @thresholdLine.
  ///
  /// In en, this message translates to:
  /// **'Threshold {value}'**
  String thresholdLine(String value);

  /// No description provided for @eventStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get eventStart;

  /// No description provided for @eventClassification.
  ///
  /// In en, this message translates to:
  /// **'Waste classified'**
  String get eventClassification;

  /// No description provided for @eventCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get eventCollection;

  /// No description provided for @eventCurrent.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get eventCurrent;

  /// No description provided for @fillHistoryMovements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get fillHistoryMovements;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldCode.
  ///
  /// In en, this message translates to:
  /// **'Code (optional)'**
  String get fieldCode;

  /// No description provided for @fieldCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty to generate it automatically'**
  String get fieldCodeHint;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldEcoPoint.
  ///
  /// In en, this message translates to:
  /// **'Eco point'**
  String get fieldEcoPoint;

  /// No description provided for @fieldCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity (items)'**
  String get fieldCapacity;

  /// No description provided for @fieldThreshold.
  ///
  /// In en, this message translates to:
  /// **'Own threshold % (optional)'**
  String get fieldThreshold;

  /// No description provided for @fieldThresholdHint.
  ///
  /// In en, this message translates to:
  /// **'Empty = use the global threshold'**
  String get fieldThresholdHint;

  /// No description provided for @fieldActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get fieldActive;

  /// No description provided for @invalidName.
  ///
  /// In en, this message translates to:
  /// **'Use 2 to 100 characters'**
  String get invalidName;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Up to 20 characters: letters, numbers, - _ .'**
  String get invalidCode;

  /// No description provided for @invalidCapacity.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number between 1 and 100000'**
  String get invalidCapacity;

  /// No description provided for @invalidThreshold.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 1 and 100'**
  String get invalidThreshold;

  /// No description provided for @containerCreated.
  ///
  /// In en, this message translates to:
  /// **'Container created'**
  String get containerCreated;

  /// No description provided for @containerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Container updated'**
  String get containerUpdated;

  /// No description provided for @alertsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 container needs attention} other{{count} containers need attention}}'**
  String alertsSummary(int count);

  /// No description provided for @alertsEmpty.
  ///
  /// In en, this message translates to:
  /// **'All good: no container is over the threshold.'**
  String get alertsEmpty;

  /// No description provided for @addAllToRoute.
  ///
  /// In en, this message translates to:
  /// **'Add all to my route'**
  String get addAllToRoute;

  /// No description provided for @addedAllToRoute.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{They were already in your route} =1{1 container added to your route} other{{count} containers added to your route}}'**
  String addedAllToRoute(int count);

  /// No description provided for @routeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your route is empty'**
  String get routeEmptyTitle;

  /// No description provided for @routeEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add containers from Fill alerts or Containers.'**
  String get routeEmptyMessage;

  /// No description provided for @goToAlerts.
  ///
  /// In en, this message translates to:
  /// **'View alerts'**
  String get goToAlerts;

  /// No description provided for @routeSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 container} other{{count} containers}} · {units} items'**
  String routeSummary(int count, int units);

  /// No description provided for @routeHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press and drag to reorder. Swipe to remove.'**
  String get routeHint;

  /// No description provided for @routeRegisterAll.
  ///
  /// In en, this message translates to:
  /// **'Register collection ({count})'**
  String routeRegisterAll(int count);

  /// No description provided for @routeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Register the collection?'**
  String get routeConfirmTitle;

  /// No description provided for @routeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The collection of 1 container will be registered and its count will go back to zero.} other{The collection of {count} containers will be registered and their count will go back to zero.}}'**
  String routeConfirmMessage(int count);

  /// No description provided for @routeProgress.
  ///
  /// In en, this message translates to:
  /// **'Registering {current} of {total}…'**
  String routeProgress(int current, int total);

  /// No description provided for @routeDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Route completed: 1 collection registered.} other{Route completed: {count} collections registered.}}'**
  String routeDone(int count);

  /// No description provided for @routePartial.
  ///
  /// In en, this message translates to:
  /// **'{ok} registered, {failed} could not be registered. They stay in your route.'**
  String routePartial(int ok, int failed);

  /// No description provided for @routeOffline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No connection to the server: no collection was registered. Your route is still saved on this phone; register it when the connection is back.} =1{No connection to the server: 1 collection was registered. The other containers stay in your route, saved on this phone.} other{No connection to the server: {count} collections were registered. The other containers stay in your route, saved on this phone.}}'**
  String routeOffline(int count);

  /// No description provided for @routeClear.
  ///
  /// In en, this message translates to:
  /// **'Clear route'**
  String get routeClear;

  /// No description provided for @routeRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get routeRemove;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String periodDays(int days);

  /// No description provided for @collectionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No collections in this period.'**
  String get collectionsEmpty;

  /// No description provided for @collectedBy.
  ///
  /// In en, this message translates to:
  /// **'By {name}'**
  String collectedBy(String name);

  /// No description provided for @unitsCollected.
  ///
  /// In en, this message translates to:
  /// **'{units} items'**
  String unitsCollected(int units);

  /// No description provided for @fillAtCollection.
  ///
  /// In en, this message translates to:
  /// **'Fill {value}'**
  String fillAtCollection(String value);

  /// No description provided for @collectionsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 collection} other{{count} collections}} · {units} items'**
  String collectionsTotal(int count, int units);

  /// No description provided for @ecoPointsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no eco points yet.'**
  String get ecoPointsEmpty;

  /// No description provided for @pointContainers.
  ///
  /// In en, this message translates to:
  /// **'{active} of {total} containers active'**
  String pointContainers(int active, int total);

  /// No description provided for @activeBadge.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeBadge;

  /// No description provided for @inactiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveBadge;

  /// No description provided for @newEcoPoint.
  ///
  /// In en, this message translates to:
  /// **'New eco point'**
  String get newEcoPoint;

  /// No description provided for @editEcoPoint.
  ///
  /// In en, this message translates to:
  /// **'Edit eco point'**
  String get editEcoPoint;

  /// No description provided for @fieldZone.
  ///
  /// In en, this message translates to:
  /// **'Building or zone (optional)'**
  String get fieldZone;

  /// No description provided for @fieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get fieldDescription;

  /// No description provided for @invalidZone.
  ///
  /// In en, this message translates to:
  /// **'Up to 100 characters'**
  String get invalidZone;

  /// No description provided for @invalidDescription.
  ///
  /// In en, this message translates to:
  /// **'Up to 255 characters'**
  String get invalidDescription;

  /// No description provided for @menuViewContainers.
  ///
  /// In en, this message translates to:
  /// **'View containers'**
  String get menuViewContainers;

  /// No description provided for @menuActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get menuActivate;

  /// No description provided for @menuDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get menuDeactivate;

  /// No description provided for @menuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuDelete;

  /// No description provided for @deletePointTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this eco point?'**
  String get deletePointTitle;

  /// No description provided for @deletePointMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deletePointMessage;

  /// No description provided for @ecoPointSaved.
  ///
  /// In en, this message translates to:
  /// **'Eco point saved'**
  String get ecoPointSaved;

  /// No description provided for @ecoPointDeleted.
  ///
  /// In en, this message translates to:
  /// **'Eco point deleted'**
  String get ecoPointDeleted;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search by name, username or email'**
  String get searchUsers;

  /// No description provided for @usersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users match the search.'**
  String get usersEmpty;

  /// No description provided for @fieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get fieldUsername;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name (optional)'**
  String get fieldFullName;

  /// No description provided for @fieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get fieldRole;

  /// No description provided for @fieldNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldNewPassword;

  /// No description provided for @fieldPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldPasswordConfirm;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'3 to 50 characters: letters, numbers, . _ -'**
  String get invalidUsername;

  /// No description provided for @invalidFullName.
  ///
  /// In en, this message translates to:
  /// **'Use letters and spaces (2 to 100)'**
  String get invalidFullName;

  /// No description provided for @userCreated.
  ///
  /// In en, this message translates to:
  /// **'User created'**
  String get userCreated;

  /// No description provided for @userUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated'**
  String get userUpdated;

  /// No description provided for @menuResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get menuResetPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password for {username}'**
  String resetPasswordTitle(String username);

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @deactivateUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {username}?'**
  String deactivateUserTitle(String username);

  /// No description provided for @deactivateUserMessage.
  ///
  /// In en, this message translates to:
  /// **'They won\'t be able to sign in until the account is activated again.'**
  String get deactivateUserMessage;

  /// No description provided for @youBadge.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youBadge;

  /// No description provided for @lastLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Last sign in: {date}'**
  String lastLoginLabel(String date);

  /// No description provided for @neverSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Never signed in'**
  String get neverSignedIn;

  /// No description provided for @cantEditOwnRole.
  ///
  /// In en, this message translates to:
  /// **'You cannot change your own role or deactivate yourself.'**
  String get cantEditOwnRole;

  /// No description provided for @allEcoPoints.
  ///
  /// In en, this message translates to:
  /// **'All eco points'**
  String get allEcoPoints;

  /// No description provided for @reportRange.
  ///
  /// In en, this message translates to:
  /// **'From {start} to {end}'**
  String reportRange(String start, String end);

  /// No description provided for @kpiClassifications.
  ///
  /// In en, this message translates to:
  /// **'Classified'**
  String get kpiClassifications;

  /// No description provided for @kpiValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get kpiValid;

  /// No description provided for @kpiLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get kpiLowConfidence;

  /// No description provided for @kpiRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get kpiRejected;

  /// No description provided for @kpiAvgConfidence.
  ///
  /// In en, this message translates to:
  /// **'Avg. confidence'**
  String get kpiAvgConfidence;

  /// No description provided for @kpiCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get kpiCollections;

  /// No description provided for @kpiUnitsCollected.
  ///
  /// In en, this message translates to:
  /// **'Items collected'**
  String get kpiUnitsCollected;

  /// No description provided for @kpiDailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get kpiDailyAverage;

  /// No description provided for @chartByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get chartByCategory;

  /// No description provided for @chartDaily.
  ///
  /// In en, this message translates to:
  /// **'Classified per day'**
  String get chartDaily;

  /// No description provided for @chartByLocation.
  ///
  /// In en, this message translates to:
  /// **'By eco point'**
  String get chartByLocation;

  /// No description provided for @chartByHour.
  ///
  /// In en, this message translates to:
  /// **'Busiest hours'**
  String get chartByHour;

  /// No description provided for @chartTopContainers.
  ///
  /// In en, this message translates to:
  /// **'Containers with the most waste'**
  String get chartTopContainers;

  /// No description provided for @reportEmptySection.
  ///
  /// In en, this message translates to:
  /// **'No data in this period.'**
  String get reportEmptySection;

  /// No description provided for @searchEvents.
  ///
  /// In en, this message translates to:
  /// **'Search the log'**
  String get searchEvents;

  /// No description provided for @eventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events match these filters.'**
  String get eventsEmpty;

  /// No description provided for @eventsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String eventsTotal(int count);

  /// No description provided for @levelInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get levelInfo;

  /// No description provided for @levelWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get levelWarning;

  /// No description provided for @levelError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get levelError;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileUsername;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get profileCreated;

  /// No description provided for @profileLastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last sign in'**
  String get profileLastLogin;

  /// No description provided for @profileSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurity;

  /// No description provided for @profileSessionUntil.
  ///
  /// In en, this message translates to:
  /// **'Session valid until'**
  String get profileSessionUntil;

  /// No description provided for @profileTokenStored.
  ///
  /// In en, this message translates to:
  /// **'Your token is stored encrypted on this device and sent in the Authorization header.'**
  String get profileTokenStored;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @homeLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get homeLast7Days;

  /// No description provided for @fieldCapacityHint.
  ///
  /// In en, this message translates to:
  /// **'Empty = default capacity (50)'**
  String get fieldCapacityHint;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @routeClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'All the containers will be removed from your route.'**
  String get routeClearConfirm;

  /// No description provided for @usernameLocked.
  ///
  /// In en, this message translates to:
  /// **'The username can\'t be changed'**
  String get usernameLocked;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilter;

  /// No description provided for @containerRetired.
  ///
  /// In en, this message translates to:
  /// **'Container retired'**
  String get containerRetired;

  /// No description provided for @containerReactivated.
  ///
  /// In en, this message translates to:
  /// **'Container reactivated'**
  String get containerReactivated;

  /// No description provided for @userActivated.
  ///
  /// In en, this message translates to:
  /// **'User activated'**
  String get userActivated;

  /// No description provided for @userDeactivated.
  ///
  /// In en, this message translates to:
  /// **'User deactivated'**
  String get userDeactivated;

  /// No description provided for @ecoPointActivated.
  ///
  /// In en, this message translates to:
  /// **'Eco point activated'**
  String get ecoPointActivated;

  /// No description provided for @ecoPointDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Eco point deactivated'**
  String get ecoPointDeactivated;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total}'**
  String ofLabel(int shown, int total);

  /// No description provided for @chartMax.
  ///
  /// In en, this message translates to:
  /// **'max. {value}'**
  String chartMax(String value);

  /// Error LOCATION_NOT_FOUND de la API.
  ///
  /// In en, this message translates to:
  /// **'The eco point no longer exists.'**
  String get apiErrorLocationNotFound;

  /// Error LOCATION_NAME_TAKEN de la API.
  ///
  /// In en, this message translates to:
  /// **'An eco point named {name} already exists.'**
  String apiErrorLocationNameTaken(String name);

  /// Error LOCATION_HAS_TERMINALS de la API.
  ///
  /// In en, this message translates to:
  /// **'This eco point has terminals assigned ({terminals}). Move them to another point or remove them and try again.'**
  String apiErrorLocationHasTerminals(String terminals);

  /// Error LOCATION_HAS_HISTORY de la API.
  ///
  /// In en, this message translates to:
  /// **'This eco point has containers or classifications. Deactivate it instead of deleting it to keep its history.'**
  String get apiErrorLocationHasHistory;

  /// Error CONTAINER_NOT_FOUND de la API.
  ///
  /// In en, this message translates to:
  /// **'Container #{id} no longer exists.'**
  String apiErrorContainerNotFound(String id);

  /// Error CONTAINER_CODE_TAKEN de la API.
  ///
  /// In en, this message translates to:
  /// **'A container with code {code} already exists.'**
  String apiErrorContainerCodeTaken(String code);

  /// Error CONTAINER_LOCATION_NOT_FOUND de la API.
  ///
  /// In en, this message translates to:
  /// **'The selected eco point doesn\'t exist.'**
  String get apiErrorContainerLocationNotFound;

  /// Error CONTAINER_INACTIVE de la API.
  ///
  /// In en, this message translates to:
  /// **'This container is deactivated.'**
  String get apiErrorContainerInactive;

  /// Error USER_NOT_FOUND de la API.
  ///
  /// In en, this message translates to:
  /// **'User #{id} no longer exists.'**
  String apiErrorUserNotFound(String id);

  /// Error USER_ALREADY_EXISTS de la API.
  ///
  /// In en, this message translates to:
  /// **'That username or email is already registered.'**
  String get apiErrorUserAlreadyExists;

  /// Error USER_OWN_ROLE de la API.
  ///
  /// In en, this message translates to:
  /// **'You can\'t change your own role.'**
  String get apiErrorUserOwnRole;

  /// Error USER_OWN_DEACTIVATION de la API.
  ///
  /// In en, this message translates to:
  /// **'You can\'t deactivate your own account.'**
  String get apiErrorUserOwnDeactivation;

  /// Error USER_LAST_ADMIN de la API.
  ///
  /// In en, this message translates to:
  /// **'At least one active administrator must remain.'**
  String get apiErrorUserLastAdmin;

  /// Tipo de evento INICIO_SISTEMA de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'System started'**
  String get eventTypeInicioSistema;

  /// Tipo de evento INICIO_SESION de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Sign-in'**
  String get eventTypeInicioSesion;

  /// Tipo de evento SESION_FALLIDA de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Failed sign-in attempt'**
  String get eventTypeSesionFallida;

  /// Tipo de evento BAJA_CONFIANZA de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Low-confidence classification'**
  String get eventTypeBajaConfianza;

  /// Tipo de evento CLASIFICACION_RECHAZADA de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Rejected classification'**
  String get eventTypeClasificacionRechazada;

  /// Tipo de evento SIN_DETECCION de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Image with no waste detected'**
  String get eventTypeSinDeteccion;

  /// Tipo de evento ALERTA_LLENADO de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Container over its threshold'**
  String get eventTypeAlertaLlenado;

  /// Tipo de evento CAPACIDAD_ALCANZADA de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Container reached capacity'**
  String get eventTypeCapacidadAlcanzada;

  /// Tipo de evento RECOLECCION de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Collection logged'**
  String get eventTypeRecoleccion;

  /// Tipo de evento REVISION de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Classification review'**
  String get eventTypeRevision;

  /// Tipo de evento CONFIGURACION de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Settings change'**
  String get eventTypeConfiguracion;

  /// Tipo de evento CONTENEDOR de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Container management'**
  String get eventTypeContenedor;

  /// Tipo de evento UBICACION de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Eco point management'**
  String get eventTypeUbicacion;

  /// Tipo de evento USUARIO de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'User management'**
  String get eventTypeUsuario;

  /// Tipo de evento EXPORTACION de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Data export'**
  String get eventTypeExportacion;

  /// Tipo de evento RENDIMIENTO de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Slow processing'**
  String get eventTypeRendimiento;

  /// Tipo de evento ERROR_IMAGEN de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Invalid image'**
  String get eventTypeErrorImagen;

  /// Tipo de evento ERROR_DETECCION de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Detection engine error'**
  String get eventTypeErrorDeteccion;

  /// Tipo de evento SIN_CONTENEDOR de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'No container available'**
  String get eventTypeSinContenedor;

  /// Tipo de evento RESIDUO_ESPECIAL de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Hazardous waste presented'**
  String get eventTypeResiduoEspecial;

  /// Tipo de evento PUNTO_ECOLOGICO de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Live eco point'**
  String get eventTypePuntoEcologico;

  /// Tipo de evento TERMINAL de la bitácora.
  ///
  /// In en, this message translates to:
  /// **'Terminal management'**
  String get eventTypeTerminal;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline: showing the data saved on this phone.'**
  String get offlineBanner;

  /// No description provided for @lastDownloadAt.
  ///
  /// In en, this message translates to:
  /// **'Last update: {date}'**
  String lastDownloadAt(String date);

  /// No description provided for @pendingChanges.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String pendingChanges(int count);

  /// No description provided for @failedChanges.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change could not be synced} other{{count} changes could not be synced}}'**
  String failedChanges(int count);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @syncDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change was saved to the system} other{{count} changes were saved to the system}}'**
  String syncDone(int count);

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. It will be saved to the system automatically when the connection is back.'**
  String get savedOffline;

  /// No description provided for @deletedOffline.
  ///
  /// In en, this message translates to:
  /// **'Deleted offline. It will be removed from the system automatically when the connection is back.'**
  String get deletedOffline;

  /// No description provided for @pendingCreate.
  ///
  /// In en, this message translates to:
  /// **'Pending: create'**
  String get pendingCreate;

  /// No description provided for @pendingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Pending: edit'**
  String get pendingUpdate;

  /// No description provided for @pendingDelete.
  ///
  /// In en, this message translates to:
  /// **'Pending: delete'**
  String get pendingDelete;

  /// No description provided for @syncErrorBadge.
  ///
  /// In en, this message translates to:
  /// **'Could not sync'**
  String get syncErrorBadge;

  /// No description provided for @menuDiscardChange.
  ///
  /// In en, this message translates to:
  /// **'Discard change'**
  String get menuDiscardChange;

  /// No description provided for @menuViewSyncError.
  ///
  /// In en, this message translates to:
  /// **'See the error'**
  String get menuViewSyncError;

  /// No description provided for @changeDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Change discarded.'**
  String get changeDiscarded;

  /// No description provided for @localOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Point created offline: it will be saved to the system automatically when a connection is available.'**
  String get localOnlyHint;

  /// No description provided for @moduleTerminals.
  ///
  /// In en, this message translates to:
  /// **'Terminals'**
  String get moduleTerminals;

  /// No description provided for @titleAssignTerminal.
  ///
  /// In en, this message translates to:
  /// **'Add terminal'**
  String get titleAssignTerminal;

  /// No description provided for @terminalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no terminals yet. Open the eco point screen and add it with the code it shows.'**
  String get terminalsEmpty;

  /// No description provided for @terminalStatusUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get terminalStatusUnassigned;

  /// No description provided for @terminalStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get terminalStatusAssigned;

  /// No description provided for @terminalStatusChange.
  ///
  /// In en, this message translates to:
  /// **'Asked to change point'**
  String get terminalStatusChange;

  /// No description provided for @terminalOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get terminalOnline;

  /// No description provided for @terminalOffline.
  ///
  /// In en, this message translates to:
  /// **'No signal'**
  String get terminalOffline;

  /// No description provided for @terminalNoPoint.
  ///
  /// In en, this message translates to:
  /// **'No eco point assigned'**
  String get terminalNoPoint;

  /// No description provided for @terminalLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last signal: {date}'**
  String terminalLastSeen(String date);

  /// No description provided for @fieldTerminalCode.
  ///
  /// In en, this message translates to:
  /// **'Terminal code'**
  String get fieldTerminalCode;

  /// No description provided for @terminalCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Type the 6-digit code shown on the terminal screen.'**
  String get terminalCodeHelp;

  /// No description provided for @terminalCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'The code must have 6 digits.'**
  String get terminalCodeInvalid;

  /// No description provided for @terminalFind.
  ///
  /// In en, this message translates to:
  /// **'Find terminal'**
  String get terminalFind;

  /// No description provided for @terminalFound.
  ///
  /// In en, this message translates to:
  /// **'Terminal found'**
  String get terminalFound;

  /// No description provided for @terminalAlreadyAt.
  ///
  /// In en, this message translates to:
  /// **'It is already at “{point}” and asked to change point.'**
  String terminalAlreadyAt(String point);

  /// No description provided for @terminalWhere.
  ///
  /// In en, this message translates to:
  /// **'Which eco point does it go to?'**
  String get terminalWhere;

  /// No description provided for @terminalExistingPoint.
  ///
  /// In en, this message translates to:
  /// **'Existing point'**
  String get terminalExistingPoint;

  /// No description provided for @terminalNewPoint.
  ///
  /// In en, this message translates to:
  /// **'New point'**
  String get terminalNewPoint;

  /// No description provided for @terminalPickPoint.
  ///
  /// In en, this message translates to:
  /// **'Choose an eco point.'**
  String get terminalPickPoint;

  /// No description provided for @terminalNoPoints.
  ///
  /// In en, this message translates to:
  /// **'There are no eco points yet. Create a new one for this terminal.'**
  String get terminalNoPoints;

  /// No description provided for @terminalNewPointHint.
  ///
  /// In en, this message translates to:
  /// **'The point is created with its three containers: recyclable, organic and non-recyclable.'**
  String get terminalNewPointHint;

  /// No description provided for @terminalExistingHint.
  ///
  /// In en, this message translates to:
  /// **'If the point is missing a container, it is created when the terminal is assigned.'**
  String get terminalExistingHint;

  /// No description provided for @terminalAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign terminal'**
  String get terminalAssign;

  /// No description provided for @terminalAssigned.
  ///
  /// In en, this message translates to:
  /// **'{terminal} assigned to “{point}”.'**
  String terminalAssigned(String terminal, String point);

  /// No description provided for @terminalAssignedWithContainers.
  ///
  /// In en, this message translates to:
  /// **'{terminal} assigned to “{point}”. Containers created: {codes}.'**
  String terminalAssignedWithContainers(
    String terminal,
    String point,
    String codes,
  );

  /// No description provided for @menuRemoveTerminal.
  ///
  /// In en, this message translates to:
  /// **'Remove terminal'**
  String get menuRemoveTerminal;

  /// No description provided for @removeTerminalTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove the terminal?'**
  String get removeTerminalTitle;

  /// No description provided for @removeTerminalMessage.
  ///
  /// In en, this message translates to:
  /// **'If that screen is opened again, it will appear as a new terminal with a code. The point\'s containers are not deleted.'**
  String get removeTerminalMessage;

  /// No description provided for @terminalRemoved.
  ///
  /// In en, this message translates to:
  /// **'Terminal removed.'**
  String get terminalRemoved;

  /// No description provided for @emptyContainer.
  ///
  /// In en, this message translates to:
  /// **'Empty container'**
  String get emptyContainer;

  /// No description provided for @emptyContainerTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty {code}'**
  String emptyContainerTitle(String code);

  /// No description provided for @emptyContainerMessage.
  ///
  /// In en, this message translates to:
  /// **'The collection is recorded and the container count goes back to zero.'**
  String get emptyContainerMessage;

  /// No description provided for @containerEmptied.
  ///
  /// In en, this message translates to:
  /// **'Container emptied: {units} items. The count went back to zero.'**
  String containerEmptied(int units);

  /// No description provided for @terminalCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'The code is not valid or has expired. Check the one the terminal shows.'**
  String get terminalCodeNotFound;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
