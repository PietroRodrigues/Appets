import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/feedback/widget_dialogs.dart';

/// Testa o diálogo modular [WGDialog] nas três APIs tipadas.
void main() {
  group('WGDialog.showConfirm', () {
    testWidgets('exibe os botões padrão "Não" e "Sim"', (tester) async {
      await tester.pumpWidget(_host((context) async {
        await WGDialog.showConfirm(
          context,
          title: 'Excluir?',
          message: 'Tem certeza que deseja excluir?',
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Não'), findsOneWidget);
      expect(find.text('Sim'), findsOneWidget);

      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('retorna true ao confirmar', (tester) async {
      bool? result;

      await tester.pumpWidget(_host((context) async {
        result = await WGDialog.showConfirm(
          context,
          title: 'Excluir?',
          message: 'Tem certeza que deseja excluir?',
          confirmLabel: 'Confirmar',
          cancelLabel: 'Cancelar',
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Excluir?'), findsOneWidget);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('retorna false ao cancelar', (tester) async {
      bool? result;

      await tester.pumpWidget(_host((context) async {
        result = await WGDialog.showConfirm(
          context,
          title: 'Excluir?',
          message: 'Tem certeza que deseja excluir?',
          confirmLabel: 'Confirmar',
          cancelLabel: 'Cancelar',
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('exibe a mensagem completa com destaque', (tester) async {
      await tester.pumpWidget(_host((context) async {
        await WGDialog.showConfirm(
          context,
          title: 'Excluir?',
          message: 'Excluir o pet "Rex"? Esta ação não pode ser desfeita.',
          confirmLabel: 'Excluir',
          messageHighlight: 'Rex',
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(
        find.text('Excluir o pet "Rex"? Esta ação não pode ser desfeita.'),
        findsOneWidget,
      );
    });
  });

  group('WGDialog.showAction', () {
    testWidgets('exibe um único botão padrão "OK"', (tester) async {
      await tester.pumpWidget(_host((context) async {
        await WGDialog.showAction(
          context,
          title: 'Aviso',
          message: 'Mensagem informativa.',
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Não'), findsNothing);
      expect(find.text('Sim'), findsNothing);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('retorna true ao tocar em uma ação única', (tester) async {
      bool? result;

      await tester.pumpWidget(_host((context) async {
        result = await WGDialog.showAction(
          context,
          title: 'Perfil incompleto',
          message: 'Complete seu cadastro.',
          actionLabel: 'Completar cadastro',
          actionIcon: Icons.edit_outlined,
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Perfil incompleto'), findsOneWidget);
      expect(find.text('Completar cadastro'), findsOneWidget);
      expect(find.text('Cancelar'), findsNothing);

      await tester.tap(find.text('Completar cadastro'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('retorna false ao dispensar pela barreira', (tester) async {
      bool? result;

      await tester.pumpWidget(_host((context) async {
        result = await WGDialog.showAction(
          context,
          title: 'Perfil incompleto',
          message: 'Complete seu cadastro.',
          actionLabel: 'Completar cadastro',
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });

  group('WGDialog.showInput', () {
    testWidgets('devolve o texto digitado ao confirmar', (tester) async {
      String? result;

      await tester.pumpWidget(_host((context) async {
        result = await WGDialog.showInput(
          context,
          title: 'Senha',
          message: 'Digite sua senha para continuar.',
          confirmLabel: 'Continuar',
          cancelLabel: 'Cancelar',
          hintText: 'Sua senha',
          obscureText: true,
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Senha'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'minha-senha');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(result, 'minha-senha');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('valida o campo vazio e não fecha o diálogo', (tester) async {
      String? result;

      await tester.pumpWidget(_host((context) async {
        result = await WGDialog.showInput(
          context,
          title: 'Senha',
          message: 'Digite sua senha para continuar.',
          confirmLabel: 'Continuar',
          cancelLabel: 'Cancelar',
          hintText: 'Sua senha',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe a senha';
            return null;
          },
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('retorna null ao cancelar', (tester) async {
      String? result;

      await tester.pumpWidget(_host((context) async {
        result = await WGDialog.showInput(
          context,
          title: 'Senha',
          message: 'Digite sua senha para continuar.',
          confirmLabel: 'Continuar',
          cancelLabel: 'Cancelar',
          hintText: 'Sua senha',
        );
      }));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}

/// Host que abre o diálogo a partir de um botão.
Widget _host(Future<void> Function(BuildContext) onOpen) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: FilledButton(
            onPressed: () => onOpen(context),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
}