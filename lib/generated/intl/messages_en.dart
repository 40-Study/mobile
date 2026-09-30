// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m9(id) => "Account ID: ${id}";

  static String m10(earned, total) => "${earned} / ${total} badges earned";

  static String m11(blockNumber) => "Block ${blockNumber}";

  static String m12(provider) => "Cannot link with ${provider}";

  static String m13(count) => "${count} certificates earned";

  static String m14(role) => "Continue with ${role}";

  static String m0(days) => "In ${days} days";

  static String m15(count) => "${count} days learned";

  static String m1(days) => "${days} days ago";

  static String m2(number) => "Flight #${number}";

  static String m3(id) => "Sample Item ${id}";

  static String m16(date) => "Joined ${date}";

  static String m4(date) => "Launched: ${date}";

  static String m5(launchedAt) => "Launched at: ${launchedAt}";

  static String m17(provider) =>
      "Linking ${provider} is only available in production";

  static String m18(provider) => "Link with ${provider}";

  static String m6(mission) => "Mission: ${mission}";

  static String m19(count) => "${count} missions";

  static String m20(query) => "No cores found for \"${query}\"";

  static String m21(email) => "Enter the OTP sent to ${email}";

  static String m22(seconds) => "Resend in ${seconds}s";

  static String m23(count) => "${count} reuses";

  static String m7(rocketName, rocketType) =>
      "Rocket: ${rocketName} (${rocketType})";

  static String m8(percentage) => "${percentage}% success";

  static String m24(provider) => "Unlink ${provider}";

  static String m25(provider) =>
      "You will not be able to log in with ${provider} after unlinking. Are you sure?";

  static String m26(provider) => "Unlinked ${provider}";

  static String m27(version) => "Version ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutSettingsItem": MessageLookupByLibrary.simpleMessage("About"),
    "aboutSettingsItemDescription": MessageLookupByLibrary.simpleMessage(
      "Version, links, feedback",
    ),
    "aboutYourself": MessageLookupByLibrary.simpleMessage("About yourself"),
    "aboutYourselfHint": MessageLookupByLibrary.simpleMessage(
      "Write a few lines about you...",
    ),
    "accountId": m9,
    "accountInfo": MessageLookupByLibrary.simpleMessage("Account Information"),
    "achievement": MessageLookupByLibrary.simpleMessage("Achievement"),
    "achievementTitle": MessageLookupByLibrary.simpleMessage("Achievement"),
    "achievements": MessageLookupByLibrary.simpleMessage("Achievements"),
    "activeStatus": MessageLookupByLibrary.simpleMessage("Active"),
    "activityHistory": MessageLookupByLibrary.simpleMessage("Activity history"),
    "activityHistoryHint": MessageLookupByLibrary.simpleMessage(
      "View all account-related actions",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addEducation": MessageLookupByLibrary.simpleMessage("Add education"),
    "addExperience": MessageLookupByLibrary.simpleMessage("Add experience"),
    "addItem": MessageLookupByLibrary.simpleMessage("Add item"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add profile"),
    "addProject": MessageLookupByLibrary.simpleMessage("Add project"),
    "addSkill": MessageLookupByLibrary.simpleMessage("Add skill"),
    "addToLinkedIn": MessageLookupByLibrary.simpleMessage("Add to\nLinkedIn"),
    "advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "agreeToTerms": MessageLookupByLibrary.simpleMessage("I agree to the"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allBadges": MessageLookupByLibrary.simpleMessage("All Badges"),
    "allObjectivesCompleted": MessageLookupByLibrary.simpleMessage(
      "All objectives completed",
    ),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "and": MessageLookupByLibrary.simpleMessage("and"),
    "apoapsis": MessageLookupByLibrary.simpleMessage("Apoapsis"),
    "appTitle": MessageLookupByLibrary.simpleMessage("40Study"),
    "appearanceSettingsItem": MessageLookupByLibrary.simpleMessage(
      "Appearance",
    ),
    "appearanceSettingsItemDescription": MessageLookupByLibrary.simpleMessage(
      "Dark theme dynamic color, languages",
    ),
    "appearanceTitle": MessageLookupByLibrary.simpleMessage("Appearance"),
    "apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "article": MessageLookupByLibrary.simpleMessage("Article"),
    "badges": MessageLookupByLibrary.simpleMessage("Badges"),
    "badgesEarned": m10,
    "basic": MessageLookupByLibrary.simpleMessage("Basic"),
    "bioHint": MessageLookupByLibrary.simpleMessage(
      "Tell us about yourself...",
    ),
    "bioLabel": MessageLookupByLibrary.simpleMessage("Bio"),
    "blockLabel": m11,
    "borderRadiusButtonTitle": MessageLookupByLibrary.simpleMessage(
      "BorderRadius",
    ),
    "borderSideButtonTitle": MessageLookupByLibrary.simpleMessage("BorderSide"),
    "business": MessageLookupByLibrary.simpleMessage("Business"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotLink": m12,
    "cannotOpenBrowser": MessageLookupByLibrary.simpleMessage(
      "Cannot open browser",
    ),
    "category": MessageLookupByLibrary.simpleMessage("Category"),
    "categoryLabel": MessageLookupByLibrary.simpleMessage("Category"),
    "certificate": MessageLookupByLibrary.simpleMessage("Certificate"),
    "certificateConfirm": MessageLookupByLibrary.simpleMessage(
      "This certificate confirms you have completed the course and mastered the fundamentals.",
    ),
    "certificateDetail": MessageLookupByLibrary.simpleMessage(
      "Certificate Detail",
    ),
    "certificatesEarned": m13,
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "changePasswordButton": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "changePasswordHint": MessageLookupByLibrary.simpleMessage(
      "Use a strong password you don\'t use elsewhere",
    ),
    "changePasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "changePhoto": MessageLookupByLibrary.simpleMessage("Change photo"),
    "children": MessageLookupByLibrary.simpleMessage("Children"),
    "chooseProfileSubtitle": MessageLookupByLibrary.simpleMessage(
      "You have multiple profiles. Choose one to continue.",
    ),
    "chooseProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Choose profile",
    ),
    "classes": MessageLookupByLibrary.simpleMessage("Classes"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "company": MessageLookupByLibrary.simpleMessage("Company"),
    "companyHint": MessageLookupByLibrary.simpleMessage(
      "E.g: Google, Vela Studio...",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "completedLessons": MessageLookupByLibrary.simpleMessage(
      "Completed Lessons",
    ),
    "completionDate": MessageLookupByLibrary.simpleMessage("Completion Date"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmPasswordHint": MessageLookupByLibrary.simpleMessage(
      "Re-enter password",
    ),
    "confirmPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "contact": MessageLookupByLibrary.simpleMessage("Contact"),
    "continueLearning": MessageLookupByLibrary.simpleMessage(
      "Continue Learning",
    ),
    "continueWithRole": m14,
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
    "copyPortfolioLink": MessageLookupByLibrary.simpleMessage(
      "Copy portfolio link",
    ),
    "coreSerial": MessageLookupByLibrary.simpleMessage("Core Serial"),
    "core_filter_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search cores or missions...",
    ),
    "core_filter_status_active": MessageLookupByLibrary.simpleMessage("Active"),
    "core_filter_status_all": MessageLookupByLibrary.simpleMessage("All"),
    "core_filter_status_inactive": MessageLookupByLibrary.simpleMessage(
      "Inactive",
    ),
    "core_filter_status_lost": MessageLookupByLibrary.simpleMessage("Lost"),
    "core_filter_status_unknown": MessageLookupByLibrary.simpleMessage(
      "Unknown",
    ),
    "core_status_active": MessageLookupByLibrary.simpleMessage("active"),
    "core_status_inactive": MessageLookupByLibrary.simpleMessage("inactive"),
    "core_status_lost": MessageLookupByLibrary.simpleMessage("lost"),
    "core_status_unknown": MessageLookupByLibrary.simpleMessage("unknown"),
    "coresLabel": MessageLookupByLibrary.simpleMessage("Cores"),
    "course": MessageLookupByLibrary.simpleMessage("Course"),
    "courseInfo": MessageLookupByLibrary.simpleMessage("Course Information"),
    "courses": MessageLookupByLibrary.simpleMessage("Courses"),
    "creatingPdf": MessageLookupByLibrary.simpleMessage("Creating PDF..."),
    "currentPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "Current Password",
    ),
    "currentSpeed": MessageLookupByLibrary.simpleMessage("Current Speed"),
    "customers": MessageLookupByLibrary.simpleMessage("Customers"),
    "customizeNotifications": MessageLookupByLibrary.simpleMessage(
      "Customize your notifications",
    ),
    "customizePortfolio": MessageLookupByLibrary.simpleMessage(
      "Customize portfolio",
    ),
    "darkGoldThemeTitle": MessageLookupByLibrary.simpleMessage("Dark Gold"),
    "darkMintThemeTitle": MessageLookupByLibrary.simpleMessage("Dark Mint"),
    "darkThemeFollowSystemSettingsItemTitle":
        MessageLookupByLibrary.simpleMessage("System default"),
    "darkThemeOffSettingsItemTitle": MessageLookupByLibrary.simpleMessage(
      "Light",
    ),
    "darkThemeOnSettingsItemTitle": MessageLookupByLibrary.simpleMessage(
      "Dark",
    ),
    "darkThemeSettingsItemTitle": MessageLookupByLibrary.simpleMessage(
      "Theme mode",
    ),
    "darkThemeTitle": MessageLookupByLibrary.simpleMessage("Dark Theme"),
    "dateOfBirthLabel": MessageLookupByLibrary.simpleMessage("Date of Birth"),
    "daysFromTodayTitle": m0,
    "daysLearned": m15,
    "daysSinceTodayTitle": m1,
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete Account"),
    "design": MessageLookupByLibrary.simpleMessage("Design"),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "devices": MessageLookupByLibrary.simpleMessage("Logged In Devices"),
    "diameterLabel": MessageLookupByLibrary.simpleMessage("Diameter"),
    "disabledButtonTitle": MessageLookupByLibrary.simpleMessage("Disabled"),
    "disabledRoundedButtonTitle": MessageLookupByLibrary.simpleMessage(
      "Disabled Rounded",
    ),
    "disabledWithIconButtonTitle": MessageLookupByLibrary.simpleMessage(
      "Disabled With Icon",
    ),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "dontHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadPdf": MessageLookupByLibrary.simpleMessage("Download PDF"),
    "downloadPortfolioPdf": MessageLookupByLibrary.simpleMessage(
      "Download portfolio as PDF",
    ),
    "dragToReorder": MessageLookupByLibrary.simpleMessage(
      "Drag to reorder sections",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Duration"),
    "dynamicColorSettingsItemDescription": MessageLookupByLibrary.simpleMessage(
      "Adapt app colors to your wallpaper",
    ),
    "dynamicColorSettingsItemTitle": MessageLookupByLibrary.simpleMessage(
      "Use dynamic colors",
    ),
    "earned": MessageLookupByLibrary.simpleMessage("Earned"),
    "earthDistance": MessageLookupByLibrary.simpleMessage("Earth Distance"),
    "eccentricity": MessageLookupByLibrary.simpleMessage("Eccentricity"),
    "editCover": MessageLookupByLibrary.simpleMessage("Edit Cover"),
    "editIntroduction": MessageLookupByLibrary.simpleMessage(
      "Edit introduction",
    ),
    "editPortfolio": MessageLookupByLibrary.simpleMessage("Edit"),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "education": MessageLookupByLibrary.simpleMessage("Education"),
    "emailHint": MessageLookupByLibrary.simpleMessage("Enter your email"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "emailsTitle": MessageLookupByLibrary.simpleMessage("Emails"),
    "emptyList": MessageLookupByLibrary.simpleMessage("Empty list"),
    "enabledButtonTitle": MessageLookupByLibrary.simpleMessage("Enabled"),
    "engineDetails": MessageLookupByLibrary.simpleMessage("Engine Details"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorInvalidEmail": MessageLookupByLibrary.simpleMessage(
      "Invalid email address",
    ),
    "errorInvalidOtp": MessageLookupByLibrary.simpleMessage("Invalid OTP code"),
    "errorLoadingCores": MessageLookupByLibrary.simpleMessage(
      "Error loading cores",
    ),
    "errorNetworkError": MessageLookupByLibrary.simpleMessage(
      "Network connection error",
    ),
    "errorPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "errorPasswordTooShort": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters",
    ),
    "errorRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "errorUnknown": MessageLookupByLibrary.simpleMessage("An error occurred"),
    "everyoneCanView": MessageLookupByLibrary.simpleMessage(
      "Everyone can view",
    ),
    "experience": MessageLookupByLibrary.simpleMessage("Experience"),
    "experimentalThemeTitle": MessageLookupByLibrary.simpleMessage(
      "Experimental Theme",
    ),
    "faqAndSupport": MessageLookupByLibrary.simpleMessage("FAQ and support"),
    "featuredCourses": MessageLookupByLibrary.simpleMessage("Featured Courses"),
    "featuredProjects": MessageLookupByLibrary.simpleMessage(
      "Featured Projects",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "firstLaunch": MessageLookupByLibrary.simpleMessage("First Launch"),
    "firstStage": MessageLookupByLibrary.simpleMessage("🚀 First Stage"),
    "flight": MessageLookupByLibrary.simpleMessage("Flight"),
    "flightNumber": m2,
    "followers": MessageLookupByLibrary.simpleMessage("Followers"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot password?"),
    "forgotPasswordSubtitle": MessageLookupByLibrary.simpleMessage(
      "Enter email to receive recovery code",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Forgot Password",
    ),
    "fullName": MessageLookupByLibrary.simpleMessage("Full name"),
    "fullNameHint": MessageLookupByLibrary.simpleMessage(
      "Enter your full name",
    ),
    "fullNameLabel": MessageLookupByLibrary.simpleMessage("Full Name"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "goodAfternoon": MessageLookupByLibrary.simpleMessage("Good afternoon"),
    "goodEvening": MessageLookupByLibrary.simpleMessage("Good evening"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Good morning"),
    "gridFins": MessageLookupByLibrary.simpleMessage("Grid Fins"),
    "habit": MessageLookupByLibrary.simpleMessage("Habit"),
    "heightLabel": MessageLookupByLibrary.simpleMessage("Height"),
    "helpCenter": MessageLookupByLibrary.simpleMessage("Help center"),
    "iconAndPaddingButtonTitle": MessageLookupByLibrary.simpleMessage(
      "With Icon Padding",
    ),
    "iconButtonTitle": MessageLookupByLibrary.simpleMessage("With Icon"),
    "id": MessageLookupByLibrary.simpleMessage("ID"),
    "inProgress": MessageLookupByLibrary.simpleMessage("In Progress"),
    "inclination": MessageLookupByLibrary.simpleMessage("Inclination"),
    "instructor": MessageLookupByLibrary.simpleMessage("Instructor"),
    "interests": MessageLookupByLibrary.simpleMessage("Interests"),
    "introduction": MessageLookupByLibrary.simpleMessage("Introduction"),
    "itemDetailsTitle": MessageLookupByLibrary.simpleMessage("Item Details"),
    "itemTitle": m3,
    "itemsTitle": MessageLookupByLibrary.simpleMessage("Sample Items"),
    "jobDescription": MessageLookupByLibrary.simpleMessage("Job description"),
    "jobTitle": MessageLookupByLibrary.simpleMessage("Job title"),
    "jobTitleHint": MessageLookupByLibrary.simpleMessage("E.g: UI/UX Designer"),
    "joinedDate": MessageLookupByLibrary.simpleMessage("Joined Date"),
    "joinedOn": m16,
    "landing": MessageLookupByLibrary.simpleMessage("Landing"),
    "landingLegs": MessageLookupByLibrary.simpleMessage("Landing Legs"),
    "landingSuccess": MessageLookupByLibrary.simpleMessage("Landing Success"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageTitle": MessageLookupByLibrary.simpleMessage("Language"),
    "last7Days": MessageLookupByLibrary.simpleMessage("Last 7 days"),
    "launch": MessageLookupByLibrary.simpleMessage("Launch"),
    "launchInformation": MessageLookupByLibrary.simpleMessage(
      "Launch Information",
    ),
    "launchMass": MessageLookupByLibrary.simpleMessage("Launch Mass"),
    "launchSite": MessageLookupByLibrary.simpleMessage("Launch Site"),
    "launchVehicle": MessageLookupByLibrary.simpleMessage("Launch Vehicle"),
    "launched": m4,
    "launchedAt": m5,
    "launchesTitle": MessageLookupByLibrary.simpleMessage("Launches"),
    "learnMore": MessageLookupByLibrary.simpleMessage("Learn More"),
    "learning": MessageLookupByLibrary.simpleMessage("Learning"),
    "learningActivity": MessageLookupByLibrary.simpleMessage(
      "Learning Activity",
    ),
    "learningTrend": MessageLookupByLibrary.simpleMessage("Learning Trend"),
    "less": MessageLookupByLibrary.simpleMessage("Less"),
    "lessons": MessageLookupByLibrary.simpleMessage("lessons"),
    "level": MessageLookupByLibrary.simpleMessage("Level"),
    "lightGoldThemeTitle": MessageLookupByLibrary.simpleMessage("Light Gold"),
    "lightMintThemeTitle": MessageLookupByLibrary.simpleMessage("Light Mint"),
    "lightThemeTitle": MessageLookupByLibrary.simpleMessage("Light Theme"),
    "linkCopied": MessageLookupByLibrary.simpleMessage("Link copied"),
    "linkCopiedToShare": MessageLookupByLibrary.simpleMessage(
      "Link copied for sharing",
    ),
    "linkOnlyPortfolio": MessageLookupByLibrary.simpleMessage(
      "People with link",
    ),
    "linkOnlyProduction": m17,
    "linkWith": m18,
    "linkedAccounts": MessageLookupByLibrary.simpleMessage("Linked Accounts"),
    "linksResources": MessageLookupByLibrary.simpleMessage("Links & Resources"),
    "locationHint": MessageLookupByLibrary.simpleMessage("E.g: Hanoi, Vietnam"),
    "locationLabel": MessageLookupByLibrary.simpleMessage("Location"),
    "loggedOutAllDevices": MessageLookupByLibrary.simpleMessage(
      "Logged out all devices",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
    "loginSection": MessageLookupByLibrary.simpleMessage("Login"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage("Welcome back"),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Login"),
    "loginWithThisProfile": MessageLookupByLibrary.simpleMessage(
      "Login with this profile",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutAll": MessageLookupByLibrary.simpleMessage("Logout All"),
    "logoutAllDevices": MessageLookupByLibrary.simpleMessage(
      "Logout All Devices",
    ),
    "logoutAllDevicesContent": MessageLookupByLibrary.simpleMessage(
      "You will be logged out of all devices, including this one. You will need to log in again.",
    ),
    "logoutAllDevicesTitle": MessageLookupByLibrary.simpleMessage(
      "Logout all devices",
    ),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout?",
    ),
    "longitude": MessageLookupByLibrary.simpleMessage("Longitude"),
    "manageLayout": MessageLookupByLibrary.simpleMessage("Manage layout"),
    "managePlanBilling": MessageLookupByLibrary.simpleMessage(
      "Manage your plan and billing",
    ),
    "managePrivacySettings": MessageLookupByLibrary.simpleMessage(
      "Manage your privacy settings",
    ),
    "manufacturer": MessageLookupByLibrary.simpleMessage("Manufacturer"),
    "marsDistance": MessageLookupByLibrary.simpleMessage("Mars Distance"),
    "mass": MessageLookupByLibrary.simpleMessage("Mass"),
    "massLabel": MessageLookupByLibrary.simpleMessage("Mass"),
    "millionKm": MessageLookupByLibrary.simpleMessage("million km"),
    "minutes": MessageLookupByLibrary.simpleMessage("min"),
    "missionDetails": MessageLookupByLibrary.simpleMessage("Mission Details"),
    "missionFailed": MessageLookupByLibrary.simpleMessage("Mission Failed"),
    "missionOverview": MessageLookupByLibrary.simpleMessage("Mission Overview"),
    "missionSuccess": MessageLookupByLibrary.simpleMessage("Mission Success"),
    "missionSuccessful": MessageLookupByLibrary.simpleMessage(
      "Mission Successful",
    ),
    "missionTimeline": MessageLookupByLibrary.simpleMessage("Mission Timeline"),
    "missionTitle": m6,
    "missions": m19,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "myPortfolio": MessageLookupByLibrary.simpleMessage("My Portfolio"),
    "na": MessageLookupByLibrary.simpleMessage("N/A"),
    "nationality": MessageLookupByLibrary.simpleMessage("Nationality"),
    "newBadge": MessageLookupByLibrary.simpleMessage("NEW"),
    "newPasswordHint": MessageLookupByLibrary.simpleMessage(
      "Enter new password",
    ),
    "newPasswordLabel": MessageLookupByLibrary.simpleMessage("New Password"),
    "newsScreen": MessageLookupByLibrary.simpleMessage("News"),
    "noCoresFound": m20,
    "noDetails": MessageLookupByLibrary.simpleMessage("No details available"),
    "noDevices": MessageLookupByLibrary.simpleMessage("No devices found"),
    "notAvailable": MessageLookupByLibrary.simpleMessage("N/A"),
    "notEarned": MessageLookupByLibrary.simpleMessage("Not Earned"),
    "notUpdated": MessageLookupByLibrary.simpleMessage("Not updated"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "numberLabel": MessageLookupByLibrary.simpleMessage("Number"),
    "objectivesCompleted": MessageLookupByLibrary.simpleMessage(
      "Objectives Completed",
    ),
    "objectivesNotMet": MessageLookupByLibrary.simpleMessage(
      "Mission objectives not met",
    ),
    "onlyWithLink": MessageLookupByLibrary.simpleMessage(
      "Only people with link can view",
    ),
    "onlyYouCanView": MessageLookupByLibrary.simpleMessage("Only you can view"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "orContinueWith": MessageLookupByLibrary.simpleMessage("Or continue with"),
    "orbit": MessageLookupByLibrary.simpleMessage("Orbit"),
    "orbitalParameters": MessageLookupByLibrary.simpleMessage(
      "Orbital Parameters",
    ),
    "orbitalPeriod": MessageLookupByLibrary.simpleMessage("Orbital Period"),
    "organizationProfile": MessageLookupByLibrary.simpleMessage(
      "Organization profile",
    ),
    "otpSubtitle": m21,
    "otpTitle": MessageLookupByLibrary.simpleMessage("OTP Verification"),
    "overallProgress": MessageLookupByLibrary.simpleMessage("Overall Progress"),
    "overview": MessageLookupByLibrary.simpleMessage("Overview"),
    "parentOverview": MessageLookupByLibrary.simpleMessage("Parent Overview"),
    "passwordAndSecurity": MessageLookupByLibrary.simpleMessage(
      "Password & Security",
    ),
    "passwordChangedSuccess": MessageLookupByLibrary.simpleMessage(
      "Password changed successfully",
    ),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Enter password"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordSecurityHint": MessageLookupByLibrary.simpleMessage(
      "Password, 2FA, login devices",
    ),
    "payload": MessageLookupByLibrary.simpleMessage("Payload"),
    "payloadCapacity": MessageLookupByLibrary.simpleMessage("Payload Capacity"),
    "payloadTitle": MessageLookupByLibrary.simpleMessage("Payload"),
    "periapsis": MessageLookupByLibrary.simpleMessage("Periapsis"),
    "phoneLabel": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "portfolio": MessageLookupByLibrary.simpleMessage("Portfolio"),
    "position": MessageLookupByLibrary.simpleMessage("Position"),
    "positionHint": MessageLookupByLibrary.simpleMessage("E.g: UI/UX Designer"),
    "premium": MessageLookupByLibrary.simpleMessage("Premium"),
    "present": MessageLookupByLibrary.simpleMessage("Present"),
    "pressKit": MessageLookupByLibrary.simpleMessage("Press Kit"),
    "previewPortfolio": MessageLookupByLibrary.simpleMessage("Preview"),
    "printCertificate": MessageLookupByLibrary.simpleMessage("Print"),
    "privacy": MessageLookupByLibrary.simpleMessage("Privacy"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacySettings": MessageLookupByLibrary.simpleMessage("Privacy"),
    "privatePortfolio": MessageLookupByLibrary.simpleMessage("Only me"),
    "proficiencyLevel": MessageLookupByLibrary.simpleMessage(
      "Proficiency level",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "programming": MessageLookupByLibrary.simpleMessage("Programming"),
    "projectName": MessageLookupByLibrary.simpleMessage("Project name"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage("E.g: EduFlow"),
    "projectsCompleted": MessageLookupByLibrary.simpleMessage(
      "Projects completed",
    ),
    "propellant1Label": MessageLookupByLibrary.simpleMessage("Propellant 1"),
    "propellant2Label": MessageLookupByLibrary.simpleMessage("Propellant 2"),
    "publicPortfolio": MessageLookupByLibrary.simpleMessage("Public"),
    "rating": MessageLookupByLibrary.simpleMessage("Rating"),
    "recentBadges": MessageLookupByLibrary.simpleMessage("Recent Badges"),
    "recoveryShips": MessageLookupByLibrary.simpleMessage("Recovery Ships"),
    "reddit": MessageLookupByLibrary.simpleMessage("Reddit"),
    "register": MessageLookupByLibrary.simpleMessage("Register"),
    "registerButton": MessageLookupByLibrary.simpleMessage("Register"),
    "registerSubtitle": MessageLookupByLibrary.simpleMessage(
      "Start your learning journey",
    ),
    "registerTitle": MessageLookupByLibrary.simpleMessage("Create Account"),
    "reload": MessageLookupByLibrary.simpleMessage("Reload"),
    "reportIssue": MessageLookupByLibrary.simpleMessage("Report Issue"),
    "resendOtp": MessageLookupByLibrary.simpleMessage("Resend code"),
    "resendOtpIn": m22,
    "resetPasswordButton": MessageLookupByLibrary.simpleMessage(
      "Reset Password",
    ),
    "resetPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Reset Password",
    ),
    "retiredStatus": MessageLookupByLibrary.simpleMessage("Retired"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "reused": MessageLookupByLibrary.simpleMessage("Reused"),
    "reuses": m23,
    "roadsterDescription": MessageLookupByLibrary.simpleMessage(
      "Elon Musk\'s Tesla Roadster",
    ),
    "roadsterTitle": MessageLookupByLibrary.simpleMessage("Roadster"),
    "rocket": m7,
    "rocketBlock": MessageLookupByLibrary.simpleMessage("Block"),
    "rocketDetails": MessageLookupByLibrary.simpleMessage("Rocket Details"),
    "rocketName": MessageLookupByLibrary.simpleMessage("Rocket Name"),
    "rocketTitle": MessageLookupByLibrary.simpleMessage("Rocket"),
    "rocketType": MessageLookupByLibrary.simpleMessage("Type"),
    "rocketsTab": MessageLookupByLibrary.simpleMessage("Rockets"),
    "rocketsTitle": MessageLookupByLibrary.simpleMessage("Rockets"),
    "roleOrganization": MessageLookupByLibrary.simpleMessage("Organization"),
    "roleParent": MessageLookupByLibrary.simpleMessage("Parent"),
    "roleStudent": MessageLookupByLibrary.simpleMessage("Student"),
    "roleTeacher": MessageLookupByLibrary.simpleMessage("Teacher"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "saved": MessageLookupByLibrary.simpleMessage("Saved"),
    "saving": MessageLookupByLibrary.simpleMessage("Saving..."),
    "securityEmails": MessageLookupByLibrary.simpleMessage(
      "Security notification emails",
    ),
    "securityEmailsHint": MessageLookupByLibrary.simpleMessage(
      "View official emails from us",
    ),
    "securityTitle": MessageLookupByLibrary.simpleMessage("Security"),
    "selectRoleSubtitle": MessageLookupByLibrary.simpleMessage(
      "Swipe to explore",
    ),
    "selectRoleTitle": MessageLookupByLibrary.simpleMessage("Select Role"),
    "semiMajorAxis": MessageLookupByLibrary.simpleMessage("Semi-major axis"),
    "sendResetCode": MessageLookupByLibrary.simpleMessage("Send Recovery Code"),
    "serverNotConfigured": MessageLookupByLibrary.simpleMessage(
      "Server not configured",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "shareOnSocial": MessageLookupByLibrary.simpleMessage(
      "Share portfolio on social media",
    ),
    "shortDescription": MessageLookupByLibrary.simpleMessage(
      "Short description",
    ),
    "shortDescriptionHint": MessageLookupByLibrary.simpleMessage(
      "E.g: Learning management system",
    ),
    "showQrCode": MessageLookupByLibrary.simpleMessage("Show QR Code"),
    "signOutHint": MessageLookupByLibrary.simpleMessage(
      "Sign out from your current account",
    ),
    "siteIdLabel": MessageLookupByLibrary.simpleMessage("Site ID:"),
    "skillName": MessageLookupByLibrary.simpleMessage("Skill name"),
    "skillNameHint": MessageLookupByLibrary.simpleMessage(
      "E.g: UI Design, Figma, React...",
    ),
    "skills": MessageLookupByLibrary.simpleMessage("Skills"),
    "skillsEarned": MessageLookupByLibrary.simpleMessage("Skills Earned"),
    "spaceXCoresTitle": MessageLookupByLibrary.simpleMessage(
      "SpaceX Falcon Cores",
    ),
    "specifications": MessageLookupByLibrary.simpleMessage("Specifications"),
    "stagesLabel": MessageLookupByLibrary.simpleMessage("Stages"),
    "staticFireTest": MessageLookupByLibrary.simpleMessage("Static Fire Test"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "streak": MessageLookupByLibrary.simpleMessage("Streak"),
    "student": MessageLookupByLibrary.simpleMessage("Student"),
    "students": MessageLookupByLibrary.simpleMessage("Students"),
    "studyHours": MessageLookupByLibrary.simpleMessage("Study Hours"),
    "studying": MessageLookupByLibrary.simpleMessage("Studying"),
    "subscription": MessageLookupByLibrary.simpleMessage("Subscription"),
    "successRate": m8,
    "swipeToChangeProfile": MessageLookupByLibrary.simpleMessage(
      "Swipe to change profile",
    ),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Switch profile"),
    "switchRole": MessageLookupByLibrary.simpleMessage("Switch Role"),
    "systemProfile": MessageLookupByLibrary.simpleMessage("System profile"),
    "systemThemeTitle": MessageLookupByLibrary.simpleMessage("System Theme"),
    "tabAchievements": MessageLookupByLibrary.simpleMessage("Achievements"),
    "tabChildren": MessageLookupByLibrary.simpleMessage("Children"),
    "tabHome": MessageLookupByLibrary.simpleMessage("Home"),
    "tabNotifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "tabOverview": MessageLookupByLibrary.simpleMessage("Overview"),
    "tabSettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "tapToSelect": MessageLookupByLibrary.simpleMessage("Tap to select"),
    "termsOfService": MessageLookupByLibrary.simpleMessage("Terms of Service"),
    "themeTitle": MessageLookupByLibrary.simpleMessage("Theme"),
    "thisDevice": MessageLookupByLibrary.simpleMessage("This device"),
    "thisMonth": MessageLookupByLibrary.simpleMessage("this month"),
    "thrustSeaLevelLabel": MessageLookupByLibrary.simpleMessage(
      "Thrust (Sea Level)",
    ),
    "toggleVisibility": MessageLookupByLibrary.simpleMessage(
      "Toggle section visibility",
    ),
    "tons": MessageLookupByLibrary.simpleMessage("tons"),
    "totalEarnings": MessageLookupByLibrary.simpleMessage("Total Earnings"),
    "trackLive": MessageLookupByLibrary.simpleMessage("Track Live"),
    "transparentButtonTitle": MessageLookupByLibrary.simpleMessage(
      "Transparent",
    ),
    "tryAgainButton": MessageLookupByLibrary.simpleMessage("Try Again"),
    "type": MessageLookupByLibrary.simpleMessage("Type"),
    "typeLabel": MessageLookupByLibrary.simpleMessage("Type"),
    "unitDays": MessageLookupByLibrary.simpleMessage("days"),
    "unitKph": MessageLookupByLibrary.simpleMessage("km/h"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownDevice": MessageLookupByLibrary.simpleMessage("Unknown device"),
    "unlink": MessageLookupByLibrary.simpleMessage("Unlink"),
    "unlinkAccount": m24,
    "unlinkAccountContent": m25,
    "unlinkedAccount": m26,
    "updatePersonalDetails": MessageLookupByLibrary.simpleMessage(
      "Update your personal details",
    ),
    "usernameHint": MessageLookupByLibrary.simpleMessage("Enter username"),
    "usernameLabel": MessageLookupByLibrary.simpleMessage("Username"),
    "verified": MessageLookupByLibrary.simpleMessage("Verified"),
    "verifyButton": MessageLookupByLibrary.simpleMessage("Verify"),
    "version": m27,
    "versionLabel": MessageLookupByLibrary.simpleMessage("Version"),
    "viewAll": MessageLookupByLibrary.simpleMessage("View All"),
    "viewAsOthers": MessageLookupByLibrary.simpleMessage(
      "View portfolio as others see it",
    ),
    "viewCertificate": MessageLookupByLibrary.simpleMessage("View Certificate"),
    "viewPortfolio": MessageLookupByLibrary.simpleMessage("View Portfolio"),
    "watchVideo": MessageLookupByLibrary.simpleMessage("Watch Video"),
    "websiteHint": MessageLookupByLibrary.simpleMessage("E.g: yourname.design"),
    "websiteLabel": MessageLookupByLibrary.simpleMessage("Website"),
    "whereYouLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Where you\'re logged in",
    ),
    "wikipedia": MessageLookupByLibrary.simpleMessage("Wikipedia"),
    "xpPoints": MessageLookupByLibrary.simpleMessage("XP Points"),
    "yearsExperience": MessageLookupByLibrary.simpleMessage("Years experience"),
    "yourAccount": MessageLookupByLibrary.simpleMessage("Your account"),
    "yourCertificates": MessageLookupByLibrary.simpleMessage(
      "Your Certificates",
    ),
  };
}
