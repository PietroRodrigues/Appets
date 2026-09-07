import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/utils/storage_tokens.dart';
import 'package:appets/models/enums/enums_app.dart';

void main() {
  group('storage tokens (PT normalizado)', () {
    test('espécie gera token PT normalizado para todos os valores', () {
      expect(speciesStorageToken(AppPetSpecies.dog), 'cachorro');
      expect(speciesStorageToken(AppPetSpecies.cat), 'gato');
      expect(speciesStorageToken(AppPetSpecies.rabbit), 'coelho');
      expect(speciesStorageToken(AppPetSpecies.hamster), 'hamster');
      expect(speciesStorageToken(AppPetSpecies.bird), 'passaro');
      expect(speciesStorageToken(AppPetSpecies.turtle), 'tartaruga');
      expect(speciesStorageToken(AppPetSpecies.reptile), 'reptil');
      expect(speciesStorageToken(AppPetSpecies.other), 'outro');
    });

    test('gênero, unidade de idade e tipo geram tokens PT', () {
      expect(genderStorageToken(AppPetGender.male), 'macho');
      expect(genderStorageToken(AppPetGender.female), 'femea');
      expect(ageUnitStorageToken(AppPetAgeUnit.days), 'dias');
      expect(ageUnitStorageToken(AppPetAgeUnit.months), 'meses');
      expect(ageUnitStorageToken(AppPetAgeUnit.years), 'anos');
      expect(publicationTypeStorageToken(AppPetPublicationType.adoption), 'adocao');
      expect(publicationTypeStorageToken(AppPetPublicationType.lost), 'perdido');
    });
  });

  group('fromStored (leitura tolerante)', () {
    test('aceita o token PT atual', () {
      expect(speciesFromStored('cachorro'), AppPetSpecies.dog);
      expect(speciesFromStored('passaro'), AppPetSpecies.bird);
      expect(genderFromStored('femea'), AppPetGender.female);
      expect(ageUnitFromStored('anos'), AppPetAgeUnit.years);
      expect(publicationTypeFromStored('adocao'), AppPetPublicationType.adoption);
      expect(publicationTypeFromStored('perdido'), AppPetPublicationType.lost);
    });

    test('aceita o código legado em inglês', () {
      expect(speciesFromStored('dog'), AppPetSpecies.dog);
      expect(speciesFromStored('cat'), AppPetSpecies.cat);
      expect(genderFromStored('male'), AppPetGender.male);
      expect(genderFromStored('female'), AppPetGender.female);
      expect(ageUnitFromStored('days'), AppPetAgeUnit.days);
      expect(ageUnitFromStored('years'), AppPetAgeUnit.years);
      expect(publicationTypeFromStored('adoption'), AppPetPublicationType.adoption);
      expect(publicationTypeFromStored('lost'), AppPetPublicationType.lost);
    });

    test('valor desconhecido usa o fallback padrão', () {
      expect(speciesFromStored('dragon'), AppPetSpecies.dog);
      expect(genderFromStored('mito'), AppPetGender.male);
      expect(ageUnitFromStored('semanas'), AppPetAgeUnit.years);
      expect(publicationTypeFromStored('emprestimo'), AppPetPublicationType.adoption);
    });

    test('valor ausente ou não-string usa o fallback', () {
      expect(speciesFromStored(null), AppPetSpecies.dog);
      expect(speciesFromStored(123), AppPetSpecies.dog);
      expect(genderFromStored(''), AppPetGender.male);
      expect(ageUnitFromStored(0), AppPetAgeUnit.years);
    });

    test('espécie prioriza o token PT mesmo parecido com legado', () {
      // 'other' é um nome legado de enum; o token PT de other é 'outro'.
      expect(speciesFromStored('outro'), AppPetSpecies.other);
      expect(speciesFromStored('other'), AppPetSpecies.other);
    });
  });
}