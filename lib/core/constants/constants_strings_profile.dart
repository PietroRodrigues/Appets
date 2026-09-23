// ignore_for_file: constant_identifier_names

/// Strings da interface do perfil e dados da conta, centralizadas.
class ProfileStrings {
  ProfileStrings._();

  static const PROFILE_TITLE = 'Meu Perfil';

  static const ACCOUNT_DATA_TITLE = 'Dados da conta';

  static const LOGOUT_OPTION = 'Desconectar';

  static const LOGOUT_TITLE = 'Desconectar?';

  static const LOGOUT_MESSAGE = 'Deseja realmente sair da sua conta?';

  static const CHANGE_AVATAR_FEATURE = 'Alterar avatar';

  // ── Dados da conta ─────────────────────────────────────

  static const PERSONAL_INFO_SECTION = 'Informações pessoais';

  static const NAME_LABEL = 'Nome';

  static const EDIT_EMAIL_FEATURE = 'Edição de e-mail';

  static const PHONE_LABEL = 'Telefone';

  static const EDIT_PHONE_FEATURE = 'Edição de telefone';

  static const ADDRESS_SECTION = 'Endereço';

  static const ADDRESS_LABEL = 'Endereço';

  static const EDIT_ADDRESS_FEATURE = 'Edição de endereço';

  static const SAVE_CONTACT = 'Salvar';

  static const CONTACT_SAVED = 'Dados salvos com sucesso!';

  static const CONTACT_SAVE_ERROR = 'Não foi possível salvar. Tente novamente.';

  static const NAME_SYNC_WARNING =
      'Dados salvos! Mas não foi possível atualizar o nome de exibição.';

  static const EMAIL_CHANGE_ERROR =
      'Não foi possível alterar o e-mail. Tente novamente.';

  static const UPDATE_CONTACT_TITLE = 'Atualizar publicações?';

  static const UPDATE_CONTACT_UPDATED = 'Telefone atualizado em todos os seus pets!';

  static String updatePublicationsMessage(String phone) =>
      'Deseja atualizar o telefone de contato para "$phone" em todos os seus pets?';

  static const EDIT_HINT = 'Toque para editar';

  static const DISCARD_CHANGES_TITLE = 'Alterações não salvas';

  static const DISCARD_CHANGES_MESSAGE =
      'Você tem alterações que ainda não foram salvas. Descartá-las?';

  static const SECURITY_SECTION = 'Segurança';

  static const CHANGE_PASSWORD = 'Alterar senha';

  static const CHANGE_PASSWORD_FEATURE = 'Alteração de senha';

  // ── Alterar senha ──────────────────────────────────────

  static const CHANGE_PASSWORD_GOOGLE_HINT =
      'Disponível apenas para contas com senha';

  static const CHANGE_PASSWORD_CURRENT_MESSAGE =
      'Digite sua senha atual para continuar';

  static const CHANGE_PASSWORD_CURRENT_HINT = 'Senha atual';

  static const CHANGE_PASSWORD_NEW_MESSAGE =
      'Escolha a nova senha (mínimo 6 caracteres)';

  static const CHANGE_PASSWORD_NEW_HINT = 'Nova senha';

  static const CHANGE_PASSWORD_CONFIRM_MESSAGE =
      'Digite novamente a nova senha para confirmar';

  static const CHANGE_PASSWORD_CONFIRM_HINT = 'Confirme a nova senha';

  static const CHANGE_PASSWORD_SUCCESS = 'Senha alterada com sucesso!';

  static const CHANGE_PASSWORD_ERROR =
      'Não foi possível alterar a senha. Tente novamente.';

  static const DANGER_ZONE = 'Gerenciar conta';
}
