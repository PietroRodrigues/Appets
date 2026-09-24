import 'dart:async';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/my_publications_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/widgets/publish/widget_publish_pet_form.dart';

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
  group('WGPublishPetForm', () {
    Widget createTestWidget() {
      return const MaterialApp(home: Scaffold(body: WGPublishPetForm()));
    }

    // Lê a cor de fundo do botão "Publicar Pet".
    Color? publishButtonColor(WidgetTester tester) {
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Publicar Pet'),
          matching: find.byType(ElevatedButton),
        ),
      );
      return button.style?.backgroundColor?.resolve(<WidgetState>{});
    }

    testWidgets('exibe todos os campos do formulário', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verifica se os labels dos campos estão presentes.
      expect(find.text('Tipo de publicação'), findsOneWidget);
      expect(find.text('Nome do pet'), findsOneWidget);
      expect(find.text('Idade'), findsOneWidget);
      expect(find.text('Gênero'), findsOneWidget);
      expect(find.text('Telefone'), findsOneWidget);
      expect(find.text('Endereço'), findsOneWidget);
      expect(find.text('Sobre o pet'), findsOneWidget);
      expect(find.text('Fotos do pet'), findsOneWidget);
    });

    testWidgets('exibe botão de publicar', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Publicar Pet'), findsOneWidget);
    });

    testWidgets('campo nome aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final nameField = find.widgetWithText(
        TextFormField,
        'Digite o nome do pet',
      );
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Rex');
      expect(find.text('Rex'), findsOneWidget);
    });

    testWidgets('campo endereço aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final addressField = find.widgetWithText(
        TextFormField,
        'Digite o endereço',
      );
      expect(addressField, findsOneWidget);

      await tester.enterText(addressField, 'São Paulo');
      expect(find.text('São Paulo'), findsOneWidget);
    });

    testWidgets('campo descrição aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final descField = find.widgetWithText(
        TextFormField,
        'Conte um pouco sobre o pet',
      );
      expect(descField, findsOneWidget);

      await tester.enterText(descField, '描述 um pet muito bom');
      expect(find.text('描述 um pet muito bom'), findsOneWidget);
    });

    testWidgets('botão de publicar começa cinza (formulário incompleto)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(publishButtonColor(tester), ThemeColors.disabled);
    });

    testWidgets('botão fica cinza sem foto mesmo com formulário preenchido', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Nome válido.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o nome do pet'),
        'Rex',
      );
      // Celular válido (máscara aplicada com 11 dígitos).
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '11987654321',
      );
      // Endereço preenchido.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o endereço'),
        'São Paulo',
      );
      await tester.pump();

      // Sem fotos, o botão permanece cinza (barreira de fotos).
      expect(publishButtonColor(tester), ThemeColors.disabled);
    });

    testWidgets('exibe dica de foto obrigatória quando falta apenas a foto', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o nome do pet'),
        'Rex',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '11987654321',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o endereço'),
        'São Paulo',
      );
      await tester.pump();

      expect(
        find.text(PublishStrings.PHOTO_REQUIRED_HINT),
        findsOneWidget,
      );
    });

    testWidgets('botão continua cinza com celular inválido (fixo/10 dígitos)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o nome do pet'),
        'Rex',
      );
      // 10 dígitos (fixo) é inválido; a máscara mostra (11) 8765-4321.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '1187654321',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o endereço'),
        'São Paulo',
      );
      await tester.pump();

      expect(publishButtonColor(tester), ThemeColors.disabled);
    });

    testWidgets('publicar sem foto mostra aviso em vez de falhar em silêncio', (
      tester,
    ) async {
      AuthService.instance.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_test_001'),
      );
      addTearDown(() => AuthService.instance.debugAuth = null);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o nome do pet'),
        'Rex',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '11987654321',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o endereço'),
        'São Paulo',
      );
      await tester.pump();

      await tester.ensureVisible(find.text(PublishStrings.PUBLISH_BUTTON));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PublishStrings.PUBLISH_BUTTON));
      await tester.pumpAndSettle();

      // O toque sem fotos abre um aviso visível (barreira de fotos).
      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(
          of: dialog,
          matching: find.text(PublishStrings.INCOMPLETE_FORM_TITLE),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(PublishStrings.PHOTO_REQUIRED_HINT),
        ),
        findsOneWidget,
      );
    });

    testWidgets('publicar sem nome mostra aviso em vez de falhar em silêncio', (
      tester,
    ) async {
      _signInUser();

      await tester.pumpWidget(createTestWidget());

      // Deixa o nome vazio e preenche apenas contato válido.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '11987654321',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o endereço'),
        'São Paulo',
      );
      await tester.pump();

      await tester.ensureVisible(find.text(PublishStrings.PUBLISH_BUTTON));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PublishStrings.PUBLISH_BUTTON));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(PublishStrings.PET_NAME_REQUIRED),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(PublishStrings.OWNER_PHONE_INVALID),
        ),
        findsNothing,
      );
    });

    testWidgets('publicar com telefone inválido mostra aviso específico', (
      tester,
    ) async {
      _signInUser();

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o nome do pet'),
        'Rex',
      );
      // 10 dígitos (fixo) é inválido.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '1187654321',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o endereço'),
        'São Paulo',
      );
      await tester.pump();

      await tester.ensureVisible(find.text(PublishStrings.PUBLISH_BUTTON));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PublishStrings.PUBLISH_BUTTON));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(PublishStrings.OWNER_PHONE_INVALID),
        ),
        findsOneWidget,
      );
    });

    testWidgets('publicar lista nome e endereço faltando no aviso', (
      tester,
    ) async {
      _signInUser();

      await tester.pumpWidget(createTestWidget());

      // Apenas o telefone válido preenchido.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '11987654321',
      );
      await tester.pump();

      await tester.ensureVisible(find.text(PublishStrings.PUBLISH_BUTTON));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PublishStrings.PUBLISH_BUTTON));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(PublishStrings.PET_NAME_REQUIRED),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(PublishStrings.ADDRESS_REQUIRED),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(PublishStrings.PHOTO_REQUIRED_HINT),
        ),
        findsOneWidget,
      );
    });
  });

  group('WGPublishPetForm (publicação com foto)', () {
    testWidgets(
      'publicar notifica "Minhas Publicações" só depois de anexar as fotos',
      (tester) async {
        _signInUser();
        MyPublicationsService.instance.reset();
        ConnectivityService.instance.debugOnline = true;
        addTearDown(() => ConnectivityService.instance.debugOnline = null);

        // Firestore fake compartilhado pelos serviços.
        final db = FakeFirebaseFirestore();
        FirestoreService.instance.debugDb = db;
        PetService.instance.debugDb = db;
        addTearDown(() {
          FirestoreService.instance.debugDb = null;
          PetService.instance.debugDb = null;
        });

        // Conta do dono com o mesmo contato do formulário (evita o aviso
        // de "atualizar todas as publicações" após o sucesso).
        await FirestoreService.instance.createUser(UserModel(
          id: 'user_test_001',
          name: 'Usuária Teste',
          email: 'teste@email.com',
          phone: '(11) 98765-4321',
          address: 'São Paulo',
        ));

        // Foto local temporária usada pelo slot.
        final tempDir = Directory.systemTemp.createTempSync('appets_photo');
        final photoPath = '${tempDir.path}/photo_1.jpg';
        File(photoPath).writeAsBytesSync(List<int>.filled(64, 1));
        addTearDown(() {
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        });

        // Storage fake que valida a ordem das operações.
        final storage = _PublishOrderStorage();
        StorageService.instance.debugStorage = storage;
        addTearDown(() => StorageService.instance.debugStorage = null);

        // Picker fake: "escolhe" a foto local no slot.
        final originalPicker = ImagePickerPlatform.instance;
        ImagePickerPlatform.instance = _PickerReturnsFile(photoPath);
        addTearDown(() => ImagePickerPlatform.instance = originalPicker);

        // Abre o formulário como rota empurrada (o sucesso faz pop).
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(
                        body: WGPublishPetForm(),
                      ),
                    ),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('abrir'));
        await tester.pumpAndSettle();

        // Adiciona a foto pelo slot vazio (ícone de "adicionar"). O slot
        // lê o arquivo (tamanho/compressão), o que é I/O real: roda dentro
        // de runAsync para sair do FakeAsync dos testWidgets.
        await tester.ensureVisible(find.byIcon(Icons.add_a_photo_outlined));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
          await Future<void>.delayed(const Duration(milliseconds: 150));
        });
        await tester.pumpAndSettle();
        expect(find.text(PublishStrings.MAIN_PHOTO_BADGE), findsOneWidget);

        // Nome (telefone e endereço já vêm pré-preenchidos da conta).
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Digite o nome do pet'),
          'Rex',
        );
        await tester.pump();

        // Publicar.
        await tester.ensureVisible(find.text(PublishStrings.PUBLISH_BUTTON));
        await tester.pumpAndSettle();
        await tester.tap(find.text(PublishStrings.PUBLISH_BUTTON));
        await tester.pumpAndSettle();

        // Descrição vazia -> "Continuar".
        await tester.tap(find.text(PublishStrings.CONTINUE_BUTTON));
        await tester.pumpAndSettle();

        // Sucesso: diálogo de "Pet publicado".
        expect(find.text(PublishStrings.PET_PUBLISHED), findsOneWidget);
        await tester.tap(find.text(SharedStrings.OK));
        await tester.pumpAndSettle();

        // O upload observou o pet fora de "Minhas Publicações" e depois
        // ele entrou somente com as imagens já anexadas no Firestore.
        final petId = storage.uploadedPetId;
        expect(petId, isNotNull);
        final petDoc = await db.collection('pets').doc(petId!).get();
        expect(petDoc.exists, isTrue);
        final images = (petDoc.data()! as Map)['images'];
        expect(images, isNotEmpty);
        expect(
          MyPublicationsService.instance.current.contains(petId),
          isTrue,
        );
      },
    );
  });

  group('WGPublishPetForm em modo edição', () {
    setUp(() {
      AppImageCache.instance.debugManager = _FailingCacheManager();
    });

    tearDown(() {
      AppImageCache.instance.debugManager = null;
    });

    Pet createEditPet({String description = 'Muito dócil.'}) {
      return Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: 'São Paulo',
        ownerPhone: '(11) 98765-4321',
        ownerAddress: 'São Paulo',
        description: description,
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.dog,
        race: 'Poodle',
        images: ['a.png'],
      );
    }

    Widget createEditWidget() {
      return MaterialApp(
        home: Scaffold(body: WGPublishPetForm(pet: createEditPet())),
      );
    }

    testWidgets('exibe botão "Salvar Alterações" em vez de "Publicar Pet"', (
      tester,
    ) async {
      await tester.pumpWidget(createEditWidget());

      expect(find.text('Salvar Alterações'), findsOneWidget);
      expect(find.text('Publicar Pet'), findsNothing);
    });

    testWidgets('pré-preenche os campos com os dados do pet', (tester) async {
      await tester.pumpWidget(createEditWidget());

      expect(find.text('Rex'), findsWidgets);
      expect(find.text('Poodle'), findsWidgets);
      expect(find.text('Muito dócil.'), findsWidgets);
      expect(find.text('Perdido'), findsWidgets);
      expect(find.text('Cachorro'), findsWidgets);
      // Telefone com a máscara aplicada.
      expect(find.text('(11) 98765-4321'), findsWidgets);
    });

    testWidgets('botão "Salvar Alterações" começa verde (formulário válido)', (
      tester,
    ) async {
      await tester.pumpWidget(createEditWidget());

      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Salvar Alterações'),
          matching: find.byType(ElevatedButton),
        ),
      );
      final color = button.style?.backgroundColor?.resolve(<WidgetState>{});
      expect(color, ThemeColors.success);
    });

    testWidgets('carrega as fotos existentes do pet nos slots', (tester) async {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: 'São Paulo',
        ownerPhone: '(11) 98765-4321',
        ownerAddress: 'São Paulo',
        description: 'Muito dócil.',
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.dog,
        race: 'Poodle',
        images: _networkImages(5),
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: WGPublishPetForm(pet: pet)),
      ));

      // A edição trunca para o máximo de 3 slots visíveis (X por slot).
      expect(find.byIcon(Icons.close), findsNWidgets(3));
    });

    testWidgets('excluir foto existente pede confirmação antes de remover', (
      tester,
    ) async {
      final pet = Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: 'São Paulo',
        ownerPhone: '(11) 98765-4321',
        ownerAddress: 'São Paulo',
        description: 'Muito dócil.',
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.dog,
        race: 'Poodle',
        images: _networkImages(3),
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: WGPublishPetForm(pet: pet)),
      ));

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(
        find.text(PublishStrings.PHOTO_REMOVE_TITLE),
        findsOneWidget,
      );
    });

    testWidgets('remover a única foto deixa o botão cinza e mostra a dica', (
      tester,
    ) async {
      await tester.pumpWidget(createEditWidget());

      ElevatedButton saveButton() => tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Salvar Alterações'),
          matching: find.byType(ElevatedButton),
        ),
      );

      // Começa verde (formulário completo com foto).
      expect(
        saveButton().style?.backgroundColor?.resolve(<WidgetState>{}),
        ThemeColors.success,
      );

      // Remove a foto: X -> confirmar "Sim".
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(SharedStrings.YES));
      await tester.pumpAndSettle();

      // Sem fotos, o botão fica cinza e a dica da foto aparece.
      expect(
        saveButton().style?.backgroundColor?.resolve(<WidgetState>{}),
        ThemeColors.disabled,
      );
      expect(find.text(PublishStrings.PHOTO_REQUIRED_HINT), findsOneWidget);
    });

    testWidgets('descrição vazia pergunta se quer continuar ou preencher', (
      tester,
    ) async {
      _signInUser();
      ConnectivityService.instance.debugOnline = false;
      addTearDown(() => ConnectivityService.instance.debugOnline = null);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: WGPublishPetForm(pet: createEditPet(description: '')),
        ),
      ));

      await tester.ensureVisible(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();

      // Aviso de descrição vazia com as duas opções.
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(PublishStrings.EMPTY_DESCRIPTION_TITLE),
        findsOneWidget,
      );
      expect(find.text(PublishStrings.CONTINUE_BUTTON), findsOneWidget);
      expect(find.text(PublishStrings.FILL_BUTTON), findsOneWidget);

      // "Preencher" fecha o aviso e mantém o formulário aberto.
      await tester.tap(find.text(PublishStrings.FILL_BUTTON));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Salvar Alterações'), findsOneWidget);

      // "Continuar" segue adiante (offline: para na guarda de rede).
      await tester.ensureVisible(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PublishStrings.CONTINUE_BUTTON));
      await tester.pumpAndSettle();

      expect(find.text(SharedStrings.NO_CONNECTION), findsOneWidget);
    });
  });
}

