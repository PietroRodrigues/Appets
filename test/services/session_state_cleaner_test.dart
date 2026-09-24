import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/session_state_cleaner.dart';

void main() {
  late MockFirebaseAuth auth;
  final service = AuthService.instance;

  setUp(() {
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'user_a', email: 'a@test.com'),
    );
    service.debugAuth = auth;
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
  });

  tearDown(() {
    service.debugAuth = null;
    SessionStateCleaner.instance.detach();
    FavoritesService.instance.reset();
    MyPublicationsService.instance.reset();
  });

  group('SessionStateCleaner', () {
    test('zera favoritos e publicações quando a sessão é perdida sem logout'
        ' (token expirado/revogado)', () async {
      FavoritesService.instance.favoriteIds.value = {'pet_a'};
      MyPublicationsService.instance.myPetIds.value = {'pet_b'};

      SessionStateCleaner.instance.attach();

      await auth.signOut();

      expect(FavoritesService.instance.current, isEmpty);
      expect(MyPublicationsService.instance.current, isEmpty);
    });

    test('zera o estado quando o usuário atual muda de conta', () async {
      final other = MockUser(uid: 'user_b', email: 'b@test.com');

      FavoritesService.instance.favoriteIds.value = {'pet_a'};
      MyPublicationsService.instance.myPetIds.value = {'pet_b'};

      SessionStateCleaner.instance.attach();

      auth.mockUser = other;
      await auth.signInWithCredential(null);

      expect(FavoritesService.instance.current, isEmpty);
      expect(MyPublicationsService.instance.current, isEmpty);
    });

    test('mantém o estado enquanto a sessão não muda', () async {
      SessionStateCleaner.instance.attach();
      // Primeira emissão estabelece a sessão atual (igual ao cold start).
      await auth.signInWithCredential(null);

      FavoritesService.instance.favoriteIds.value = {'pet_a'};
      MyPublicationsService.instance.myPetIds.value = {'pet_b'};

      // Relogin do mesmo usuário: nada deve ser limpo.
      await auth.signInWithCredential(null);

      expect(FavoritesService.instance.current, {'pet_a'});
      expect(MyPublicationsService.instance.current, {'pet_b'});
    });
  });
}