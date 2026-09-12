import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/constants/constants_strings_profile.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/pet/widget_pet_details_info.dart';
import 'package:appets/widgets/pet/widget_pet_gallery.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Tela de detalhes com imagens e informações do pet selecionado.
///
/// Permite favoritar o pet e compartilhar.
class PetDetailsScreen extends StatefulWidget {
  const PetDetailsScreen({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  // Estado de favorito derivado da fonte global de favoritos.
  bool get _isFavorited => FavoritesService.instance.isFavorite(widget.pet.id);

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.favoriteIds.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    FavoritesService.instance.favoriteIds.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  // Alterna o estado de favorito do pet, persistindo no Firestore
  // por meio do serviço global.
  Future<void> _toggleFavorite() async {
    final authUser = AuthService.instance.currentUser;
    if (authUser == null || widget.pet.id.isEmpty) return;

    final service = FavoritesService.instance;
    final wasFavorited = _isFavorited;

    final ok = wasFavorited
        ? await service.remove(authUser.uid, widget.pet.id)
        : await service.add(authUser.uid, widget.pet.id);

    if (!ok && mounted) {
      WGDialog.showAction(
        context,
        title: SharedStrings.ERROR_TITLE,
        message: ProfileStrings.CONTACT_SAVE_ERROR,
        actionColor: ThemeColors.error,
      );
    }
  }

  // Abre o share sheet com o texto do pet. Em falha (ex.: sem apps de
  // compartilhamento), mostra um diálogo de erro.
  Future<void> _sharePet() async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: widget.pet.shareText),
      );
    } catch (_) {
      if (!mounted) return;
      WGDialog.showAction(
        context,
        title: SharedStrings.ERROR_TITLE,
        message: PetDetailsStrings.SHARE_ERROR,
        actionColor: ThemeColors.error,
      );
    }
  }

  // Constrói a tela de detalhes com galeria, informações e ações.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,

      appBar: AppBar(
        backgroundColor: ThemeColors.primary,

        foregroundColor: ThemeColors.white,

        elevation: 0,

        title: Text(widget.pet.name),

        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: _isFavorited
                ? PetDetailsStrings.REMOVE_FROM_FAVORITES
                : PetDetailsStrings.ADD_TO_FAVORITES,
            icon: Icon(
              _isFavorited ? Icons.star_rounded : Icons.star_border_rounded,
              color: ThemeColors.white,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: _sharePet,
            tooltip: PetDetailsStrings.SHARE_TOOLTIP,
            icon: const Icon(
              Icons.share_outlined,
              color: ThemeColors.white,
              size: 24,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ÁREA DAS FOTOS
              WGPetGallery(
                images: widget.pet.images,
                heroTag: 'pet-image-${widget.pet.id}',
              ),

              // INFORMAÇÕES DO PET
              WGPetDetailsInfo(pet: widget.pet),
            ],
          ),
        ),
      ),
    );
  }
}
