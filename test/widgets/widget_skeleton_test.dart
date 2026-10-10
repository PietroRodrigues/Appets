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
  final now = DateTime(2024, 1, 1);
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
      'images': const [],
      'createdAt': createdAt,
    };
  }

  group('WGSkeletonPetGrid · esqueleto de carregamento (item 30)', () {
    testWidgets('renderiza cards placeholder em grade com pulso', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WGSkeletonPetGrid())),
      );
      await tester.pump();

      expect(find.byType(WGSkeletonPetCard), findsNWidgets(6));
      expect(find.byType(FadeTransition), findsWidgets);
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('sem animação quando animações estão desabilitadas', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const Scaffold(body: WGSkeletonPetGrid()),
        ),
      );
      await tester.pump();

      expect(find.byType(WGSkeletonPetCard), findsNWidgets(6));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('WGResponsivePetGrid · loading inicial usa skeleton (item 30)', () {
    testWidgets(
      'mostra o esqueleto durante o loading e some quando os pets chegam',
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

        expect(find.byType(WGSkeletonPetGrid), findsOneWidget);
        expect(find.byType(WGSkeletonPetCard), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // O pet chega pela stream: o skeleton sai e o conteúdo entra.
        await db.collection('pets').doc('fido').set(petDoc('fido', now));
        await tester.pumpAndSettle();

        expect(find.byType(WGSkeletonPetGrid), findsNothing);
        expect(find.text('fido'), findsOneWidget);
      },
    );
  });
}
