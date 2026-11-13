import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/models/registro_ativ_dia.dart';

void main() {
  group('RegistroAtivDia', () {
    final json = {
      'data': '07/11/2026',
      'horaInicio': '08:30',
      'duracao': '00:15:00',
      'ownerPessoa_id': 'pessoa-1',
      'ownerExercicio_id': 'ex-1',
      'ownerTreinoSugerido_id': 'treino-1',
    };

    test('fromJson lê as chaves com sufixo _id do Firestore', () {
      final registro = RegistroAtivDia.fromJson(json, 'reg-1');

      expect(registro.id, 'reg-1');
      expect(registro.data, '07/11/2026');
      expect(registro.horaInicio, '08:30');
      expect(registro.duracao, '00:15:00');
      expect(registro.ownerPessoaId, 'pessoa-1');
      expect(registro.ownerExercicioId, 'ex-1');
      expect(registro.ownerTreinoSugeridoId, 'treino-1');
    });

    test('toJson gera o mesmo mapa (sem o id do documento)', () {
      final registro = RegistroAtivDia.fromJson(json, 'reg-1');

      expect(registro.toJson(), json);
    });

    test('fromJson usa string vazia para campos ausentes', () {
      final registro = RegistroAtivDia.fromJson({}, 'reg-2');

      expect(registro.id, 'reg-2');
      expect(registro.data, '');
      expect(registro.horaInicio, '');
      expect(registro.duracao, '');
      expect(registro.ownerPessoaId, '');
      expect(registro.ownerExercicioId, '');
      expect(registro.ownerTreinoSugeridoId, '');
    });
  });
}
