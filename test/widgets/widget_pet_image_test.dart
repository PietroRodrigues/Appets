

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/widgets/display/widget_pet_image.dart';

/// Cache que falha na hora: o CachedNetworkImage cai no placeholder sem
/// rede e sem animação infinita nos testes.
class _FailingCacheManager implements BaseCacheManager {
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    return Stream<FileResponse>.error(StateError('rede indisponível em testes'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WGPetImage · URL vazia', () {
    testWidgets('mostra o placeholder com o ícone de pets', (tester) async {
      await tester.pumpWidget(wrap(const WGPetImage(url: '')));

      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });

  group('WGPetImage · caminho local', () {
    testWidgets('usa Image.asset para caminhos que não são URL', (tester) async {
      await tester.pumpWidget(
        wrap(const WGPetImage(url: 'assets/images/dog.png')),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/dog.png',
      );
    });
  });

  group('WGPetImage · URL remota', () {
    setUp(() {
      AppImageCache.instance.debugManager = _FailingCacheManager();
    });

    tearDown(() {
      AppImageCache.instance.debugManager = null;
    });

    testWidgets('renderiza via CachedNetworkImage com o memCacheWidth',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const WGPetImage(
            url: 'https://exemplo.com/foto.jpg',
            memCacheWidth: 480,
          ),
        ),
      );

      final cached = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cached.imageUrl, 'https://exemplo.com/foto.jpg');
      expect(cached.memCacheWidth, 480);
    });

    testWidgets('mostra o placeholder quando a rede falha', (tester) async {
      await tester.pumpWidget(
        wrap(const WGPetImage(url: 'https://exemplo.com/foto.jpg')),
      );

      // O stream de erro do cache chega: cai no errorWidget (placeholder).
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });
  });
}
