import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/utils/search_tokens.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';

void main() {
  late FakeFirebaseFirestore db;
  final service = PetService.instance;

  setUp(() {
    db = FakeFirebaseFirestore();
    service.debugDb = db;
  });

  Pet makePet(
    String id, {
    required String ownerId,
    required String name,
    required int age,
  }) {
    return Pet(
      id: id,
      ownerId: ownerId,
      name: name,
      age: age,
      gender: AppPetGender.male,
      address: 'Endereço',
      images: const [],
    );
  }

  Future<void> insertPet(Map<String, dynamic> data) {
    return db.collection('pets').doc(data['id'] as String).set(data);
  }

  Map<String, dynamic> petDoc(
    String id, {
    required String ownerId,
    DateTime? createdAt,
    List<String> searchTokens = const [],
  }) {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': 'Pet $id',
      'age': 2,
      'ageUnit': 'anos',
      'gender': 'macho',
      'address': 'Rua 1',
      'ownerPhone': '',
      'ownerAddress': '',
      'description': '',
      'publicationType': 'adocao',
      'species': 'cachorro',
      'race': '',
      'searchTokens': searchTokens,
      'specifications': const [],
      'images': const [],
      'createdAt': createdAt ?? DateTime(2024, 1, 1),
    };
  }

  group('PetService · leitura por dono', () {
    test('getPetsByOwner retorna apenas os pets do dono', () async {
      await insertPet(petDoc('p1', ownerId: 'dono_a'));
      await insertPet(petDoc('p2', ownerId: 'dono_a'));
      await insertPet(petDoc('p3', ownerId: 'dono_b'));

      final pets = await service.getPetsByOwner('dono_a');

      expect(pets.map((p) => p.id).toSet(), {'p1', 'p2'});
    });

    test('getPetsByOwner ordena do mais recente para o mais antigo', () async {
      await insertPet(
        petDoc('p1', ownerId: 'dono_a', createdAt: DateTime(2024, 1, 1)),
      );
      await insertPet(
        petDoc('p2', ownerId: 'dono_a', createdAt: DateTime(2024, 3, 3)),
      );
      await insertPet(
        petDoc('p3', ownerId: 'dono_a', createdAt: DateTime(2024, 2, 2)),
      );

      final pets = await service.getPetsByOwner('dono_a');

      expect([pets[0].id, pets[1].id, pets[2].id], ['p2', 'p3', 'p1']);
    });

    test('getOwnerPetDocuments retorna os documentos crus do dono', () async {
      await insertPet(petDoc('p1', ownerId: 'dono_a'));
      await insertPet(petDoc('p2', ownerId: 'dono_b'));

      final docs = await service.getOwnerPetDocuments('dono_a');

      expect(docs.map((d) => d.id), ['p1']);
    });
  });

  group('PetService · batch e propagação de telefone', () {
    test(
      'updatePetsBatch com mapa vazio retorna 0 sem atualizar nada',
      () async {
        final count = await service.updatePetsBatch({});
        expect(count, 0);
      },
    );

    test('updatePetsBatch atualiza vários pets e retorna a contagem', () async {
      await insertPet(petDoc('p1', ownerId: 'dono_a'));
      await insertPet(petDoc('p2', ownerId: 'dono_a'));

      final count = await service.updatePetsBatch({
        'p1': {'ownerPhone': '999'},
        'p2': {'ownerPhone': '888'},
      });

      expect(count, 2);
      final doc1 = await db.collection('pets').doc('p1').get();
      final doc2 = await db.collection('pets').doc('p2').get();
      expect(doc1.get('ownerPhone'), '999');
      expect(doc2.get('ownerPhone'), '888');
    });

    test(
      'updateOwnerPhone propaga o telefone em batch para todos os pets',
      () async {
        await insertPet(petDoc('p1', ownerId: 'dono_a'));
        await insertPet(petDoc('p2', ownerId: 'dono_a'));

        await service.updateOwnerPhone('dono_a', '(11) 99999-0000');

        final doc1 = await db.collection('pets').doc('p1').get();
        final doc2 = await db.collection('pets').doc('p2').get();
        expect(doc1.get('ownerPhone'), '(11) 99999-0000');
        expect(doc2.get('ownerPhone'), '(11) 99999-0000');
      },
    );

    test('updateOwnerPhone não falha quando o dono não tem pets', () async {
      await service.updateOwnerPhone('dono_sozinho', '(11) 99999-0000');
    });
  });

  group('PetService · CRUD', () {
    test('createPet persiste o pet e retorna o ID gerado', () async {
      final id = await service.createPet(
        makePet('', ownerId: 'dono_a', name: 'Rex', age: 2),
      );

      expect(id, isNotEmpty);
      final doc = await db.collection('pets').doc(id).get();
      expect(doc.exists, isTrue);
    });

    test('updatePet atualiza apenas os campos informados', () async {
      await insertPet(petDoc('p1', ownerId: 'dono_a'));

      await service.updatePet('p1', {'name': 'Novo Nome'});

      final doc = await db.collection('pets').doc('p1').get();
      expect(doc.get('name'), 'Novo Nome');
      expect(doc.get('ownerId'), 'dono_a');
    });

    test('deletePet remove o documento', () async {
      await insertPet(petDoc('p1', ownerId: 'dono_a'));

      await service.deletePet('p1');

      final doc = await db.collection('pets').doc('p1').get();
      expect(doc.exists, isFalse);
    });
  });

  group('PetService · getPetsByIds', () {
    test('devolve lista vazia quando não há IDs', () async {
      expect(await service.getPetsByIds([]), isEmpty);
    });

    test('devolve os pets de uma lista pequena de IDs', () async {
      await insertPet(petDoc('p1', ownerId: 'dono_a'));
      await insertPet(petDoc('p2', ownerId: 'dono_a'));

      final pets = await service.getPetsByIds(['p1', 'p2']);

      expect(pets.map((p) => p.id).toSet(), {'p1', 'p2'});
    });

    test('divide em lotes de 10 quando há muitos IDs', () async {
      for (var i = 0; i < 15; i++) {
        await insertPet(petDoc('pet_$i', ownerId: 'dono_a'));
      }

      final pets = await service.getPetsByIds([
        for (var i = 0; i < 15; i++) 'pet_$i',
      ]);

      expect(pets, hasLength(15));
    });
  });

  group('PetService · busca por tokens', () {
    test('devolve página vazia quando o termo não gera tokens', () async {
      final page = await service.searchPetsByTokens('a');
      expect(page.pets, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('busca parcial por prefixo, insensível a caixa', () async {
      await insertPet(
        petDoc(
          'p1',
          ownerId: 'dono_a',
          searchTokens: buildSearchTokens(name: 'Poodle'),
        ),
      );
      await insertPet(
        petDoc(
          'p2',
          ownerId: 'dono_a',
          searchTokens: buildSearchTokens(name: 'Vira-lata'),
        ),
      );

      final page = await service.searchPetsByTokens('POO');

      expect(page.pets.map((p) => p.id), ['p1']);
      expect(page.hasMore, isFalse);
    });

    test('considera múltiplos tokens e aplica o limite de página', () async {
      for (var i = 0; i < 22; i++) {
        await insertPet(
          petDoc('pet_$i', ownerId: 'dono_a', searchTokens: ['golden']),
        );
      }

      final page = await service.searchPetsByTokens('Golden');

      expect(page.pets, hasLength(PetService.pageSize));
      expect(page.hasMore, isTrue);
      expect(page.lastDoc, isNotNull);
    });

    test('searchPetsNextPage continua do cursor sem repetir pets', () async {
      final total = PetService.pageSize * 2 + 5;
      for (var i = 0; i < total; i++) {
        await insertPet(
          petDoc(
            'pet_$i',
            ownerId: 'dono_a',
            searchTokens: ['golden'],
            createdAt: DateTime(2024, 1, 1).add(Duration(minutes: i)),
          ),
        );
      }

      final first = await service.searchPetsByTokens('Golden');
      expect(first.pets, hasLength(PetService.pageSize));
      expect(first.hasMore, isTrue);
      expect(first.lastDoc, isNotNull);

      final second = await service.searchPetsNextPage('Golden', first.lastDoc!);

      expect(second.pets, hasLength(PetService.pageSize));
      expect(second.hasMore, isTrue);
      expect(second.lastDoc, isNotNull);
      expect(
        second.pets.any((p) => first.pets.any((f) => f.id == p.id)),
        isFalse,
      );

      final last = await service.searchPetsNextPage('Golden', second.lastDoc!);

      expect(last.pets, hasLength(5));
      expect(last.hasMore, isFalse);
      expect(last.lastDoc, isNull);
    });

    test('searchPetsNextPage com termo sem tokens devolve página vazia',
        () async {
      for (var i = 0; i < 22; i++) {
        await insertPet(
          petDoc('pet_$i', ownerId: 'dono_a', searchTokens: ['golden']),
        );
      }
      final first = await service.searchPetsByTokens('Golden');

      final page = await service.searchPetsNextPage('a', first.lastDoc!);

      expect(page.pets, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test(
      'limita a busca às 10 primeiras palavras (limite do Firestore)',
      () async {
        const first10 = [
          'palavra0',
          'palavra1',
          'palavra2',
          'palavra3',
          'palavra4',
          'palavra5',
          'palavra6',
          'palavra7',
          'palavra8',
          'palavra9',
        ];
        await insertPet(petDoc('p1', ownerId: 'dono_a', searchTokens: first10));
        await insertPet(
          petDoc('p2', ownerId: 'dono_a', searchTokens: ['palavra10']),
        );

        final page = await service.searchPetsByTokens(
          '${first10.join(' ')} palavra10',
        );

        expect(page.pets.map((p) => p.id), ['p1']);
      },
    );
  });

  group('PetService · paginação (getNextPage)', () {
    test('detecta hasMore quando a página seguinte excede o limite', () async {
      for (var i = 0; i < 45; i++) {
        await insertPet(
          petDoc(
            'pet_$i',
            ownerId: 'dono_a',
            createdAt: DateTime(2024, 1, 1).add(Duration(minutes: i)),
          ),
        );
      }

      final firstSnapshot = await db
          .collection('pets')
          .orderBy('createdAt', descending: true)
          .limit(PetService.pageSize + 1)
          .get();
      final cursor = firstSnapshot.docs[PetService.pageSize - 1];

      final next = await service.getNextPage(cursor);

      expect(next.pets, hasLength(PetService.pageSize));
      expect(next.hasMore, isTrue);
      expect(next.lastDoc, isNotNull);
    });

    test('hasMore é false na última página', () async {
      for (var i = 0; i < PetService.pageSize + 5; i++) {
        await insertPet(
          petDoc(
            'pet_$i',
            ownerId: 'dono_a',
            createdAt: DateTime(2024, 1, 1).add(Duration(minutes: i)),
          ),
        );
      }

      final firstSnapshot = await db
          .collection('pets')
          .orderBy('createdAt', descending: true)
          .limit(PetService.pageSize + 1)
          .get();
      final cursor = firstSnapshot.docs[PetService.pageSize - 1];

      final next = await service.getNextPage(cursor);

      expect(next.pets, hasLength(5));
      expect(next.hasMore, isFalse);
      expect(next.lastDoc, isNull);
    });
  });
}
