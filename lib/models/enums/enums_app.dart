/// Enums do domínio e da navegação do aplicativo.
library;

// ── Gênero ──────────────────────────────────────────────

enum AppPetGender {
  male,
  female;

  /// Rótulo exibido na interface.
  String get label {
    switch (this) {
      case AppPetGender.male:
        return 'Macho';

      case AppPetGender.female:
        return 'Fêmea';
    }
  }
}

// ── Unidade de idade ────────────────────────────────────

enum AppPetAgeUnit {
  days,
  months,
  years;

  /// Rótulo exibido na interface.
  String get label {
    switch (this) {
      case AppPetAgeUnit.days:
        return 'dias';

      case AppPetAgeUnit.months:
        return 'meses';

      case AppPetAgeUnit.years:
        return 'anos';
    }
  }
}

// ── Tipo de publicação ──────────────────────────────────

enum AppPetPublicationType {
  adoption,
  lost;

  /// Rótulo exibido na interface.
  String get label {
    switch (this) {
      case AppPetPublicationType.adoption:
        return 'Adoção';

      case AppPetPublicationType.lost:
        return 'Perdido';
    }
  }
}

// ── Espécie ─────────────────────────────────────────────

enum AppPetSpecies {
  dog,
  cat,
  rabbit,
  hamster,
  bird,
  turtle,
  reptile,
  other;

  /// Rótulo exibido na interface.
  String get label {
    switch (this) {
      case AppPetSpecies.dog:
        return 'Cachorro';

      case AppPetSpecies.cat:
        return 'Gato';

      case AppPetSpecies.rabbit:
        return 'Coelho';

      case AppPetSpecies.hamster:
        return 'Hamster';

      case AppPetSpecies.bird:
        return 'Pássaro';

      case AppPetSpecies.turtle:
        return 'Tartaruga';

      case AppPetSpecies.reptile:
        return 'Réptil';

      case AppPetSpecies.other:
        return 'Outro';
    }
  }
}

// ── Filtro do feed de pets ──────────────────────────────

enum AppPetFilter {
  /// Feed paginado de todos os pets publicados.
  all,

  /// Lista reativa dos pets favoritados do usuário logado.
  favorites,

  /// Feed paginado apenas das publicações do usuário logado.
  myPublications,
}

// ── Páginas da navegação ────────────────────────────────

enum AppPage {
  /// Tela inicial.
  home,

  /// Tela de favoritos.
  favorites,

  /// Tela de minhas publicações.
  myPublications,

  /// Tela de perfil.
  profile,
}
