import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/display/widget_pet_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Card reutilizável para exibir um pet em listas da interface.
///
/// Suporta favoritar com long press (segurar). Ao segurar o card,
/// uma estrela aparece no canto superior direito indicando que
/// o pet foi adicionado aos favoritos.
///
/// Quando [isMyPublication] é `true`, exibe um botão de edição
/// flutuante no canto inferior direito do card.
class WGPetCard extends StatefulWidget {
  const WGPetCard({
    super.key,
    required this.pet,
    this.onTap,
    this.onEdit,
    this.isMyPublication = false,
    this.heroTag,
  });

  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  /// Indica se este card é uma publicação do usuário atual.
  /// Quando `true`, exibe o botão de edição flutuante.
  final bool isMyPublication;

  /// Tag opcional para a animação Hero da imagem.
  ///
  /// Forneça apenas na origem principal da navegação (aba inicial)
  /// para evitar tags duplicadas com as abas do IndexedStack.
  final String? heroTag;

  @override
  State<WGPetCard> createState() => _WGPetCardState();
}

class _WGPetCardState extends State<WGPetCard>
    with SingleTickerProviderStateMixin {
  // Controlador da animação da estrela.
  late AnimationController _starController;
  late Animation<double> _starScaleAnimation;

  // Estado de favorito derivado da fonte global de favoritos.
  bool get _isFavorited => FavoritesService.instance.isFavorite(widget.pet.id);

  @override
  void initState() {
    super.initState();

    // Configura animação de escala para a estrela.
    _starController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _starScaleAnimation = CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    );

    // Se já estiver favoritado, mostra a estrela imediatamente.
    if (_isFavorited) {
      _starController.value = 1.0;
    }

    _favoritesListener = _onFavoritesChanged;
    FavoritesService.instance.favoriteIds.addListener(_favoritesListener);
  }

  // Listener da fonte global de favoritos.
  late VoidCallback _favoritesListener;

  // Quando qualquer favorito muda, sincroniza a animação da estrela.
  void _onFavoritesChanged() {
    if (!mounted) return;
    if (_isFavorited) {
      _starController.forward();
    } else {
      _starController.reverse();
    }
    setState(() {});
  }

  // Libera o controlador da animação da estrela.
  @override
  void dispose() {
    FavoritesService.instance.favoriteIds.removeListener(_favoritesListener);
    _starController.dispose();
    super.dispose();
  }

  /// Alterna o estado de favorito com animação, vibração e feedback visual,
  /// persistindo a alteração no Firestore por meio do serviço global.
  Future<void> _toggleFavorite() async {
    final authUser = AuthService.instance.currentUser;
    if (authUser == null) return;

    final service = FavoritesService.instance;

    final wasFavorited = _isFavorited;

    // Atualiza de forma otimista (o serviço notifica e sincroniza tudo).
    final ok = wasFavorited
        ? await service.remove(authUser.uid, widget.pet.id)
        : await service.add(authUser.uid, widget.pet.id);

    // Persistência falhou: o estado já foi revertido pelo serviço.
    if (!ok) return;

    HapticFeedback.mediumImpact();
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasFavorited
                ? PetDetailsStrings.petRemovedFromFavorites(widget.pet.name)
                : PetDetailsStrings.petAddedToFavorites(widget.pet.name),
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  // Constrói o layout do card com imagem, informações e botão de edição.
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // CARD PRINCIPAL
        Card(
          elevation: 3,
          color: ThemeColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: _toggleFavorite,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight = constraints.maxHeight * 0.54;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGEM COM ESTRELA DE FAVORITO
                    SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: _PetCardImage(
                        url: widget.pet.images.isNotEmpty
                            ? widget.pet.images.first
                            : '',
                        heroTag: widget.heroTag,
                        scale: _starScaleAnimation,
                        favorited: _isFavorited,
                        onFavoritePressed: _toggleFavorite,
                      ),
                    ),

                    // INFORMAÇÕES DO PET
                    Flexible(child: _PetCardInfo(pet: widget.pet)),
                  ],
                );
              },
            ),
          ),
        ),

        // BOTÃO DE EDIÇÃO FLUTUANTE
        if (widget.isMyPublication) _PetCardEditButton(onTap: widget.onEdit),
      ],
    );
  }
}

/// Imagem do pet com a estrela de favorito.
class _PetCardImage extends StatelessWidget {
  const _PetCardImage({
    required this.url,
    required this.heroTag,
    required this.scale,
    required this.favorited,
    required this.onFavoritePressed,
  });

  final String url;
  final String? heroTag;
  final Animation<double> scale;
  final bool favorited;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagem do pet.
        Positioned.fill(
          child: Container(
            color: ThemeColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: WGPetImage(url: url, heroTag: heroTag),
            ),
          ),
        ),

        // Estrela de favorito (canto superior direito).
        Positioned(
          top: 2,
          right: 2,
          child: ScaleTransition(
            scale: scale,
            child: IconButton(
              onPressed: onFavoritePressed,
              tooltip: favorited
                  ? PetDetailsStrings.REMOVE_FROM_FAVORITES
                  : PetDetailsStrings.ADD_TO_FAVORITES,
              icon: Icon(
                favorited ? Icons.star_rounded : Icons.star_border_rounded,
                color: favorited ? ThemeColors.warning : ThemeColors.hint,
                size: 30,
                shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Informações do pet exibidas na parte inferior do card.
class _PetCardInfo extends StatelessWidget {
  const _PetCardInfo({required this.pet});

  final Pet pet;

  // Rótulos formatados exibidos no card.
  String get _formattedPublicationType => pet.publicationType.label;

  Color get _publicationTypeColor => pet.publicationType.color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
      child: MergeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ThemeTextStyles.subtitle.copyWith(fontSize: 16),
            ),
            if (pet.speciesRaceLabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                pet.speciesRaceLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ThemeTextStyles.caption.copyWith(
                  color: ThemeColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 2),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Idade
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cake_outlined,
                      size: 13,
                      color: ThemeColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      pet.ageLabel,
                      style: ThemeTextStyles.body.copyWith(fontSize: 12),
                    ),
                  ],
                ),

                // Gênero (ícone colorido)
                Icon(pet.genderIcon, size: 16, color: pet.genderColor),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _publicationTypeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formattedPublicationType,
                style: ThemeTextStyles.caption.copyWith(
                  color: _publicationTypeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão flutuante de edição, exibido quando o card é uma publicação do usuário.
class _PetCardEditButton extends StatelessWidget {
  const _PetCardEditButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: ThemeColors.primary,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: ThemeColors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
