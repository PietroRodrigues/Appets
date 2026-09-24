import 'dart:io';
import 'package:appets/core/constants/constants_strings_profile.dart';
import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/utils/offline_guard.dart';
import 'package:appets/core/validators/validators.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/buttons/widget_buttons.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_process.dart';
import 'package:appets/widgets/fields/widget_field_label.dart';
import 'package:appets/widgets/fields/widget_phone_field.dart';
import 'package:appets/widgets/fields/widget_text_field.dart';
import 'package:appets/widgets/publish/widget_attribute_fields.dart';
import 'package:appets/widgets/publish/widget_image_slots_grid.dart';
import 'package:appets/widgets/publish/widget_publication_type_selector.dart';
import 'package:flutter/material.dart';

/// Formulário reutilizável de publicação/edição de pet.
///
/// Contém todos os campos (fotos, tipo, nome, idade,
/// gênero, cidade e descrição), a validação e a
/// confirmação de descarte ao voltar.
///
/// Sem [pet], opera em modo publicação (cria um pet novo). Com [pet],
/// opera em modo edição: pré-preenche os dados e as fotos existentes,
/// permitindo remover, substituir ou adicionar imagens ao salvar.
class WGPublishPetForm extends StatefulWidget {
  const WGPublishPetForm({super.key, this.pet});

  /// Pet em edição. Quando `null`, o formulário está em modo publicação.
  final Pet? pet;

  @override
  State<WGPublishPetForm> createState() => _WGPublishPetFormState();
}

class _WGPublishPetFormState extends State<WGPublishPetForm> {
  // Quantidade máxima de fotos permitidas.
  static const int _maximumImageCount = 3;

  // Controla a validação do formulário de publicação.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Campos do formulário.
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _raceController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  // Controla a navegação de foco entre os campos pelo teclado.
  final FocusNode _raceFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  // Dados da conta do dono (para pré-preencher o contato por herança).
  UserModel? _owner;

  // Estado do formulário de publicação.
  AppPetGender? _selectedGender = AppPetGender.male;
  AppPetSpecies _selectedSpecies = AppPetSpecies.dog;
  int? _selectedAgeValue = 1;
  AppPetAgeUnit _selectedAgeUnit = AppPetAgeUnit.years;
  AppPetPublicationType _selectedPublicationType =
      AppPetPublicationType.adoption;

  // Evita publicações duplicadas enquanto o envio está em andamento.
  bool _isSaving = false;

  // Lista de caminhos das imagens selecionadas.
  List<String> _imagePaths = [];

  /// Indica se o formulário está em modo edição.
  bool get _isEditing => widget.pet != null;

