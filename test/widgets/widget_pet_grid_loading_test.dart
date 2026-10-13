import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/widgets/feedback/widget_page_states.dart';
import 'package:appets/widgets/feed/widget_responsive_pet_grid.dart';

void main() {
  final service = PetService.instance;
  final connectivity = ConnectivityService.instance;
  final now = DateTime(2024);
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    service.debugDb = db;
    service.debugFirstPageError = null;
    connectivity.debugOnline = true;
  });

  tearDown(() {
    service.debugDb = null;
    service.debugFirstPageError = null;
    connectivity.reset();
  });

  Map<String, dynamic> petDoc(String id, DateTime createdAt) {
    return {
      'id': id,
      'ownerId': 'dono_a',
      'name': id,
      'age': 2,
      'ageUnit': 'anos',
      'gender': 'macho',
      'address': 'Rua 1',
      'ownerPhone': '',
      'ownerAddress': '',
      'description': '',
      'publicationType': 'adocao',
      'species': 'cachorro',
      'race': '',
      'searchTokens': const ['token'],
      'specifications': const ['cachorro', 'macho', 'adocao', 'jovem'],
      'images': const <String>[],
      'createdAt': createdAt,
    };
  }

  group('WGPetGridLoading · spinner de carregamento', () {
    //501
    testWidgets('renderiza o spinner em animação', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WGPetGridLoading())),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
    });

    //502
    testWidgets('anima mesmo com animações desabilitadas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const Scaffold(body: WGPetGridLoading()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
    });

    //503
    testWidgets('anuncia o carregamento para leitores de tela (a11y)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WGPetGridLoading())),
      );
      await tester.pump();

      expect(find.bySemanticsLabel(RegExp('Carregando')), findsOneWidget);

      handle.dispose();
    });
  });

  group('WGPetGridLoading · sem overflow em várias larguras', () {
    Future<void> expectNoOverflowAt(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WGPetGridLoading())),
      );
      await tester.pump();

      // Overflow do RenderFlex viraria exceção capturada aqui (e falharia a
      // expect) — a regressão do "erro de pixel" é detectada automaticamente.
      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }

    //504
    testWidgets('1 coluna em 320×480', (tester) async {
      await expectNoOverflowAt(tester, const Size(320, 480));
    });

    //505
    testWidgets('2 colunas em 360×640 (cards baixos)', (tester) async {
      await expectNoOverflowAt(tester, const Size(360, 640));
    });

    //506
    testWidgets('3 colunas em 800×600', (tester) async {
      await expectNoOverflowAt(tester, const Size(800, 600));
    });

    //507
    testWidgets('1 coluna muito baixa em 200×600 (escala mínima)', (
      tester,
    ) async {
      await expectNoOverflowAt(tester, const Size(200, 600));
    });
  });

  group('WGResponsivePetGrid · loading inicial usa o spinner', () {
    //508
    testWidgets(
      'mostra o spinner durante o loading e some quando os pets chegam',
      (tester) async {
        // Sem pets no banco nem no cache: o primeiro frame é o de
        // carregamento (o cache-first resolve em microtask e o grid entra
        // no vazio/stream no frame seguinte).
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WGResponsivePetGrid(
                filter: AppPetFilter.all,
                itemBuilder: (context, pet) => Text(pet.name),
              ),
            ),
          ),
        );

        expect(find.byType(WGPetGridLoading), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // O pet chega pela stream: o spinner sai e o conteúdo entra.
        await db.collection('pets').doc('fido').set(petDoc('fido', now));
        await tester.pumpAndSettle();

        expect(find.byType(WGPetGridLoading), findsNothing);
        expect(find.text('fido'), findsOneWidget);
      },
    );
  });
}
