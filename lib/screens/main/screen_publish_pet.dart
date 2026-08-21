import 'package:flutter/material.dart';

import 'package:appets/widgets/common/layout/widget_scaffold.dart';
import 'package:appets/widgets/main/widget_page_header.dart';
import 'package:appets/widgets/publish/widget_publish_pet_form.dart';

/// Tela para publicar um novo pet na plataforma.
///
/// Apenas o shell (cabeçalho e rolagem); todos os campos
/// e a lógica ficam em [PublishPetForm].
class PublishPetScreen extends StatelessWidget {
  const PublishPetScreen({
    super.key,
  });

  // UI
  @override
  Widget build(BuildContext context) {
    return AppScaffold(

      child: Column(

        children: [


          // CABEÇALHO
          AppPageHeader.title(
            title: 'Publicar pet',
            description: 'Informe os dados para publicar o pet.',
            showSearchBar: false,
          ),

          // FORMULÁRIO
          Expanded(
            child: PublishPetForm(),
          ),

        ],
      ),
    );
  }
}
