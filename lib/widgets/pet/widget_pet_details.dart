import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/common/display/widget_display.dart';

/// Galeria de fotos reutilizável do pet.
///
/// Exibe as imagens em um [PageView] com indicadores (dots),
/// contador de fotos e suporte a [Hero] na primeira imagem.
class AppPetGallery extends StatefulWidget {
  const AppPetGallery({
    super.key,
    required this.images,
    this.heroTag,
  });

  // PROPERTIES
  final List<String> images;

  /// Tag do [Hero] aplicada somente à primeira imagem
  /// para evitar tags duplicadas na mesma rota.
  final String? heroTag;

  @override
  State<AppPetGallery> createState() => _AppPetGalleryState();
}

class _AppPetGalleryState extends State<AppPetGallery> {
  // Índice da imagem atualmente exibida na galeria.
  int _currentImage = 0;

  // UI
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: Container(
        color: ThemeColors.surface,
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      // Somente a primeira imagem participa
                      // do Hero para evitar tags duplicadas.
                      return AppPetImage(
                        url: widget.images[index],
                        heroTag: widget.heroTag != null && index == 0
                            ? widget.heroTag
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // INDICADORES (DOTS)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (index) {
                      final isActive = index == _currentImage;
                      return AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        width: isActive ? 12 : 8,
                        height: isActive ? 12 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? ThemeColors.primary
                              : ThemeColors.secondary
                                  .withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // CONTADOR DE FOTOS
            if (widget.images.length > 1)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImage + 1}/${widget.images.length}',
                    style: ThemeTextStyles.caption.copyWith(
                      color: ThemeColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Painel de informações reutilizável da tela de detalhes do pet.
///
/// Exibe nome, dados básicos (idade, gênero, cidade e
/// tipo de publicação), a seção "Sobre" e o botão de contato.
class AppPetDetailsInfo extends StatelessWidget {
  const AppPetDetailsInfo({
    super.key,
    required this.pet,
  });

  // PROPERTIES
  final Pet pet;

  // UI

  /// Botão de contato via WhatsApp.
  Widget _buildContactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: ThemeColors.primary,

          padding: const EdgeInsets.symmetric(vertical: 16),
        ),

        onPressed: () async {
          final owner = await FirestoreService().getUser(pet.ownerId);
          if (owner == null || owner.phone.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.ownerPhoneUnavailable),
                ),
              );
            }
            return;
          }

          final phone = owner.phone.replaceAll(RegExp(r'[^0-9]'), '');
          final message = Uri.encodeComponent(
            AppStrings.whatsAppMessage(pet.name),
          );
          final url = Uri.parse('https://wa.me/55$phone?text=$message');

          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.whatsAppError),
                ),
              );
            }
          }
        },

        child: const Text(
          AppStrings.contactButton,

          style: TextStyle(color: ThemeColors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Nome
          Text(pet.name, style: ThemeTextStyles.heading),

          const SizedBox(height: 20),

          // Informações
          AppInfoRow(
            icon: Icons.cake_outlined,
            text: pet.ageLabel,
          ),

          const SizedBox(height: 14),

          AppInfoRow(
            icon: Icons.pets,
            text: pet.genderLabel,
          ),

          const SizedBox(height: 14),

          AppInfoRow(
            icon: Icons.location_on_outlined,
            text: pet.city,
          ),

          const SizedBox(height: 14),

          // Tipo de publicação
          AppInfoRow(
            icon: pet.publicationType.icon,
            iconColor: pet.publicationType.color,
            text: pet.publicationType.label,
            textStyle: ThemeTextStyles.body.copyWith(
              color: pet.publicationType.color,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 30),

          // Sobre
          Text(AppStrings.aboutSection, style: ThemeTextStyles.subtitle),

          const SizedBox(height: 10),

          Text(
            pet.description ?? AppStrings.descriptionNotInformed,

            style: ThemeTextStyles.body,
          ),

          const SizedBox(height: 40),

          // CONTATO
          _buildContactButton(context),
        ],
      ),
    );
  }
}