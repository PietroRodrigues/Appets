import 'dart:math' as math;

import 'package:appets/core/constants/constants_strings_block.dart';
import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/constants/constants_strings_report.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/block_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/report_service.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/utils/offline_guard.dart';
import 'package:appets/core/utils/whatsapp_launcher.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_snackbar.dart';
import 'package:appets/widgets/feedback/widget_report_dialog.dart';
import 'package:appets/widgets/pet/widget_pet_gallery.dart';
import 'package:appets/widgets/pet/widget_pet_full_screen_gallery.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Tela de detalhes com imagens e informações do pet selecionado.
class PetDetailsScreen extends StatefulWidget {
  const PetDetailsScreen({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  bool get _isFavorited => FavoritesService.instance.isFavorite(widget.pet.id);

  String? _ownerName;
  String? _ownerPhotoUrl;
  bool _isLoadingOwner = true;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.favoriteIds.addListener(_onFavoritesChanged);
    _loadOwnerData();
    _initBlockState();
  }

  @override
  void dispose() {
    FavoritesService.instance.favoriteIds.removeListener(_onFavoritesChanged);
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser != null &&
          widget.pet.ownerId.isNotEmpty &&
          widget.pet.ownerId != authUser.uid) {
        BlockService.instance.blockedIds.removeListener(_onBlockedIdsChanged);
      }
    } catch (_) {
      // Sem Firebase inicializado (ex.: testes): nada a remover.
    }
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadOwnerData() async {
    if (widget.pet.ownerId.isEmpty) {
      setState(() => _isLoadingOwner = false);
      return;
    }

    try {
      final user = await FirestoreService.instance.getUser(widget.pet.ownerId);
      if (mounted) {
        setState(() {
          _ownerName = user?.name;
          _ownerPhotoUrl = user?.photoUrl;
          _isLoadingOwner = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingOwner = false);
    }
  }

  void _onBlockedIdsChanged() {
    if (!mounted) return;
    final blocked = BlockService.instance.isBlocked(widget.pet.ownerId);
    if (blocked != _isBlocked) {
      setState(() => _isBlocked = blocked);
    }
  }

  Future<void> _initBlockState() async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null ||
          widget.pet.ownerId.isEmpty ||
          widget.pet.ownerId == authUser.uid) {
        return;
      }

      await BlockService.instance.init(authUser.uid).catchError((_) {});
      if (!mounted) return;
      _isBlocked = BlockService.instance.isBlocked(widget.pet.ownerId);
      BlockService.instance.blockedIds.addListener(_onBlockedIdsChanged);
      if (mounted) setState(() {});
    } catch (_) {
      // Sem Firebase inicializado (ex.: testes) ou falha de auth:
      // o botão de bloqueio simplesmente não aparece.
    }
  }

  Future<void> _toggleFavorite() async {
    final authUser = AuthService.instance.currentUser;
    if (authUser == null || widget.pet.id.isEmpty) return;
    if (_isBlocked) return;

    if (!await ensureOnline(context)) return;

    final service = FavoritesService.instance;
    final wasFavorited = _isFavorited;

    final ok = wasFavorited
        ? await service.remove(authUser.uid, widget.pet.id)
        : await service.add(authUser.uid, widget.pet.id);

    if (!ok && mounted) {
      WGSnackBar.showError(context, PetDetailsStrings.FAVORITE_ERROR);
    }
  }

  Future<void> _sharePet() async {
    try {
      await SharePlus.instance.share(ShareParams(text: widget.pet.shareText));
    } catch (_) {
      if (!mounted) return;
      WGDialog.showAction(
        context,
        title: SharedStrings.ERROR_TITLE,
        message: PetDetailsStrings.SHARE_ERROR,
        actionColor: context.appColors.error,
      );
    }
  }

  /// Solicita o motivo e envia uma denúncia para este anúncio.
  Future<void> _reportPet() async {
    final author = AuthService.instance.currentUser;
    if (author == null ||
        author.uid == widget.pet.ownerId ||
        widget.pet.id.isEmpty) {
      return;
    }
    if (!await ensureOnline(context)) return;

    if (!mounted) return;
    final reason = await showReportDialog(context);
    if (!mounted || reason == null) return;

    try {
      await ReportService.instance.createReport(
        authorId: author.uid,
        targetId: widget.pet.id,
        reason: reason,
      );
      if (mounted) {
        WGSnackBar.showSuccess(context, ReportStrings.REPORT_SUCCESS);
      }
    } catch (_) {
      if (mounted) {
        WGSnackBar.showError(context, ReportStrings.REPORT_ERROR);
      }
    }
  }

  /// Alterna o bloqueio do dono deste anúncio.
  Future<void> _toggleBlock() async {
    final authUser = AuthService.instance.currentUser;
    if (authUser == null ||
        widget.pet.ownerId.isEmpty ||
        widget.pet.ownerId == authUser.uid) {
      return;
    }

    if (!await ensureOnline(context)) return;
    if (!mounted) return;

    final willBlock = !_isBlocked;
    final confirmed = await WGDialog.showConfirm(
      context,
      title: BlockStrings.blockConfirmTitle,
      message: BlockStrings.blockConfirmMessage,
      confirmLabel: willBlock
          ? BlockStrings.blockAction
          : BlockStrings.unblockAction,
      confirmColor: context.appColors.error,
    );
    if (!confirmed || !mounted) return;

    bool ok;
    if (willBlock) {
      // Evita manter favorito de um usuário que acaba de ser bloqueado.
      if (_isFavorited) {
        await FavoritesService.instance.remove(authUser.uid, widget.pet.id);
      }
      ok = await BlockService.instance.block(authUser.uid, widget.pet.ownerId);
    } else {
      ok = await BlockService.instance.unblock(authUser.uid, widget.pet.ownerId);
    }

    if (!mounted) return;
    if (ok) {
      setState(() => _isBlocked = willBlock);
      WGSnackBar.showSuccess(
        context,
        willBlock ? BlockStrings.blockSuccess : BlockStrings.unblockSuccess,
      );
    } else {
      WGSnackBar.showError(
        context,
        willBlock ? BlockStrings.blockError : BlockStrings.unblockError,
      );
    }
  }

  /// Linha de informação: ícone + valor.
  Widget _buildInfoRow({
    required IconData icon,
    required String value,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? context.appColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: valueColor != null
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  /// Largura do cabeçalho suficiente para exibir o nome completo do
  /// usuário, respeitando o espaço dos botões de ação da barra.
  double _ownerHeaderWidth(BuildContext context) {
    const avatarSize = 32.0; // CircleAvatar de raio 16
    const leftPadding = 6.0;
    const gap = 8.0;
    const reservedForActions = 208.0; // 4 botões (4 × 48) + respiro

    final name = _ownerName ?? 'Usuário';
    final style = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    final painter = TextPainter(
      text: TextSpan(text: name, style: style),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: TextDirection.ltr,
    )..layout();

    final measured = leftPadding + avatarSize + gap + painter.size.width;
    final available = MediaQuery.sizeOf(context).width - reservedForActions;

    return math.min(measured, math.max(44.0, available));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.primary,
        foregroundColor: context.appColors.onPrimary,
        elevation: 0,
        leadingWidth: _isLoadingOwner ? 44 : _ownerHeaderWidth(context),
        leading: _isLoadingOwner
            ? const SizedBox(width: 44)
            : Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          _ownerPhotoUrl != null && _ownerPhotoUrl!.isNotEmpty
                          ? NetworkImage(_ownerPhotoUrl!)
                          : null,
                      child: _ownerPhotoUrl == null || _ownerPhotoUrl!.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.white70,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _ownerName ?? 'Usuário',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: _isFavorited
                ? PetDetailsStrings.REMOVE_FROM_FAVORITES
                : PetDetailsStrings.ADD_TO_FAVORITES,
            icon: Icon(
              _isFavorited ? Icons.star_rounded : Icons.star_border_rounded,
              color: context.appColors.onPrimary,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: _sharePet,
            tooltip: PetDetailsStrings.SHARE_TOOLTIP,
            icon: Icon(
              Icons.share_outlined,
              color: context.appColors.onPrimary,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _reportPet,
            tooltip: ReportStrings.REPORT_ACTION,
            icon: Icon(
              Icons.flag_outlined,
              color: context.appColors.onPrimary,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _toggleBlock,
            tooltip: _isBlocked
                ? BlockStrings.unblockAction
                : BlockStrings.blockAction,
            icon: Icon(
              Icons.block,
              color: _isBlocked
                  ? context.appColors.error
                  : context.appColors.onPrimary,
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
              // NOME DO PET
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  widget.pet.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // FOTOS DO PET (galeria)
              GestureDetector(
                onTap: () {
                  if (widget.pet.images.isEmpty) return;
                  showDialog<void>(
                    context: context,
                    builder: (_) =>
                        WGPetFullScreenGallery(images: widget.pet.images),
                  );
                },
                child: WGPetGallery(images: widget.pet.images),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 10),

              // AVISO DE USUÁRIO BLOQUEADO
              if (_isBlocked)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.appColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.error),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          BlockStrings.blockedUserBannerTitle,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: context.appColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          BlockStrings.blockedUserBannerDescription,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

              if (_isBlocked) const SizedBox(height: 12),

              // BOTÃO DE ENTRAR EM CONTATO
              if (!_isBlocked)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _onContactPressed,
                      icon: const Icon(Icons.phone, size: 20),
                      label: const Text(
                        PetDetailsStrings.CONTACT_BUTTON,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.appColors.primary,
                        foregroundColor: context.appColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // INFORMAÇÕES DO PET
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: widget.pet.publicationType.icon,
                      iconColor: widget.pet.publicationType.color(
                        context.appColors,
                      ),
                      value: widget.pet.publicationType.label,
                      valueColor: widget.pet.publicationType.color(
                        context.appColors,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.pets_outlined,
                      value: widget.pet.species.label,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.label_outline,
                      value: widget.pet.race.isNotEmpty
                          ? widget.pet.race
                          : PetDetailsStrings.UNKNOWN,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.cake_outlined,
                      value: widget.pet.ageLabel,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: widget.pet.genderIcon,
                      iconColor: widget.pet.genderColor(context.appColors),
                      value: widget.pet.genderLabel,
                    ),
                    if (widget.pet.weight != null) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        icon: Icons.monitor_weight_outlined,
                        value: widget.pet.weightLabel!,
                      ),
                    ],
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      value: widget.pet.address,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SOBRE O PET
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PetDetailsStrings.ABOUT_SECTION,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      widget.pet.description ??
                          PetDetailsStrings.DESCRIPTION_NOT_INFORMED,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContactPressed() => openWhatsAppContact(
    context,
    ownerPhone: widget.pet.ownerPhone,
    petName: widget.pet.name,
  );
}
