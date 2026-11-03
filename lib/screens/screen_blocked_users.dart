import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appets/core/constants/constants_strings_block.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/block_service.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/core/utils/offline_guard.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/feedback/widget_loading.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';
import 'package:appets/widgets/feedback/widget_snackbar.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:flutter/material.dart';

/// Tela de gestao de usuarios bloqueados.
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFetching = false;
  List<UserModel> _users = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final user = (AuthService.instance.currentUser);
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _users = const [];
          _hasError = false;
        });
        return;
      }

      if (!mounted) return;
      if (!await ensureOnline(context)) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

      await BlockService.instance.init(user.uid);

      final loaded =
          await BlockService.instance.getBlockedUsers(user.uid).timeout(
                const Duration(seconds: 8),
              );

      if (!mounted) return;
      setState(() {
        _users = loaded;
        _isLoading = false;
        _hasError = false;
      });
    } on FirebaseException catch (e) {
      debugPrint(
        '[BlockedUsersScreen] Firebase error: ${e.code} - ${e.message}',
      );
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        WGSnackBar.showError(
          context,
          'Não foi possível carregar usuários bloqueados: ${e.code}',
        );
      }
    } catch (e, st) {
      debugPrint('[BlockedUsersScreen] load error: $e\n$st');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        WGSnackBar.showError(
          context,
          'Não foi possível carregar usuários bloqueados.',
        );
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _unblock(UserModel user) async {
    final authUser = AuthService.instance.currentUser;
    if (authUser == null) return;
    if (!await ensureOnline(context)) return;

    final ok = await BlockService.instance.unblock(authUser.uid, user.id);
    if (!mounted) return;

    if (ok) {
      setState(() => _users = _users.where((u) => u.id != user.id).toList());
      WGSnackBar.showSuccess(context, BlockStrings.unblockSuccess);
    } else {
      WGSnackBar.showError(context, BlockStrings.unblockError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WGScaffold(
      child: Column(
        children: [
          WGPageHeader.title(
            title: BlockStrings.blockedUsersTitle,
            showSearchBar: false,
          ),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) return const Center(child: WGLoading());

    if (_hasError) {
      return WGErrorState(onAction: _load);
    }

    if (_users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 40, color: context.appColors.hint),
              const SizedBox(height: 12),
              Text(
                BlockStrings.blockedUsersEmpty,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                BlockStrings.blockedUsersSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _users.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            elevation: 0,
            color: context.appColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: context.appColors.border),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : null,
                child: user.photoUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(
                user.name.isEmpty ? 'Usu\u00e1rio' : user.name,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
              subtitle: Text(
                user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: SizedBox(
                width: 128,
                child: OutlinedButton(
                  onPressed: () => _unblock(user),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.appColors.error, width: 2),
                    backgroundColor: context.appColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    BlockStrings.unblockAction,
                    style: ThemeTextStyles.button.copyWith(
                      color: context.appColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}