  /// Indica se houve qualquer alteração nos campos desde o carregamento.
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _prefillPet();
    } else {
      _loadOwnerContact();
    }
  }

  /// Pré-preenche os campos com os dados do pet em edição.
  void _prefillPet() {
    final pet = widget.pet!;
    _nameController.text = pet.name;
    _raceController.text = pet.race;
    _phoneController.text = pet.ownerPhone;
    _addressController.text = pet.ownerAddress;
    _descriptionController.text = pet.description ?? '';
    _selectedGender = pet.gender;
    _selectedSpecies = pet.species;
    _selectedAgeValue = pet.age;
    _selectedAgeUnit = pet.ageUnit;
    _selectedPublicationType = pet.publicationType;
    _imagePaths = List<String>.of(pet.images.take(_maximumImageCount));
  }

  // Carrega o contato da conta do dono para pré-preencher os campos.
  Future<void> _loadOwnerContact() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return;

      final owner = await FirestoreService.instance.getUser(user.uid);
      if (!mounted) return;
      setState(() {
        _owner = owner;
      });
      if (owner != null) {
        _phoneController.text = owner.phone;
        _addressController.text = owner.address;
      }
    } catch (_) {
      // Se a busca falhar (ex.: ambiente sem Firebase), os campos
      // permanecem vazios/editáveis e a publicação segue o fluxo normal.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _raceController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();

    _raceFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  // ACTIONS

  /// Exibe confirmação antes de descartar o formulário preenchido.
  Future<bool> _confirmDiscard() async {
    if (!_isDirty) {
      return true;
    }

    final shouldDiscard = await WGDialog.showConfirm(
      context,
      title: PublishStrings.DISCARD_TITLE,
      message: PublishStrings.DISCARD_MESSAGE,
    );

    return shouldDiscard;
  }

  /// Intercepta o botão voltar para confirmar o descarte do formulário.
  Future<void> _onPopInvokedWithResult(bool didPop, Object? result) async {
    if (didPop) return;

    final shouldDiscard = await _confirmDiscard();

    if (shouldDiscard && mounted) {
      Navigator.pop(context);
    }
  }

  /// Atualiza o estado das fotos ao receber alterações da grade de slots.
  void _onImageSlotsChanged(List<String> paths) {
    setState(() {
      _isDirty = true;
      _imagePaths = paths;
    });
  }

  /// Atualiza o tipo de publicação selecionado.
  void _onPublicationTypeChanged(AppPetPublicationType type) {
    _isDirty = true;
    setState(() {
      _selectedPublicationType = type;
    });
  }

  /// Atualiza a idade selecionada a partir dos campos reutilizáveis.
  void _onAgeChanged(int? value, AppPetAgeUnit unit) {
    _isDirty = true;
    setState(() {
      _selectedAgeValue = value;
      _selectedAgeUnit = unit;
    });
  }

  /// Atualiza o gênero selecionado.
  void _onGenderChanged(AppPetGender? gender) {
    _isDirty = true;
    setState(() {
      _selectedGender = gender;
    });
  }

  /// Valida o celular de contato (obrigatório, 11 dígitos, WhatsApp).
  String? _validatePhone(String? value) =>
      AppValidators.validateCellPhone(value);

  /// Monta o pet com os dados atuais do formulário.
  Pet _buildPet(String ownerId) {
    return Pet(
      id: _isEditing ? widget.pet!.id : '',
      ownerId: ownerId,
      name: _nameController.text.trim(),
      race: _raceController.text.trim(),
      species: _selectedSpecies,
      age: _selectedAgeValue ?? 1,
      ageUnit: _selectedAgeUnit,
      gender: _selectedGender ?? AppPetGender.male,
      address: _addressController.text.trim(),
      ownerPhone: _phoneController.text.trim(),
      ownerAddress: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      publicationType: _selectedPublicationType,
      images: _isEditing ? widget.pet!.images : [],
    );
  }

  /// Indica se o valor é uma URL remota (foto já existente) ou um
  /// caminho local (foto recém selecionada).
  bool _isNetworkUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

/// Aplica as alterações de fotos de um pet em edição, devolvendo a lista
/// final de URLs na ordem da grade.
///
/// Somente faz os UPLOADS das fotos novas: **nada é apagado aqui**. As
/// remoções ficam em [removedUrls] para serem apagadas APÓS o commit no
/// Firestore (feito pelo chamador), evitando URLs quebradas se o salvar
/// falhar. Fotos mantidas permanecem como estão; novas sobem com índice
/// após as atuais (evita colisão de nomes mesmo depois de remoções).
///
/// Se um upload novo falhar no meio, as fotos já enviadas são apagadas
/// (rollback) e a exceção segue para o chamador.
Future<({List<String> finalImages, List<String> uploadedUrls, List<String> removedUrls})>
    _applyPhotoChanges(String ownerId, String petId) async {
  final originalUrls = widget.pet!.images;
  final keptUrls = <String>[];
  final newPaths = <String>[];

  for (final entry in _imagePaths) {
    if (_isNetworkUrl(entry)) {
      keptUrls.add(entry);
    } else {
      newPaths.add(entry);
    }
  }

  final removedUrls =
      originalUrls.where((url) => !keptUrls.contains(url)).toList();

  // Novas fotos sobem após os índices atuais (nunca colidem com os
  // arquivos existentes, mesmo que a ordem tenha mudado).
  final finalImages = <String>[];
  final uploadedUrls = <String>[];
  int nextIndex = originalUrls.length;
  try {
    for (final entry in _imagePaths) {
      if (_isNetworkUrl(entry)) {
        finalImages.add(entry);
      } else {
        final url = await StorageService.instance.uploadPetImage(
          ownerId,
          petId,
          nextIndex,
          File(entry),
        );
        nextIndex++;
        uploadedUrls.add(url);
        finalImages.add(url);
      }
    }
  } on Exception {
    // Desfaz os uploads que já aconteceram antes da falha, para não
    // deixar fotos órfãs no Storage.
    try {
      if (uploadedUrls.isNotEmpty) {
        await StorageService.instance.deletePetImagesByUrls(uploadedUrls);
      }
    } catch (_) {
      // Melhor esforço: o erro original segue, o lixo pode ser removido
      // depois.
    }
    rethrow;
  }

  return (
    finalImages: finalImages,
    uploadedUrls: uploadedUrls,
    removedUrls: removedUrls,
  );
}

  /// Salva o pet: publica um novo (sem [pet]) ou atualiza os dados e as
  /// fotos do existente (com [pet]).
  void _savePet() async {
    if (_isSaving) return;

    final user = AuthService.instance.currentUser;
    if (user == null) return;

    // Acende os erros inline dos campos antes de checar as barreiras.
    _formKey.currentState?.validate();

    // Barreira única: junta as pendências dos campos obrigatórios (nome,
    // telefone e endereço) com a foto faltando num só aviso.
    final problems = _missingRequiredFields();
    if (_imagePaths.isEmpty) {
      problems.add(PublishStrings.PHOTO_REQUIRED_HINT);
    }
    if (problems.isNotEmpty) {
      await WGDialog.showAction(
        context,
        title: PublishStrings.INCOMPLETE_FORM_TITLE,
        message: problems.map((p) => '• $p').join('\n'),
      );
      return;
    }

    // Descrição vazia: pergunta se o usuário quer continuar mesmo assim.
    if (_descriptionController.text.trim().isEmpty) {
      final shouldContinue = await WGDialog.showConfirm(
        context,
        title: PublishStrings.EMPTY_DESCRIPTION_TITLE,
        message: PublishStrings.EMPTY_DESCRIPTION_MESSAGE,
        confirmLabel: PublishStrings.CONTINUE_BUTTON,
        cancelLabel: PublishStrings.FILL_BUTTON,
        confirmColor: ThemeColors.primary,
      );
      if (!shouldContinue) {
        if (mounted) _descriptionFocusNode.requestFocus();
        return;
      }
    }

    if (!mounted) return;

    // Sem rede não há como publicar: avisa e aborta antes de travar na
    // tela de carregamento (que ficaria presa esperando a rede).
    if (!await ensureOnline(context)) {
      return;
    }
    if (!mounted) return;

    _isSaving = true;
    FocusManager.instance.primaryFocus?.unfocus();

    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final pet = _buildPet(user.uid);

    final result = await Navigator.push<WGProcessResult>(
      context,
      MaterialPageRoute<WGProcessResult>(
        builder: (_) => WGProcessLoadingScreen(
          message: _isEditing
              ? PublishStrings.SAVE_LOADING
              : PublishStrings.PUBLISH_LOADING,
          task: () async {
            try {
              final String petId;
              if (_isEditing) {
                // Atualiza dados e fotos (mantidas/removidas/novas).
                petId = pet.id;
                final photos = await _applyPhotoChanges(user.uid, petId);
                try {
                  await PetService.instance.updatePet(petId, {
                    ...pet.toUpdateMap(),
                    'images': photos.finalImages,
                  });
                } on Exception {
                  // Commit falhou: devolve os uploads novos já feitos. As
                  // fotos removidas NÃO foram apagadas ainda, então o
                  // Firestore segue apontando para arquivos válidos (sem
                  // URLs quebradas).
                  try {
                    if (photos.uploadedUrls.isNotEmpty) {
                      await StorageService.instance
                          .deletePetImagesByUrls(photos.uploadedUrls);
                    }
                  } catch (_) {
                    // Melhor esforço: o erro do commit segue, o lixo pode
                    // ser removido depois.
                  }
                  rethrow;
                }
                // Commit ok: só agora apaga as fotos removidas (melhor
                // esforço — se falhar sobra lixo, mas nada quebrado).
                if (photos.removedUrls.isNotEmpty) {
                  try {
                    await StorageService.instance
                        .deletePetImagesByUrls(photos.removedUrls);
                  } catch (_) {
                    // Melhor esforço.
                  }
                }
              } else {
                // 1. Criar pet no Firestore
                petId = await PetService.instance.createPet(pet);

                // 2. Upload das imagens (se houver). Se o Storage falhar
                //    (ex.: ainda não configurado no Firebase), desfaz a
                //    publicação criada para não deixar um pet órfão sem fotos.
                if (_imagePaths.isNotEmpty) {
                  final imageUrls = <String>[];
                  try {
                    for (int i = 0; i < _imagePaths.length; i++) {
                      final url = await StorageService.instance.uploadPetImage(
                        user.uid,
                        petId,
                        i,
                        File(_imagePaths[i]),
                      );
                      imageUrls.add(url);
                    }
                    await PetService.instance.updatePet(petId, {
                      'images': imageUrls,
                    });
                  } on Exception catch (error, stackTrace) {
                    try {
                      // Desfaz também os uploads que já aconteceram antes
                      // da falha, para não deixar fotos órfãs no Storage.
                      if (imageUrls.isNotEmpty) {
                        await StorageService.instance
                            .deletePetImagesByUrls(imageUrls);
                      }
                      await PetService.instance.deletePet(petId);
                    } catch (_) {
                      // Melhor esforço: se o rollback falhar, o usuário é
                      // informado do erro e o pet pode ser removido depois.
                    }
                    return WGProcessResult.failure(
                      PublishStrings.PUBLISH_PHOTOS_ERROR,
                      cause: error,
                      stackTrace: stackTrace,
                    );
                  }
                }

                // 3. Só notifica a "Minhas Publicações" depois de as fotos
                //    estarem anexadas ao pet, para o grid já recarregar o
                //    card com as imagens (sem precisar de pull-to-refresh).
                await MyPublicationsService.instance.add(user.uid, petId);
              }

              return const WGProcessResult.success();
            } on Exception catch (error, stackTrace) {
              return WGProcessResult.failure(
                _isEditing
                    ? PublishStrings.SAVE_ERROR
                    : PublishStrings.PUBLISH_ERROR,
                cause: error,
                stackTrace: stackTrace,
              );
            }
          },
        ),
      ),
    );
    if (!mounted) return;

    switch (result?.status) {
      case WGProcessStatus.success:
        if (mounted) {
          await WGDialog.showAction(
            context,
            title: SharedStrings.SUCCESS_TITLE,
            message: _isEditing
                ? PublishStrings.PET_UPDATED
                : PublishStrings.PET_PUBLISHED,
          );
        }
        if (_isEditing) {
          if (mounted) Navigator.pop(context, true);
          return;
        }
        // D1: contato alterado em relação à conta -> perguntar se atualiza tudo.
        if (mounted && _contactChanged(phone, address)) {
          final shouldUpdate = await _confirmUpdateAllPublications();
          if (shouldUpdate && mounted) {
            await _updateAllPublications(user.uid, phone, address);
          }
        }
        if (mounted) Navigator.pop(context, true);
      case WGProcessStatus.failure:
        if (mounted) {
          await WGDialog.showAction(
            context,
            title: SharedStrings.ERROR_TITLE,
            message: result!.userFacingMessage,
            actionColor: ThemeColors.error,
          );
        }
      case WGProcessStatus.canceled:
      case null:
        break;
    }

    _isSaving = false;
  }

  // Lista as pendências dos campos obrigatórios (nome, telefone e
  // endereço). Vazia quando todos estão corretos.
  List<String> _missingRequiredFields() {
    final problems = <String>[];

    if ((_nameController.text.trim().length) < 2) {
      problems.add(PublishStrings.PET_NAME_REQUIRED);
    }

    final phoneError = AppValidators.validateCellPhone(_phoneController.text);
    if (phoneError != null) {
      problems.add(phoneError);
    }

    if (_addressController.text.trim().isEmpty) {
      problems.add(PublishStrings.ADDRESS_REQUIRED);
    }

    return problems;
  }

  // Indica se os campos obrigatórios (à exceção das fotos) estão ok.
  bool get _requiredFieldsFilled {
    if ((_nameController.text.trim().length) < 2) return false;
    if (AppValidators.validateCellPhone(_phoneController.text) != null) {
      return false;
    }
    if (_addressController.text.trim().isEmpty) return false;
    return true;
  }

  // Indica se o formulário está completo para publicar/editar — isso
  // inclui a exigência de pelo menos 1 foto. Usado apenas para a cor do
  // botão; os erros de campo só aparecem ao salvar.
  bool get _isFormComplete =>
      _imagePaths.isNotEmpty && _requiredFieldsFilled;

  // Recalcula o estado para atualizar a cor do botão ao digitar.
  void _onFieldChanged(String _) {
    _isDirty = true;
    setState(() {});
  }

  // Compara o contato informado com o da conta.
  bool _contactChanged(String phone, String address) {
    final ownerPhone = _owner?.phone ?? '';
    final ownerAddress = _owner?.address ?? '';
    return phone != ownerPhone || address != ownerAddress;
  }

  /// Abre o diálogo Sim/Não para atualizar todas as publicações.
  Future<bool> _confirmUpdateAllPublications() {
    return WGDialog.showConfirm(
      context,
      title: PublishStrings.UPDATE_ALL_PUBLICATIONS_TITLE,
      message: PublishStrings.UPDATE_ALL_PUBLICATIONS_MESSAGE,
    );
  }

  // Atualiza a conta e todas as publicações do dono com o novo contato.
  Future<void> _updateAllPublications(
    String uid,
    String phone,
    String address,
  ) async {
    try {
      if (_owner != null) {
        await FirestoreService.instance.updateUser(uid, {
          'phone': phone,
          'address': address,
        });
      }
      final myPets = await PetService.instance.getPetsByOwner(uid);
      for (final pet in myPets) {
        await PetService.instance.updatePet(pet.id, {
          'ownerPhone': phone,
          'ownerAddress': address,
        });
      }
    } catch (_) {
      // Falha silenciosa: a publicação atual já foi gravada corretamente.
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,

      child: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // FOTOS
              WGImageSlotsGrid(
                title: PublishStrings.PHOTOS_TITLE,
                description: PublishStrings.photosGridDescription(
                  _maximumImageCount,
                ),
                initialImageUrls: (widget.pet?.images ?? const [])
                  .take(_maximumImageCount)
                  .toList(),
                maxImages: _maximumImageCount,
                onChanged: _onImageSlotsChanged,
              ),

              const SizedBox(height: 28),

              // TIPO DE PUBLICAÇÃO
              WGFieldLabel(text: PublishStrings.PUBLICATION_TYPE),

              WGPublicationTypeSelector(
                selectedType: _selectedPublicationType,
                onChanged: _onPublicationTypeChanged,
              ),

              const SizedBox(height: 20),

              // NOME
              WGFieldLabel(text: PublishStrings.PET_NAME_LABEL),

              WGTextField(
                controller: _nameController,

                hintText: PublishStrings.PET_NAME_HINT,

                textInputAction: TextInputAction.next,

                onChanged: _onFieldChanged,

                onFieldSubmitted: (_) {
                  _raceFocusNode.requestFocus();
                },

                validator: (value) {
                  if ((value?.trim().length ?? 0) < 2) {
                    return PublishStrings.PET_NAME_REQUIRED;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ESPÉCIE
              WGFieldLabel(text: PublishStrings.SPECIES_LABEL),

              DropdownButtonFormField<AppPetSpecies>(
                initialValue: _selectedSpecies,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: ThemeColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isDirty = true;
                    _selectedSpecies = value ?? AppPetSpecies.dog;
                  });
                },
                items: AppPetSpecies.values
                    .map(
                      (species) => DropdownMenuItem(
                        value: species,
                        child: Text(species.label),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 20),

              // RAÇA (opcional)
              WGFieldLabel(text: PublishStrings.PET_RACE_LABEL),

              WGTextField(
                controller: _raceController,
                hintText: PublishStrings.PET_RACE_HINT,
                textInputAction: TextInputAction.next,
                focusNode: _raceFocusNode,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _phoneFocusNode.requestFocus();
                },
              ),

              const SizedBox(height: 20),

              // IDADE
              WGFieldLabel(text: PublishStrings.AGE),

              WGAgeFields(
                initialValue: _selectedAgeValue,
                initialUnit: _selectedAgeUnit,
                onChanged: _onAgeChanged,
              ),

              const SizedBox(height: 20),

              // GÊNERO
              WGFieldLabel(text: PublishStrings.GENDER),

              WGGenderFields(
                groupValue: _selectedGender,
                onChanged: _onGenderChanged,
              ),

              // TELEFONE DE CONTATO (herdado da conta, editável)
              WGFieldLabel(text: PublishStrings.CONTACT_OWNER_LABEL),

              WGPhoneField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                hintText: PublishStrings.CONTACT_OWNER_HINT,
                textInputAction: TextInputAction.next,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _addressFocusNode.requestFocus();
                },
                validator: _validatePhone,
              ),

              const SizedBox(height: 20),

              // ENDEREÇO (herdado da conta, editável)
              WGFieldLabel(text: ProfileStrings.ADDRESS_LABEL),

              WGTextField(
                controller: _addressController,
                hintText: PublishStrings.ADDRESS_HINT,
                textInputAction: TextInputAction.next,
                focusNode: _addressFocusNode,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _descriptionFocusNode.requestFocus();
                },
                validator: (value) {
                  if ((value?.trim().isEmpty ?? true)) {
                    return PublishStrings.ADDRESS_REQUIRED;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // DESCRIÇÃO (opcional)
              WGFieldLabel(text: PublishStrings.ABOUT_PET),

              WGTextField(
                controller: _descriptionController,
                hintText: PublishStrings.ABOUT_PET_HINT,
                maxLines: 6,
                textInputAction: TextInputAction.done,
                focusNode: _descriptionFocusNode,
                onChanged: _onFieldChanged,
                onFieldSubmitted: (_) {
                  _descriptionFocusNode.unfocus();
                  _savePet();
                },
              ),

              const SizedBox(height: 32),

              // SALVAR / PUBLICAR
              WGButton(
                text: _isEditing
                    ? PublishStrings.SAVE_BUTTON
                    : PublishStrings.PUBLISH_BUTTON,

                onPressed: _savePet,

                backgroundColor: _isFormComplete
                    ? ThemeColors.success
                    : ThemeColors.disabled,
              ),

              // Dica da barreira de fotos: só aparece quando a foto é o
              // único requisito faltando.
              if (_requiredFieldsFilled && _imagePaths.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  PublishStrings.PHOTO_REQUIRED_HINT,
                  style: ThemeTextStyles.caption.copyWith(
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
