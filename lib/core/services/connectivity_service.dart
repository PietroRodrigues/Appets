import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, visibleForTesting;

/// Controla o estado de conectividade da rede do dispositivo e o expõe
/// como um [ValueNotifier] para que a interface reaja a mudanças.
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> _notifier = ValueNotifier<bool>(true);

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;
  bool? _debugOnline;

  /// Estado atual da conectividade (online quando qualquer interface de
  /// rede está ativa).
  ValueNotifier<bool> get isOnlineNotifier => _notifier;

  /// Indica se o dispositivo está online. Antes da [init], assume otimista
  /// `true` (para não bloquear a carga inicial).
  bool get isOnline => _debugOnline ?? (_started ? _notifier.value : true);

  /// Permite injetar o estado de conectividade em testes, sem tocar no
  /// plugin (que lança `MissingPluginException` no `flutter test`).
  @visibleForTesting
  set debugOnline(bool? value) {
    _debugOnline = value;
    _notifier.value = value ?? true;
  }

  /// Inicia o monitoramento: lê o estado atual e passa a escutar mudanças.
  void init() {
    if (_started || _debugOnline != null) return;
    _started = true;
    _checkNow();
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  /// Re-verifica o estado atual (ex.: ao voltar do background, já que o
  /// Android não reporta mudanças de conectividade em segundo plano).
  Future<void> refresh() async {
    if (_debugOnline != null) return;
    await _checkNow();
  }

  Future<void> _checkNow() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _setOnline(results.any((result) => result != ConnectivityResult.none));
    } catch (_) {
      // Mantém o último estado conhecido.
    }
  }

  void _onChanged(List<ConnectivityResult> results) {
    _setOnline(results.any((result) => result != ConnectivityResult.none));
  }

  void _setOnline(bool online) {
    if (_notifier.value != online) {
      _notifier.value = online;
    }
  }

  /// Restaura o estado inicial (usado entre testes).
  @visibleForTesting
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
    _debugOnline = null;
    _notifier.value = true;
  }
}