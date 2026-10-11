import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/connectivity_service.dart';

void main() {
  final service = ConnectivityService.instance;

  setUp(() => service.reset());

  tearDown(() => service.reset());

  //283
  test('antes do init assume online por padrão', () {
    expect(service.isOnline, isTrue);
    expect(service.isOnlineNotifier.value, isTrue);
  });

  //284
  test('debugOnline=false reflete offline e atualiza o notifier', () {
    service.debugOnline = false;
    expect(service.isOnline, isFalse);
    expect(service.isOnlineNotifier.value, isFalse);
  });

  //285
  test('reset restaura o estado online padrão', () {
    service.debugOnline = false;
    service.reset();
    expect(service.isOnline, isTrue);
    expect(service.isOnlineNotifier.value, isTrue);
  });

  //286
  test('notifier emite mudanças relevantes de valor', () {
    final values = <bool>[];
    void listener() => values.add(service.isOnlineNotifier.value);
    service.isOnlineNotifier.addListener(listener);

    service.debugOnline = false;
    service.debugOnline = false;
    service.debugOnline = true;

    service.isOnlineNotifier.removeListener(listener);
    expect(values, [false, true]);
  });
}