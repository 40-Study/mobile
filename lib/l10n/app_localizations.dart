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

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch profile'**
  String get switchProfile;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get addProfile;

  /// No description provided for @updatePersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Update your personal details'**
  String get updatePersonalDetails;

  /// No description provided for @passwordSecurityHint.
  ///
  /// In en, this message translates to:
  /// **'Password, 2FA, login devices'**
  String get passwordSecurityHint;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @managePlanBilling.
  ///
  /// In en, this message translates to:
  /// **'Manage your plan and billing'**
  String get managePlanBilling;

  /// No description provided for @customizeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Customize your notifications'**
  String get customizeNotifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @managePrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get managePrivacySettings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// No description provided for @faqAndSupport.
  ///
  /// In en, this message translates to:
  /// **'FAQ and support'**
  String get faqAndSupport;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(Object version);

  /// No description provided for @signOutHint.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your current account'**
  String get signOutHint;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself...'**
  String get bioHint;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @myPortfolio.
  ///
  /// In en, this message translates to:
  /// **'My Portfolio'**
  String get myPortfolio;

  /// No description provided for @editPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editPortfolio;

  /// No description provided for @previewPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewPortfolio;

  /// No description provided for @introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// No description provided for @featuredProjects.
  ///
  /// In en, this message translates to:
  /// **'Featured Projects'**
  String get featuredProjects;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years experience'**
  String get yearsExperience;

  /// No description provided for @projectsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Projects completed'**
  String get projectsCompleted;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add project'**
  String get addProject;

  /// No description provided for @addExperience.
  ///
  /// In en, this message translates to:
  /// **'Add experience'**
  String get addExperience;

  /// No description provided for @addEducation.
  ///
  /// In en, this message translates to:
  /// **'Add education'**
  String get addEducation;

  /// No description provided for @addSkill.
  ///
  /// In en, this message translates to:
  /// **'Add skill'**
  String get addSkill;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @customizePortfolio.
  ///
  /// In en, this message translates to:
  /// **'Customize portfolio'**
  String get customizePortfolio;

  /// No description provided for @manageLayout.
  ///
  /// In en, this message translates to:
  /// **'Manage layout'**
  String get manageLayout;

  /// No description provided for @toggleVisibility.
  ///
  /// In en, this message translates to:
  /// **'Toggle section visibility'**
  String get toggleVisibility;

  /// No description provided for @publicPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicPortfolio;

  /// No description provided for @privatePortfolio.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get privatePortfolio;

  /// No description provided for @linkOnlyPortfolio.
  ///
  /// In en, this message translates to:
  /// **'People with link'**
  String get linkOnlyPortfolio;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @viewPortfolio.
  ///
  /// In en, this message translates to:
  /// **'View Portfolio'**
  String get viewPortfolio;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: EduFlow'**
  String get projectNameHint;

  /// No description provided for @shortDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get shortDescription;

  /// No description provided for @shortDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: Learning management system'**
  String get shortDescriptionHint;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skillName.
  ///
  /// In en, this message translates to:
  /// **'Skill name'**
  String get skillName;

  /// No description provided for @skillNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: UI Design, Figma, React...'**
  String get skillNameHint;

  /// No description provided for @proficiencyLevel.
  ///
  /// In en, this message translates to:
  /// **'Proficiency level'**
  String get proficiencyLevel;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @positionHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: UI/UX Designer'**
  String get positionHint;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @companyHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: Google, Vela Studio...'**
  String get companyHint;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job description'**
  String get jobDescription;

  /// No description provided for @editIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Edit introduction'**
  String get editIntroduction;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitle;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: UI/UX Designer'**
  String get jobTitleHint;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: Hanoi, Vietnam'**
  String get locationHint;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// No description provided for @websiteHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: yourname.design'**
  String get websiteHint;

  /// No description provided for @aboutYourself.
  ///
  /// In en, this message translates to:
  /// **'About yourself'**
  String get aboutYourself;

  /// No description provided for @aboutYourselfHint.
  ///
  /// In en, this message translates to:
  /// **'Write a few lines about you...'**
  String get aboutYourselfHint;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder sections'**
  String get dragToReorder;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacySettings;

  /// No description provided for @everyoneCanView.
  ///
  /// In en, this message translates to:
  /// **'Everyone can view'**
  String get everyoneCanView;

  /// No description provided for @onlyYouCanView.
  ///
  /// In en, this message translates to:
  /// **'Only you can view'**
  String get onlyYouCanView;

  /// No description provided for @onlyWithLink.
  ///
  /// In en, this message translates to:
  /// **'Only people with link can view'**
  String get onlyWithLink;

  /// No description provided for @linkCopiedToShare.
  ///
  /// In en, this message translates to:
  /// **'Link copied for sharing'**
  String get linkCopiedToShare;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @creatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Creating PDF...'**
  String get creatingPdf;

  /// No description provided for @viewAsOthers.
  ///
  /// In en, this message translates to:
  /// **'View portfolio as others see it'**
  String get viewAsOthers;

  /// No description provided for @shareOnSocial.
  ///
  /// In en, this message translates to:
  /// **'Share portfolio on social media'**
  String get shareOnSocial;

  /// No description provided for @copyPortfolioLink.
  ///
  /// In en, this message translates to:
  /// **'Copy portfolio link'**
  String get copyPortfolioLink;

  /// No description provided for @downloadPortfolioPdf.
  ///
  /// In en, this message translates to:
  /// **'Download portfolio as PDF'**
  String get downloadPortfolioPdf;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @courseLoadError.
  ///
  /// In en, this message translates to:
  /// **'Cannot load course'**
  String get courseLoadError;

  /// No description provided for @lessonUnlockError.
  ///
  /// In en, this message translates to:
  /// **'You need to complete the previous lesson to unlock this one'**
  String get lessonUnlockError;

  /// No description provided for @certificateIssueError.
  ///
  /// In en, this message translates to:
  /// **'Certificate issue error: {error}'**
  String certificateIssueError(Object error);

  /// No description provided for @courseUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Course removed from saved'**
  String get courseUnsaved;

  /// No description provided for @courseSaved.
  ///
  /// In en, this message translates to:
  /// **'Course saved'**
  String get courseSaved;

  /// No description provided for @enrollmentDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Enrollment feature is under development'**
  String get enrollmentDeveloping;

  /// No description provided for @enrollNow.
  ///
  /// In en, this message translates to:
  /// **'Enroll Now'**
  String get enrollNow;

  /// No description provided for @viewCertificateButton.
  ///
  /// In en, this message translates to:
  /// **'View Certificate'**
  String get viewCertificateButton;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @lessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'You have completed {completed} / {total} lessons'**
  String lessonsCompleted(Object completed, Object total);

  /// No description provided for @freeCourse.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeCourse;

  /// No description provided for @lessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String lessonCount(Object count);

  /// No description provided for @minuteCount.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minuteCount(Object count);

  /// No description provided for @downloadCourseMaterial.
  ///
  /// In en, this message translates to:
  /// **'Download course materials'**
  String get downloadCourseMaterial;

  /// No description provided for @openAll.
  ///
  /// In en, this message translates to:
  /// **'Open all'**
  String get openAll;

  /// No description provided for @viewInstructorPage.
  ///
  /// In en, this message translates to:
  /// **'View instructor page'**
  String get viewInstructorPage;

  /// No description provided for @coursesAndStudents.
  ///
  /// In en, this message translates to:
  /// **'{courses} courses • {students} students'**
  String coursesAndStudents(Object courses, Object students);

  /// No description provided for @messageInstructor.
  ///
  /// In en, this message translates to:
  /// **'Message instructor'**
  String get messageInstructor;

  /// No description provided for @lessonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lessonCompleted;

  /// No description provided for @lessonInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get lessonInProgress;

  /// No description provided for @lessonLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lessonLocked;

  /// No description provided for @lessonNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get lessonNotStarted;

  /// No description provided for @lessonWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get lessonWatched;

  /// No description provided for @lessonProgress.
  ///
  /// In en, this message translates to:
  /// **'Lesson Progress'**
  String get lessonProgress;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get settingsLearning;

  /// No description provided for @settingsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get settingsOther;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get settingsLanguageVietnamese;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsEmailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get settingsEmailNotifications;

  /// No description provided for @settingsScheduleReminders.
  ///
  /// In en, this message translates to:
  /// **'Schedule reminders'**
  String get settingsScheduleReminders;

  /// No description provided for @settingsAutoplayVideo.
  ///
  /// In en, this message translates to:
  /// **'Autoplay video'**
  String get settingsAutoplayVideo;

  /// No description provided for @settingsPlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Default playback speed'**
  String get settingsPlaybackSpeed;

  /// No description provided for @settingsWifiDownload.
  ///
  /// In en, this message translates to:
  /// **'Download over Wi-Fi only'**
  String get settingsWifiDownload;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get settingsClearCache;

  /// No description provided for @settingsCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get settingsCacheCleared;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get settingsDarkTheme;

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenterTitle;

  /// No description provided for @helpCenterQuestion.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get helpCenterQuestion;

  /// No description provided for @helpContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get helpContactSupport;

  /// No description provided for @helpEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get helpEmail;

  /// No description provided for @helpHotline.
  ///
  /// In en, this message translates to:
  /// **'Hotline'**
  String get helpHotline;

  /// No description provided for @helpLiveChat.
  ///
  /// In en, this message translates to:
  /// **'Live chat'**
  String get helpLiveChat;

  /// No description provided for @helpLiveChatResponse.
  ///
  /// In en, this message translates to:
  /// **'Response within minutes'**
  String get helpLiveChatResponse;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpFaq;

  /// No description provided for @helpFaqPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'How to change password?'**
  String get helpFaqPasswordChange;

  /// No description provided for @helpFaqPasswordChangeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Account > Password & Security > Change Password to update your password.'**
  String get helpFaqPasswordChangeAnswer;

  /// No description provided for @helpFaqForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password, what should I do?'**
  String get helpFaqForgotPassword;

  /// No description provided for @helpFaqForgotPasswordAnswer.
  ///
  /// In en, this message translates to:
  /// **'On the login screen, tap \'Forgot password\' and follow the instructions to reset your password via email.'**
  String get helpFaqForgotPasswordAnswer;

  /// No description provided for @helpFaqViewCertificate.
  ///
  /// In en, this message translates to:
  /// **'How to view earned certificates?'**
  String get helpFaqViewCertificate;

  /// No description provided for @helpFaqViewCertificateAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to the Achievements tab to view all certificates you have earned.'**
  String get helpFaqViewCertificateAnswer;

  /// No description provided for @helpFaqRefund.
  ///
  /// In en, this message translates to:
  /// **'I want a refund for a course?'**
  String get helpFaqRefund;

  /// No description provided for @helpFaqRefundAnswer.
  ///
  /// In en, this message translates to:
  /// **'Contact us via email or hotline within 7 days of purchase for refund support.'**
  String get helpFaqRefundAnswer;

  /// No description provided for @scheduleErrorLoadData.
  ///
  /// In en, this message translates to:
  /// **'Cannot load data'**
  String get scheduleErrorLoadData;

  /// No description provided for @scheduleOpenItem.
  ///
  /// In en, this message translates to:
  /// **'Open: {title}'**
  String scheduleOpenItem(Object title);

  /// No description provided for @scheduleCourseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Course not found'**
  String get scheduleCourseNotFound;

  /// No description provided for @scheduleNotEnrolled.
  ///
  /// In en, this message translates to:
  /// **'You are not enrolled in this course'**
  String get scheduleNotEnrolled;

  /// No description provided for @quizExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit quiz?'**
  String get quizExitTitle;

  /// No description provided for @quizExitContent.
  ///
  /// In en, this message translates to:
  /// **'Your progress will not be saved.'**
  String get quizExitContent;

  /// No description provided for @quizContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get quizContinue;

  /// No description provided for @quizExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get quizExit;

  /// No description provided for @quizPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get quizPrevious;

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// No description provided for @quizSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get quizSubmit;

  /// No description provided for @quizBackToLesson.
  ///
  /// In en, this message translates to:
  /// **'Back to lesson'**
  String get quizBackToLesson;

  /// No description provided for @quizRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get quizRetry;

  /// No description provided for @exerciseMinutes.
  ///
  /// In en, this message translates to:
  /// **'{duration} minutes'**
  String exerciseMinutes(Object duration);

  /// No description provided for @exercisePoints.
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String exercisePoints(Object points);

  /// No description provided for @exerciseCompletion.
  ///
  /// In en, this message translates to:
  /// **'{rate}% completed'**
  String exerciseCompletion(Object rate);

  /// No description provided for @exerciseDoOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Do on web'**
  String get exerciseDoOnWeb;

  /// No description provided for @exerciseViewScore.
  ///
  /// In en, this message translates to:
  /// **'View score'**
  String get exerciseViewScore;

  /// No description provided for @exerciseDoExercise.
  ///
  /// In en, this message translates to:
  /// **'Do exercise'**
  String get exerciseDoExercise;

  /// No description provided for @exerciseUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get exerciseUnlimited;

  /// No description provided for @exerciseSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get exerciseSubmit;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorGeneric(Object message);

  /// No description provided for @videoLoadError.
  ///
  /// In en, this message translates to:
  /// **'Cannot load video'**
  String get videoLoadError;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved list'**
  String get removeFromSaved;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get openMenu;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @notificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationLabel;

  /// No description provided for @featureDeveloping.
  ///
  /// In en, this message translates to:
  /// **'Feature is under development'**
  String get featureDeveloping;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updateSuccess;

  /// No description provided for @addRoleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added role {role}'**
  String addRoleSuccess(Object role);

  /// No description provided for @addRoleError.
  ///
  /// In en, this message translates to:
  /// **'Error: Cannot add role'**
  String get addRoleError;

  /// No description provided for @noRoleError.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a role, please register'**
  String get noRoleError;

  /// No description provided for @cannotLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Cannot login with {provider}'**
  String cannotLoginWith(Object provider);

  /// No description provided for @pleaseSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Please go back to select a role'**
  String get pleaseSelectRole;

  /// No description provided for @parentLinkChild.
  ///
  /// In en, this message translates to:
  /// **'Link child profile'**
  String get parentLinkChild;

  /// No description provided for @parentManageChildren.
  ///
  /// In en, this message translates to:
  /// **'Manage children'**
  String get parentManageChildren;

  /// No description provided for @parentPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get parentPayment;

  /// No description provided for @parentLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get parentLearning;

  /// No description provided for @parentHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get parentHome;

  /// No description provided for @parentSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get parentSchedule;

  /// No description provided for @parentConfirmLink.
  ///
  /// In en, this message translates to:
  /// **'Confirm link'**
  String get parentConfirmLink;

  /// No description provided for @parentEditInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit info'**
  String get parentEditInfo;

  /// No description provided for @parentEditComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Edit info - Coming soon'**
  String get parentEditComingSoon;

  /// No description provided for @parentContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get parentContactSupport;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;
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
