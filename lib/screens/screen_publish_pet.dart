import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:appets/widgets/publish/widget_publish_pet_form.dart';
import 'package:flutter/material.dart';

/// Tela para publicar um novo pet ou editar um pet já publicado.
///
/// Com [pet] nulo, publica um novo pet; com [pet] informado, edita os
/// dados do pet existente (as fotos não mudam). Apenas o shell (cabeçalho
/// e rolagem); todos os campos e a lógica ficam em [WGPublishPetForm].
class PublishPetScreen extends StatelessWidget {
  const PublishPetScreen({super.key, this.pet});

  /// Pet em edição; quando nulo, a tela publica um pet novo.
  final Pet? pet;

  // UI
  @override
  Widget build(BuildContext context) {
    final isEditing = pet != null;

    return WGScaffold(
      child: Column(
        children: [
          // CABEÇALHO
          WGPageHeader.title(
            title: isEditing ? HomeStrings.EDIT_PET : HomeStrings.PUBLISH_PET,
            description: isEditing
                ? PublishStrings.EDIT_PET_DESCRIPTION
                : PublishStrings.PUBLISH_PET_DESCRIPTION,
            showSearchBar: false,
          ),

          // FORMULÁRIO
          Expanded(child: WGPublishPetForm(pet: pet)),
        ],
      ),
    );
  }
}