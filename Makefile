.PHONY: gen genAll rebuild check get localize runDev runQa runProd \
        release apk debug_apk lines force_upgrade integration_test

# Clean project, install dependencies & generate sources
rebuild:
	flutter clean
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs
	fluttergen -c pubspec.yaml

# Generate code with build_runner
gen:
	dart run build_runner build --delete-conflicting-outputs

# Generate code and localizations
genAll:
	dart run build_runner build --delete-conflicting-outputs
	flutter pub run intl_utils:generate
	fluttergen -c pubspec.yaml

# Generate localizations only
localize:
	flutter pub run intl_utils:generate

# Analyze the project
check:
	dart analyze . && flutter analyze
	# flutter pub run dart_code_metrics:metrics analyze lib

# Run with flavors — all use single main.dart + --dart-define=ENV
runDev:
	flutter run --flavor dev --dart-define=ENV=dev

runQa:
	flutter run --flavor dev --dart-define=ENV=qa

runProd:
	flutter run --flavor prod --release --dart-define=ENV=prod

# Build release APK
apk:
	flutter build apk --flavor dev --release --dart-define=ENV=prod

# Build debug APK
debug_apk:
	flutter build apk --flavor dev --debug --dart-define=ENV=dev

# Count lines of Dart code
lines:
	find . -name '*.dart' | xargs wc -l

# Force upgrade packages
force_upgrade:
	flutter update-packages --force-upgrade

# Run integration test
integration_test:
	flutter test integration_test --flavor dev

screenshot_test:
	flutter drive --driver=test_driver/integration_test.dart --target=screenshot_test/settings_screenshot_test.dart --flavor dev
