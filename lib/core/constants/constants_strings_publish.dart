// ignore_for_file: constant_identifier_names

/// Strings da interface do formulário de publicação/edição de pet,
/// centralizadas.
class PublishStrings {
  PublishStrings._();

  static const PUBLISH_PET_DESCRIPTION =
      'Informe os dados para publicar o pet.';

  static const EDIT_PET_DESCRIPTION =
      'Ajuste os dados publicados do pet. As fotos não mudam por enquanto.';

  static const DISCARD_TITLE = 'Descartar alterações?';

  static const DISCARD_MESSAGE = 'As informações preenchidas serão perdidas.';

  static const PET_PUBLISHED = 'Pet publicado com sucesso!';

  static const PUBLISH_LOADING = 'Publicando anúncio...';

  static const PUBLISH_ERROR = 'Erro ao publicar o pet. Tente novamente.';

  static const SAVE_BUTTON = 'Salvar Alterações';

  static const SAVE_LOADING = 'Salvando alterações...';

  static const PET_UPDATED = 'Alterações salvas com sucesso!';

  static const SAVE_ERROR = 'Erro ao salvar as alterações. Tente novamente.';

  static const PHOTOS_TITLE = 'Fotos do pet';

  static String photosGridDescription(int max) =>
      'Toque para adicionar (mínimo 1, máximo $max fotos)';

  static const PUBLICATION_TYPE = 'Tipo de publicação';

  static const PET_NAME_LABEL = 'Nome do pet';

  static const PET_NAME_HINT = 'Digite o nome do pet';

  static const PET_NAME_REQUIRED = 'Informe o nome do pet';

  static const SPECIES_LABEL = 'Espécie';

  static const PET_RACE_LABEL = 'Raça (opcional)';

  static const PET_RACE_HINT = 'Ex.: Poodle, SRD…';

  static const AGE = 'Idade';

  static const AGE_REQUIRED = 'Informe a idade';

  static const GENDER = 'Gênero';

  static const ADDRESS = 'Endereço';

  static const ADDRESS_HINT = 'Digite o endereço';

  static const ADDRESS_REQUIRED = 'Informe o endereço';

  static const ABOUT_PET = 'Sobre o pet';

  static const ABOUT_PET_HINT = 'Conte um pouco sobre o pet';

  static const ABOUT_PET_REQUIRED = 'Descreva o pet (mínimo 10 caracteres)';

  static const PUBLISH_BUTTON = 'Publicar Pet';

  static const CONTACT_OWNER_LABEL = 'Telefone';

  static const CONTACT_OWNER_HINT = 'Ex.: (11) 98765-4321';

  static const CONTACT_OWNER_REQUIRED = 'Informe o telefone de contato';

  static const OWNER_PHONE_INVALID =
      'Informe um celular válido com DDD (11 dígitos)';

  // ── Cadastro incompleto ────────────────────────────────

  static const INCOMPLETE_PROFILE_TITLE = 'Complete seu cadastro';

  static const INCOMPLETE_PROFILE_MESSAGE =
      'Para publicar um pet, é preciso ter celular e endereço cadastrados '
      'na sua conta. Deseja completar o cadastro agora?';

  // ── Atualização de contato em publicações ──────────────

  static const UPDATE_ALL_PUBLICATIONS_TITLE = 'Atualizar contato?';

  static const UPDATE_ALL_PUBLICATIONS_MESSAGE =
      'Atualizar todas as publicações com o telefone novo?';

  // ── Fotos ──────────────────────────────────────────────

  static const PHOTO_REMOVE_TITLE = 'Remover foto?';

  static const PHOTO_REMOVE_MESSAGE = 'Deseja remover esta foto da publicação?';

  static const MAIN_PHOTO_BADGE = 'Principal';

  static const MAIN_PHOTO_SLOT = 'Foto principal *';

  static String photoSlotLabel(int index) => 'Adicionar foto $index';
}
