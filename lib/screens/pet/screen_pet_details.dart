import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/pet/widget_pet_details_info.dart';
import 'package:appets/widgets/pet/widget_pet_gallery.dart';

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
  // Estado de favorito do pet.
  bool _isFavorited = false;

  // Alterna o estado de favorito do pet.
  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  // Exibe aviso de que o compartilhamento está em desenvolvimento.
  void _sharePet() {
    AppSnackBar.show(context, AppStrings.shareInDevelopment);
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
                ? AppStrings.removeFromFavorites
                : AppStrings.addToFavorites,
            icon: Icon(
              _isFavorited
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: ThemeColors.white,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: _sharePet,
            tooltip: AppStrings.shareTooltip,
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
                  AppPetGallery(
                    images: widget.pet.images,
                    heroTag: 'pet-image-${widget.pet.id}',
                  ),

              // INFORMAÇÕES DO PET
              AppPetDetailsInfo(pet: widget.pet),
            ],
          ),
        ),
      ),
    );
  }
}
