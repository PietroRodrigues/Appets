/// Strings da interface centralizadas.
class AppStrings {
  AppStrings._();

  static const slogan = 'Encontre um novo melhor amigo.';

  // ── Mensagens de feedback ──────────────────────────────

  static const shareInDevelopment = 'Compartilhar em desenvolvimento';

  static String featureInDevelopment(String feature) =>
      '$feature em desenvolvimento';

  // ── Autenticação ───────────────────────────────────────

  static const email = 'E-mail';

  static const emailHint = 'Digite seu e-mail';

  static const emailRequired = 'Informe seu e-mail';

  static const emailInvalid = 'Digite um e-mail válido';

  static const password = 'Senha';

  static const passwordHint = 'Digite sua senha';

  static const passwordRequired = 'Informe sua senha';

  static const passwordMinLength = 'A senha deve ter no mínimo 6 caracteres';

  static const forgotPassword = 'Esqueci minha senha';

  static const loginButton = 'Entrar';

  static const googleLogin = 'Entrar com Google';

  static const or = 'ou';

  static const createAccount = 'Criar Conta';

  static const alreadyHaveAccount = 'Já possuo uma conta';

  static const loginError = 'Erro ao fazer login.';

  static const userNotFound = 'Usuário não encontrado.';

  static const wrongPasswordMessage = 'Senha incorreta.';

  static const invalidEmail = 'E-mail inválido.';

  static const invalidCredentials = 'E-mail ou senha incorretos.';

  static const googleLoginCanceled = 'Login com Google cancelado.';

  static const googleLoginError = 'Erro ao fazer login com Google.';

  static const connectionError = 'Erro de conexão. Verifique sua internet.';

  static const loginCanceled = 'Login cancelado.';

  static const loginLoading = 'Entrando na sua conta...';

  static const googleLoginLoading = 'Entrando com Google...';

  // ── Cadastro ───────────────────────────────────────────

  static const createYourAccount = 'Crie sua conta';

  static const registerNameLabel = 'Nome';

  static const registerNameHint = 'Digite seu nome completo';

  static const confirmPassword = 'Confirmar Senha';

  static const confirmPasswordHint = 'Digite novamente sua senha';

  static const passwordMismatch = 'As senhas não coincidem.';

  static const accountCreated = 'Conta criada com sucesso!';

  static const registerError = 'Erro ao criar conta.';

  static const registerLoading = 'Criando sua conta...';

  static const emailAlreadyInUse = 'E-mail já cadastrado.';

  static const weakPassword = 'Senha muito fraca. Use pelo menos 6 caracteres.';

  // ── Recuperação de senha ───────────────────────────────

  static const recoverTitle = 'Recuperar Senha';

  static const recoverDescription =
      'Informe o e-mail cadastrado para receber um link de recuperação da senha.';

  static const recoverButton = 'Enviar Link';

  static const backToLogin = 'Voltar ao Login';

  static const recoverLinkSent = 'Link de recuperação enviado!';

  static const recoverError = 'Erro ao enviar link.';

  static const emailNotRegistered = 'E-mail não cadastrado.';

  static const recoverLoading = 'Enviando link de recuperação...';

  // ── Navegação ──────────────────────────────────────────

  static const navHome = 'Início';

  static const navFavorites = 'Favoritos';

  static const navPublications = 'Publicações';

  static const navProfile = 'Perfil';

  // ── Cabeçalho / Busca ──────────────────────────────────

  static String helloUser(String name) => 'Olá, $name';

  static const searchDefaultHint = 'Buscar meu futuro pet';

  static const clearSearch = 'Limpar busca';

  static const filters = 'Filtros';

  // ── Home ───────────────────────────────────────────────

  static const emptyPetsTitle = 'Nenhum pet por aqui';

  static const emptyPetsDescription =
      'Ainda não há pets publicados. Que tal ser o primeiro a publicar?';

  static const emptyPetsAction = 'Publicar pet';

  static const defaultUserName = 'Usuário';

  // ── Favoritos ──────────────────────────────────────────

  static const favoritesTitle = 'Meus favoritos';

