// ignore_for_file: constant_identifier_names

/// Strings da interface da navegação, cabeçalho/busca, home, favoritos e
/// minhas publicações, centralizadas.
class HomeStrings {
  HomeStrings._();

  // ── Navegação ──────────────────────────────────────────

  static const NAV_HOME = 'Início';

  static const NAV_FAVORITES = 'Favoritos';

  static const NAV_PUBLICATIONS = 'Publicações';

  static const NAV_PROFILE = 'Perfil';

  // ── Cabeçalho / Busca ──────────────────────────────────

  static String helloUser(String name) => 'Olá, $name';

  static const SEARCH_DEFAULT_HINT =
      'Busque pelo nome ou palavras do Sobre o pet';

  static const CLEAR_SEARCH = 'Limpar busca';

  static const SUBMIT_SEARCH = 'Buscar';

  static const FILTERS = 'Filtros';

  // ── Home ───────────────────────────────────────────────

  static const EMPTY_PETS_TITLE = 'Nenhum pet por aqui';

  static const EMPTY_PETS_DESCRIPTION =
      'Ainda não há pets publicados. Que tal ser o primeiro a publicar?';

  static const EMPTY_PETS_ACTION = 'Publicar pet';

  static const DEFAULT_USER_NAME = 'Usuário';

  // ── Favoritos ──────────────────────────────────────────

  static const FAVORITES_TITLE = 'Meus favoritos';

  static const FAVORITES_SEARCH_HINT =
      'Busque pelo nome ou palavras do Sobre o pet';

  static const EMPTY_FAVORITES_TITLE = 'Nenhum favorito ainda';

  static const EMPTY_FAVORITES_DESCRIPTION =
      'Toque na estrela de um pet para salvá-lo aqui.';

  static const EXPLORE_PETS = 'Explorar pets';

  static const FAVORITES_LOAD_ERROR =
      'Não foi possível carregar seus favoritos. Tente novamente.';

  // ── Minhas publicações ─────────────────────────────────

  static const MY_PUBLICATIONS_TITLE = 'Minhas Publicações';

  static const MY_PUBLICATIONS_DESCRIPTION = 'Gerencie seus pets publicados.';

  static const PUBLICATIONS_SEARCH_HINT =
      'Busque pelo nome ou palavras do Sobre o pet';

  static const EMPTY_PUBLICATIONS_TITLE = 'Nenhuma publicação encontrada';

  static const EMPTY_PUBLICATIONS_DESCRIPTION =
      'Publique um pet para encontrá-lo aqui.';

  static const PUBLISH_PET = 'Publicar pet';

  static String editingPet(String petName) => 'Editando: $petName';
}