/// URLs remotas fictícias usadas como fotos já publicadas em testes.
List<String> _networkImages(int count) {
  return [
    for (int i = 0; i < count; i++) 'https://exemplo.com/foto_$i.jpg',
  ];
}

/// Loga um usuário de teste no AuthService (abortado no fim do teste).
void _signInUser() {
  AuthService.instance.debugAuth = MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: 'user_test_001'),
  );
  addTearDown(() => AuthService.instance.debugAuth = null);
}

/// Picker fake que devolve sempre a mesma foto local (evita o plugin real).
class _PickerReturnsFile extends ImagePickerPlatform {
  _PickerReturnsFile(this.path);

  final String path;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile(path);
  }
}

/// Storage fake que grava a ORDEM da publicação: no momento do upload o pet
/// ainda NÃO pode estar em "Minhas Publicações" — o `add` só deve rodar
/// depois de o `updatePet({'images': ...})` anexar as fotos.
class _PublishOrderStorage implements FirebaseStorage {
  String? uploadedPetId;

  @override
  Reference ref([String? path]) => _PublishOrderReference(this);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _PublishOrderReference implements Reference {
  _PublishOrderReference(this.publishStorage, {this.path});

  final _PublishOrderStorage publishStorage;
  final String? path;

  @override
  Reference child(String childPath) =>
      _PublishOrderReference(publishStorage, path: childPath);

  @override
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    final petId = path!.split('/')[2];
    publishStorage.uploadedPetId = petId;
    expect(
      MyPublicationsService.instance.current.contains(petId),
      isFalse,
      reason: 'o pet não pode entrar em "Minhas Publicações" antes de as '
          'fotos serem enviadas/anexadas',
    );
    return _PublishOrderUploadTask();
  }

  @override
  Future<String> getDownloadURL() async => 'https://fake.storage/$path';

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _PublishOrderUploadTask implements UploadTask {
  _PublishOrderUploadTask()
      : _future = Future<TaskSnapshot>.value(_FakeTaskSnapshot());

  // UploadTask é um Future<TaskSnapshot>: o upload "conclui" e o fluxo segue.
  final Future<TaskSnapshot> _future;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);

  @override
  Future<TaskSnapshot> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) =>
      _future.catchError(onError, test: test);

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<TaskSnapshot> timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeTaskSnapshot implements TaskSnapshot {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
