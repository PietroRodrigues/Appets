import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/widgets/pet/widget_pet_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cache que falha na hora: faz o CachedNetworkImage cair no placeholder
/// imediatamente, sem rede e sem animação infinita nos testes.
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

  // Métodos não usados pelo CachedNetworkImage nestes testes.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  const urls = [
    'https://firebasestorage.googleapis.com/foto_0.jpg',
    'https://firebasestorage.googleapis.com/foto_1.jpg',
    'https://firebasestorage.googleapis.com/foto_2.jpg',
  ];

  setUp(() {
    AppImageCache.instance.debugManager = _FailingCacheManager();
  });

  tearDown(() {
    AppImageCache.instance.debugManager = null;
  });

  Widget wrap({
    required List<String> images,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WGPetGallery(images: images),
      ),
    );
  }

  group('WGPetGallery → sem fotos', () {
    testWidgets('mostra o placeholder de pet em vez de caixa em branco',
        (tester) async {
      await tester.pumpWidget(wrap(images: const []));

      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('não exibe contador nem dots', (tester) async {
      await tester.pumpWidget(wrap(images: const []));

      expect(find.text('1/0'), findsNothing);
      expect(find.byType(AnimatedContainer), findsNothing);
    });
  });

  group('WGPetGallery → contador e dots', () {
    testWidgets('mostra 1/N ao abrir e acompanha o deslize', (tester) async {
      await tester.pumpWidget(wrap(images: urls));

      expect(find.text('1/3'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('2/3'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('3/3'), findsOneWidget);
      expect(find.text('1/3'), findsNothing);
    });

    testWidgets('resincroniza o índice quando a lista encolhe',
        (tester) async {
      await tester.pumpWidget(wrap(images: urls));
      expect(find.text('1/3'), findsOneWidget);

      // Vai para a última foto (índice 2)…
      for (var i = 0; i < 2; i++) {
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
      }
      expect(find.text('3/3'), findsOneWidget);

      // …e a lista passa a ter só 2 fotos: o índice recua para o último
      // válido (2/2) em vez de ficar preso em 3/2.
      await tester.pumpWidget(wrap(images: urls.sublist(0, 2)));
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('3/2'), findsNothing);
    });
  });
}