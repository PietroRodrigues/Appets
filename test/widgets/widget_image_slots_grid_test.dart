import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/widgets/publish/widget_image_slots_grid.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Wraper básico para renderizar o grid isolado.
Widget _host() {
  return MaterialApp(
    home: Scaffold(
      body: WGImageSlotsGrid(),
    ),
  );
}

void main() {
  group('WGImageSlotsGrid', () {
    testWidgets('erro do picker mostra aviso em vez de exceção não tratada', (
      tester,
    ) async {
      final originalPicker = ImagePickerPlatform.instance;
      ImagePickerPlatform.instance = _PickerThrows();
      addTearDown(() => ImagePickerPlatform.instance = originalPicker);

      await tester.pumpWidget(_host());

      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(
          of: dialog,
          matching: find.text(PublishStrings.PICK_PHOTO_ERROR_TITLE),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.text(PublishStrings.PICK_PHOTO_ERROR_MESSAGE),
        ),
        findsOneWidget,
      );
      expect(find.text(PublishStrings.MAIN_PHOTO_BADGE), findsNothing);
    });

    testWidgets('cancelar a seleção não mostra aviso nem adiciona foto', (
      tester,
    ) async {
      final originalPicker = ImagePickerPlatform.instance;
      ImagePickerPlatform.instance = _PickerCancels();
      addTearDown(() => ImagePickerPlatform.instance = originalPicker);

      await tester.pumpWidget(_host());

      await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(PublishStrings.MAIN_PHOTO_BADGE), findsNothing);
    });
  });
}

/// Picker fake que lança erro da plataforma (ex.: permissão negada).
class _PickerThrows extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    throw PlatformException(
      code: 'photo_access_denied',
      message: 'Permissão de acesso às fotos negada',
    );
  }
}

/// Picker fake que simula o usuário cancelando a seleção.
class _PickerCancels extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return null;
  }
}