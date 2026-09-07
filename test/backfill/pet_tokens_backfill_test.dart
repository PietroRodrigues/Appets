import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/backfill/pet_tokens_backfill.dart';
import 'package:appets/core/backfill/pet_tokens_backfill_runner.dart';
import 'package:appets/core/backfill/pet_tokens_backfill_writer.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';

Pet _pet(String id, {AppPetSpecies species = AppPetSpecies.dog}) {
  return Pet(
    id: id,
    ownerId: 'uid',
    name: 'Rex',
    age: 1,
    gender: AppPetGender.male,
    address: 'Endereço',
    images: const <String>[],
    ageUnit: AppPetAgeUnit.years,
    publicationType: AppPetPublicationType.adoption,
    species: species,
  );
}

/// Writer fake que registra as escritas em [writes] e devolve a contagem.
class _FakeWriter implements PetTokensBackfillWriter {
  _FakeWriter(this.writes);

  final List<Map<String, Map<String, dynamic>>> writes;

  @override
  Future<int> write(Map<String, Map<String, dynamic>> updatesByPetId) async {
    writes.add(updatesByPetId);
    return updatesByPetId.length;
  }
}

void main() {
  group('petTokenFields', () {
    test('gera os 5 campos de token em PT normalizado', () {
      final fields = petTokenFields(_pet('p1'));

      expect(fields, {
        'species': 'cachorro',
        'gender': 'macho',
        'ageUnit': 'anos',
        'publicationType': 'adocao',
        'specifications': ['cachorro', 'macho', 'adocao', 'jovem'],
      });
    });
  });

  group('petTokensNeedingBackfill', () {
    test('migra todos os campos quando o documento é legado (inglês)', () {
      final pet = _pet('p1');
      final stored = {
        'p1': {
          'species': 'dog',
          'gender': 'male',
          'ageUnit': 'years',
          'publicationType': 'adoption',
          'specifications': ['dog', 'male', 'adoption', 'young'],
        },
      };

      final pending = petTokensNeedingBackfill([pet], stored);

      expect(pending, {
        'p1': {
          'species': 'cachorro',
          'gender': 'macho',
          'ageUnit': 'anos',
          'publicationType': 'adocao',
          'specifications': ['cachorro', 'macho', 'adocao', 'jovem'],
        },
      });
    });

    test('pula quando tudo já está em PT', () {
      final pet = _pet('p1');
      final stored = {'p1': petTokenFields(pet)};

      final pending = petTokensNeedingBackfill([pet], stored);

      expect(pending, isEmpty);
    });

    test('corrige só o campo divergente (migração parcial)', () {
      final pet = _pet('p1');
      final stored = {
        'p1': {
          'species': 'cachorro',
          'gender': 'macho',
          'ageUnit': 'anos',
          'publicationType': 'adocao',
          'specifications': ['dog', 'male', 'adoption', 'young'],
        },
      };

      final pending = petTokensNeedingBackfill([pet], stored);

      expect(pending, {
        'p1': {'specifications': ['cachorro', 'macho', 'adocao', 'jovem']},
      });
    });

    test('campos extras e ausentes são tratados como divergência', () {
      final pet = _pet('p1');

      final semCampos = petTokensNeedingBackfill([pet], {});

      expect(semCampos['p1'], containsPair('species', 'cachorro'));
      expect(semCampos['p1'], containsPair('specifications', pet.specifications));
      // Campos de token pendentes são exatamente os 5.
      expect(semCampos['p1']!.length, 5);
    });

    test('mistura pendentes e já migrados corretamente', () {
      final ok = _pet('ok');
      final legacy = _pet('legacy');

      final pending = petTokensNeedingBackfill(
        [ok, legacy],
        {'ok': petTokenFields(ok)},
      );

      expect(pending.keys.toSet(), {'legacy'});
    });
  });

  group('PetTokensBackfillRunner', () {
    test('sem pendentes retorna 0 e não chama o writer', () async {
      final writes = <Map<String, Map<String, dynamic>>>[];
      final runner = PetTokensBackfillRunner(_FakeWriter(writes));
      final pet = _pet('p1');

      final written = await runner.run([pet], {'p1': petTokenFields(pet)});

      expect(written, 0);
      expect(writes, isEmpty);
    });

    test('grava apenas os pendentes e retorna a quantidade', () async {
      final writes = <Map<String, Map<String, dynamic>>>[];
      final runner = PetTokensBackfillRunner(_FakeWriter(writes));
      final ok = _pet('ok');
      final legacy = _pet('legacy', species: AppPetSpecies.cat);

      final written = await runner.run(
        [ok, legacy],
        {
          'ok': petTokenFields(ok),
          'legacy': {
            'species': 'cat',
            'gender': 'male',
            'ageUnit': 'years',
            'publicationType': 'adoption',
          },
        },
      );

      expect(written, 1);
      expect(writes.single.keys, {'legacy'});
      expect(writes.single['legacy'], containsPair('species', 'gato'));
    });
  });
}