  static const favoritesSearchHint = 'Buscar nos favoritos';

  static const emptyFavoritesTitle = 'Nenhum favorito ainda';

  static const emptyFavoritesDescription =
      'Toque na estrela de um pet para salvá-lo aqui.';

  static const explorePets = 'Explorar pets';

  static const favoritesLoadError =
      'Não foi possível carregar seus favoritos. Tente novamente.';

  // ── Minhas publicações ─────────────────────────────────

  static const myPublicationsTitle = 'Minhas Publicações';

  static const myPublicationsDescription = 'Gerencie seus pets publicados.';

  static const publicationsSearchHint = 'Buscar nas publicações';

  static const emptyPublicationsTitle = 'Nenhuma publicação encontrada';

  static const emptyPublicationsDescription =
      'Publique um pet para encontrá-lo aqui.';

  static const publishPet = 'Publicar pet';

  static String editingPet(String petName) => 'Editando: $petName';

  // ── Publicar pet ───────────────────────────────────────

  static const publishPetDescription = 'Informe os dados para publicar o pet.';

  static const discardTitle = 'Descartar alterações?';

  static const discardMessage = 'As informações preenchidas serão perdidas.';

  static const discardConfirm = 'Sim, descartar';

  static const petPublished = 'Pet publicado com sucesso!';

  static const publishLoading = 'Publicando anúncio...';

  static const publishError = 'Erro ao publicar o pet. Tente novamente.';

  static const photosTitle = 'Fotos do pet';

  static String photosGridDescription(int max) =>
      'Toque para adicionar (mínimo 1, máximo $max fotos)';

  static const publicationType = 'Tipo de publicação';

  static const petNameLabel = 'Nome do pet';

  static const petNameHint = 'Digite o nome do pet';

  static const petNameRequired = 'Informe o nome do pet';

  static const age = 'Idade';

  static const ageRequired = 'Informe a idade';

  static const gender = 'Gênero';

  static const address = 'Endereço';

  static const addressHint = 'Digite o endereço';

  static const addressRequired = 'Informe o endereço';

  static const aboutPet = 'Sobre o pet';

  static const aboutPetHint = 'Conte um pouco sobre o pet';

  static const aboutPetRequired = 'Descreva o pet (mínimo 10 caracteres)';

  static const publishButton = 'Publicar Pet';

  static const contactOwnerLabel = 'Telefone';

  static const contactOwnerHint = 'Ex.: (11) 98765-4321';

  static const contactOwnerRequired = 'Informe o telefone de contato';

  static const ownerPhoneInvalid =
      'Informe um celular válido com DDD (11 dígitos)';

  static const incompleteProfileTitle = 'Complete seu cadastro';

  static const incompleteProfileMessage =
      'Para publicar um pet é preciso ter celular e endereço cadastrados na sua conta.';

  static const completeProfileButton = 'Completar cadastro';

  static const updateAllPublicationsTitle = 'Atualizar contato?';

  static const updateAllPublicationsMessage =
      'Atualizar todas as publicações com o telefone novo?';

  static const updateAllPublicationsConfirm = 'Sim';

  static const updateAllPublicationsCancel = 'Não';

  static const photoRemoveTitle = 'Remover foto?';

  static const photoRemoveMessage =
      'Deseja remover esta foto da publicação?';

  static const photoRemoveConfirm = 'Sim, remover';

  static const mainPhotoBadge = 'Principal';

  static const mainPhotoSlot = 'Foto principal *';

  static String photoSlotLabel(int index) => 'Adicionar foto $index';

  // ── Detalhes do pet ────────────────────────────────────

  static const addToFavorites = 'Adicionar aos favoritos';

  static const removeFromFavorites = 'Remover dos favoritos';

  static const shareTooltip = 'Compartilhar';

  static const ownerPhoneUnavailable =
      'Telefone do proprietário não disponível.';

  static String whatsAppMessage(String petName) =>
      'Olá! Vi o pet $petName no APPets e gostaria de saber mais.';

  static const whatsAppError = 'Não foi possível abrir o WhatsApp.';

