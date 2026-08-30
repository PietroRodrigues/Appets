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
  lost,
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