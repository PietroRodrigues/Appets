// ignore_for_file: constant_identifier_names

/// Strings da interface relacionadas à autenticação (login, cadastro e
/// recuperação de senha), centralizadas.
class AuthStrings {
  AuthStrings._();

  static const EMAIL = 'E-mail';

  static const EMAIL_HINT = 'Digite seu e-mail';

  static const EMAIL_REQUIRED = 'Informe seu e-mail';

  static const EMAIL_INVALID = 'Digite um e-mail válido';

  static const PASSWORD = 'Senha';

  static const PASSWORD_HINT = 'Digite sua senha';

  static const PASSWORD_REQUIRED = 'Informe sua senha';

  static const PASSWORD_MIN_LENGTH = 'A senha deve ter no mínimo 6 caracteres';

  static const FORGOT_PASSWORD = 'Esqueci minha senha';

  static const LOGIN_BUTTON = 'Entrar';

  static const GOOGLE_LOGIN = 'Entrar com Google';

  static const OR = 'ou';

  static const CREATE_ACCOUNT = 'Criar Conta';

  static const ALREADY_HAVE_ACCOUNT = 'Já possuo uma conta';

  static const LOGIN_ERROR = 'Erro ao fazer login.';

  static const USER_NOT_FOUND = 'Usuário não encontrado.';

  static const WRONG_PASSWORD_MESSAGE = 'Senha incorreta.';

  static const INVALID_EMAIL = 'E-mail inválido.';

  static const INVALID_CREDENTIALS = 'E-mail ou senha incorretos.';

  static const GOOGLE_LOGIN_CANCELED = 'Login com Google cancelado.';

  static const GOOGLE_LOGIN_ERROR = 'Erro ao fazer login com Google.';

  static const CONNECTION_ERROR = 'Erro de conexão. Verifique sua internet.';

  static const LOGIN_CANCELED = 'Login cancelado.';

  static const LOGIN_LOADING = 'Entrando na sua conta...';

  static const GOOGLE_LOGIN_LOADING = 'Entrando com Google...';

  // ── Cadastro ───────────────────────────────────────────

  static const CREATE_YOUR_ACCOUNT = 'Crie sua conta';

  static const REGISTER_NAME_LABEL = 'Nome';

  static const REGISTER_NAME_HINT = 'Digite seu nome completo';

  static const CONFIRM_PASSWORD = 'Confirmar Senha';

  static const CONFIRM_PASSWORD_HINT = 'Digite novamente sua senha';

  static const PASSWORD_MISMATCH = 'As senhas não coincidem.';

  static const ACCOUNT_CREATED = 'Conta criada com sucesso!';

  static const REGISTER_ERROR = 'Erro ao criar conta.';

  static const REGISTER_LOADING = 'Criando sua conta...';

  static const EMAIL_ALREADY_IN_USE = 'E-mail já cadastrado.';

  static const WEAK_PASSWORD =
      'Senha muito fraca. Use pelo menos 6 caracteres.';

  // ── Recuperação de senha ───────────────────────────────

  static const RECOVER_TITLE = 'Recuperar Senha';

  static const RECOVER_DESCRIPTION =
      'Informe o e-mail cadastrado para receber um link de recuperação da senha.';

  static const RECOVER_BUTTON = 'Enviar Link';

  static const BACK_TO_LOGIN = 'Voltar ao Login';

  static const RECOVER_LINK_SENT = 'Link de recuperação enviado!';

  static const RECOVER_ERROR = 'Erro ao enviar link.';

  static const EMAIL_NOT_REGISTERED = 'E-mail não cadastrado.';

  static const RECOVER_LOADING = 'Enviando link de recuperação...';
}
