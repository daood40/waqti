import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/core/auth/auth_gateway.dart';
import 'package:waqti/core/cloud_backup_service.dart';
import 'package:waqti/models/models.dart';
import 'package:waqti/state/app_state.dart';

/// بوابة مصادقة وهمية تحاكي Supabase في الاختبارات (لا شبكة).
class FakeAuth implements AuthGateway {
  AuthUser? user;
  final controller = StreamController<AuthEvent>.broadcast();
  bool deleted = false;

  @override
  bool get isAvailable => true;
  @override
  bool get supportsGoogle => false;
  @override
  bool get supportsApple => false;
  @override
  AuthUser? get currentUser => user;
  @override
  Stream<AuthEvent> get events => controller.stream;

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async => const SignUpResult(needsEmailConfirmation: true);

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (password != 'secret1') throw const AuthFailure('invalidCredentials');
    return user = AuthUser(id: 'u1', email: email, name: 'داود');
  }

  @override
  Future<AuthUser?> signInWithGoogle() async => null;
  @override
  Future<AuthUser?> signInWithApple() async => null;
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> updateName(String name) async {}
  @override
  Future<void> signOut() async => user = null;
  @override
  Future<void> deleteAccount() async {
    deleted = true;
    user = null;
  }
}

class FakeCloud implements CloudBackupGateway {
  CloudSnapshot? remote;
  int pushes = 0;
  bool available = true;

  @override
  bool get isAvailable => available;
  @override
  Future<CloudSnapshot?> fetch() async => remote;
  @override
  Future<DateTime> push(String payload, {required String appVersion}) async {
    pushes++;
    final now = DateTime.now().toUtc();
    remote = CloudSnapshot(payload: payload, updatedAt: now);
    return now;
  }
}

Future<AppState> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final state = await AppState.load();
  state.setOnboarded();
  return state;
}

