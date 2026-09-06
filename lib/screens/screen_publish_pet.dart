import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:appets/widgets/publish/widget_publish_pet_form.dart';
import 'package:flutter/material.dart';

/// Tela para publicar um novo pet na plataforma.
///
/// Apenas o shell (cabeçalho e rolagem); todos os campos
/// e a lógica ficam em [WGPublishPetForm].
class PublishPetScreen extends StatelessWidget {
  const PublishPetScreen({super.key});

  // UI
  @override
  Widget build(BuildContext context) {
    return WGScaffold(
      child: Column(
        children: [
          // CABEÇALHO
          WGPageHeader.title(
            title: HomeStrings.PUBLISH_PET,
            description: PublishStrings.PUBLISH_PET_DESCRIPTION,
            showSearchBar: false,
          ),

          // FORMULÁRIO
          Expanded(child: WGPublishPetForm()),
        ],
      ),
    );
  }
}
