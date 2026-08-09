import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('pt'),
    Locale('uk'),
    Locale('vi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'40Study'**
  String get appTitle;

  /// The title of the sample items
  ///
  /// In en, this message translates to:
  /// **'Sample Items'**
  String get itemsTitle;

  /// The title of the emails screen
  ///
  /// In en, this message translates to:
  /// **'Emails'**
  String get emailsTitle;

  /// The title of the launches screen
  ///
  /// In en, this message translates to:
  /// **'Launches'**
  String get launchesTitle;

  /// The title of the item
  ///
  /// In en, this message translates to:
  /// **'Sample Item {id}'**
  String itemTitle(Object id);

  /// The title of the settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title for appearance screen
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// Title for enabling dynamic colors from wallpaper
  ///
  /// In en, this message translates to:
  /// **'Use dynamic colors'**
  String get dynamicColorSettingsItemTitle;

  /// Description for dynamic color setting
  ///
  /// In en, this message translates to:
  /// **'Adapt app colors to your wallpaper'**
  String get dynamicColorSettingsItemDescription;

  /// Title for selecting light/dark/system theme
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get darkThemeSettingsItemTitle;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkThemeOnSettingsItemTitle;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get darkThemeOffSettingsItemTitle;

  /// Option to follow system theme
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get darkThemeFollowSystemSettingsItemTitle;

  /// Label for the retry button on error screens
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// Title for appearance settings item
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSettingsItem;

  /// Description for appearance settings item
  ///
  /// In en, this message translates to:
  /// **'Dark theme dynamic color, languages'**
  String get appearanceSettingsItemDescription;

  /// Title for about settings item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSettingsItem;

  /// Description for about settings item
  ///
  /// In en, this message translates to:
  /// **'Version, links, feedback'**
  String get aboutSettingsItemDescription;

  /// The mission launch item label
  ///
  /// In en, this message translates to:
  /// **'Mission: {mission}'**
  String missionTitle(Object mission);

  /// Launched at item label
  ///
  /// In en, this message translates to:
  /// **'Launched at: {launchedAt}'**
  String launchedAt(Object launchedAt);

  /// Rocket item label
  ///
  /// In en, this message translates to:
  /// **'Rocket: {rocketName} ({rocketType})'**
  String rocket(Object rocketName, Object rocketType);

  /// Shows how many days ago from today
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysSinceTodayTitle(Object days);

  /// Shows how many days from today
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String daysFromTodayTitle(Object days);

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @systemThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemThemeTitle;

  /// No description provided for @lightThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightThemeTitle;

  /// No description provided for @darkThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkThemeTitle;

  /// No description provided for @lightGoldThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Light Gold'**
  String get lightGoldThemeTitle;

  /// No description provided for @darkGoldThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Gold'**
  String get darkGoldThemeTitle;

  /// No description provided for @lightMintThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Light Mint'**
  String get lightMintThemeTitle;

  /// No description provided for @darkMintThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mint'**
  String get darkMintThemeTitle;

  /// No description provided for @experimentalThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Experimental Theme'**
  String get experimentalThemeTitle;

  /// The title of the Item Details screen
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetailsTitle;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Empty list'**
  String get emptyList;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @newsScreen.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsScreen;

  /// No description provided for @disabledButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledButtonTitle;

  /// No description provided for @disabledRoundedButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Disabled Rounded'**
  String get disabledRoundedButtonTitle;

  /// No description provided for @disabledWithIconButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Disabled With Icon'**
  String get disabledWithIconButtonTitle;

  /// No description provided for @enabledButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledButtonTitle;

  /// No description provided for @borderRadiusButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'BorderRadius'**
  String get borderRadiusButtonTitle;

  /// No description provided for @borderSideButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'BorderSide'**
  String get borderSideButtonTitle;

  /// No description provided for @iconButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'With Icon'**
  String get iconButtonTitle;

  /// No description provided for @iconAndPaddingButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'With Icon Padding'**
  String get iconAndPaddingButtonTitle;

  /// No description provided for @transparentButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Transparent'**
  String get transparentButtonTitle;

  /// The title for the mission timeline card
  ///
  /// In en, this message translates to:
  /// **'Mission Timeline'**
  String get missionTimeline;

  /// Label for the static fire test item in the timeline
  ///
  /// In en, this message translates to:
  /// **'Static Fire Test'**
  String get staticFireTest;

  /// Label for the launch item in the timeline
  ///
  /// In en, this message translates to:
  /// **'Launch'**
  String get launch;

  /// Label for the mission success item in the timeline
  ///
  /// In en, this message translates to:
  /// **'Mission Success'**
  String get missionSuccess;

  /// Subtitle for mission success item
  ///
  /// In en, this message translates to:
  /// **'Objectives Completed'**
  String get objectivesCompleted;

  /// Displayed when the mission has succeeded
  ///
  /// In en, this message translates to:
  /// **'Mission Successful'**
  String get missionSuccessful;

  /// Displayed when the mission has failed
  ///
  /// In en, this message translates to:
  /// **'Mission Failed'**
  String get missionFailed;

  /// Subtitle when mission succeeded
  ///
  /// In en, this message translates to:
  /// **'All objectives completed'**
  String get allObjectivesCompleted;

  /// Subtitle when mission failed
  ///
  /// In en, this message translates to:
  /// **'Mission objectives not met'**
  String get objectivesNotMet;

  /// Label for the rocket stat card
  ///
  /// In en, this message translates to:
  /// **'Rocket'**
  String get rocketTitle;

  /// Label for the payload stat card
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get payload;

  /// Label for the orbit stat card
  ///
  /// In en, this message translates to:
  /// **'Orbit'**
  String get orbit;

  /// Title for the rocket card section
  ///
  /// In en, this message translates to:
  /// **'Rocket Details'**
  String get rocketDetails;

  /// Label for rocket name in rocket details
  ///
  /// In en, this message translates to:
  /// **'Rocket Name'**
  String get rocketName;

  /// Label for rocket type in rocket details
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get rocketType;

  /// Label for rocket block number
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get rocketBlock;

  /// Title for the first stage details
  ///
  /// In en, this message translates to:
  /// **'🚀 First Stage'**
  String get firstStage;

  /// Label for the core serial number
  ///
  /// In en, this message translates to:
  /// **'Core Serial'**
  String get coreSerial;

  /// Label for flight number
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get flight;

  /// Label for landing type
  ///
  /// In en, this message translates to:
  /// **'Landing'**
  String get landing;

  /// Label for landing success indicator
  ///
  /// In en, this message translates to:
  /// **'Landing Success'**
  String get landingSuccess;

  /// Label for grid fins feature
  ///
  /// In en, this message translates to:
  /// **'Grid Fins'**
  String get gridFins;

  /// Label for landing legs feature
  ///
  /// In en, this message translates to:
  /// **'Landing Legs'**
  String get landingLegs;

  /// Label for reused feature
  ///
  /// In en, this message translates to:
  /// **'Reused'**
  String get reused;

  /// Displayed when data is not available
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// Title for the recovery ships section
  ///
  /// In en, this message translates to:
  /// **'Recovery Ships'**
  String get recoveryShips;

  /// Title of the payload section
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get payloadTitle;

  /// Label for payload ID
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// Label for payload type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Label for payload mass
  ///
  /// In en, this message translates to:
  /// **'Mass'**
  String get mass;

  /// Label for payload manufacturer
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer;

  /// Label for payload nationality
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// Label for payload customers
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// Title for the mission overview section
  ///
  /// In en, this message translates to:
  /// **'Mission Overview'**
  String get missionOverview;

  /// Displayed when no mission details are provided
  ///
  /// In en, this message translates to:
  /// **'No details available'**
  String get noDetails;

  /// Title for links and resources section
  ///
  /// In en, this message translates to:
  /// **'Links & Resources'**
  String get linksResources;

  /// Button label to watch video
  ///
  /// In en, this message translates to:
  /// **'Watch Video'**
  String get watchVideo;

  /// Button label for Wikipedia link
  ///
  /// In en, this message translates to:
  /// **'Wikipedia'**
  String get wikipedia;

  /// Button label for article link
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// Button label for Reddit discussion
  ///
  /// In en, this message translates to:
  /// **'Reddit'**
  String get reddit;

  /// Button label for press kit link
  ///
  /// In en, this message translates to:
  /// **'Press Kit'**
  String get pressKit;

  /// Title for the launch site section
  ///
  /// In en, this message translates to:
  /// **'Launch Site'**
  String get launchSite;

  /// Label for site ID
  ///
  /// In en, this message translates to:
  /// **'Site ID:'**
  String get siteIdLabel;

  /// Label for the flight number
  ///
  /// In en, this message translates to:
  /// **'Flight #{number}'**
  String flightNumber(Object number);

  /// The title of the Rockets tab
  ///
  /// In en, this message translates to:
  /// **'Rockets'**
  String get rocketsTab;

  /// Label for active rocket
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// Label for retired rocket
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get retiredStatus;

  /// Label for rocket success rate with percentage
  ///
  /// In en, this message translates to:
  /// **'{percentage}% success'**
  String successRate(Object percentage);

  /// The title of the Rockets screen
  ///
  /// In en, this message translates to:
  /// **'Rockets'**
  String get rocketsTitle;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @payloadCapacity.
  ///
  /// In en, this message translates to:
  /// **'Payload Capacity'**
  String get payloadCapacity;

  /// No description provided for @engineDetails.
  ///
  /// In en, this message translates to:
  /// **'Engine Details'**
  String get engineDetails;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @diameterLabel.
  ///
  /// In en, this message translates to:
  /// **'Diameter'**
  String get diameterLabel;

  /// No description provided for @massLabel.
  ///
  /// In en, this message translates to:
  /// **'Mass'**
  String get massLabel;

  /// No description provided for @stagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Stages'**
  String get stagesLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @numberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get numberLabel;

  /// No description provided for @propellant1Label.
  ///
  /// In en, this message translates to:
  /// **'Propellant 1'**
  String get propellant1Label;

  /// No description provided for @propellant2Label.
  ///
  /// In en, this message translates to:
  /// **'Propellant 2'**
  String get propellant2Label;

  /// No description provided for @thrustSeaLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Thrust (Sea Level)'**
  String get thrustSeaLevelLabel;

  /// No description provided for @tons.
  ///
  /// In en, this message translates to:
  /// **'tons'**
  String get tons;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @launchInformation.
  ///
  /// In en, this message translates to:
  /// **'Launch Information'**
  String get launchInformation;

  /// No description provided for @launchMass.
  ///
  /// In en, this message translates to:
  /// **'Launch Mass'**
  String get launchMass;

  /// No description provided for @launchVehicle.
  ///
  /// In en, this message translates to:
  /// **'Launch Vehicle'**
  String get launchVehicle;

  /// No description provided for @orbitalParameters.
  ///
  /// In en, this message translates to:
  /// **'Orbital Parameters'**
  String get orbitalParameters;

  /// No description provided for @millionKm.
  ///
  /// In en, this message translates to:
  /// **'million km'**
  String get millionKm;

  /// No description provided for @missionDetails.
  ///
  /// In en, this message translates to:
  /// **'Mission Details'**
  String get missionDetails;

  /// No description provided for @trackLive.
  ///
  /// In en, this message translates to:
  /// **'Track Live'**
  String get trackLive;

  /// No description provided for @marsDistance.
  ///
  /// In en, this message translates to:
  /// **'Mars Distance'**
  String get marsDistance;

  /// No description provided for @earthDistance.
  ///
  /// In en, this message translates to:
  /// **'Earth Distance'**
  String get earthDistance;

  /// No description provided for @currentSpeed.
  ///
  /// In en, this message translates to:
  /// **'Current Speed'**
  String get currentSpeed;

  /// No description provided for @orbitalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Orbital Period'**
  String get orbitalPeriod;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get unitDays;

  /// No description provided for @unitKph.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get unitKph;

  /// No description provided for @launched.
  ///
  /// In en, this message translates to:
  /// **'Launched: {date}'**
  String launched(Object date);

  /// No description provided for @roadsterTitle.
  ///
  /// In en, this message translates to:
  /// **'Roadster'**
  String get roadsterTitle;

  /// No description provided for @roadsterDescription.
  ///
  /// In en, this message translates to:
  /// **'Elon Musk\'s Tesla Roadster'**
  String get roadsterDescription;

  /// No description provided for @apoapsis.
  ///
  /// In en, this message translates to:
  /// **'Apoapsis'**
  String get apoapsis;

  /// No description provided for @periapsis.
  ///
  /// In en, this message translates to:
  /// **'Periapsis'**
  String get periapsis;

  /// No description provided for @semiMajorAxis.
  ///
  /// In en, this message translates to:
  /// **'Semi-major axis'**
  String get semiMajorAxis;

  /// No description provided for @eccentricity.
  ///
  /// In en, this message translates to:
  /// **'Eccentricity'**
  String get eccentricity;

  /// No description provided for @inclination.
  ///
  /// In en, this message translates to:
  /// **'Inclination'**
  String get inclination;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @core_status_active.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get core_status_active;

  /// No description provided for @core_status_lost.
  ///
  /// In en, this message translates to:
  /// **'lost'**
  String get core_status_lost;

  /// No description provided for @core_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'inactive'**
  String get core_status_inactive;

  /// No description provided for @core_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get core_status_unknown;

  /// No description provided for @errorLoadingCores.
  ///
  /// In en, this message translates to:
  /// **'Error loading cores'**
  String get errorLoadingCores;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @firstLaunch.
  ///
  /// In en, this message translates to:
  /// **'First Launch'**
  String get firstLaunch;

  /// No description provided for @missions.
  ///
  /// In en, this message translates to:
  /// **'{count} missions'**
  String missions(Object count);

  /// No description provided for @reuses.
  ///
  /// In en, this message translates to:
  /// **'{count} reuses'**
  String reuses(Object count);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @core_filter_status_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get core_filter_status_all;

  /// No description provided for @core_filter_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get core_filter_status_active;

  /// No description provided for @core_filter_status_lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get core_filter_status_lost;

  /// No description provided for @core_filter_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get core_filter_status_inactive;

  /// No description provided for @core_filter_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get core_filter_status_unknown;

  /// No description provided for @core_filter_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search cores or missions...'**
  String get core_filter_search_hint;

  /// No description provided for @noCoresFound.
  ///
  /// In en, this message translates to:
  /// **'No cores found for \"{query}\"'**
  String noCoresFound(Object query);

  /// No description provided for @blockLabel.
  ///
  /// In en, this message translates to:
  /// **'Block {blockNumber}'**
  String blockLabel(Object blockNumber);

  /// No description provided for @spaceXCoresTitle.
  ///
  /// In en, this message translates to:
  /// **'SpaceX Falcon Cores'**
  String get spaceXCoresTitle;

  /// No description provided for @coresLabel.
  ///
  /// In en, this message translates to:
  /// **'Cores'**
  String get coresLabel;

  /// No description provided for @selectRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRoleTitle;

  /// No description provided for @selectRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe to explore'**
  String get selectRoleSubtitle;

  /// No description provided for @continueWithRole.
  ///
  /// In en, this message translates to:
  /// **'Continue with {role}'**
  String continueWithRole(Object role);

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleTeacher;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @roleOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get roleOrganization;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your learning journey'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get usernameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get agreeToTerms;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to {email}'**
  String otpSubtitle(Object email);

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendOtp;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendOtpIn(Object seconds);

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter email to receive recovery code'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Recovery Code'**
  String get sendResetCode;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get newPasswordHint;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @linkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Linked Accounts'**
  String get linkedAccounts;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Logged In Devices'**
  String get devices;

  /// No description provided for @logoutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Logout All Devices'**
  String get logoutAllDevices;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordMismatch;

  /// No description provided for @errorInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get errorInvalidOtp;

  /// No description provided for @errorNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection error'**
  String get errorNetworkError;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorUnknown;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @featuredCourses.
  ///
  /// In en, this message translates to:
  /// **'Featured Courses'**
  String get featuredCourses;

  /// No description provided for @editCover.
  ///
  /// In en, this message translates to:
  /// **'Edit Cover'**
  String get editCover;

  /// No description provided for @xpPoints.
  ///
  /// In en, this message translates to:
  /// **'XP Points'**
  String get xpPoints;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @tabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// No description provided for @tabAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get tabAchievements;

  /// No description provided for @tabChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get tabChildren;

  /// No description provided for @tabNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tabNotifications;

  /// No description provided for @joinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedOn(Object date);

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfo;

  /// No description provided for @notUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not updated'**
  String get notUpdated;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined Date'**
  String get joinedDate;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @switchRole.
  ///
  /// In en, this message translates to:
  /// **'Switch Role'**
  String get switchRole;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get thisMonth;

  /// No description provided for @parentOverview.
  ///
  /// In en, this message translates to:
  /// **'Parent Overview'**
  String get parentOverview;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @passwordAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Password & Security'**
  String get passwordAndSecurity;

  /// No description provided for @loginSection.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginSection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Use a strong password you don\'t use elsewhere'**
  String get changePasswordHint;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @loggedOutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Logged out all devices'**
  String get loggedOutAllDevices;

  /// No description provided for @unlinkedAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlinked {provider}'**
  String unlinkedAccount(Object provider);

  /// No description provided for @whereYouLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Where you\'re logged in'**
  String get whereYouLoggedIn;

  /// No description provided for @logoutAll.
  ///
  /// In en, this message translates to:
  /// **'Logout All'**
  String get logoutAll;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @securityEmails.
  ///
  /// In en, this message translates to:
  /// **'Security notification emails'**
  String get securityEmails;

  /// No description provided for @securityEmailsHint.
  ///
  /// In en, this message translates to:
  /// **'View official emails from us'**
  String get securityEmailsHint;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity history'**
  String get activityHistory;

  /// No description provided for @activityHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'View all account-related actions'**
  String get activityHistoryHint;

  /// No description provided for @accountId.
  ///
  /// In en, this message translates to:
  /// **'Account ID: {id}'**
  String accountId(Object id);

  /// No description provided for @logoutAllDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout all devices'**
  String get logoutAllDevicesTitle;

  /// No description provided for @logoutAllDevicesContent.
  ///
  /// In en, this message translates to:
  /// **'You will be logged out of all devices, including this one. You will need to log in again.'**
  String get logoutAllDevicesContent;

  /// No description provided for @unlinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlink {provider}'**
  String unlinkAccount(Object provider);

  /// No description provided for @unlinkAccountContent.
  ///
  /// In en, this message translates to:
  /// **'You will not be able to log in with {provider} after unlinking. Are you sure?'**
  String unlinkAccountContent(Object provider);

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @linkOnlyProduction.
  ///
  /// In en, this message translates to:
  /// **'Linking {provider} is only available in production'**
  String linkOnlyProduction(Object provider);

  /// No description provided for @serverNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Server not configured'**
  String get serverNotConfigured;

  /// No description provided for @cannotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Cannot open browser'**
  String get cannotOpenBrowser;

  /// No description provided for @cannotLink.
  ///
  /// In en, this message translates to:
  /// **'Cannot link with {provider}'**
  String cannotLink(Object provider);

  /// No description provided for @noDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevices;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get unknownDevice;

  /// No description provided for @linkWith.
  ///
  /// In en, this message translates to:
  /// **'Link with {provider}'**
  String linkWith(Object provider);

  /// No description provided for @loginWithThisProfile.
  ///
  /// In en, this message translates to:
  /// **'Login with this profile'**
  String get loginWithThisProfile;

  /// No description provided for @swipeToChangeProfile.
  ///
  /// In en, this message translates to:
  /// **'Swipe to change profile'**
  String get swipeToChangeProfile;

  /// No description provided for @organizationProfile.
  ///
  /// In en, this message translates to:
  /// **'Organization profile'**
  String get organizationProfile;

  /// No description provided for @systemProfile.
  ///
  /// In en, this message translates to:
  /// **'System profile'**
  String get systemProfile;

  /// No description provided for @chooseProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose profile'**
  String get chooseProfileTitle;

  /// No description provided for @chooseProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have multiple profiles. Choose one to continue.'**
  String get chooseProfileSubtitle;

  /// No description provided for @achievementTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievementTitle;

  /// No description provided for @allBadges.
  ///
  /// In en, this message translates to:
  /// **'All Badges'**
  String get allBadges;

  /// No description provided for @badgesEarned.
  ///
  /// In en, this message translates to:
  /// **'{earned} / {total} badges earned'**
  String badgesEarned(Object earned, Object total);

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @notEarned.
  ///
  /// In en, this message translates to:
  /// **'Not Earned'**
  String get notEarned;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @habit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habit;

  /// No description provided for @achievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievement;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificate;

  /// No description provided for @yourCertificates.
  ///
  /// In en, this message translates to:
  /// **'Your Certificates'**
  String get yourCertificates;

  /// No description provided for @certificatesEarned.
  ///
  /// In en, this message translates to:
  /// **'{count} certificates earned'**
  String certificatesEarned(Object count);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @studying.
  ///
  /// In en, this message translates to:
  /// **'Studying'**
  String get studying;

  /// No description provided for @design.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get design;

  /// No description provided for @programming.
  ///
  /// In en, this message translates to:
  /// **'Programming'**
  String get programming;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'lessons'**
  String get lessons;

  /// No description provided for @certificateDetail.
  ///
  /// In en, this message translates to:
  /// **'Certificate Detail'**
  String get certificateDetail;

  /// No description provided for @certificateConfirm.
  ///
  /// In en, this message translates to:
  /// **'This certificate confirms you have completed the course and mastered the fundamentals.'**
  String get certificateConfirm;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @addToLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Add to\nLinkedIn'**
  String get addToLinkedIn;

  /// No description provided for @printCertificate.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printCertificate;

  /// No description provided for @courseInfo.
  ///
  /// In en, this message translates to:
  /// **'Course Information'**
  String get courseInfo;

  /// No description provided for @course.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get course;

  /// No description provided for @completionDate.
  ///
  /// In en, this message translates to:
  /// **'Completion Date'**
  String get completionDate;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @instructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructor;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @skillsEarned.
  ///
  /// In en, this message translates to:
  /// **'Skills Earned'**
  String get skillsEarned;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @showQrCode.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get showQrCode;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @viewCertificate.
  ///
  /// In en, this message translates to:
  /// **'View Certificate'**
  String get viewCertificate;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @recentBadges.
  ///
  /// In en, this message translates to:
  /// **'Recent Badges'**
  String get recentBadges;

  /// No description provided for @learningActivity.
  ///
  /// In en, this message translates to:
  /// **'Learning Activity'**
  String get learningActivity;

  /// No description provided for @daysLearned.
  ///
  /// In en, this message translates to:
  /// **'{count} days learned'**
  String daysLearned(Object count);

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @learningTrend.
  ///
  /// In en, this message translates to:
  /// **'Learning Trend'**
  String get learningTrend;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @studyHours.
  ///
  /// In en, this message translates to:
  /// **'Study Hours'**
  String get studyHours;

  /// No description provided for @completedLessons.
  ///
  /// In en, this message translates to:
  /// **'Completed Lessons'**
  String get completedLessons;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;
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
      <String>['de', 'en', 'pt', 'uk', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
