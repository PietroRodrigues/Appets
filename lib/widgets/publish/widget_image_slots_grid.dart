import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/common/feedback/widget_confirm_dialog.dart';

/// Grade de slots para seleção de fotos do pet.
///
/// Cada slot representa uma posição de imagem:
/// vazio permite adicionar; preenchido exibe confirmação
/// antes de remover, deslocando as seguintes para a esquerda.
///
/// Regras dos slots visíveis:
/// - Sempre há pelo menos 1 slot visível.
/// - Ao adicionar, o próximo slot vazio é exibido.
/// - Quando todos os [maxImages] slots estão preenchidos,
///   nenhum vazio extra aparece.
///
/// Notifica o pai a cada alteração através de [onChanged].
class AppImageSlotsGrid extends StatefulWidget {
  const AppImageSlotsGrid({
    super.key,
    this.title,
    this.description,
    this.maxImages = 5,
    this.onChanged,
  });

  // PROPERTIES

  /// Título opcional exibido acima da grade.
  final String? title;

  /// Descrição opcional exibida abaixo do título.
  final String? description;

  /// Quantidade máxima de fotos permitida.
  final int maxImages;

  /// Notifica as alterações nos slots
  /// (caminhos das imagens selecionadas).
  final ValueChanged<List<String>>? onChanged;

  @override
  State<AppImageSlotsGrid> createState() => _AppImageSlotsGridState();
}

class _AppImageSlotsGridState extends State<AppImageSlotsGrid> {
  // Lista de caminhos das imagens selecionadas.
  final List<String> _imagePaths = [];

  // Controlador do image_picker.
  final ImagePicker _picker = ImagePicker();

  // ACTIONS

  /// Quantidade de slots visíveis (mínimo 1, máximo [widget.maxImages]).
  int get _visibleImageSlots {
    if (_imagePaths.isNotEmpty) {
      final needed = _imagePaths.length + 1;
      return needed > widget.maxImages ? widget.maxImages : needed;
    }

    return 1;
  }

  /// Abre o seletor de imagem (galeria) e adiciona no [index].
  Future<void> _addImage(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && mounted) {
      setState(() {
        if (index < _imagePaths.length) {
          _imagePaths[index] = image.path;
        } else {
          _imagePaths.add(image.path);
        }
      });

      _notifyChanged();
    }
  }

  /// Remove a imagem do [index] e desloca as imagens seguintes
  /// para a esquerda, mantendo ao menos 1 slot vazio visível.
  void _removeImage(int index) {
    setState(() {
      if (index < 0 || index >= _imagePaths.length) return;

      _imagePaths.removeAt(index);
    });

    _notifyChanged();
  }

  /// Exibe confirmação antes de remover a foto do [index].
  Future<void> _confirmImageRemoval(int index) async {
    final shouldRemove = await AppConfirmDialog.show(
      context,
      title: AppStrings.photoRemoveTitle,
      message: AppStrings.photoRemoveMessage,
      confirmLabel: AppStrings.photoRemoveConfirm,
    );

    if (shouldRemove && mounted) {
      _removeImage(index);
    }
  }

  /// Notifica o pai sobre o estado atual dos slots.
  void _notifyChanged() {
    widget.onChanged?.call(List<String>.of(_imagePaths));
  }

  // UI
  Widget _buildSlot(int index) {
    final isMainImage = index == 0;
    final hasImage = index < _imagePaths.length;
    final accentColor = hasImage
        ? ThemeColors.success
        : isMainImage
            ? ThemeColors.primary
            : ThemeColors.border;

    return Material(
      color: ThemeColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: hasImage
            ? () => _confirmImageRemoval(index)
            : () => _addImage(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor,
              width: isMainImage && !hasImage ? 2 : 1,
            ),
          ),
          child: hasImage
              ? _buildImagePreview(index, isMainImage)
              : _buildPlaceholder(isMainImage, index),
        ),
      ),
    );
  }

  /// Miniatura da imagem selecionada.
  Widget _buildImagePreview(int index, bool isMainImage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(_imagePaths[index]),
            fit: BoxFit.cover,
          ),
          if (isMainImage)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: ThemeColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  AppStrings.mainPhotoBadge,
                  style: TextStyle(
                    color: ThemeColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _confirmImageRemoval(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: ThemeColors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder vazio com ícone e texto.
  Widget _buildPlaceholder(bool isMainImage, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          color: isMainImage ? ThemeColors.primary : ThemeColors.hint,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          isMainImage
              ? AppStrings.mainPhotoSlot
              : AppStrings.photoSlotLabel(index + 1),
          textAlign: TextAlign.center,
          style: ThemeTextStyles.caption.copyWith(
            color: isMainImage
                ? ThemeColors.primary
                : ThemeColors.textSecondary,
            fontWeight: isMainImage ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // UI

  /// Grade de slots.
  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 360 ? 2 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _visibleImageSlots,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) => _buildSlot(index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.title == null && widget.description == null) {
      return _buildGrid();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TÍTULO
        if (widget.title != null)
          Text(
            widget.title!,
            style: ThemeTextStyles.subtitle,
          ),

        // DESCRIÇÃO
        if (widget.description != null) ...[
          SizedBox(height: widget.title != null ? 4 : 0),
          Text(
            widget.description!,
            style: ThemeTextStyles.caption,
          ),
        ],

        const SizedBox(height: 12),

        _buildGrid(),
      ],
    );
  }
}
