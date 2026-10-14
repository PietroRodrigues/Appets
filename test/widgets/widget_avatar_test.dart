import 'dart:async';

import 'package:appets/widgets/display/widget_avatar.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Imagem que falha de forma determinística (sem rede) ao carregar.
class _FailingImageProvider extends ImageProvider<_FailingImageProvider> {
  const _FailingImageProvider();

  @override
  Future<_FailingImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_FailingImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    _FailingImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error(StateError('imagem indisponível em teste')),
    );
  }
}

/// Imagem que nunca conclui (nem sucesso, nem erro): mantém o widget no
/// estado "carregando" de forma determinística, sem rede.
class _PendingImageProvider extends ImageProvider<_PendingImageProvider> {
  const _PendingImageProvider();

  @override
  Future<_PendingImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_PendingImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    _PendingImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      Completer<ImageInfo>().future,
    );
  }
}

void main() {
  final failingProvider = const _FailingImageProvider();
  final pendingProvider = const _PendingImageProvider();

  Widget wrap({
    String? imageUrl,
    ImageProvider<Object>? debugImageProvider,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WGAvatar(
            imageUrl: imageUrl,
            debugImageProvider: debugImageProvider,
          ),
        ),
      ),
    );
  }

  CircleAvatar avatarOf(WidgetTester tester) =>
      tester.widget<CircleAvatar>(find.byType(CircleAvatar));

  group('WGAvatar → sem imagem', () {
    //403
    testWidgets('sem URL mostra o ícone de pessoa', (tester) async {
      await tester.pumpWidget(wrap());

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(avatarOf(tester).backgroundImage, isNull);
    });

    //404
    testWidgets('URL vazia mostra o ícone de pessoa', (tester) async {
      await tester.pumpWidget(wrap(imageUrl: ''));

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(avatarOf(tester).backgroundImage, isNull);
    });
  });

  group('WGAvatar → imagem que falha', () {
    //405
    testWidgets('começa com a imagem e reverte para o ícone no erro',
        (tester) async {
      await tester.pumpWidget(wrap(debugImageProvider: failingProvider));

      // Enquanto a imagem não falhou, o background está preenchido.
      expect(avatarOf(tester).backgroundImage, isNotNull);
      expect(find.byIcon(Icons.person), findsNothing);

      // O erro assíncrono do provider chega: sumir o círculo vazio.
      await tester.pump();
      await tester.pump();

      expect(avatarOf(tester).backgroundImage, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    //406
    testWidgets('com URL e sem rede não deixa círculo vazio', (tester) async {
      await tester.pumpWidget(
        wrap(
          imageUrl: 'https://lh3.googleusercontent.com/expired.jpg',
          debugImageProvider: failingProvider,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(avatarOf(tester).backgroundImage, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('WGAvatar → imagem presente', () {
    //407
    testWidgets('mantém o background enquanto carrega', (tester) async {
      await tester.pumpWidget(
        wrap(imageUrl: 'https://lh3.googleusercontent.com/foto.jpg'),
      );

      expect(avatarOf(tester).backgroundImage, isNotNull);
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });

  group('WGAvatar → troca de URL', () {
    //621
    testWidgets('URL nova depois de uma falha volta a tentar a imagem',
        (tester) async {
      // Primeira URL falha: o widget cai no fallback (ícone de pessoa).
      await tester.pumpWidget(
        wrap(
          imageUrl: 'https://cdn.example.com/quebrada.webp',
          debugImageProvider: failingProvider,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(avatarOf(tester).backgroundImage, isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);

      // URL nova: a falha anterior não é herdada — a imagem volta a ser
      // tentada (background preenchido enquanto carrega, sem ícone).
      await tester.pumpWidget(
        wrap(
          imageUrl: 'https://cdn.example.com/nova.webp',
          debugImageProvider: pendingProvider,
        ),
      );
      expect(avatarOf(tester).backgroundImage, isNotNull);
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });
}