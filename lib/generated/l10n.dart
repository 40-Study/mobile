// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `40Study`
  String get appTitle {
    return Intl.message(
      '40Study',
      name: 'appTitle',
      desc: 'The title of the application',
      args: [],
    );
  }

  /// `Sample Items`
  String get itemsTitle {
    return Intl.message(
      'Sample Items',
      name: 'itemsTitle',
      desc: 'The title of the sample items',
      args: [],
    );
  }

  /// `Emails`
  String get emailsTitle {
    return Intl.message(
      'Emails',
      name: 'emailsTitle',
      desc: 'The title of the emails screen',
      args: [],
    );
  }

  /// `Launches`
  String get launchesTitle {
    return Intl.message(
      'Launches',
      name: 'launchesTitle',
      desc: 'The title of the launches screen',
      args: [],
    );
  }

  /// `Sample Item {id}`
  String itemTitle(Object id) {
    return Intl.message(
      'Sample Item $id',
      name: 'itemTitle',
      desc: 'The title of the item',
      args: [id],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: 'The title of the settings',
      args: [],
    );
  }

  /// `Appearance`
  String get appearanceTitle {
    return Intl.message(
      'Appearance',
      name: 'appearanceTitle',
      desc: 'Title for appearance screen',
      args: [],
    );
  }

  /// `Use dynamic colors`
  String get dynamicColorSettingsItemTitle {
    return Intl.message(
      'Use dynamic colors',
      name: 'dynamicColorSettingsItemTitle',
      desc: 'Title for enabling dynamic colors from wallpaper',
      args: [],
    );
  }

  /// `Adapt app colors to your wallpaper`
  String get dynamicColorSettingsItemDescription {
    return Intl.message(
      'Adapt app colors to your wallpaper',
      name: 'dynamicColorSettingsItemDescription',
      desc: 'Description for dynamic color setting',
      args: [],
    );
  }

  /// `Theme mode`
  String get darkThemeSettingsItemTitle {
    return Intl.message(
      'Theme mode',
      name: 'darkThemeSettingsItemTitle',
      desc: 'Title for selecting light/dark/system theme',
      args: [],
    );
  }

  /// `Dark`
  String get darkThemeOnSettingsItemTitle {
    return Intl.message(
      'Dark',
      name: 'darkThemeOnSettingsItemTitle',
      desc: 'Dark theme option',
      args: [],
    );
  }

  /// `Light`
  String get darkThemeOffSettingsItemTitle {
    return Intl.message(
      'Light',
      name: 'darkThemeOffSettingsItemTitle',
      desc: 'Light theme option',
      args: [],
    );
  }

  /// `System default`
  String get darkThemeFollowSystemSettingsItemTitle {
    return Intl.message(
      'System default',
      name: 'darkThemeFollowSystemSettingsItemTitle',
      desc: 'Option to follow system theme',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgainButton {
    return Intl.message(
      'Try Again',
      name: 'tryAgainButton',
      desc: 'Label for the retry button on error screens',
      args: [],
    );
  }

  /// `Appearance`
  String get appearanceSettingsItem {
    return Intl.message(
      'Appearance',
      name: 'appearanceSettingsItem',
      desc: 'Title for appearance settings item',
      args: [],
    );
  }

  /// `Dark theme dynamic color, languages`
  String get appearanceSettingsItemDescription {
    return Intl.message(
      'Dark theme dynamic color, languages',
      name: 'appearanceSettingsItemDescription',
      desc: 'Description for appearance settings item',
      args: [],
    );
  }

  /// `About`
  String get aboutSettingsItem {
    return Intl.message(
      'About',
      name: 'aboutSettingsItem',
      desc: 'Title for about settings item',
      args: [],
    );
  }

  /// `Version, links, feedback`
  String get aboutSettingsItemDescription {
    return Intl.message(
      'Version, links, feedback',
      name: 'aboutSettingsItemDescription',
      desc: 'Description for about settings item',
      args: [],
    );
  }

  /// `Mission: {mission}`
  String missionTitle(Object mission) {
    return Intl.message(
      'Mission: $mission',
      name: 'missionTitle',
      desc: 'The mission launch item label',
      args: [mission],
    );
  }

  /// `Launched at: {launchedAt}`
  String launchedAt(Object launchedAt) {
    return Intl.message(
      'Launched at: $launchedAt',
      name: 'launchedAt',
      desc: 'Launched at item label',
      args: [launchedAt],
    );
  }

  /// `Rocket: {rocketName} ({rocketType})`
  String rocket(Object rocketName, Object rocketType) {
    return Intl.message(
      'Rocket: $rocketName ($rocketType)',
      name: 'rocket',
      desc: 'Rocket item label',
      args: [rocketName, rocketType],
    );
  }

  /// `{days} days ago`
  String daysSinceTodayTitle(Object days) {
    return Intl.message(
      '$days days ago',
      name: 'daysSinceTodayTitle',
      desc: 'Shows how many days ago from today',
      args: [days],
    );
  }

  /// `In {days} days`
  String daysFromTodayTitle(Object days) {
    return Intl.message(
      'In $days days',
      name: 'daysFromTodayTitle',
      desc: 'Shows how many days from today',
      args: [days],
    );
  }

  /// `Theme`
  String get themeTitle {
    return Intl.message('Theme', name: 'themeTitle', desc: '', args: []);
  }

  /// `System Theme`
  String get systemThemeTitle {
    return Intl.message(
      'System Theme',
      name: 'systemThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Light Theme`
  String get lightThemeTitle {
    return Intl.message(
      'Light Theme',
      name: 'lightThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dark Theme`
  String get darkThemeTitle {
    return Intl.message(
      'Dark Theme',
      name: 'darkThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Light Gold`
  String get lightGoldThemeTitle {
    return Intl.message(
      'Light Gold',
      name: 'lightGoldThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dark Gold`
  String get darkGoldThemeTitle {
    return Intl.message(
      'Dark Gold',
      name: 'darkGoldThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Light Mint`
  String get lightMintThemeTitle {
    return Intl.message(
      'Light Mint',
      name: 'lightMintThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mint`
  String get darkMintThemeTitle {
    return Intl.message(
      'Dark Mint',
      name: 'darkMintThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Experimental Theme`
  String get experimentalThemeTitle {
    return Intl.message(
      'Experimental Theme',
      name: 'experimentalThemeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Item Details`
  String get itemDetailsTitle {
    return Intl.message(
      'Item Details',
      name: 'itemDetailsTitle',
      desc: 'The title of the Item Details screen',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Empty list`
  String get emptyList {
    return Intl.message('Empty list', name: 'emptyList', desc: '', args: []);
  }

  /// `Home`
  String get tabHome {
    return Intl.message('Home', name: 'tabHome', desc: '', args: []);
  }

  /// `Settings`
  String get tabSettings {
    return Intl.message('Settings', name: 'tabSettings', desc: '', args: []);
  }

  /// `News`
  String get newsScreen {
    return Intl.message('News', name: 'newsScreen', desc: '', args: []);
  }

  /// `Disabled`
  String get disabledButtonTitle {
    return Intl.message(
      'Disabled',
      name: 'disabledButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Disabled Rounded`
  String get disabledRoundedButtonTitle {
    return Intl.message(
      'Disabled Rounded',
      name: 'disabledRoundedButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Disabled With Icon`
  String get disabledWithIconButtonTitle {
    return Intl.message(
      'Disabled With Icon',
      name: 'disabledWithIconButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enabled`
  String get enabledButtonTitle {
    return Intl.message(
      'Enabled',
      name: 'enabledButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `BorderRadius`
  String get borderRadiusButtonTitle {
    return Intl.message(
      'BorderRadius',
      name: 'borderRadiusButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `BorderSide`
  String get borderSideButtonTitle {
    return Intl.message(
      'BorderSide',
      name: 'borderSideButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `With Icon`
  String get iconButtonTitle {
    return Intl.message(
      'With Icon',
      name: 'iconButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `With Icon Padding`
  String get iconAndPaddingButtonTitle {
    return Intl.message(
      'With Icon Padding',
      name: 'iconAndPaddingButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Transparent`
  String get transparentButtonTitle {
    return Intl.message(
      'Transparent',
      name: 'transparentButtonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Mission Timeline`
  String get missionTimeline {
    return Intl.message(
      'Mission Timeline',
      name: 'missionTimeline',
      desc: 'The title for the mission timeline card',
      args: [],
    );
  }

  /// `Static Fire Test`
  String get staticFireTest {
    return Intl.message(
      'Static Fire Test',
      name: 'staticFireTest',
      desc: 'Label for the static fire test item in the timeline',
      args: [],
    );
  }

  /// `Launch`
  String get launch {
    return Intl.message(
      'Launch',
      name: 'launch',
      desc: 'Label for the launch item in the timeline',
      args: [],
    );
  }

  /// `Mission Success`
  String get missionSuccess {
    return Intl.message(
      'Mission Success',
      name: 'missionSuccess',
      desc: 'Label for the mission success item in the timeline',
      args: [],
    );
  }

  /// `Objectives Completed`
  String get objectivesCompleted {
    return Intl.message(
      'Objectives Completed',
      name: 'objectivesCompleted',
      desc: 'Subtitle for mission success item',
      args: [],
    );
  }

  /// `Mission Successful`
  String get missionSuccessful {
    return Intl.message(
      'Mission Successful',
      name: 'missionSuccessful',
      desc: 'Displayed when the mission has succeeded',
      args: [],
    );
  }

  /// `Mission Failed`
  String get missionFailed {
    return Intl.message(
      'Mission Failed',
      name: 'missionFailed',
      desc: 'Displayed when the mission has failed',
      args: [],
    );
  }

  /// `All objectives completed`
  String get allObjectivesCompleted {
    return Intl.message(
      'All objectives completed',
      name: 'allObjectivesCompleted',
      desc: 'Subtitle when mission succeeded',
      args: [],
    );
  }

  /// `Mission objectives not met`
  String get objectivesNotMet {
    return Intl.message(
      'Mission objectives not met',
      name: 'objectivesNotMet',
      desc: 'Subtitle when mission failed',
      args: [],
    );
  }

  /// `Rocket`
  String get rocketTitle {
    return Intl.message(
      'Rocket',
      name: 'rocketTitle',
      desc: 'Label for the rocket stat card',
      args: [],
    );
  }

  /// `Payload`
  String get payload {
    return Intl.message(
      'Payload',
      name: 'payload',
      desc: 'Label for the payload stat card',
      args: [],
    );
  }

  /// `Orbit`
  String get orbit {
    return Intl.message(
      'Orbit',
      name: 'orbit',
      desc: 'Label for the orbit stat card',
      args: [],
    );
  }

  /// `Rocket Details`
  String get rocketDetails {
    return Intl.message(
      'Rocket Details',
      name: 'rocketDetails',
      desc: 'Title for the rocket card section',
      args: [],
    );
  }

  /// `Rocket Name`
  String get rocketName {
    return Intl.message(
      'Rocket Name',
      name: 'rocketName',
      desc: 'Label for rocket name in rocket details',
      args: [],
    );
  }

  /// `Type`
  String get rocketType {
    return Intl.message(
      'Type',
      name: 'rocketType',
      desc: 'Label for rocket type in rocket details',
      args: [],
    );
  }

  /// `Block`
  String get rocketBlock {
    return Intl.message(
      'Block',
      name: 'rocketBlock',
      desc: 'Label for rocket block number',
      args: [],
    );
  }

  /// `🚀 First Stage`
  String get firstStage {
    return Intl.message(
      '🚀 First Stage',
      name: 'firstStage',
      desc: 'Title for the first stage details',
      args: [],
    );
  }

  /// `Core Serial`
  String get coreSerial {
    return Intl.message(
      'Core Serial',
      name: 'coreSerial',
      desc: 'Label for the core serial number',
      args: [],
    );
  }

  /// `Flight`
  String get flight {
    return Intl.message(
      'Flight',
      name: 'flight',
      desc: 'Label for flight number',
      args: [],
    );
  }

  /// `Landing`
  String get landing {
    return Intl.message(
      'Landing',
      name: 'landing',
      desc: 'Label for landing type',
      args: [],
    );
  }

  /// `Landing Success`
  String get landingSuccess {
    return Intl.message(
      'Landing Success',
      name: 'landingSuccess',
      desc: 'Label for landing success indicator',
      args: [],
    );
  }

  /// `Grid Fins`
  String get gridFins {
    return Intl.message(
      'Grid Fins',
      name: 'gridFins',
      desc: 'Label for grid fins feature',
      args: [],
    );
  }

  /// `Landing Legs`
  String get landingLegs {
    return Intl.message(
      'Landing Legs',
      name: 'landingLegs',
      desc: 'Label for landing legs feature',
      args: [],
    );
  }

  /// `Reused`
  String get reused {
    return Intl.message(
      'Reused',
      name: 'reused',
      desc: 'Label for reused feature',
      args: [],
    );
  }

  /// `N/A`
  String get notAvailable {
    return Intl.message(
      'N/A',
      name: 'notAvailable',
      desc: 'Displayed when data is not available',
      args: [],
    );
  }

  /// `Recovery Ships`
  String get recoveryShips {
    return Intl.message(
      'Recovery Ships',
      name: 'recoveryShips',
      desc: 'Title for the recovery ships section',
      args: [],
    );
  }

  /// `Payload`
  String get payloadTitle {
    return Intl.message(
      'Payload',
      name: 'payloadTitle',
      desc: 'Title of the payload section',
      args: [],
    );
  }

  /// `ID`
  String get id {
    return Intl.message(
      'ID',
      name: 'id',
      desc: 'Label for payload ID',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: 'Label for payload type',
      args: [],
    );
  }

  /// `Mass`
  String get mass {
    return Intl.message(
      'Mass',
      name: 'mass',
      desc: 'Label for payload mass',
      args: [],
    );
  }

  /// `Manufacturer`
  String get manufacturer {
    return Intl.message(
      'Manufacturer',
      name: 'manufacturer',
      desc: 'Label for payload manufacturer',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message(
      'Nationality',
      name: 'nationality',
      desc: 'Label for payload nationality',
      args: [],
    );
  }

  /// `Customers`
  String get customers {
    return Intl.message(
      'Customers',
      name: 'customers',
      desc: 'Label for payload customers',
      args: [],
    );
  }

  /// `Mission Overview`
  String get missionOverview {
    return Intl.message(
      'Mission Overview',
      name: 'missionOverview',
      desc: 'Title for the mission overview section',
      args: [],
    );
  }

  /// `No details available`
  String get noDetails {
    return Intl.message(
      'No details available',
      name: 'noDetails',
      desc: 'Displayed when no mission details are provided',
      args: [],
    );
  }

  /// `Links & Resources`
  String get linksResources {
    return Intl.message(
      'Links & Resources',
      name: 'linksResources',
      desc: 'Title for links and resources section',
      args: [],
    );
  }

  /// `Watch Video`
  String get watchVideo {
    return Intl.message(
      'Watch Video',
      name: 'watchVideo',
      desc: 'Button label to watch video',
      args: [],
    );
  }

  /// `Wikipedia`
  String get wikipedia {
    return Intl.message(
      'Wikipedia',
      name: 'wikipedia',
      desc: 'Button label for Wikipedia link',
      args: [],
    );
  }

  /// `Article`
  String get article {
    return Intl.message(
      'Article',
      name: 'article',
      desc: 'Button label for article link',
      args: [],
    );
  }

  /// `Reddit`
  String get reddit {
    return Intl.message(
      'Reddit',
      name: 'reddit',
      desc: 'Button label for Reddit discussion',
      args: [],
    );
  }

  /// `Press Kit`
  String get pressKit {
    return Intl.message(
      'Press Kit',
      name: 'pressKit',
      desc: 'Button label for press kit link',
      args: [],
    );
  }

  /// `Launch Site`
  String get launchSite {
    return Intl.message(
      'Launch Site',
      name: 'launchSite',
      desc: 'Title for the launch site section',
      args: [],
    );
  }

  /// `Site ID:`
  String get siteIdLabel {
    return Intl.message(
      'Site ID:',
      name: 'siteIdLabel',
      desc: 'Label for site ID',
      args: [],
    );
  }

  /// `Flight #{number}`
  String flightNumber(Object number) {
    return Intl.message(
      'Flight #$number',
      name: 'flightNumber',
      desc: 'Label for the flight number',
      args: [number],
    );
  }

  /// `Rockets`
  String get rocketsTab {
    return Intl.message(
      'Rockets',
      name: 'rocketsTab',
      desc: 'The title of the Rockets tab',
      args: [],
    );
  }

  /// `Active`
  String get activeStatus {
    return Intl.message(
      'Active',
      name: 'activeStatus',
      desc: 'Label for active rocket',
      args: [],
    );
  }

  /// `Retired`
  String get retiredStatus {
    return Intl.message(
      'Retired',
      name: 'retiredStatus',
      desc: 'Label for retired rocket',
      args: [],
    );
  }

  /// `{percentage}% success`
  String successRate(Object percentage) {
    return Intl.message(
      '$percentage% success',
      name: 'successRate',
      desc: 'Label for rocket success rate with percentage',
      args: [percentage],
    );
  }

  /// `Rockets`
  String get rocketsTitle {
    return Intl.message(
      'Rockets',
      name: 'rocketsTitle',
      desc: 'The title of the Rockets screen',
      args: [],
    );
  }

  /// `Overview`
  String get overview {
    return Intl.message('Overview', name: 'overview', desc: '', args: []);
  }

  /// `Specifications`
  String get specifications {
    return Intl.message(
      'Specifications',
      name: 'specifications',
      desc: '',
      args: [],
    );
  }

  /// `Payload Capacity`
  String get payloadCapacity {
    return Intl.message(
      'Payload Capacity',
      name: 'payloadCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Engine Details`
  String get engineDetails {
    return Intl.message(
      'Engine Details',
      name: 'engineDetails',
      desc: '',
      args: [],
    );
  }

  /// `Height`
  String get heightLabel {
    return Intl.message('Height', name: 'heightLabel', desc: '', args: []);
  }

  /// `Diameter`
  String get diameterLabel {
    return Intl.message('Diameter', name: 'diameterLabel', desc: '', args: []);
  }

  /// `Mass`
  String get massLabel {
    return Intl.message('Mass', name: 'massLabel', desc: '', args: []);
  }

  /// `Stages`
  String get stagesLabel {
    return Intl.message('Stages', name: 'stagesLabel', desc: '', args: []);
  }

  /// `Type`
  String get typeLabel {
    return Intl.message('Type', name: 'typeLabel', desc: '', args: []);
  }

  /// `Version`
  String get versionLabel {
    return Intl.message('Version', name: 'versionLabel', desc: '', args: []);
  }

  /// `Number`
  String get numberLabel {
    return Intl.message('Number', name: 'numberLabel', desc: '', args: []);
  }

  /// `Propellant 1`
  String get propellant1Label {
    return Intl.message(
      'Propellant 1',
      name: 'propellant1Label',
      desc: '',
      args: [],
    );
  }

  /// `Propellant 2`
  String get propellant2Label {
    return Intl.message(
      'Propellant 2',
      name: 'propellant2Label',
      desc: '',
      args: [],
    );
  }

  /// `Thrust (Sea Level)`
  String get thrustSeaLevelLabel {
    return Intl.message(
      'Thrust (Sea Level)',
      name: 'thrustSeaLevelLabel',
      desc: '',
      args: [],
    );
  }

  /// `tons`
  String get tons {
    return Intl.message('tons', name: 'tons', desc: '', args: []);
  }

  /// `Learn More`
  String get learnMore {
    return Intl.message('Learn More', name: 'learnMore', desc: '', args: []);
  }

  /// `Launch Information`
  String get launchInformation {
    return Intl.message(
      'Launch Information',
      name: 'launchInformation',
      desc: '',
      args: [],
    );
  }

  /// `Launch Mass`
  String get launchMass {
    return Intl.message('Launch Mass', name: 'launchMass', desc: '', args: []);
  }

  /// `Launch Vehicle`
  String get launchVehicle {
    return Intl.message(
      'Launch Vehicle',
      name: 'launchVehicle',
      desc: '',
      args: [],
    );
  }

  /// `Orbital Parameters`
  String get orbitalParameters {
    return Intl.message(
      'Orbital Parameters',
      name: 'orbitalParameters',
      desc: '',
      args: [],
    );
  }

  /// `million km`
  String get millionKm {
    return Intl.message('million km', name: 'millionKm', desc: '', args: []);
  }

  /// `Mission Details`
  String get missionDetails {
    return Intl.message(
      'Mission Details',
      name: 'missionDetails',
      desc: '',
      args: [],
    );
  }

  /// `Track Live`
  String get trackLive {
    return Intl.message('Track Live', name: 'trackLive', desc: '', args: []);
  }

  /// `Mars Distance`
  String get marsDistance {
    return Intl.message(
      'Mars Distance',
      name: 'marsDistance',
      desc: '',
      args: [],
    );
  }

  /// `Earth Distance`
  String get earthDistance {
    return Intl.message(
      'Earth Distance',
      name: 'earthDistance',
      desc: '',
      args: [],
    );
  }

  /// `Current Speed`
  String get currentSpeed {
    return Intl.message(
      'Current Speed',
      name: 'currentSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Orbital Period`
  String get orbitalPeriod {
    return Intl.message(
      'Orbital Period',
      name: 'orbitalPeriod',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get unitDays {
    return Intl.message('days', name: 'unitDays', desc: '', args: []);
  }

  /// `km/h`
  String get unitKph {
    return Intl.message('km/h', name: 'unitKph', desc: '', args: []);
  }

  /// `Launched: {date}`
  String launched(Object date) {
    return Intl.message(
      'Launched: $date',
      name: 'launched',
      desc: '',
      args: [date],
    );
  }

  /// `Roadster`
  String get roadsterTitle {
    return Intl.message('Roadster', name: 'roadsterTitle', desc: '', args: []);
  }

  /// `Elon Musk's Tesla Roadster`
  String get roadsterDescription {
    return Intl.message(
      'Elon Musk\'s Tesla Roadster',
      name: 'roadsterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Apoapsis`
  String get apoapsis {
    return Intl.message('Apoapsis', name: 'apoapsis', desc: '', args: []);
  }

  /// `Periapsis`
  String get periapsis {
    return Intl.message('Periapsis', name: 'periapsis', desc: '', args: []);
  }

  /// `Semi-major axis`
  String get semiMajorAxis {
    return Intl.message(
      'Semi-major axis',
      name: 'semiMajorAxis',
      desc: '',
      args: [],
    );
  }

  /// `Eccentricity`
  String get eccentricity {
    return Intl.message(
      'Eccentricity',
      name: 'eccentricity',
      desc: '',
      args: [],
    );
  }

  /// `Inclination`
  String get inclination {
    return Intl.message('Inclination', name: 'inclination', desc: '', args: []);
  }

  /// `Longitude`
  String get longitude {
    return Intl.message('Longitude', name: 'longitude', desc: '', args: []);
  }

  /// `active`
  String get core_status_active {
    return Intl.message(
      'active',
      name: 'core_status_active',
      desc: '',
      args: [],
    );
  }

  /// `lost`
  String get core_status_lost {
    return Intl.message('lost', name: 'core_status_lost', desc: '', args: []);
  }

  /// `inactive`
  String get core_status_inactive {
    return Intl.message(
      'inactive',
      name: 'core_status_inactive',
      desc: '',
      args: [],
    );
  }

  /// `unknown`
  String get core_status_unknown {
    return Intl.message(
      'unknown',
      name: 'core_status_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Error loading cores`
  String get errorLoadingCores {
    return Intl.message(
      'Error loading cores',
      name: 'errorLoadingCores',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `First Launch`
  String get firstLaunch {
    return Intl.message(
      'First Launch',
      name: 'firstLaunch',
      desc: '',
      args: [],
    );
  }

  /// `{count} missions`
  String missions(Object count) {
    return Intl.message(
      '$count missions',
      name: 'missions',
      desc: '',
      args: [count],
    );
  }

  /// `{count} reuses`
  String reuses(Object count) {
    return Intl.message(
      '$count reuses',
      name: 'reuses',
      desc: '',
      args: [count],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `N/A`
  String get na {
    return Intl.message('N/A', name: 'na', desc: '', args: []);
  }

  /// `All`
  String get core_filter_status_all {
    return Intl.message(
      'All',
      name: 'core_filter_status_all',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get core_filter_status_active {
    return Intl.message(
      'Active',
      name: 'core_filter_status_active',
      desc: '',
      args: [],
    );
  }

  /// `Lost`
  String get core_filter_status_lost {
    return Intl.message(
      'Lost',
      name: 'core_filter_status_lost',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get core_filter_status_inactive {
    return Intl.message(
      'Inactive',
      name: 'core_filter_status_inactive',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get core_filter_status_unknown {
    return Intl.message(
      'Unknown',
      name: 'core_filter_status_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Search cores or missions...`
  String get core_filter_search_hint {
    return Intl.message(
      'Search cores or missions...',
      name: 'core_filter_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `No cores found for "{query}"`
  String noCoresFound(Object query) {
    return Intl.message(
      'No cores found for "$query"',
      name: 'noCoresFound',
      desc: '',
      args: [query],
    );
  }

  /// `Block {blockNumber}`
  String blockLabel(Object blockNumber) {
    return Intl.message(
      'Block $blockNumber',
      name: 'blockLabel',
      desc: '',
      args: [blockNumber],
    );
  }

  /// `SpaceX Falcon Cores`
  String get spaceXCoresTitle {
    return Intl.message(
      'SpaceX Falcon Cores',
      name: 'spaceXCoresTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cores`
  String get coresLabel {
    return Intl.message('Cores', name: 'coresLabel', desc: '', args: []);
  }

  /// `Select Role`
  String get selectRoleTitle {
    return Intl.message(
      'Select Role',
      name: 'selectRoleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Swipe to explore`
  String get selectRoleSubtitle {
    return Intl.message(
      'Swipe to explore',
      name: 'selectRoleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Continue with {role}`
  String continueWithRole(Object role) {
    return Intl.message(
      'Continue with $role',
      name: 'continueWithRole',
      desc: '',
      args: [role],
    );
  }

  /// `Tap to select`
  String get tapToSelect {
    return Intl.message(
      'Tap to select',
      name: 'tapToSelect',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Student`
  String get roleStudent {
    return Intl.message('Student', name: 'roleStudent', desc: '', args: []);
  }

  /// `Teacher`
  String get roleTeacher {
    return Intl.message('Teacher', name: 'roleTeacher', desc: '', args: []);
  }

  /// `Parent`
  String get roleParent {
    return Intl.message('Parent', name: 'roleParent', desc: '', args: []);
  }

  /// `Organization`
  String get roleOrganization {
    return Intl.message(
      'Organization',
      name: 'roleOrganization',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginTitle {
    return Intl.message('Login', name: 'loginTitle', desc: '', args: []);
  }

  /// `Welcome back`
  String get loginSubtitle {
    return Intl.message(
      'Welcome back',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get emailLabel {
    return Intl.message('Email', name: 'emailLabel', desc: '', args: []);
  }

  /// `Enter your email`
  String get emailHint {
    return Intl.message(
      'Enter your email',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwordLabel {
    return Intl.message('Password', name: 'passwordLabel', desc: '', args: []);
  }

  /// `Enter password`
  String get passwordHint {
    return Intl.message(
      'Enter password',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginButton {
    return Intl.message('Login', name: 'loginButton', desc: '', args: []);
  }

  /// `Or continue with`
  String get orContinueWith {
    return Intl.message(
      'Or continue with',
      name: 'orContinueWith',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get dontHaveAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get registerTitle {
    return Intl.message(
      'Create Account',
      name: 'registerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Start your learning journey`
  String get registerSubtitle {
    return Intl.message(
      'Start your learning journey',
      name: 'registerSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullNameLabel {
    return Intl.message('Full Name', name: 'fullNameLabel', desc: '', args: []);
  }

  /// `Enter your full name`
  String get fullNameHint {
    return Intl.message(
      'Enter your full name',
      name: 'fullNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get usernameLabel {
    return Intl.message('Username', name: 'usernameLabel', desc: '', args: []);
  }

  /// `Enter username`
  String get usernameHint {
    return Intl.message(
      'Enter username',
      name: 'usernameHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPasswordLabel {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Re-enter password`
  String get confirmPasswordHint {
    return Intl.message(
      'Re-enter password',
      name: 'confirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get registerButton {
    return Intl.message('Register', name: 'registerButton', desc: '', args: []);
  }

  /// `I agree to the`
  String get agreeToTerms {
    return Intl.message(
      'I agree to the',
      name: 'agreeToTerms',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get and {
    return Intl.message('and', name: 'and', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `OTP Verification`
  String get otpTitle {
    return Intl.message(
      'OTP Verification',
      name: 'otpTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter the OTP sent to {email}`
  String otpSubtitle(Object email) {
    return Intl.message(
      'Enter the OTP sent to $email',
      name: 'otpSubtitle',
      desc: '',
      args: [email],
    );
  }

  /// `Resend code`
  String get resendOtp {
    return Intl.message('Resend code', name: 'resendOtp', desc: '', args: []);
  }

  /// `Resend in {seconds}s`
  String resendOtpIn(Object seconds) {
    return Intl.message(
      'Resend in ${seconds}s',
      name: 'resendOtpIn',
      desc: '',
      args: [seconds],
    );
  }

  /// `Verify`
  String get verifyButton {
    return Intl.message('Verify', name: 'verifyButton', desc: '', args: []);
  }

  /// `Forgot Password`
  String get forgotPasswordTitle {
    return Intl.message(
      'Forgot Password',
      name: 'forgotPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter email to receive recovery code`
  String get forgotPasswordSubtitle {
    return Intl.message(
      'Enter email to receive recovery code',
      name: 'forgotPasswordSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Send Recovery Code`
  String get sendResetCode {
    return Intl.message(
      'Send Recovery Code',
      name: 'sendResetCode',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPasswordTitle {
    return Intl.message(
      'Reset Password',
      name: 'resetPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPasswordLabel {
    return Intl.message(
      'New Password',
      name: 'newPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter new password`
  String get newPasswordHint {
    return Intl.message(
      'Enter new password',
      name: 'newPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPasswordButton {
    return Intl.message(
      'Reset Password',
      name: 'resetPasswordButton',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileTitle {
    return Intl.message('Profile', name: 'profileTitle', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneLabel {
    return Intl.message('Phone Number', name: 'phoneLabel', desc: '', args: []);
  }

  /// `Date of Birth`
  String get dateOfBirthLabel {
    return Intl.message(
      'Date of Birth',
      name: 'dateOfBirthLabel',
      desc: '',
      args: [],
    );
  }

  /// `Bio`
  String get bioLabel {
    return Intl.message('Bio', name: 'bioLabel', desc: '', args: []);
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePasswordTitle {
    return Intl.message(
      'Change Password',
      name: 'changePasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get currentPasswordLabel {
    return Intl.message(
      'Current Password',
      name: 'currentPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePasswordButton {
    return Intl.message(
      'Change Password',
      name: 'changePasswordButton',
      desc: '',
      args: [],
    );
  }

  /// `Security`
  String get securityTitle {
    return Intl.message('Security', name: 'securityTitle', desc: '', args: []);
  }

  /// `Linked Accounts`
  String get linkedAccounts {
    return Intl.message(
      'Linked Accounts',
      name: 'linkedAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Logged In Devices`
  String get devices {
    return Intl.message(
      'Logged In Devices',
      name: 'devices',
      desc: '',
      args: [],
    );
  }

  /// `Logout All Devices`
  String get logoutAllDevices {
    return Intl.message(
      'Logout All Devices',
      name: 'logoutAllDevices',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Are you sure you want to logout?`
  String get logoutConfirm {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'logoutConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `This field is required`
  String get errorRequired {
    return Intl.message(
      'This field is required',
      name: 'errorRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get errorInvalidEmail {
    return Intl.message(
      'Invalid email address',
      name: 'errorInvalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters`
  String get errorPasswordTooShort {
    return Intl.message(
      'Password must be at least 8 characters',
      name: 'errorPasswordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get errorPasswordMismatch {
    return Intl.message(
      'Passwords do not match',
      name: 'errorPasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Invalid OTP code`
  String get errorInvalidOtp {
    return Intl.message(
      'Invalid OTP code',
      name: 'errorInvalidOtp',
      desc: '',
      args: [],
    );
  }

  /// `Network connection error`
  String get errorNetworkError {
    return Intl.message(
      'Network connection error',
      name: 'errorNetworkError',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get errorUnknown {
    return Intl.message(
      'An error occurred',
      name: 'errorUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get languageTitle {
    return Intl.message('Language', name: 'languageTitle', desc: '', args: []);
  }

  /// `Students`
  String get students {
    return Intl.message('Students', name: 'students', desc: '', args: []);
  }

  /// `Courses`
  String get courses {
    return Intl.message('Courses', name: 'courses', desc: '', args: []);
  }

  /// `Rating`
  String get rating {
    return Intl.message('Rating', name: 'rating', desc: '', args: []);
  }

  /// `View All`
  String get viewAll {
    return Intl.message('View All', name: 'viewAll', desc: '', args: []);
  }

  /// `Featured Courses`
  String get featuredCourses {
    return Intl.message(
      'Featured Courses',
      name: 'featuredCourses',
      desc: '',
      args: [],
    );
  }

  /// `Edit Cover`
  String get editCover {
    return Intl.message('Edit Cover', name: 'editCover', desc: '', args: []);
  }

  /// `XP Points`
  String get xpPoints {
    return Intl.message('XP Points', name: 'xpPoints', desc: '', args: []);
  }

  /// `Streak`
  String get streak {
    return Intl.message('Streak', name: 'streak', desc: '', args: []);
  }

  /// `Overview`
  String get tabOverview {
    return Intl.message('Overview', name: 'tabOverview', desc: '', args: []);
  }

  /// `Achievements`
  String get tabAchievements {
    return Intl.message(
      'Achievements',
      name: 'tabAchievements',
      desc: '',
      args: [],
    );
  }

  /// `Children`
  String get tabChildren {
    return Intl.message('Children', name: 'tabChildren', desc: '', args: []);
  }

  /// `Notifications`
  String get tabNotifications {
    return Intl.message(
      'Notifications',
      name: 'tabNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Joined {date}`
  String joinedOn(Object date) {
    return Intl.message(
      'Joined $date',
      name: 'joinedOn',
      desc: '',
      args: [date],
    );
  }

  /// `Account Information`
  String get accountInfo {
    return Intl.message(
      'Account Information',
      name: 'accountInfo',
      desc: '',
      args: [],
    );
  }

  /// `Not updated`
  String get notUpdated {
    return Intl.message('Not updated', name: 'notUpdated', desc: '', args: []);
  }

  /// `Joined Date`
  String get joinedDate {
    return Intl.message('Joined Date', name: 'joinedDate', desc: '', args: []);
  }

  /// `Options`
  String get options {
    return Intl.message('Options', name: 'options', desc: '', args: []);
  }

  /// `Switch Role`
  String get switchRole {
    return Intl.message('Switch Role', name: 'switchRole', desc: '', args: []);
  }

  /// `Skills`
  String get skills {
    return Intl.message('Skills', name: 'skills', desc: '', args: []);
  }

  /// `Interests`
  String get interests {
    return Intl.message('Interests', name: 'interests', desc: '', args: []);
  }

  /// `Achievements`
  String get achievements {
    return Intl.message(
      'Achievements',
      name: 'achievements',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message('Contact', name: 'contact', desc: '', args: []);
  }

  /// `Total Earnings`
  String get totalEarnings {
    return Intl.message(
      'Total Earnings',
      name: 'totalEarnings',
      desc: '',
      args: [],
    );
  }

  /// `this month`
  String get thisMonth {
    return Intl.message('this month', name: 'thisMonth', desc: '', args: []);
  }

  /// `Parent Overview`
  String get parentOverview {
    return Intl.message(
      'Parent Overview',
      name: 'parentOverview',
      desc: '',
      args: [],
    );
  }

  /// `Children`
  String get children {
    return Intl.message('Children', name: 'children', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Classes`
  String get classes {
    return Intl.message('Classes', name: 'classes', desc: '', args: []);
  }

  /// `Password & Security`
  String get passwordAndSecurity {
    return Intl.message(
      'Password & Security',
      name: 'passwordAndSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginSection {
    return Intl.message('Login', name: 'loginSection', desc: '', args: []);
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Use a strong password you don't use elsewhere`
  String get changePasswordHint {
    return Intl.message(
      'Use a strong password you don\'t use elsewhere',
      name: 'changePasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Password changed successfully`
  String get passwordChangedSuccess {
    return Intl.message(
      'Password changed successfully',
      name: 'passwordChangedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Logged out all devices`
  String get loggedOutAllDevices {
    return Intl.message(
      'Logged out all devices',
      name: 'loggedOutAllDevices',
      desc: '',
      args: [],
    );
  }

  /// `Unlinked {provider}`
  String unlinkedAccount(Object provider) {
    return Intl.message(
      'Unlinked $provider',
      name: 'unlinkedAccount',
      desc: '',
      args: [provider],
    );
  }

  /// `Where you're logged in`
  String get whereYouLoggedIn {
    return Intl.message(
      'Where you\'re logged in',
      name: 'whereYouLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `Logout All`
  String get logoutAll {
    return Intl.message('Logout All', name: 'logoutAll', desc: '', args: []);
  }

  /// `Advanced`
  String get advanced {
    return Intl.message('Advanced', name: 'advanced', desc: '', args: []);
  }

  /// `Security notification emails`
  String get securityEmails {
    return Intl.message(
      'Security notification emails',
      name: 'securityEmails',
      desc: '',
      args: [],
    );
  }

  /// `View official emails from us`
  String get securityEmailsHint {
    return Intl.message(
      'View official emails from us',
      name: 'securityEmailsHint',
      desc: '',
      args: [],
    );
  }

  /// `Activity history`
  String get activityHistory {
    return Intl.message(
      'Activity history',
      name: 'activityHistory',
      desc: '',
      args: [],
    );
  }

  /// `View all account-related actions`
  String get activityHistoryHint {
    return Intl.message(
      'View all account-related actions',
      name: 'activityHistoryHint',
      desc: '',
      args: [],
    );
  }

  /// `Account ID: {id}`
  String accountId(Object id) {
    return Intl.message(
      'Account ID: $id',
      name: 'accountId',
      desc: '',
      args: [id],
    );
  }

  /// `Logout all devices`
  String get logoutAllDevicesTitle {
    return Intl.message(
      'Logout all devices',
      name: 'logoutAllDevicesTitle',
      desc: '',
      args: [],
    );
  }

  /// `You will be logged out of all devices, including this one. You will need to log in again.`
  String get logoutAllDevicesContent {
    return Intl.message(
      'You will be logged out of all devices, including this one. You will need to log in again.',
      name: 'logoutAllDevicesContent',
      desc: '',
      args: [],
    );
  }

  /// `Unlink {provider}`
  String unlinkAccount(Object provider) {
    return Intl.message(
      'Unlink $provider',
      name: 'unlinkAccount',
      desc: '',
      args: [provider],
    );
  }

  /// `You will not be able to log in with {provider} after unlinking. Are you sure?`
  String unlinkAccountContent(Object provider) {
    return Intl.message(
      'You will not be able to log in with $provider after unlinking. Are you sure?',
      name: 'unlinkAccountContent',
      desc: '',
      args: [provider],
    );
  }

  /// `Unlink`
  String get unlink {
    return Intl.message('Unlink', name: 'unlink', desc: '', args: []);
  }

  /// `Linking {provider} is only available in production`
  String linkOnlyProduction(Object provider) {
    return Intl.message(
      'Linking $provider is only available in production',
      name: 'linkOnlyProduction',
      desc: '',
      args: [provider],
    );
  }

  /// `Server not configured`
  String get serverNotConfigured {
    return Intl.message(
      'Server not configured',
      name: 'serverNotConfigured',
      desc: '',
      args: [],
    );
  }

  /// `Cannot open browser`
  String get cannotOpenBrowser {
    return Intl.message(
      'Cannot open browser',
      name: 'cannotOpenBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Cannot link with {provider}`
  String cannotLink(Object provider) {
    return Intl.message(
      'Cannot link with $provider',
      name: 'cannotLink',
      desc: '',
      args: [provider],
    );
  }

  /// `No devices found`
  String get noDevices {
    return Intl.message(
      'No devices found',
      name: 'noDevices',
      desc: '',
      args: [],
    );
  }

  /// `Reload`
  String get reload {
    return Intl.message('Reload', name: 'reload', desc: '', args: []);
  }

  /// `This device`
  String get thisDevice {
    return Intl.message('This device', name: 'thisDevice', desc: '', args: []);
  }

  /// `Unknown device`
  String get unknownDevice {
    return Intl.message(
      'Unknown device',
      name: 'unknownDevice',
      desc: '',
      args: [],
    );
  }

  /// `Link with {provider}`
  String linkWith(Object provider) {
    return Intl.message(
      'Link with $provider',
      name: 'linkWith',
      desc: '',
      args: [provider],
    );
  }

  /// `Login with this profile`
  String get loginWithThisProfile {
    return Intl.message(
      'Login with this profile',
      name: 'loginWithThisProfile',
      desc: '',
      args: [],
    );
  }

  /// `Swipe to change profile`
  String get swipeToChangeProfile {
    return Intl.message(
      'Swipe to change profile',
      name: 'swipeToChangeProfile',
      desc: '',
      args: [],
    );
  }

  /// `Organization profile`
  String get organizationProfile {
    return Intl.message(
      'Organization profile',
      name: 'organizationProfile',
      desc: '',
      args: [],
    );
  }

  /// `System profile`
  String get systemProfile {
    return Intl.message(
      'System profile',
      name: 'systemProfile',
      desc: '',
      args: [],
    );
  }

  /// `Choose profile`
  String get chooseProfileTitle {
    return Intl.message(
      'Choose profile',
      name: 'chooseProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have multiple profiles. Choose one to continue.`
  String get chooseProfileSubtitle {
    return Intl.message(
      'You have multiple profiles. Choose one to continue.',
      name: 'chooseProfileSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Achievement`
  String get achievementTitle {
    return Intl.message(
      'Achievement',
      name: 'achievementTitle',
      desc: '',
      args: [],
    );
  }

  /// `All Badges`
  String get allBadges {
    return Intl.message('All Badges', name: 'allBadges', desc: '', args: []);
  }

  /// `{earned} / {total} badges earned`
  String badgesEarned(Object earned, Object total) {
    return Intl.message(
      '$earned / $total badges earned',
      name: 'badgesEarned',
      desc: '',
      args: [earned, total],
    );
  }

  /// `Overall Progress`
  String get overallProgress {
    return Intl.message(
      'Overall Progress',
      name: 'overallProgress',
      desc: '',
      args: [],
    );
  }

  /// `Earned`
  String get earned {
    return Intl.message('Earned', name: 'earned', desc: '', args: []);
  }

  /// `In Progress`
  String get inProgress {
    return Intl.message('In Progress', name: 'inProgress', desc: '', args: []);
  }

  /// `Not Earned`
  String get notEarned {
    return Intl.message('Not Earned', name: 'notEarned', desc: '', args: []);
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Learning`
  String get learning {
    return Intl.message('Learning', name: 'learning', desc: '', args: []);
  }

  /// `Habit`
  String get habit {
    return Intl.message('Habit', name: 'habit', desc: '', args: []);
  }

  /// `Achievement`
  String get achievement {
    return Intl.message('Achievement', name: 'achievement', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `NEW`
  String get newBadge {
    return Intl.message('NEW', name: 'newBadge', desc: '', args: []);
  }

  /// `Certificate`
  String get certificate {
    return Intl.message('Certificate', name: 'certificate', desc: '', args: []);
  }

  /// `Your Certificates`
  String get yourCertificates {
    return Intl.message(
      'Your Certificates',
      name: 'yourCertificates',
      desc: '',
      args: [],
    );
  }

  /// `{count} certificates earned`
  String certificatesEarned(Object count) {
    return Intl.message(
      '$count certificates earned',
      name: 'certificatesEarned',
      desc: '',
      args: [count],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Studying`
  String get studying {
    return Intl.message('Studying', name: 'studying', desc: '', args: []);
  }

  /// `Design`
  String get design {
    return Intl.message('Design', name: 'design', desc: '', args: []);
  }

  /// `Programming`
  String get programming {
    return Intl.message('Programming', name: 'programming', desc: '', args: []);
  }

  /// `Business`
  String get business {
    return Intl.message('Business', name: 'business', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `lessons`
  String get lessons {
    return Intl.message('lessons', name: 'lessons', desc: '', args: []);
  }

  /// `Certificate Detail`
  String get certificateDetail {
    return Intl.message(
      'Certificate Detail',
      name: 'certificateDetail',
      desc: '',
      args: [],
    );
  }

  /// `This certificate confirms you have completed the course and mastered the fundamentals.`
  String get certificateConfirm {
    return Intl.message(
      'This certificate confirms you have completed the course and mastered the fundamentals.',
      name: 'certificateConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Add to\nLinkedIn`
  String get addToLinkedIn {
    return Intl.message(
      'Add to\nLinkedIn',
      name: 'addToLinkedIn',
      desc: '',
      args: [],
    );
  }

  /// `Print`
  String get printCertificate {
    return Intl.message('Print', name: 'printCertificate', desc: '', args: []);
  }

  /// `Course Information`
  String get courseInfo {
    return Intl.message(
      'Course Information',
      name: 'courseInfo',
      desc: '',
      args: [],
    );
  }

  /// `Course`
  String get course {
    return Intl.message('Course', name: 'course', desc: '', args: []);
  }

  /// `Completion Date`
  String get completionDate {
    return Intl.message(
      'Completion Date',
      name: 'completionDate',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `Instructor`
  String get instructor {
    return Intl.message('Instructor', name: 'instructor', desc: '', args: []);
  }

  /// `Level`
  String get level {
    return Intl.message('Level', name: 'level', desc: '', args: []);
  }

  /// `Basic`
  String get basic {
    return Intl.message('Basic', name: 'basic', desc: '', args: []);
  }

  /// `Skills Earned`
  String get skillsEarned {
    return Intl.message(
      'Skills Earned',
      name: 'skillsEarned',
      desc: '',
      args: [],
    );
  }

  /// `Download PDF`
  String get downloadPdf {
    return Intl.message(
      'Download PDF',
      name: 'downloadPdf',
      desc: '',
      args: [],
    );
  }

  /// `Copy Link`
  String get copyLink {
    return Intl.message('Copy Link', name: 'copyLink', desc: '', args: []);
  }

  /// `Show QR Code`
  String get showQrCode {
    return Intl.message('Show QR Code', name: 'showQrCode', desc: '', args: []);
  }

  /// `Report Issue`
  String get reportIssue {
    return Intl.message(
      'Report Issue',
      name: 'reportIssue',
      desc: '',
      args: [],
    );
  }

  /// `View Certificate`
  String get viewCertificate {
    return Intl.message(
      'View Certificate',
      name: 'viewCertificate',
      desc: '',
      args: [],
    );
  }

  /// `Continue Learning`
  String get continueLearning {
    return Intl.message(
      'Continue Learning',
      name: 'continueLearning',
      desc: '',
      args: [],
    );
  }

  /// `Recent Badges`
  String get recentBadges {
    return Intl.message(
      'Recent Badges',
      name: 'recentBadges',
      desc: '',
      args: [],
    );
  }

  /// `Learning Activity`
  String get learningActivity {
    return Intl.message(
      'Learning Activity',
      name: 'learningActivity',
      desc: '',
      args: [],
    );
  }

  /// `{count} days learned`
  String daysLearned(Object count) {
    return Intl.message(
      '$count days learned',
      name: 'daysLearned',
      desc: '',
      args: [count],
    );
  }

  /// `Less`
  String get less {
    return Intl.message('Less', name: 'less', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Learning Trend`
  String get learningTrend {
    return Intl.message(
      'Learning Trend',
      name: 'learningTrend',
      desc: '',
      args: [],
    );
  }

  /// `Last 7 days`
  String get last7Days {
    return Intl.message('Last 7 days', name: 'last7Days', desc: '', args: []);
  }

  /// `min`
  String get minutes {
    return Intl.message('min', name: 'minutes', desc: '', args: []);
  }

  /// `Study Hours`
  String get studyHours {
    return Intl.message('Study Hours', name: 'studyHours', desc: '', args: []);
  }

  /// `Completed Lessons`
  String get completedLessons {
    return Intl.message(
      'Completed Lessons',
      name: 'completedLessons',
      desc: '',
      args: [],
    );
  }

  /// `Badges`
  String get badges {
    return Intl.message('Badges', name: 'badges', desc: '', args: []);
  }

  /// `Good morning`
  String get goodMorning {
    return Intl.message(
      'Good morning',
      name: 'goodMorning',
      desc: '',
      args: [],
    );
  }

  /// `Good afternoon`
  String get goodAfternoon {
    return Intl.message(
      'Good afternoon',
      name: 'goodAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good evening`
  String get goodEvening {
    return Intl.message(
      'Good evening',
      name: 'goodEvening',
      desc: '',
      args: [],
    );
  }

  /// `Your account`
  String get yourAccount {
    return Intl.message(
      'Your account',
      name: 'yourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Switch profile`
  String get switchProfile {
    return Intl.message(
      'Switch profile',
      name: 'switchProfile',
      desc: '',
      args: [],
    );
  }

  /// `Add profile`
  String get addProfile {
    return Intl.message('Add profile', name: 'addProfile', desc: '', args: []);
  }

  /// `Update your personal details`
  String get updatePersonalDetails {
    return Intl.message(
      'Update your personal details',
      name: 'updatePersonalDetails',
      desc: '',
      args: [],
    );
  }

  /// `Password, 2FA, login devices`
  String get passwordSecurityHint {
    return Intl.message(
      'Password, 2FA, login devices',
      name: 'passwordSecurityHint',
      desc: '',
      args: [],
    );
  }

  /// `Subscription`
  String get subscription {
    return Intl.message(
      'Subscription',
      name: 'subscription',
      desc: '',
      args: [],
    );
  }

  /// `Manage your plan and billing`
  String get managePlanBilling {
    return Intl.message(
      'Manage your plan and billing',
      name: 'managePlanBilling',
      desc: '',
      args: [],
    );
  }

  /// `Customize your notifications`
  String get customizeNotifications {
    return Intl.message(
      'Customize your notifications',
      name: 'customizeNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacy {
    return Intl.message('Privacy', name: 'privacy', desc: '', args: []);
  }

  /// `Manage your privacy settings`
  String get managePrivacySettings {
    return Intl.message(
      'Manage your privacy settings',
      name: 'managePrivacySettings',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `Help center`
  String get helpCenter {
    return Intl.message('Help center', name: 'helpCenter', desc: '', args: []);
  }

  /// `FAQ and support`
  String get faqAndSupport {
    return Intl.message(
      'FAQ and support',
      name: 'faqAndSupport',
      desc: '',
      args: [],
    );
  }

  /// `Version {version}`
  String version(Object version) {
    return Intl.message(
      'Version $version',
      name: 'version',
      desc: '',
      args: [version],
    );
  }

  /// `Sign out from your current account`
  String get signOutHint {
    return Intl.message(
      'Sign out from your current account',
      name: 'signOutHint',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get premium {
    return Intl.message('Premium', name: 'premium', desc: '', args: []);
  }

  /// `Student`
  String get student {
    return Intl.message('Student', name: 'student', desc: '', args: []);
  }

  /// `Change photo`
  String get changePhoto {
    return Intl.message(
      'Change photo',
      name: 'changePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Tell us about yourself...`
  String get bioHint {
    return Intl.message(
      'Tell us about yourself...',
      name: 'bioHint',
      desc: '',
      args: [],
    );
  }

  /// `Verified`
  String get verified {
    return Intl.message('Verified', name: 'verified', desc: '', args: []);
  }

  /// `Portfolio`
  String get portfolio {
    return Intl.message('Portfolio', name: 'portfolio', desc: '', args: []);
  }

  /// `My Portfolio`
  String get myPortfolio {
    return Intl.message(
      'My Portfolio',
      name: 'myPortfolio',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get editPortfolio {
    return Intl.message('Edit', name: 'editPortfolio', desc: '', args: []);
  }

  /// `Preview`
  String get previewPortfolio {
    return Intl.message(
      'Preview',
      name: 'previewPortfolio',
      desc: '',
      args: [],
    );
  }

  /// `Introduction`
  String get introduction {
    return Intl.message(
      'Introduction',
      name: 'introduction',
      desc: '',
      args: [],
    );
  }

  /// `Featured Projects`
  String get featuredProjects {
    return Intl.message(
      'Featured Projects',
      name: 'featuredProjects',
      desc: '',
      args: [],
    );
  }

  /// `Experience`
  String get experience {
    return Intl.message('Experience', name: 'experience', desc: '', args: []);
  }

  /// `Education`
  String get education {
    return Intl.message('Education', name: 'education', desc: '', args: []);
  }

  /// `Years experience`
  String get yearsExperience {
    return Intl.message(
      'Years experience',
      name: 'yearsExperience',
      desc: '',
      args: [],
    );
  }

  /// `Projects completed`
  String get projectsCompleted {
    return Intl.message(
      'Projects completed',
      name: 'projectsCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Followers`
  String get followers {
    return Intl.message('Followers', name: 'followers', desc: '', args: []);
  }

  /// `Add project`
  String get addProject {
    return Intl.message('Add project', name: 'addProject', desc: '', args: []);
  }

  /// `Add experience`
  String get addExperience {
    return Intl.message(
      'Add experience',
      name: 'addExperience',
      desc: '',
      args: [],
    );
  }

  /// `Add education`
  String get addEducation {
    return Intl.message(
      'Add education',
      name: 'addEducation',
      desc: '',
      args: [],
    );
  }

  /// `Add skill`
  String get addSkill {
    return Intl.message('Add skill', name: 'addSkill', desc: '', args: []);
  }

  /// `Present`
  String get present {
    return Intl.message('Present', name: 'present', desc: '', args: []);
  }

  /// `Customize portfolio`
  String get customizePortfolio {
    return Intl.message(
      'Customize portfolio',
      name: 'customizePortfolio',
      desc: '',
      args: [],
    );
  }

  /// `Manage layout`
  String get manageLayout {
    return Intl.message(
      'Manage layout',
      name: 'manageLayout',
      desc: '',
      args: [],
    );
  }

  /// `Toggle section visibility`
  String get toggleVisibility {
    return Intl.message(
      'Toggle section visibility',
      name: 'toggleVisibility',
      desc: '',
      args: [],
    );
  }

  /// `Public`
  String get publicPortfolio {
    return Intl.message('Public', name: 'publicPortfolio', desc: '', args: []);
  }

  /// `Only me`
  String get privatePortfolio {
    return Intl.message(
      'Only me',
      name: 'privatePortfolio',
      desc: '',
      args: [],
    );
  }

  /// `People with link`
  String get linkOnlyPortfolio {
    return Intl.message(
      'People with link',
      name: 'linkOnlyPortfolio',
      desc: '',
      args: [],
    );
  }

  /// `Saved`
  String get saved {
    return Intl.message('Saved', name: 'saved', desc: '', args: []);
  }

  /// `Saving...`
  String get saving {
    return Intl.message('Saving...', name: 'saving', desc: '', args: []);
  }

  /// `View Portfolio`
  String get viewPortfolio {
    return Intl.message(
      'View Portfolio',
      name: 'viewPortfolio',
      desc: '',
      args: [],
    );
  }

  /// `Project name`
  String get projectName {
    return Intl.message(
      'Project name',
      name: 'projectName',
      desc: '',
      args: [],
    );
  }

  /// `E.g: EduFlow`
  String get projectNameHint {
    return Intl.message(
      'E.g: EduFlow',
      name: 'projectNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Short description`
  String get shortDescription {
    return Intl.message(
      'Short description',
      name: 'shortDescription',
      desc: '',
      args: [],
    );
  }

  /// `E.g: Learning management system`
  String get shortDescriptionHint {
    return Intl.message(
      'E.g: Learning management system',
      name: 'shortDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Category`
  String get categoryLabel {
    return Intl.message('Category', name: 'categoryLabel', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Skill name`
  String get skillName {
    return Intl.message('Skill name', name: 'skillName', desc: '', args: []);
  }

  /// `E.g: UI Design, Figma, React...`
  String get skillNameHint {
    return Intl.message(
      'E.g: UI Design, Figma, React...',
      name: 'skillNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Proficiency level`
  String get proficiencyLevel {
    return Intl.message(
      'Proficiency level',
      name: 'proficiencyLevel',
      desc: '',
      args: [],
    );
  }

  /// `Position`
  String get position {
    return Intl.message('Position', name: 'position', desc: '', args: []);
  }

  /// `E.g: UI/UX Designer`
  String get positionHint {
    return Intl.message(
      'E.g: UI/UX Designer',
      name: 'positionHint',
      desc: '',
      args: [],
    );
  }

  /// `Company`
  String get company {
    return Intl.message('Company', name: 'company', desc: '', args: []);
  }

  /// `E.g: Google, Vela Studio...`
  String get companyHint {
    return Intl.message(
      'E.g: Google, Vela Studio...',
      name: 'companyHint',
      desc: '',
      args: [],
    );
  }

  /// `Job description`
  String get jobDescription {
    return Intl.message(
      'Job description',
      name: 'jobDescription',
      desc: '',
      args: [],
    );
  }

  /// `Edit introduction`
  String get editIntroduction {
    return Intl.message(
      'Edit introduction',
      name: 'editIntroduction',
      desc: '',
      args: [],
    );
  }

  /// `Full name`
  String get fullName {
    return Intl.message('Full name', name: 'fullName', desc: '', args: []);
  }

  /// `Job title`
  String get jobTitle {
    return Intl.message('Job title', name: 'jobTitle', desc: '', args: []);
  }

  /// `E.g: UI/UX Designer`
  String get jobTitleHint {
    return Intl.message(
      'E.g: UI/UX Designer',
      name: 'jobTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get locationLabel {
    return Intl.message('Location', name: 'locationLabel', desc: '', args: []);
  }

  /// `E.g: Hanoi, Vietnam`
  String get locationHint {
    return Intl.message(
      'E.g: Hanoi, Vietnam',
      name: 'locationHint',
      desc: '',
      args: [],
    );
  }

  /// `Website`
  String get websiteLabel {
    return Intl.message('Website', name: 'websiteLabel', desc: '', args: []);
  }

  /// `E.g: yourname.design`
  String get websiteHint {
    return Intl.message(
      'E.g: yourname.design',
      name: 'websiteHint',
      desc: '',
      args: [],
    );
  }

  /// `About yourself`
  String get aboutYourself {
    return Intl.message(
      'About yourself',
      name: 'aboutYourself',
      desc: '',
      args: [],
    );
  }

  /// `Write a few lines about you...`
  String get aboutYourselfHint {
    return Intl.message(
      'Write a few lines about you...',
      name: 'aboutYourselfHint',
      desc: '',
      args: [],
    );
  }

  /// `Drag to reorder sections`
  String get dragToReorder {
    return Intl.message(
      'Drag to reorder sections',
      name: 'dragToReorder',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacySettings {
    return Intl.message('Privacy', name: 'privacySettings', desc: '', args: []);
  }

  /// `Everyone can view`
  String get everyoneCanView {
    return Intl.message(
      'Everyone can view',
      name: 'everyoneCanView',
      desc: '',
      args: [],
    );
  }

  /// `Only you can view`
  String get onlyYouCanView {
    return Intl.message(
      'Only you can view',
      name: 'onlyYouCanView',
      desc: '',
      args: [],
    );
  }

  /// `Only people with link can view`
  String get onlyWithLink {
    return Intl.message(
      'Only people with link can view',
      name: 'onlyWithLink',
      desc: '',
      args: [],
    );
  }

  /// `Link copied for sharing`
  String get linkCopiedToShare {
    return Intl.message(
      'Link copied for sharing',
      name: 'linkCopiedToShare',
      desc: '',
      args: [],
    );
  }

  /// `Link copied`
  String get linkCopied {
    return Intl.message('Link copied', name: 'linkCopied', desc: '', args: []);
  }

  /// `Creating PDF...`
  String get creatingPdf {
    return Intl.message(
      'Creating PDF...',
      name: 'creatingPdf',
      desc: '',
      args: [],
    );
  }

  /// `View portfolio as others see it`
  String get viewAsOthers {
    return Intl.message(
      'View portfolio as others see it',
      name: 'viewAsOthers',
      desc: '',
      args: [],
    );
  }

  /// `Share portfolio on social media`
  String get shareOnSocial {
    return Intl.message(
      'Share portfolio on social media',
      name: 'shareOnSocial',
      desc: '',
      args: [],
    );
  }

  /// `Copy portfolio link`
  String get copyPortfolioLink {
    return Intl.message(
      'Copy portfolio link',
      name: 'copyPortfolioLink',
      desc: '',
      args: [],
    );
  }

  /// `Download portfolio as PDF`
  String get downloadPortfolioPdf {
    return Intl.message(
      'Download portfolio as PDF',
      name: 'downloadPortfolioPdf',
      desc: '',
      args: [],
    );
  }

  /// `Add item`
  String get addItem {
    return Intl.message('Add item', name: 'addItem', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'uk'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
