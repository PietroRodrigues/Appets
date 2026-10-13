import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/screens/screen_pet_details.dart';
import 'package:appets/screens/screen_publish_pet.dart';
import 'package:appets/widgets/feed/widget_feed_page.dart';
import 'package:appets/widgets/feed/widget_pet_card.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:flutter/material.dart';

/// Tela que exibe as publicações de pets feitas pelo usuário.
///
/// Filtra apenas os pets cujo [Pet.ownerId] corresponde ao
/// usuário logado. Exibe botão de edição nos cards.
class MyPublicationsScreen extends StatefulWidget {
  const MyPublicationsScreen({super.key, this.onPublish});

  /// Ação do CTA do estado vazio (abre a tela de publicar pet).
  final VoidCallback? onPublish;

  @override
  State<MyPublicationsScreen> createState() => _MyPublicationsScreenState();
}

class _MyPublicationsScreenState extends State<MyPublicationsScreen>
    with WGProcessMixin<MyPublicationsScreen> {
  final GlobalKey<WGFeedPageState> _feedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    AppNavigation.selectedPage.addListener(_clearSearch);
  }

  @override
  void dispose() {
    AppNavigation.selectedPage.removeListener(_clearSearch);
    super.dispose();
  }

  void _clearSearch() {
    _feedKey.currentState?.searchNotifier.value = '';
  }

  // Abre a tela de edição do pet e recarrega a grade ao salvar.
  Future<void> _editPet(Pet pet) async {
    final edited = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => PublishPetScreen(pet: pet)),
    );
    if (edited == true && mounted) {
      await _feedKey.currentState?.reload();
    }
  }

  // Confirma e exclui uma publicação, refletindo na grade automaticamente
  // (o `remove` dispara o notifier `myPetIds`, que recarrega a grade).
  //
  // O processo roda na WGProcessLoadingScreen: dá feedback visível, bloqueia
  // duplo toque e só toca o Firebase online (guarda do pushProcess). As
  // fotos do pet também são removidas do Storage (melhor esforço), mesmo
  // padrão da exclusão de conta.
  Future<void> _deletePet(Pet pet) async {
    final confirmed = await WGDialog.showConfirm(
      context,
      title: HomeStrings.DELETE_PET_CONFIRM_TITLE,
      message: HomeStrings.deletePetConfirmMessage(pet.name),
      messageHighlight: pet.name,
    );
    if (!confirmed || !mounted) return;

    final result = await pushProcess(
      message: HomeStrings.DELETE_PET_LOADING,
      task: () async {
        try {
          final uid = AuthService.instance.currentUser?.uid;
          if (pet.images.isNotEmpty) {
            await StorageService.instance.deletePetImagesByUrls(pet.images);
          }
          await PetService.instance.deletePet(pet.id);
          if (uid != null) {
            // Best-effort: se a persistência falhar, o ID órfão é limpo
            // pelo `cleanOrphans` na próxima carga.
            await MyPublicationsService.instance.remove(uid, pet.id);
          }
          return const WGProcessResult.success();
        } on Exception catch (e) {
          // Nada foi excluído: a falha aborta antes do commit (fotos e pet).
          return WGProcessResult.failure(HomeStrings.DELETE_PET_ERROR, cause: e);
        }
      },
    );
    if (!mounted) return;
    switch (result?.status) {
      case WGProcessStatus.success:
        WGDialog.showAction(
          context,
          title: SharedStrings.SUCCESS_TITLE,
          message: HomeStrings.DELETE_PET_SUCCESS,
        );
      case WGProcessStatus.failure:
        WGDialog.showAction(
          context,
          title: SharedStrings.ERROR_TITLE,
          message: result!.userFacingMessage,
          actionColor: context.appColors.error,
        );
      case WGProcessStatus.canceled:
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WGFeedPage(
      key: _feedKey,
      filter: AppPetFilter.myPublications,
      visibleTab: AppPage.myPublications,
      headerTitle: HomeStrings.MY_PUBLICATIONS_TITLE,
      headerDescription: HomeStrings.MY_PUBLICATIONS_DESCRIPTION,
      headerHintText: HomeStrings.PUBLICATIONS_SEARCH_HINT,
      emptyIcon: Icons.pets_outlined,
      emptyTitle: HomeStrings.EMPTY_PUBLICATIONS_TITLE,
      emptyDescription: HomeStrings.EMPTY_PUBLICATIONS_DESCRIPTION,
      emptyActionLabel: widget.onPublish != null
          ? HomeStrings.PUBLISH_PET
          : null,
      emptyAction: widget.onPublish,
      itemBuilder: (context, pet) {
        return WGPetCard(
          pet: pet,
          isMyPublication: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PetDetailsScreen(pet: pet),
              ),
            );
          },
          onEdit: () => _editPet(pet),
          onDelete: () => _deletePet(pet),
        );
      },
    );
  }
}