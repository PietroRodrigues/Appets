import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/common/display/widget_display.dart';

/// Card reutilizável para exibir um pet em listas da interface.
///
/// Suporta favoritar com long press (segurar). Ao segurar o card,
/// uma estrela aparece no canto superior direito indicando que
/// o pet foi adicionado aos favoritos.
///
/// Quando [isMyPublication] é `true`, exibe um botão de edição
/// flutuante no canto inferior direito do card.
class AppPetCard extends StatefulWidget {
  const AppPetCard({
    super.key,
    required this.pet,
    this.onTap,
    this.onEdit,
    this.initialIsFavorited = false,
    this.isMyPublication = false,
    this.heroTag,
  });

  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  /// Estado inicial de favorito. Pode ser definido externamente
  /// quando o card é reutilizado em diferentes telas.
  final bool initialIsFavorited;

  /// Indica se este card é uma publicação do usuário atual.
  /// Quando `true`, exibe o botão de edição flutuante.
  final bool isMyPublication;

  /// Tag opcional para a animação Hero da imagem.
  ///
  /// Forneça apenas na origem principal da navegação (aba inicial)
  /// para evitar tags duplicadas com as abas do IndexedStack.
  final String? heroTag;

  @override
  State<AppPetCard> createState() => _AppPetCardState();
}

class _AppPetCardState extends State<AppPetCard>
    with SingleTickerProviderStateMixin {
  // Estado de favorito do card.
  late bool _isFavorited;

  // Controlador da animação da estrela.
  late AnimationController _starController;
  late Animation<double> _starScaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.initialIsFavorited;

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
  }

  // Libera o controlador da animação da estrela.
  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  /// Alterna o estado de favorito com animação, vibração e feedback visual,
  /// persistindo a alteração no Firestore.
  void _toggleFavorite() async {
    setState(() {
      _isFavorited = !_isFavorited;

      if (_isFavorited) {
        _starController.forward();
      } else {
        _starController.reverse();
      }
    });

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _isFavorited
                ? AppStrings.petAddedToFavorites(widget.pet.name)
                : AppStrings.petRemovedFromFavorites(widget.pet.name),
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );

    final authUser = AuthService().currentUser;
    if (authUser == null || widget.pet.id.isEmpty) return;

    final service = FirestoreService();
    try {
      if (_isFavorited) {
        await service.addFavorite(authUser.uid, widget.pet.id);
      } else {
        await service.removeFavorite(authUser.uid, widget.pet.id);
      }
    } catch (_) {
      // Mantém o estado visual; a persistência será reconciliada na próxima carga.
    }
  }

  /// Imagem do pet, com animação Hero quando há [heroTag].
  Widget _buildPetImage() {
    final url = widget.pet.images.isNotEmpty ? widget.pet.images.first : '';

    return AppPetImage(url: url, heroTag: widget.heroTag);
  }

  // Rótulos formatados exibidos no card.
  String get _formattedGender => widget.pet.genderLabel;

  String get _formattedPublicationType => widget.pet.publicationType.label;

  Color get _publicationTypeColor => widget.pet.publicationType.color;

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
                      child: Stack(
                        children: [
                          // Imagem do pet.
                          Positioned.fill(
                            child: Container(
                              color: ThemeColors.surface,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: _buildPetImage(),
                              ),
                            ),
                          ),

                          // Estrela de favorito (canto superior direito).
                          Positioned(
                            top: 2,
                            right: 2,
                            child: ScaleTransition(
                              scale: _starScaleAnimation,
                              child: IconButton(
                                onPressed: _toggleFavorite,
                                tooltip: _isFavorited
                                    ? AppStrings.removeFromFavorites
                                    : AppStrings.addToFavorites,
                                icon: Icon(
                                  _isFavorited
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: _isFavorited
                                      ? ThemeColors.warning
                                      : ThemeColors.hint,
                                  size: 30,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                    // INFORMAÇÕES DO PET
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                        child: MergeSemantics(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pet.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ThemeTextStyles.subtitle.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formattedGender,
                                style: ThemeTextStyles.body.copyWith(
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 13,
                                    color: ThemeColors.secondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      widget.pet.city,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: ThemeTextStyles.body.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _publicationTypeColor.withValues(
                                    alpha: 0.12,
                                  ),
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
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),


        // BOTÃO DE EDIÇÃO FLUTUANTE
        if (widget.isMyPublication)
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: widget.onEdit,
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
          ),
      ],
    );
  }
}