void main() {
  group('decideSync (last write wins)', () {
    final t1 = DateTime.utc(2026, 9, 1);
    final t2 = DateTime.utc(2026, 9, 2);
    test('no remote + local data → push', () {
      expect(
        decideSync(
          remoteUpdatedAt: null,
          localChangedAt: t1,
          localHasData: true,
        ),
        SyncDecision.pushLocal,
      );
    });
    test('no remote + empty local → nothing', () {
      expect(
        decideSync(
          remoteUpdatedAt: null,
          localChangedAt: null,
          localHasData: false,
        ),
        SyncDecision.nothing,
      );
    });
    test('remote newer → pull', () {
      expect(
        decideSync(remoteUpdatedAt: t2, localChangedAt: t1, localHasData: true),
        SyncDecision.pullRemote,
      );
    });
    test('local newer → push', () {
      expect(
        decideSync(remoteUpdatedAt: t1, localChangedAt: t2, localHasData: true),
        SyncDecision.pushLocal,
      );
    });
    test('remote exists, local never changed → pull', () {
      expect(
        decideSync(
          remoteUpdatedAt: t1,
          localChangedAt: null,
          localHasData: false,
        ),
        SyncDecision.pullRemote,
      );
    });
  });

  group('UserProfile', () {
    test('account fields round-trip; guest has no account', () {
      const p = UserProfile(
        name: 'د',
        email: 'a@b.c',
        id: 'u1',
        provider: 'google',
      );
      final back = UserProfile.fromJson(p.toJson());
      expect(back.id, 'u1');
      expect(back.provider, 'google');
      expect(back.hasAccount, isTrue);
      expect(const UserProfile(name: 'زائر').hasAccount, isFalse);
    });
  });

  group('AppState with account', () {
    test('sign in pulls a newer cloud snapshot into local state', () async {
      final state = await _fresh();
      final auth = FakeAuth();
      final cloud = FakeCloud();
      final remoteState = await _fresh();
      remoteState.addTask(TaskItem(id: 'r1', name: 'من السحابة'));
      cloud.remote = CloudSnapshot(
        payload: remoteState.cloudPayload(),
        updatedAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
      );
      state.attachServices(authGateway: auth, cloudGateway: cloud);

      final u = await auth.signIn(email: 'a@b.c', password: 'secret1');
      await state.onSignedIn(u);

      expect(state.loggedIn, isTrue);
      expect(state.hasAccount, isTrue);
      expect(state.tasks.map((t) => t.name), contains('من السحابة'));
      expect(state.cloudStatus, CloudStatus.synced);
      expect(state.lastCloudSyncAt, isNotNull);
    });

    test('sign in with local data and no cloud → pushes local', () async {
      final state = await _fresh();
      state.addTask(TaskItem(id: 'l1', name: 'محلي'));
      final auth = FakeAuth();
      final cloud = FakeCloud();
      state.attachServices(authGateway: auth, cloudGateway: cloud);
      await state.onSignedIn(
        await auth.signIn(email: 'a@b.c', password: 'secret1'),
      );
      expect(cloud.pushes, 1);
      expect(cloud.remote!.payload, contains('محلي'));
    });

    test('wrong password surfaces a typed failure', () async {
      final auth = FakeAuth();
      expect(
        () => auth.signIn(email: 'a@b.c', password: 'nope'),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.code,
            'code',
            'invalidCredentials',
          ),
        ),
      );
    });

    test(
      'account sign-out wipes local data; guest sign-out keeps it',
      () async {
        final state = await _fresh();
        final auth = FakeAuth();
        final cloud = FakeCloud();
        state.attachServices(authGateway: auth, cloudGateway: cloud);
        await state.onSignedIn(
          await auth.signIn(email: 'a@b.c', password: 'secret1'),
        );
        state.addTask(TaskItem(id: 't', name: 'x'));
        await state.signOut();
        expect(state.loggedIn, isFalse);
        expect(state.tasks, isEmpty);
        expect(auth.user, isNull);

        final guest = await _fresh();
        guest.signInAsGuest('زائر');
        guest.addTask(TaskItem(id: 'g', name: 'y'));
        await guest.signOut();
        expect(guest.tasks, hasLength(1));
      },
    );

    test('delete account calls gateway and clears everything', () async {
      final state = await _fresh();
      final auth = FakeAuth();
      state.attachServices(authGateway: auth, cloudGateway: FakeCloud());
      await state.onSignedIn(
        await auth.signIn(email: 'a@b.c', password: 'secret1'),
      );
      await state.deleteAccount();
      expect(auth.deleted, isTrue);
      expect(state.hasAccount, isFalse);
      expect(state.loggedIn, isFalse);
    });

    test('password recovery event shows the reset flow then clears', () async {
      final state = await _fresh();
      final auth = FakeAuth();
      state.attachServices(authGateway: auth, cloudGateway: FakeCloud());
      auth.controller.add(AuthEvent.passwordRecovery);
      await Future<void>.delayed(Duration.zero);
      expect(state.passwordRecoveryPending, isTrue);
      await state.completePasswordRecovery('newpass1');
      expect(state.passwordRecoveryPending, isFalse);
    });

    test('debounced cloud push after a local change', () async {
      final state = await _fresh();
      final auth = FakeAuth();
      final cloud = FakeCloud();
      state.attachServices(authGateway: auth, cloudGateway: cloud);
      await state.onSignedIn(
        await auth.signIn(email: 'a@b.c', password: 'secret1'),
      );
      final before = cloud.pushes;
      state.addTask(TaskItem(id: 'n', name: 'جديد'));
      state.addTask(TaskItem(id: 'n2', name: 'جديد 2'));
      await Future<void>.delayed(const Duration(seconds: 4));
      expect(cloud.pushes, before + 1); // دمج التغييرين في رفع واحد
      expect(cloud.remote!.payload, contains('جديد 2'));
    });
  });
}
