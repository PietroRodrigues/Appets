import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/models/user_model.dart';

void main() {
  late FakeFirebaseFirestore db;
  final service = FirestoreService.instance;

  const user = UserModel(id: 'uid_1', name: 'Ana', email: 'ana@test.com');

  setUp(() {
    db = FakeFirebaseFirestore();
    service.debugDb = db;
  });

  group('FirestoreService', () {
    test('createUser persiste o documento em users', () async {
      await service.createUser(user);

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.exists, isTrue);
      expect(doc.get('name'), 'Ana');
      expect(doc.get('email'), 'ana@test.com');
    });

    test('getUser devolve null quando o usuário não existe', () async {
      expect(await service.getUser('inexistente'), isNull);
    });

    test('getUser devolve o usuário quando o documento existe', () async {
      await service.createUser(user);

      final result = await service.getUser('uid_1');

      expect(result, isNotNull);
      expect(result!.id, 'uid_1');
      expect(result.name, 'Ana');
      expect(result.email, 'ana@test.com');
    });

    test('createUser com merge preserva listas e telefone já gravados', () async {
      await db.collection('users').doc('uid_1').set({
        'name': 'Nome Antigo',
        'email': 'antigo@test.com',
        'phone': '(11) 99999-0000',
        'address': 'Rua A',
        'photoUrl': 'https://foto.example.com/a.png',
        'favoritePetIds': ['pet_a', 'pet_b'],
        'myPublishedPetIds': ['pet_b'],
      });

      // Login/cadastro rodando sobre um doc existente (identity apenas).
      await service.createUser(user);

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.get('name'), 'Ana');
      expect(doc.get('email'), 'ana@test.com');
      expect(doc.get('phone'), '(11) 99999-0000');
      expect(doc.get('address'), 'Rua A');
      expect(doc.get('photoUrl'), 'https://foto.example.com/a.png');
      expect(doc.get('favoritePetIds'), ['pet_a', 'pet_b']);
      expect(doc.get('myPublishedPetIds'), ['pet_b']);
    });

    test('updateUser atualiza campos do documento', () async {
      await service.createUser(user);

      await service.updateUser('uid_1', {'phone': '(11) 99999-0000'});

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.get('phone'), '(11) 99999-0000');
    });

    test('addFavorite adiciona o pet à lista via arrayUnion', () async {
      await service.createUser(user);

      await service.addFavorite('uid_1', 'pet_a');
      await service.addFavorite('uid_1', 'pet_b');

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.get('favoritePetIds'), ['pet_a', 'pet_b']);
    });

    test('removeFavorite remove o pet da lista via arrayRemove', () async {
      await service.createUser(user);
      await service.addFavorite('uid_1', 'pet_a');
      await service.addFavorite('uid_1', 'pet_b');

      await service.removeFavorite('uid_1', 'pet_a');

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.get('favoritePetIds'), ['pet_b']);
    });

    test('addMyPet adiciona o pet à lista de publicações', () async {
      await service.createUser(user);

      await service.addMyPet('uid_1', 'pet_a');

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.get('myPublishedPetIds'), ['pet_a']);
    });

    test('removeMyPet remove o pet da lista de publicações', () async {
      await service.createUser(user);
      await service.addMyPet('uid_1', 'pet_a');
      await service.addMyPet('uid_1', 'pet_b');

      await service.removeMyPet('uid_1', 'pet_a');

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.get('myPublishedPetIds'), ['pet_b']);
    });

    test('deleteUser remove o documento do usuário', () async {
      await service.createUser(user);

      await service.deleteUser('uid_1');

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.exists, isFalse);
    });
  });
}