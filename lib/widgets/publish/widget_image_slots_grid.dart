import 'dart:io';
import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/core/services/image_compressor.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
/// Os slots podem conter tanto URLs remotas (fotos já existentes,
/// exibidas em modo edição) quanto caminhos locais (fotos recém
/// selecionadas da galeria).
///
/// Notifica o pai a cada alteração através de [onChanged].
class WGImageSlotsGrid extends StatefulWidget {
  const WGImageSlotsGrid({
    super.key,
    this.title,
    this.description,
    this.initialImageUrls = const [],
    this.maxImages = 3,
    this.onChanged,
  });

  // PROPERTIES

  /// Título opcional exibido acima da grade.
  final String? title;

  /// Descrição opcional exibida abaixo do título.
  final String? description;

  /// URLs das fotos já existentes (modo edição), carregadas nos slots
  /// no momento da criação da grade.
  final List<String> initialImageUrls;

  /// Quantidade máxima de fotos permitida.
  final int maxImages;

  /// Notifica as alterações nos slots
  /// (URLs das imagens existentes ou caminhos das recém selecionadas).
  final ValueChanged<List<String>>? onChanged;

  @override
  State<WGImageSlotsGrid> createState() => _WGImageSlotsGridState();
}

class _WGImageSlotsGridState extends State<WGImageSlotsGrid> {
  // Lista de caminhos/URLs das imagens exibidas nos slots.
  late final List<String> _imagePaths;

  // Controlador do image_picker.
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePaths = List<String>.of(widget.initialImageUrls);
  }

  // Indica se o slot contém uma URL remota (foto já existente) em vez de
  // um caminho local de arquivo (foto recém selecionada).
  bool _isNetworkUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

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
    final XFile? image;
    try {
      image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: ImageCompressor.maxDimension.toDouble(),
        maxHeight: ImageCompressor.maxDimension.toDouble(),
      );
    } on Exception {
      // Permissão negada ou erro da plataforma: avisa em vez de deixar a
      // exceção escapar sem tratamento.
      if (!mounted) return;
      await WGDialog.showAction(
        context,
        title: PublishStrings.PICK_PHOTO_ERROR_TITLE,
        message: PublishStrings.PICK_PHOTO_ERROR_MESSAGE,
      );
      return;
    }

    if (image == null || !mounted) return;

    // Bloqueia imagens muito grandes (limite do Storage) antes de comprimir.
    final maxBytes = PublishStrings.IMAGE_TOO_LARGE_MAX_MB * 1024 * 1024;
    if (await image.length() > maxBytes) {
      if (!mounted) return;
      await WGDialog.showAction(
        context,
        title: PublishStrings.PHOTO_TOO_LARGE_TITLE,
        message: PublishStrings.photoTooLargeMessage(),
      );
      return;
    }

    // Comprime (webp) antes de adicionar ao slot; mantém o original
    // se a compressão não compensar ou falhar.
    final File? compressed =
        await ImageCompressor.compressForUpload(image.path);
    final String imagePath = (compressed ?? File(image.path)).path;

    if (mounted) {
      setState(() {
        if (index < _imagePaths.length) {
          _imagePaths[index] = imagePath;
        } else {
          _imagePaths.add(imagePath);
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
    final shouldRemove = await WGDialog.showConfirm(
      context,
      title: PublishStrings.PHOTO_REMOVE_TITLE,
      message: PublishStrings.PHOTO_REMOVE_MESSAGE,
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

  /// Miniatura da imagem do slot (URL remota ou arquivo local).
  Widget _buildImagePreview(int index, bool isMainImage) {
    final value = _imagePaths[index];

    final Widget image = _isNetworkUrl(value)
        ? CachedNetworkImage(
            imageUrl: value,
            cacheManager: AppImageCache.instance.manager,
            memCacheWidth: 480,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) =>
                _buildMissingImage(ThemeColors.border),
            placeholder: (_, _) => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeColors.primary,
                ),
              ),
            ),
          )
        : Image.file(
            File(value),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                _buildMissingImage(ThemeColors.border),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (isMainImage)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  PublishStrings.MAIN_PHOTO_BADGE,
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

  /// Placeholder exibido quando uma imagem não consegue carregar.
  Widget _buildMissingImage(Color color) {
    return ColoredBox(
      color: ThemeColors.surface,
      child: Icon(Icons.pets, size: 32, color: color),
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
              ? PublishStrings.MAIN_PHOTO_SLOT
              : PublishStrings.photoSlotLabel(index + 1),
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
          Text(widget.title!, style: ThemeTextStyles.subtitle),

        // DESCRIÇÃO
        if (widget.description != null) ...[
          SizedBox(height: widget.title != null ? 4 : 0),
          Text(widget.description!, style: ThemeTextStyles.caption),
        ],

        const SizedBox(height: 12),

        _buildGrid(),
      ],
    );
  }
}
