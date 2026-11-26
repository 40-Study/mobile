import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/features/auth/data/auth_storage.dart';

class _Secure extends Mock implements FlutterSecureStorage {}

void main() {
  group('SharedPreferencesAuthStorage', () {
    late _Secure secure;
    late Map<String, String> secureData;

    // Mock secure storage có state để đọc lại được giá trị đã ghi
    void stubSecure() {
      when(
        () => secure.write(key: any(named: 'key'), value: any(named: 'value')),
      ).thenAnswer((inv) async {
        secureData[inv.namedArguments[#key] as String] =
            inv.namedArguments[#value] as String;
      });
      when(() => secure.read(key: any(named: 'key'))).thenAnswer(
        (inv) async => secureData[inv.namedArguments[#key] as String],
      );
      when(() => secure.delete(key: any(named: 'key'))).thenAnswer((inv) async {
        secureData.remove(inv.namedArguments[#key] as String);
      });
      when(() => secure.deleteAll()).thenAnswer((_) async => secureData.clear());
    }

    Future<(SharedPreferencesAuthStorage, SharedPreferences)> create([
      Map<String, Object> prefsValues = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(prefsValues);
      final prefs = await SharedPreferences.getInstance();
      return (SharedPreferencesAuthStorage(prefs, secure: secure), prefs);
    }

    setUp(() {
      secure = _Secure();
      secureData = {};
      stubSecure();
    });

    test('should write tokens to secure storage only', () async {
      final (storage, prefs) = await create();

      await storage.saveTokens(accessToken: 'a', refreshToken: 'r');

      verify(() => secure.write(key: 'auth_access_token', value: 'a')).called(1);
      expect(prefs.containsKey('auth_access_token'), isFalse);
      expect(await storage.getAccessToken(), 'a');
    });

    test('should migrate legacy token from prefs', () async {
      final (storage, prefs) = await create({
        'auth_access_token': 'legacy',
        'auth_refresh_token': 'legacy-r',
      });

      expect(await storage.getAccessToken(), 'legacy');
      verify(
        () => secure.write(key: 'auth_access_token', value: 'legacy'),
      ).called(1);
      expect(prefs.containsKey('auth_access_token'), isFalse);
      expect(await storage.getRefreshToken(), 'legacy-r');
    });

    test('should not overwrite newer secure tokens with legacy prefs', () async {
      secureData
        ..['auth_access_token'] = 'new'
        ..['auth_refresh_token'] = 'new-r';
      final (storage, prefs) = await create({
        'auth_access_token': 'legacy',
        'auth_refresh_token': 'legacy-r',
      });

      expect(await storage.getAccessToken(), 'new');
      expect(await storage.getRefreshToken(), 'new-r');
      expect(prefs.containsKey('auth_refresh_token'), isFalse);
    });

    test('should rewrite pair when previous migration wrote only access', () async {
      // Lần migrate trước chỉ ghi được access token
      secureData['auth_access_token'] = 'legacy';
      final (storage, prefs) = await create({
        'auth_access_token': 'legacy',
        'auth_refresh_token': 'legacy-r',
      });

      expect(await storage.getRefreshToken(), 'legacy-r');
      expect(prefs.containsKey('auth_refresh_token'), isFalse);
    });

    test('should keep legacy prefs token when secure write fails', () async {
      when(
        () => secure.write(key: any(named: 'key'), value: any(named: 'value')),
      ).thenThrow(PlatformException(code: 'write'));
      final (storage, prefs) = await create({'auth_access_token': 'legacy'});

      expect(await storage.getAccessToken(), 'legacy');
      expect(prefs.getString('auth_access_token'), 'legacy');
    });

    test('should return null when secure read throws', () async {
      when(
        () => secure.read(key: any(named: 'key')),
      ).thenThrow(PlatformException(code: 'keystore'));
      final (storage, _) = await create();

      expect(await storage.getAccessToken(), isNull);
      verify(() => secure.deleteAll()).called(1);
    });

    test('clearAll should delete tokens from secure storage', () async {
      final (storage, _) = await create();

      await storage.clearAll();

      verify(() => secure.delete(key: 'auth_access_token')).called(1);
      verify(() => secure.delete(key: 'auth_refresh_token')).called(1);
    });

    test('hasToken should read secure storage', () async {
      final (storage, _) = await create();
      expect(await storage.hasToken(), isFalse);

      await storage.saveTokens(accessToken: 'a', refreshToken: 'r');

      expect(await storage.hasToken(), isTrue);
    });
  });
}
