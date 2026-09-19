import 'dart:async';

import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';

/// Chave da faixa colorida (usada nos testes).
const _stripKey = ValueKey<String>('connectivity_strip');

/// Faixa fina e sutil no topo do app que reflete o estado da conexão.
///
/// Sem conexão: uma faixa fixa "Sem conexão" permanece enquanto offline.
/// Reconectou: mostra "Conexão estabelecida" por alguns instantes e recolhe.
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with WidgetsBindingObserver {
  static const _restoredDuration = Duration(seconds: 3);

  final ConnectivityService _connectivity = ConnectivityService.instance;

  String? _message;
  bool? _lastOnline;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivity.isOnlineNotifier.addListener(_onConnectivityChanged);
    _lastOnline = _connectivity.isOnline;
    if (!_lastOnline!) {
      _message = SharedStrings.NO_CONNECTION;
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _connectivity.isOnlineNotifier.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectivity.refresh();
    }
  }

  void _onConnectivityChanged() {
    final online = _connectivity.isOnline;
    if (online == _lastOnline) return;
    _lastOnline = online;
    _hideTimer?.cancel();

    if (online) {
      setState(() => _message = SharedStrings.CONNECTION_RESTORED);
      _hideTimer = Timer(_restoredDuration, () {
        if (mounted) {
          setState(() => _message = null);
        }
      });
    } else {
      setState(() => _message = SharedStrings.NO_CONNECTION);
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _message;
    final visible = message != null;
    final top = MediaQuery.paddingOf(context).top;

    var content = widget.child;
    if (visible) {
      // Evita o duplo espaço da barra de status quando a faixa está visível.
      content = MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: content,
      );
    }

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          // A área da barra de status fica transparente (mantém a cor
          // original do aparelho); a faixa aparece logo abaixo dela.
          child: visible
              ? Padding(
                  padding: EdgeInsets.only(top: top),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _BannerBar(
                      key: ValueKey(message),
                      message: message,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
        Expanded(child: content),
      ],
    );
  }
}

class _BannerBar extends StatelessWidget {
  const _BannerBar({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isOffline = message == SharedStrings.NO_CONNECTION;
    final background = isOffline ? ThemeColors.error : ThemeColors.success;
    final icon = isOffline ? Icons.wifi_off : Icons.wifi;

    return Container(
      key: _stripKey,
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: ThemeColors.white),
          const SizedBox(width: 6),
          Text(
            message,
            style: ThemeTextStyles.body.copyWith(
              color: ThemeColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}