// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EcoTrack AI';

  @override
  String get appSubtitle => 'Smart waste management';

  @override
  String get login => 'Sign in';

  @override
  String get loginTitle => 'Welcome';

  @override
  String get loginSubtitle => 'Use your username or institutional email.';

  @override
  String get userLabel => 'Username or email';

  @override
  String get userHint => 'e.g. jperez or jperez@ufpso.edu.co';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidUser =>
      'Use 3 to 50 characters (letters, numbers, . _ -) or a valid email';

  @override
  String get invalidPassword =>
      'The password must be 6 to 72 characters with no spaces';

  @override
  String get completeAllFields => 'Please complete all the fields';

  @override
  String get checkFields => 'Check the fields marked in red';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String tooManyAttempts(int seconds) {
    return 'Too many failed attempts. Try again in $seconds s.';
  }

  @override
  String get errorNoConnection =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errorTimeout => 'The connection is too slow. Please try again.';

  @override
  String get errorServer => 'Something went wrong. Please try again later.';

  @override
  String get pressBackAgainToExit => 'Press back again to exit the app.';

  @override
  String get errorForbidden => 'You don\'t have permission to see this.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get checkingSession => 'Checking your session…';

  @override
  String get sessionCheckFailed => 'We couldn\'t verify your session.';

  @override
  String get retry => 'Retry';

  @override
  String get goToLogin => 'Go to sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirmTitle => 'Sign out?';

  @override
  String get logoutConfirmMessage =>
      'You will need to enter your credentials again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get backHome => 'Back to home';

  @override
  String apiServer(String url) {
    return 'Server: $url';
  }

  @override
  String get slowConnection => 'The connection is slow. Still loading…';

  @override
  String get emptyList => 'Nothing to show yet.';

  @override
  String get actionError =>
      'The action could not be completed. Please try again.';

  @override
  String get savedOk => 'Changes saved';

  @override
  String get selectOption => 'Select an option';

  @override
  String get optional => 'Optional';

  @override
  String get allLabel => 'All';

  @override
  String get never => 'Never';

  @override
  String get roleAdministrador => 'Administrator';

  @override
  String get roleRecolector => 'Collector';

  @override
  String get roleInteresado => 'Viewer';

  @override
  String get roleDesconocido => 'No profile';

  @override
  String get menuHome => 'Home';

  @override
  String get moduleContainers => 'Containers';

  @override
  String get moduleAlerts => 'Fill alerts';

  @override
  String get moduleRoute => 'Collection route';

  @override
  String get moduleCollections => 'Collections';

  @override
  String get moduleEcoPoints => 'Eco points';

  @override
  String get moduleUsers => 'Users';

  @override
  String get moduleReports => 'Reports';

  @override
  String get moduleEvents => 'Event log';

  @override
  String get moduleProfile => 'My profile';

  @override
  String get titleContainerDetail => 'Container details';

  @override
  String get titleFillHistory => 'Fill history';

  @override
  String get titleNewContainer => 'New container';

  @override
  String get titleEditContainer => 'Edit container';

  @override
  String get titleNewUser => 'New user';

  @override
  String get titleEditUser => 'Edit user';

  @override
  String greeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeAdminDescription =>
      'Monitor containers, eco points, users and campus reports.';

  @override
  String get homeCollectorDescription =>
      'Check which containers need collection and log your routes.';

  @override
  String get homeInterestedDescription =>
      'Browse the reports and the impact of recycling on campus.';

  @override
  String get homeUnknownDescription =>
      'Your profile has no modules assigned yet.';

  @override
  String sessionValidUntil(String time) {
    return 'Session valid until $time';
  }

  @override
  String get modulesTitle => 'Your modules';

  @override
  String get homeTodaySummary => 'Today\'s summary';

  @override
  String get homeEcoPoints => 'Active eco points';

  @override
  String get homeEcoPointsEmpty => 'There are no active eco points.';

  @override
  String pointActiveContainers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active containers',
      one: '1 active container',
    );
    return '$_temp0';
  }

  @override
  String homeRouteCard(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count containers in your route',
      one: '1 container in your route',
      zero: 'Your route is empty',
    );
    return '$_temp0';
  }

  @override
  String homeAlertsCard(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count containers need collection',
      one: '1 container needs collection',
      zero: 'No containers need collection',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'See all';

  @override
  String get kpiToday => 'Classified today';

  @override
  String get kpiActiveContainers => 'Active containers';

  @override
  String get kpiAttention => 'Need attention';

  @override
  String get kpiFull => 'Full';

  @override
  String get kpiAverageFill => 'Average fill';

  @override
  String get kpiCollectionsToday => 'Collections today';

  @override
  String get categoryRecyclable => 'Recyclable';

  @override
  String get categoryOrganic => 'Organic (recyclable)';

  @override
  String get categoryOrganicShort => 'Organic';

  @override
  String get categoryNonRecyclable => 'Non-recyclable';

  @override
  String get allCategories => 'All categories';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusAttention => 'Needs attention';

  @override
  String get statusFull => 'Full';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get searchEcoPoints => 'Search by name, zone or description';

  @override
  String get searchContainers => 'Search by name or code';

  @override
  String get showRetired => 'Show retired';

  @override
  String containerUnits(int count, int capacity) {
    return '$count of $capacity items';
  }

  @override
  String ecoPointFilter(String name) {
    return 'Point: $name';
  }

  @override
  String get containersEmpty => 'No containers match these filters.';

  @override
  String get menuViewDetail => 'View details';

  @override
  String get menuFillHistory => 'Fill history';

  @override
  String get menuAddToRoute => 'Add to my route';

  @override
  String get menuRemoveFromRoute => 'Remove from my route';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuRetire => 'Retire';

  @override
  String get menuReactivate => 'Reactivate';

  @override
  String get retireTitle => 'Retire this container?';

  @override
  String get retireMessage =>
      'It will stop receiving waste. Its history is kept.';

  @override
  String get retiredBadge => 'Retired';

  @override
  String addedToRoute(String name) {
    return '$name was added to your route';
  }

  @override
  String removedFromRoute(String name) {
    return '$name was removed from your route';
  }

  @override
  String get inRouteBadge => 'In route';

  @override
  String get detailCapacity => 'Capacity';

  @override
  String get detailThreshold => 'Alert threshold';

  @override
  String detailThresholdGlobal(String value) {
    return '$value (global)';
  }

  @override
  String get detailCurrentCount => 'Current items';

  @override
  String get detailLastCollection => 'Last collection';

  @override
  String get detailSinceCollection => 'Since last collection';

  @override
  String get detailLowConfidence => 'Low confidence';

  @override
  String get detailTotalClassifications => 'Total classified';

  @override
  String get detailRecentClassifications => 'Latest classifications';

  @override
  String get detailRecentCollections => 'Recent collections';

  @override
  String get detailNoCollections => 'No collections yet.';

  @override
  String confidenceValue(String value) {
    return 'Confidence $value';
  }

  @override
  String get registerCollection => 'Register collection';

  @override
  String registerCollectionTitle(String code) {
    return 'Register collection of $code';
  }

  @override
  String get registerCollectionMessage =>
      'The container count will go back to zero.';

  @override
  String get notesLabel => 'Notes (optional)';

  @override
  String get notesTooLong => 'Up to 500 characters';

  @override
  String collectionRegistered(int units) {
    return 'Collection registered: $units items. The count was reset.';
  }

  @override
  String get fillHistoryPeriod => 'Last 14 days';

  @override
  String get fillHistoryEmpty => 'No activity in this period.';

  @override
  String thresholdLine(String value) {
    return 'Threshold $value';
  }

  @override
  String get eventStart => 'Start';

  @override
  String get eventClassification => 'Waste classified';

  @override
  String get eventCollection => 'Collection';

  @override
  String get eventCurrent => 'Now';

  @override
  String get fillHistoryMovements => 'Movements';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldCode => 'Code (optional)';

  @override
  String get fieldCodeHint => 'Leave it empty to generate it automatically';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldEcoPoint => 'Eco point';

  @override
  String get fieldCapacity => 'Capacity (items)';

  @override
  String get fieldThreshold => 'Own threshold % (optional)';

  @override
  String get fieldThresholdHint => 'Empty = use the global threshold';

  @override
  String get fieldActive => 'Active';

  @override
  String get invalidName => 'Use 2 to 100 characters';

  @override
  String get invalidCode => 'Up to 20 characters: letters, numbers, - _ .';

  @override
  String get invalidCapacity => 'Enter a whole number between 1 and 100000';

  @override
  String get invalidThreshold => 'Enter a value between 1 and 100';

  @override
  String get containerCreated => 'Container created';

  @override
  String get containerUpdated => 'Container updated';

  @override
  String alertsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count containers need attention',
      one: '1 container needs attention',
    );
    return '$_temp0';
  }

  @override
  String get alertsEmpty => 'All good: no container is over the threshold.';

  @override
  String get addAllToRoute => 'Add all to my route';

  @override
  String addedAllToRoute(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count containers added to your route',
      one: '1 container added to your route',
      zero: 'They were already in your route',
    );
    return '$_temp0';
  }

  @override
  String get routeEmptyTitle => 'Your route is empty';

  @override
  String get routeEmptyMessage =>
      'Add containers from Fill alerts or Containers.';

  @override
  String get goToAlerts => 'View alerts';

  @override
  String routeSummary(int count, int units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count containers',
      one: '1 container',
    );
    return '$_temp0 · $units items';
  }

  @override
  String get routeHint => 'Long-press and drag to reorder. Swipe to remove.';

  @override
  String routeRegisterAll(int count) {
    return 'Register collection ($count)';
  }

  @override
  String get routeConfirmTitle => 'Register the collection?';

  @override
  String routeConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The collection of $count containers will be registered and their count will go back to zero.',
      one: 'The collection of 1 container will be registered and its count will go back to zero.',
    );
    return '$_temp0';
  }

  @override
  String routeProgress(int current, int total) {
    return 'Registering $current of $total…';
  }

  @override
  String routeDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Route completed: $count collections registered.',
      one: 'Route completed: 1 collection registered.',
    );
    return '$_temp0';
  }

  @override
  String routePartial(int ok, int failed) {
    return '$ok registered, $failed could not be registered. They stay in your route.';
  }

  @override
  String routeOffline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'No connection to the server: $count collections were registered. The other containers stay in your route, saved on this phone.',
      one: 'No connection to the server: 1 collection was registered. The other containers stay in your route, saved on this phone.',
      zero: 'No connection to the server: no collection was registered. Your route is still saved on this phone; register it when the connection is back.',
    );
    return '$_temp0';
  }

  @override
  String get routeClear => 'Clear route';

  @override
  String get routeRemove => 'Remove';

  @override
  String get periodToday => 'Today';

  @override
  String periodDays(int days) {
    return '$days days';
  }

  @override
  String get collectionsEmpty => 'No collections in this period.';

  @override
  String collectedBy(String name) {
    return 'By $name';
  }

  @override
  String unitsCollected(int units) {
    return '$units items';
  }

  @override
  String fillAtCollection(String value) {
    return 'Fill $value';
  }

  @override
  String collectionsTotal(int count, int units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count collections',
      one: '1 collection',
    );
    return '$_temp0 · $units items';
  }

  @override
  String get ecoPointsEmpty => 'There are no eco points yet.';

  @override
  String pointContainers(int active, int total) {
    return '$active of $total containers active';
  }

  @override
  String get activeBadge => 'Active';

  @override
  String get inactiveBadge => 'Inactive';

  @override
  String get newEcoPoint => 'New eco point';

  @override
  String get editEcoPoint => 'Edit eco point';

  @override
  String get fieldZone => 'Building or zone (optional)';

  @override
  String get fieldDescription => 'Description (optional)';

  @override
  String get invalidZone => 'Up to 100 characters';

  @override
  String get invalidDescription => 'Up to 255 characters';

  @override
  String get menuViewContainers => 'View containers';

  @override
  String get menuActivate => 'Activate';

  @override
  String get menuDeactivate => 'Deactivate';

  @override
  String get menuDelete => 'Delete';

  @override
  String get deletePointTitle => 'Delete this eco point?';

  @override
  String get deletePointMessage => 'This action cannot be undone.';

  @override
  String get ecoPointSaved => 'Eco point saved';

  @override
  String get ecoPointDeleted => 'Eco point deleted';

  @override
  String get searchUsers => 'Search by name, username or email';

  @override
  String get usersEmpty => 'No users match the search.';

  @override
  String get fieldUsername => 'Username';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldFullName => 'Full name (optional)';

  @override
  String get fieldRole => 'Role';

  @override
  String get fieldNewPassword => 'Password';

  @override
  String get fieldPasswordConfirm => 'Confirm password';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidUsername => '3 to 50 characters: letters, numbers, . _ -';

  @override
  String get invalidFullName => 'Use letters and spaces (2 to 100)';

  @override
  String get userCreated => 'User created';

  @override
  String get userUpdated => 'User updated';

  @override
  String get menuResetPassword => 'Reset password';

  @override
  String resetPasswordTitle(String username) {
    return 'New password for $username';
  }

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String deactivateUserTitle(String username) {
    return 'Deactivate $username?';
  }

  @override
  String get deactivateUserMessage =>
      'They won\'t be able to sign in until the account is activated again.';

  @override
  String get youBadge => 'You';

  @override
  String lastLoginLabel(String date) {
    return 'Last sign in: $date';
  }

  @override
  String get neverSignedIn => 'Never signed in';

  @override
  String get cantEditOwnRole =>
      'You cannot change your own role or deactivate yourself.';

  @override
  String get allEcoPoints => 'All eco points';

  @override
  String reportRange(String start, String end) {
    return 'From $start to $end';
  }

  @override
  String get kpiClassifications => 'Classified';

  @override
  String get kpiValid => 'Valid';

  @override
  String get kpiLowConfidence => 'Low confidence';

  @override
  String get kpiRejected => 'Rejected';

  @override
  String get kpiAvgConfidence => 'Avg. confidence';

  @override
  String get kpiCollections => 'Collections';

  @override
  String get kpiUnitsCollected => 'Items collected';

  @override
  String get kpiDailyAverage => 'Daily average';

  @override
  String get chartByCategory => 'By category';

  @override
  String get chartDaily => 'Classified per day';

  @override
  String get chartByLocation => 'By eco point';

  @override
  String get chartByHour => 'Busiest hours';

  @override
  String get chartTopContainers => 'Containers with the most waste';

  @override
  String get reportEmptySection => 'No data in this period.';

  @override
  String get searchEvents => 'Search the log';

  @override
  String get eventsEmpty => 'No events match these filters.';

  @override
  String eventsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get levelInfo => 'Info';

  @override
  String get levelWarning => 'Warning';

  @override
  String get levelError => 'Error';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileUsername => 'Username';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileRole => 'Role';

  @override
  String get profileCreated => 'Account created';

  @override
  String get profileLastLogin => 'Last sign in';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profileSessionUntil => 'Session valid until';

  @override
  String get profileTokenStored =>
      'Your token is stored encrypted on this device and sent in the Authorization header.';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get homeLast7Days => 'Last 7 days';

  @override
  String get fieldCapacityHint => 'Empty = default capacity (50)';

  @override
  String get undo => 'Undo';

  @override
  String get routeClearConfirm =>
      'All the containers will be removed from your route.';

  @override
  String get usernameLocked => 'The username can\'t be changed';

  @override
  String get clearFilter => 'Clear filter';

  @override
  String get containerRetired => 'Container retired';

  @override
  String get containerReactivated => 'Container reactivated';

  @override
  String get userActivated => 'User activated';

  @override
  String get userDeactivated => 'User deactivated';

  @override
  String get ecoPointActivated => 'Eco point activated';

  @override
  String get ecoPointDeactivated => 'Eco point deactivated';

  @override
  String ofLabel(int shown, int total) {
    return '$shown of $total';
  }

  @override
  String chartMax(String value) {
    return 'max. $value';
  }

  @override
  String get apiErrorLocationNotFound => 'The eco point no longer exists.';

  @override
  String apiErrorLocationNameTaken(String name) {
    return 'An eco point named $name already exists.';
  }

  @override
  String apiErrorLocationHasTerminals(String terminals) {
    return 'This eco point has terminals assigned ($terminals). Move them to another point or remove them and try again.';
  }

  @override
  String get apiErrorLocationHasHistory =>
      'This eco point has containers or classifications. Deactivate it instead of deleting it to keep its history.';

  @override
  String apiErrorContainerNotFound(String id) {
    return 'Container #$id no longer exists.';
  }

  @override
  String apiErrorContainerCodeTaken(String code) {
    return 'A container with code $code already exists.';
  }

  @override
  String get apiErrorContainerLocationNotFound =>
      'The selected eco point doesn\'t exist.';

  @override
  String get apiErrorContainerInactive => 'This container is deactivated.';

  @override
  String apiErrorUserNotFound(String id) {
    return 'User #$id no longer exists.';
  }

  @override
  String get apiErrorUserAlreadyExists =>
      'That username or email is already registered.';

  @override
  String get apiErrorUserOwnRole => 'You can\'t change your own role.';

  @override
  String get apiErrorUserOwnDeactivation =>
      'You can\'t deactivate your own account.';

  @override
  String get apiErrorUserLastAdmin =>
      'At least one active administrator must remain.';

  @override
  String get eventTypeInicioSistema => 'System started';

  @override
  String get eventTypeInicioSesion => 'Sign-in';

  @override
  String get eventTypeSesionFallida => 'Failed sign-in attempt';

  @override
  String get eventTypeBajaConfianza => 'Low-confidence classification';

  @override
  String get eventTypeClasificacionRechazada => 'Rejected classification';

  @override
  String get eventTypeSinDeteccion => 'Image with no waste detected';

  @override
  String get eventTypeAlertaLlenado => 'Container over its threshold';

  @override
  String get eventTypeCapacidadAlcanzada => 'Container reached capacity';

  @override
  String get eventTypeRecoleccion => 'Collection logged';

  @override
  String get eventTypeRevision => 'Classification review';

  @override
  String get eventTypeConfiguracion => 'Settings change';

  @override
  String get eventTypeContenedor => 'Container management';

  @override
  String get eventTypeUbicacion => 'Eco point management';

  @override
  String get eventTypeUsuario => 'User management';

  @override
  String get eventTypeExportacion => 'Data export';

  @override
  String get eventTypeRendimiento => 'Slow processing';

  @override
  String get eventTypeErrorImagen => 'Invalid image';

  @override
  String get eventTypeErrorDeteccion => 'Detection engine error';

  @override
  String get eventTypeSinContenedor => 'No container available';

  @override
  String get eventTypeResiduoEspecial => 'Hazardous waste presented';

  @override
  String get eventTypePuntoEcologico => 'Live eco point';

  @override
  String get eventTypeTerminal => 'Terminal management';

  @override
  String get offlineBanner => 'Offline: showing the data saved on this phone.';

  @override
  String lastDownloadAt(String date) {
    return 'Last update: $date';
  }

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String failedChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes could not be synced',
      one: '1 change could not be synced',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sync';

  @override
  String get syncing => 'Syncing…';

  @override
  String syncDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes were saved to the system',
      one: '1 change was saved to the system',
    );
    return '$_temp0';
  }

  @override
  String get savedOffline =>
      'Saved offline. It will be saved to the system automatically when the connection is back.';

  @override
  String get deletedOffline =>
      'Deleted offline. It will be removed from the system automatically when the connection is back.';

  @override
  String get pendingCreate => 'Pending: create';

  @override
  String get pendingUpdate => 'Pending: edit';

  @override
  String get pendingDelete => 'Pending: delete';

  @override
  String get syncErrorBadge => 'Could not sync';

  @override
  String get menuDiscardChange => 'Discard change';

  @override
  String get menuViewSyncError => 'See the error';

  @override
  String get changeDiscarded => 'Change discarded.';

  @override
  String get localOnlyHint =>
      'Point created offline: it will be saved to the system automatically when a connection is available.';

  @override
  String get moduleTerminals => 'Terminals';

  @override
  String get titleAssignTerminal => 'Add terminal';

  @override
  String get terminalsEmpty =>
      'There are no terminals yet. Open the eco point screen and add it with the code it shows.';

  @override
  String get terminalStatusUnassigned => 'Unassigned';

  @override
  String get terminalStatusAssigned => 'Assigned';

  @override
  String get terminalStatusChange => 'Asked to change point';

  @override
  String get terminalOnline => 'Online';

  @override
  String get terminalOffline => 'No signal';

  @override
  String get terminalNoPoint => 'No eco point assigned';

  @override
  String terminalLastSeen(String date) {
    return 'Last signal: $date';
  }

  @override
  String get fieldTerminalCode => 'Terminal code';

  @override
  String get terminalCodeHelp =>
      'Type the 6-digit code shown on the terminal screen.';

  @override
  String get terminalCodeInvalid => 'The code must have 6 digits.';

  @override
  String get terminalFind => 'Find terminal';

  @override
  String get terminalFound => 'Terminal found';

  @override
  String terminalAlreadyAt(String point) {
    return 'It is already at “$point” and asked to change point.';
  }

  @override
  String get terminalWhere => 'Which eco point does it go to?';

  @override
  String get terminalExistingPoint => 'Existing point';

  @override
  String get terminalNewPoint => 'New point';

  @override
  String get terminalPickPoint => 'Choose an eco point.';

  @override
  String get terminalNoPoints =>
      'There are no eco points yet. Create a new one for this terminal.';

  @override
  String get terminalNewPointHint =>
      'The point is created with its three containers: recyclable, organic and non-recyclable.';

  @override
  String get terminalExistingHint =>
      'If the point is missing a container, it is created when the terminal is assigned.';

  @override
  String get terminalAssign => 'Assign terminal';

  @override
  String terminalAssigned(String terminal, String point) {
    return '$terminal assigned to “$point”.';
  }

  @override
  String terminalAssignedWithContainers(
    String terminal,
    String point,
    String codes,
  ) {
    return '$terminal assigned to “$point”. Containers created: $codes.';
  }

  @override
  String get menuRemoveTerminal => 'Remove terminal';

  @override
  String get removeTerminalTitle => 'Remove the terminal?';

  @override
  String get removeTerminalMessage =>
      'If that screen is opened again, it will appear as a new terminal with a code. The point\'s containers are not deleted.';

  @override
  String get terminalRemoved => 'Terminal removed.';

  @override
  String get emptyContainer => 'Empty container';

  @override
  String emptyContainerTitle(String code) {
    return 'Empty $code';
  }

  @override
  String get emptyContainerMessage =>
      'The collection is recorded and the container count goes back to zero.';

  @override
  String containerEmptied(int units) {
    return 'Container emptied: $units items. The count went back to zero.';
  }

  @override
  String get terminalCodeNotFound =>
      'The code is not valid or has expired. Check the one the terminal shows.';
}
