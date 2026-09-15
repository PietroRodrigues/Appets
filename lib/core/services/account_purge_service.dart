import 'package:firebase_auth/firebase_auth.dart';

import 'package:appets/core/constants/constants_strings_delete_account.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/widgets/feedback/widget_process.dart';

/// Executa a exclusão da conta (dados no Firestore/Storage e Auth),
/// de forma independente da interface.
///
/// Os dados do usuário são apagados ANTES da conta no Firebase Auth:
/// depois de deletar a conta o usuário é deslogado e o client perde
/// a credencial, então as regras de segurança do Firestore/Storage
/// rejeitariam as operações de limpeza.
class AccountPurgeService {
  AccountPurgeService._();

  static final AccountPurgeService instance = AccountPurgeService._();

  AuthService get _auth => AuthService.instance;

  /// Janela em que o login é considerado recente o suficiente para
  /// deletar a conta sem reautenticação (critério aproximado do
  /// `requires-recent-login` do Firebase Auth).
  static const Duration recentSessionWindow = Duration(minutes: 5);

  /// Indica se a sessão é recente o bastante para uma operação
  /// sensível (deletar a conta). Sem histórico, assume-se antiga.
  bool isSessionRecent(User user) {
    final lastSignIn = user.metadata.lastSignInTime;
    if (lastSignIn == null) return false;
    return DateTime.now().difference(lastSignIn) <= recentSessionWindow;
  }

  /// Exclui a conta do usuário, devolvendo o desfecho do processo.
  ///
  /// 0. Se a sessão não for recente, reautentica ANTES de apagar dados
  ///    (antecipa o reauth para nunca apagar a base e, em seguida, o
  ///    usuário cancelar o reauth — conta viva sem dados).
  /// 1. Apaga os dados enquanto a credencial é válida: pets (imagens no
  ///    Storage + documentos) e documento do usuário. Se a limpeza
  ///    falhar, aborta ANTES de excluir a conta no Auth (nunca deixar
  ///    pets órfãos).
  /// 2. Exclui a conta no Firebase Auth por último.
  /// 3. Garante que o aparelho fique deslogado e zera os estados locais.
  Future<WGProcessResult> deleteAccount({
    required User user,
    required Future<WGProcessResult> Function() onReauthenticate,
  }) async {
    try {
      if (!isSessionRecent(user)) {
        final reauth = await onReauthenticate();
        if (reauth.status != WGProcessStatus.success) return reauth;
      }

      final dataDeleted = await deleteUserData(user.uid);
      if (!dataDeleted) {
        return WGProcessResult.failure(
          DeleteAccountStrings.DELETE_ACCOUNT_DATA_ERROR,
        );
      }

      final deletion = await _deleteAuthAccount(onReauthenticate);
      if (deletion.status != WGProcessStatus.success) return deletion;

      try {
        await _auth.logout();
      } catch (_) {
        // Ignora falha no logout; a conta já foi excluída.
      }

      // Limpa as fontes globais da conta excluída.
      FavoritesService.instance.reset();
      MyPublicationsService.instance.reset();

      return const WGProcessResult.success();
    } catch (_) {
      return WGProcessResult.failure(
        DeleteAccountStrings.DELETE_ACCOUNT_ERROR,
      );
    }
  }

  /// Apaga os dados do usuário no Firestore e no Storage: pets
  /// (imagens e documentos) e o documento do usuário.
  ///
  /// Imagens no Storage são apagadas em modo "melhor esforço": se o
  /// Storage não estiver configurado ou uma imagem falhar, o fluxo
  /// continua (cada falha é ignorada internamente). Já os documentos
  /// (pets e usuário) são obrigatórios — se algum não puder ser
  /// removido, devolve `false` para que a exclusão da conta seja
  /// abortada e nenhum pet fique órfão.
  Future<bool> deleteUserData(String uid) async {
    try {
      final petService = PetService.instance;
      final storageService = StorageService.instance;
      final myPets = await petService.getPetsByOwner(uid);
      for (final pet in myPets) {
        if (pet.images.isNotEmpty) {
          await storageService.deletePetImagesByUrls(pet.images);
        }
        await petService.deletePet(pet.id);
      }
    } catch (_) {
      return false;
    }

    try {
      await FirestoreService.instance.deleteUser(uid);
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Exclui a conta no Firebase Auth, reautenticando o usuário
  /// quando o login não for recente.
  ///
  /// Devolve [WGProcessResult.canceled] se a reautenticação for
  /// cancelada (exclusão abortada) ou [WGProcessResult.success]
  /// quando a conta foi excluída.
  Future<WGProcessResult> _deleteAuthAccount(
    Future<WGProcessResult> Function() onReauthenticate,
  ) async {
    try {
      await _auth.deleteAccount();
      return const WGProcessResult.success();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') {
        return WGProcessResult.failure(
          DeleteAccountStrings.DELETE_ACCOUNT_ERROR,
        );
      }

      final reauth = await onReauthenticate();
      if (reauth.status != WGProcessStatus.success) return reauth;

      try {
        await _auth.deleteAccount();
        return const WGProcessResult.success();
      } on Exception {
        return WGProcessResult.failure(
          DeleteAccountStrings.DELETE_ACCOUNT_ERROR,
        );
      }
    }
  }
}