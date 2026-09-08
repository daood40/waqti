import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqti/core/auth/secure_session_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists, reads and removes the session via secure storage', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final storage = SecureSessionStorage(storage: const FlutterSecureStorage());
    await storage.initialize();

    expect(await storage.hasAccessToken(), isFalse);
    expect(await storage.accessToken(), isNull);

    await storage.persistSession('{"access_token":"x"}');
    expect(await storage.hasAccessToken(), isTrue);
    expect(await storage.accessToken(), '{"access_token":"x"}');

    await storage.removePersistedSession();
    expect(await storage.hasAccessToken(), isFalse);
  });
}
