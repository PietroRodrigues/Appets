import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/backfill/firestore_pet_tokens_backfill_writer.dart';
import 'package:appets/core/backfill/pet_tokens_backfill_runner.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';

void main() {
  late FakeFirebaseFirestore db;
  final service = PetService.instance;

  setUp(() {
    db = FakeFirebaseFirestore();
    service.debugDb = db;
  });

  Pet pet(String id, {required String name, required AppPetSpecies species}) {
    return Pet(
      id: id,
      ownerId: 'uid_test',
      name: name,
      age: 1,
      gender: AppPetGender.male,
      address: 'Rua 1',
      images: const <String>[],
      species: species,
    );
  }

  Future<void> seedOwnerPets() async {
    // Pet legado: tokens em inglês e SEM createdAt (o Firestore real o
    // excluiria de consultas com orderBy('createdAt')).
    final legacy = pet('p1', name: 'Rex', species: AppPetSpecies.dog).toMap()
      ..remove('createdAt')
      ..['species'] = 'dog'
      ..['gender'] = 'male'
      ..['ageUnit'] = 'years'
      ..['publicationType'] = 'adoption'
      ..['specifications'] = <String>['dog', 'male', 'adoption', 'young']
      ..['searchTokens'] = <String>[];
    await db.collection('pets').doc('p1').set(legacy);

    // Pet atual da versão nova do app: tokens PT e com createdAt.
    await db.collection('pets').doc('p2').set(pet('p2', name: 'Mia', species: AppPetSpecies.cat).toMap());
  }

  test('backfill cura pet legado sem createdAt e não mexe no pet atual',
      () async {
    await seedOwnerPets();

    // O próprio backfill enxerga os docs legados (leitura tolerante).
    final docs = await service.getOwnerPetDocuments('uid_test');
    expect(docs.map((d) => d.id).toSet(), {'p1', 'p2'});

    final pets = docs.map((doc) => Pet.fromFirestore(doc)).toList();
    final stored = <String, Map<String, dynamic>>{
      for (final doc in docs)
        if (doc.data() is Map<String, dynamic>)
          doc.id: doc.data() as Map<String, dynamic>,
    };

    final runner = PetTokensBackfillRunner(
      FirestorePetTokensBackfillWriter(service),
    );
    final written = await runner.run(pets, stored);

    expect(written, 1);

    final doc1 = await db.collection('pets').doc('p1').get();
    expect(doc1.get('createdAt'), isNotNull);
    expect(doc1.get('species'), 'cachorro');
    expect(doc1.get('gender'), 'macho');
    expect(doc1.get('ageUnit'), 'anos');
    expect(doc1.get('publicationType'), 'adocao');
    expect(doc1.get('specifications'), ['cachorro', 'macho', 'adocao', 'jovem']);
    expect(doc1.get('searchTokens'), ['rex']);

    final doc2 = await db.collection('pets').doc('p2').get();
    expect(doc2.get('createdAt'), isNotNull);
    expect(doc2.get('species'), 'gato');
    expect(doc2.get('searchTokens'), ['mia']);
  });

  test('backfill é idempotente: segunda execução não grava nada', () async {
    await seedOwnerPets();

    final docs = await service.getOwnerPetDocuments('uid_test');
    final pets = docs.map((doc) => Pet.fromFirestore(doc)).toList();
    final stored = <String, Map<String, dynamic>>{
      for (final doc in docs)
        if (doc.data() is Map<String, dynamic>)
          doc.id: doc.data() as Map<String, dynamic>,
    };
    final runner = PetTokensBackfillRunner(
      FirestorePetTokensBackfillWriter(service),
    );

    final first = await runner.run(pets, stored);

    final docsAfter = await service.getOwnerPetDocuments('uid_test');
    final petsAfter = docsAfter.map((doc) => Pet.fromFirestore(doc)).toList();
    final storedAfter = <String, Map<String, dynamic>>{
      for (final doc in docsAfter)
        if (doc.data() is Map<String, dynamic>)
          doc.id: doc.data() as Map<String, dynamic>,
    };

    final second = await runner.run(petsAfter, storedAfter);

    expect(first, 1);
    expect(second, 0);
  });
}