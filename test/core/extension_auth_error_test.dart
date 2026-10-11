import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/extensions/extension_auth_error.dart';

void main() {
  //14
  test('devolve a mensagem do código reconhecido', () {
    final error = Exception('FirebaseAuthException: user-not-found');

    expect(
      error.authMessage('padrão', {'user-not-found': 'Não encontrado'}),
      'Não encontrado',
    );
  });

  //15
  test('devolve o default quando nenhum código casa', () {
    final error = Exception('erro desconhecido');

    expect(
      error.authMessage('padrão', {'user-not-found': 'Não encontrado'}),
      'padrão',
    );
  });

  //16
  test('respeita a ordem do mapa quando há códigos sobrepostos', () {
    final error = Exception('wrong-password-invalid-credential');

    expect(
      error.authMessage('padrão', {
        'wrong-password': 'Senha errada',
        'invalid-credential': 'Credencial inválida',
      }),
      'Senha errada',
    );
  });
}
