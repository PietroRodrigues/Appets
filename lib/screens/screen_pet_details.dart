import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/extensions/extension_pet_display.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/utils/offline_guard.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';
import 'package:appets/widgets/feedback/widget_snackbar.dart';
import 'package:appets/widgets/pet/widget_pet_details_info.dart';
import 'package:appets/widgets/pet/widget_pet_gallery.dart';
import 'package:appets/widgets/pet/widget_pet_full_screen_gallery.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Tela de detalhes com imagens e informações do pet selecionado.
///
/// Permite favoritar o pet e compartilhar.
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

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.favoriteIds.addListener(_onFavoritesChanged);
    _loadOwnerData();
  }

  @override
  void dispose() {
    FavoritesService.instance.favoriteIds.removeListener(_onFavoritesChanged);
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

  Future<void> _toggleFavorite() async {
    final authUser = AuthService.instance.currentUser;
    if (authUser == null || widget.pet.id.isEmpty) return;

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
      await SharePlus.instance.share(
        ShareParams(text: widget.pet.shareText),
      );
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

  Widget _buildOwnerHeader(BuildContext context) {
    if (_isLoadingOwner) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: _ownerPhotoUrl != null &&
                    _ownerPhotoUrl!.isNotEmpty
                ? NetworkImage(_ownerPhotoUrl!)
                : null,
            child: _ownerPhotoUrl == null ||
                    _ownerPhotoUrl!.isEmpty
                ? const Icon(Icons.person, size: 26, color: Colors.white70)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _ownerName ?? 'Usuário',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.primary,
        foregroundColor: context.appColors.onPrimary,
        elevation: 0,
        leadingWidth: 70,
        leading: _isLoadingOwner
            ? const SizedBox(width: 44)
            : Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: _ownerPhotoUrl != null &&
                              _ownerPhotoUrl!.isNotEmpty
                          ? NetworkImage(_ownerPhotoUrl!)
                          : null,
                      child: _ownerPhotoUrl == null ||
                              _ownerPhotoUrl!.isEmpty
                          ? const Icon(Icons.person, size: 18,
                              color: Colors.white70)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
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
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOwnerHeader(context),
              const SizedBox(height: 8),
              if (!_isLoadingOwner)
                Divider(
                  height: 1,
                  color: context.appColors.divider.withValues(alpha: 0.3),
                  indent: 16,
                  endIndent: 16,
                ),
              GestureDetector(
                onTap: () {
                  if (widget.pet.images.isEmpty) return;
                  showDialog<void>(
                    context: context,
                    builder: (_) => WGPetFullScreenGallery(
                      images: widget.pet.images,
                    ),
                  );
                },
                child: WGPetGallery(images: widget.pet.images),
              ),
              WGPetDetailsInfo(pet: widget.pet),
            ],
          ),
        ),
      ),
    );
  }
}
