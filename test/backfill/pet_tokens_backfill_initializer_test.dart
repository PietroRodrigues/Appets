import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/backfill/pet_tokens_backfill_initializer.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/pet_service.dart';

// Os mocks do firebase_auth_mocks já declaram campos não-finais.
// ignore_for_file: must_be_immutable

/// Auth com stream de estado controlável, para disparar eventos de
/// login/logout sob demanda.
class _ControllableAuth extends MockFirebaseAuth {
  _ControllableAuth(MockUser user)
    : super(signedIn: true, mockUser: user);

  final StreamController<User?> _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  void emit(User? user) => _controller.add(user);

  Future<void> dispose() => _controller.close();
}

/// Documento de pet legado: tokens em inglês e sem `createdAt`.
Map<String, dynamic> _legacyPet() => {
  'ownerId': 'uid_1',
  'name': 'Rex',
  'images': <String>[],
  'species': 'dog',
  'gender': 'male',
  'ageUnit': 'years',
  'publicationType': 'adoption',
  'specifications': <String>['dog', 'male', 'adoption', 'young'],
  'searchTokens': <String>[],
};

void main() {
  test(
    'attach: migra no login, ignora uid repetido, reseta no logout e re-migra',
    () async {
      final db = FakeFirebaseFirestore();
      PetService.instance.debugDb = db;
      final auth = _ControllableAuth(MockUser(uid: 'uid_1', email: 'a@test.com'));
      AuthService.instance.debugAuth = auth;
      addTearDown(() {
        PetService.instance.debugDb = null;
        AuthService.instance.debugAuth = null;
        return auth.dispose();
      });

      Future<String?> species() async =>
          (await db.collection('pets').doc('p1').get()).get('species') as String?;

      Future<void> eventually(Future<bool> Function() check) async {
        for (var i = 0; i < 200; i++) {
          if (await check()) return;
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        fail('condição não satisfeita a tempo');
      }

      final initializer = PetTokensBackfillInitializer.instance;
      initializer.attach();

      await db.collection('pets').doc('p1').set(_legacyPet());

      // 1) Login dispara a migração dos pets do dono.
      auth.emit(auth.currentUser);
      await eventually(() async => await species() == 'cachorro');
      final migrated = await db.collection('pets').doc('p1').get();
      expect(migrated.get('createdAt'), isNotNull);

      // 2) Mesmo uid reemitido é ignorado: volta a legado e permanece legado.
      await db.collection('pets').doc('p1').set(_legacyPet());
      auth.emit(auth.currentUser);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(await species(), 'dog');

      // 3) Logout reseta o estado; novo login re-executa a migração.
      auth.emit(null);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      auth.emit(auth.currentUser);
      await eventually(() async => await species() == 'cachorro');

      // 4) Falha na migração é engolida (melhor esforço, sem derrubar).
      PetService.instance.debugDb = null;
      auth.emit(null);
      auth.emit(auth.currentUser);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    },
  );
}
