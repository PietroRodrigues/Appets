import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/common/display/widget_info_row.dart';

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
