import 'package:flutter/material.dart';

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
  /// (`true` = preenchido, `false` = vazio).
  final ValueChanged<List<bool>>? onChanged;

  @override
  State<AppImageSlotsGrid> createState() => _AppImageSlotsGridState();
}

class _AppImageSlotsGridState extends State<AppImageSlotsGrid> {
  // Estado visual temporário para o fluxo de inclusão de fotos.
  //
  // Cada posição da lista representa um slot de imagem.
  // A lista sempre começa com pelo menos 1 slot visível.
  final List<bool> _imageSlots = [false];

  // ACTIONS

  /// Quantidade de slots visíveis (mínimo 1, máximo [widget.maxImages]).
  int get _visibleImageSlots {
    // Encontra o último slot preenchido.
    int lastFilled = -1;
    for (int i = _imageSlots.length - 1; i >= 0; i--) {
      if (_imageSlots[i]) {
        lastFilled = i;
        break;
      }
    }

    // Se há slot preenchido, mostra até o próximo vazio (ou no máximo N).
    if (lastFilled >= 0) {
      final needed = lastFilled + 2;
      return needed > widget.maxImages ? widget.maxImages : needed;
    }

    // Nenhum preenchido: mostra apenas 1 slot.
    return 1;
  }

  /// Adiciona a imagem no [index], expandindo a lista se necessário.
  void _addImage(int index) { // Em desenvolvimento.
    setState(() {
      while (_imageSlots.length <= index) {
        _imageSlots.add(false);
      }

      _imageSlots[index] = true;

      // Garante que há pelo menos um slot vazio depois do último preenchido.
      if (_imageSlots.length < widget.maxImages &&
          _imageSlots.length <= index + 1) {
        _imageSlots.add(false);
      }
    });

    _notifyChanged();
  }

  /// Remove a imagem do [index] e desloca as imagens seguintes
  /// para a esquerda, mantendo ao menos 1 slot vazio visível.
  void _removeImage(int index) { // Em desenvolvimento.
    setState(() {
      if (index < 0 || index >= _imageSlots.length) return;

      _imageSlots.removeAt(index);

      // Garante pelo menos 1 slot vazio no final.
      if (_imageSlots.isEmpty || _imageSlots.last) {
        if (_imageSlots.length < widget.maxImages) {
          _imageSlots.add(false);
        }
      }
    });

    _notifyChanged();
  }

  /// Exibe confirmação antes de remover a foto do [index].
  Future<void> _confirmImageRemoval(int index) async { // Em desenvolvimento.
    final shouldRemove = await AppConfirmDialog.show(
      context,
      title: 'Remover foto?',
      message: 'Deseja remover esta foto da publicação?',
      confirmLabel: 'Sim, remover',
    );

    if (shouldRemove && mounted) {
      _removeImage(index);
    }
  }

  /// Notifica o pai sobre o estado atual dos slots.
  void _notifyChanged() {
    widget.onChanged?.call(List<bool>.of(_imageSlots));
  }

  // UI
  Widget _buildSlot(int index) { // Em desenvolvimento.
    final isMainImage = index == 0;
    final hasImage = index < _imageSlots.length && _imageSlots[index];
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
            : () => _addImage(index), // Em desenvolvimento.
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor,
              width: isMainImage && !hasImage ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                // Futuramente, uma miniatura da foto substituirá este ícone.
                hasImage ? Icons.check_circle_outline : Icons.add_a_photo_outlined,
                color: hasImage
                    ? ThemeColors.success
                    : isMainImage
                        ? ThemeColors.primary
                        : ThemeColors.hint,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                hasImage
                    ? 'Foto ${index + 1} adicionada'
                    : isMainImage
                        ? 'Foto principal *'
                        : 'Adicionar foto ${index + 1}',
                textAlign: TextAlign.center,
                style: ThemeTextStyles.caption.copyWith(
                  color: hasImage
                      ? ThemeColors.success
                      : isMainImage
                          ? ThemeColors.primary
                          : ThemeColors.textSecondary,
                  fontWeight: isMainImage ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
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
          itemBuilder: (context, index) => _buildSlot(index), // Em desenvolvimento.
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