  static const contactButton = 'Entrar em contato';

  static const aboutSection = 'Sobre';

  static const descriptionNotInformed = 'Descrição não informada.';

  static String petAddedToFavorites(String petName) =>
      '$petName adicionado aos favoritos';

  static String petRemovedFromFavorites(String petName) =>
      '$petName removido dos favoritos';

  // ── Perfil ─────────────────────────────────────────────

  static const profileTitle = 'Meu Perfil';

  static const accountDataTitle = 'Dados da conta';

  static const settingsTitle = 'Configurações';

  static const logoutOption = 'Desconectar';

  static const logoutTitle = 'Desconectar?';

  static const logoutMessage = 'Deseja realmente sair da sua conta?';

  static const logoutConfirm = 'Sim, sair';

  static const changeAvatarFeature = 'Alterar avatar';

  // ── Dados da conta ─────────────────────────────────────

  static const personalInfoSection = 'Informações pessoais';

  static const nameLabel = 'Nome';

  static const editNameFeature = 'Edição de nome';

  static const editEmailFeature = 'Edição de e-mail';

  static const phoneLabel = 'Telefone';

  static const editPhoneFeature = 'Edição de telefone';

  static const addressSection = 'Endereço';

  static const addressLabel = 'Endereço';

  static const editAddressFeature = 'Edição de endereço';

  static const saveContact = 'Salvar';

  static const contactSaved = 'Dados salvos com sucesso!';

  static const contactSaveError = 'Não foi possível salvar. Tente novamente.';

  static const editHint = 'Toque para editar';

  static const discardChangesTitle = 'Alterações não salvas';

  static const discardChangesMessage =
      'Você tem alterações que ainda não foram salvas. Descartá-las?';

  static const discardDraftConfirm = 'Descartar';

  static const securitySection = 'Segurança';

  static const changePassword = 'Alterar senha';

  static const changePasswordFeature = 'Alteração de senha';

  static const dangerZone = 'Gerenciar conta';

  // ── Configurações ──────────────────────────────────────

  static const shareLocationTitle = 'Compartilhar localização';

  static const shareLocationSubtitle = 'Permitir acesso à sua localização';

  static const shareLocationFeature = 'Configurações de privacidade';

  static const appAboutTitle = 'Sobre o APPets';

  static const appAboutSubtitle = 'Versão 1.0.0';

  static const appAboutFeature = 'Sobre o app';

  // ── Comuns ─────────────────────────────────────────────

  static const no = 'Não';

  // ── Edição de perfil ──────────────────────────────────

  static const cancel = 'Cancelar';

  // ── Exclusão de conta ─────────────────────────────────

  static const deleteAccount = 'Deletar conta';

  static const deleteAccountLoading = 'Deletando sua conta...';

  static const deleteAccountTitle = 'Deletar conta?';

  static const deleteAccountConfirmMessage =
      'Certeza que quer deletar a sua conta de usuário?';

  static const deleteAccountContinue = 'Continuar';

  static const deleteAccountFinalTitle = 'Aviso importante';

  static const deleteAccountFinalMessage =
      'Todos os dados referentes à conta serão deletados permanentemente: '
      'anúncios, imagens e dados pessoais. Esta ação não pode ser desfeita.';

  static const deleteAccountConfirm = 'Sim, Deletar';

  static const deletePermanentlyHighlight = 'deletados permanentemente';

  static const deleteAccountPasswordTitle = 'Confirmar para continuar';

  static const deleteAccountPasswordMessage =
      'Para sua segurança, confirme sua senha para excluir a conta.';

  static const deleteAccountPasswordHint = 'Digite sua senha';

  static const deleteAccountPasswordValidation =
      'Informe sua senha para continuar';

  static const wrongPassword = 'Senha incorreta. Tente novamente.';

  static const deleteAccountReauthWarning =
      'Não foi possível confirmar sua identidade para excluir a conta. '
      'Tente novamente.';

  static const accountDeleted = 'Conta deletada com sucesso.';

  static const deleteAccountError =
      'Erro ao deletar a conta. Tente novamente.';
}