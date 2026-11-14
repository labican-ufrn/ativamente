import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_academia/models/pessoa.dart';
import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/admin/exercise_management_guard.dart';

void main() {
  ProviderContainer containerForRole(String role) {
    final pessoa = Pessoa(id: 'pessoa-1', nome: 'Usuário Teste', role: role);
    return ProviderContainer(
      overrides: [
        userDataProvider.overrideWith((ref) => Stream.value(pessoa)),
        readScreenProvider.overrideWith((ref, text) => () {}),
      ],
    );
  }

  testWidgets('bloqueia acesso direto para usuários sem papel de gestão', (
    tester,
  ) async {
    final container = containerForRole('user');
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ExerciseManagementGuard(child: Text('Formulário protegido')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Você não tem autorização para gerenciar exercícios.'),
      findsOneWidget,
    );
    expect(find.text('Formulário protegido'), findsNothing);
  });

  testWidgets('libera o formulário para personal trainer e administrador', (
    tester,
  ) async {
    for (final role in ['trainer', 'admin']) {
      final container = containerForRole(role);
      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: ExerciseManagementGuard(
                child: Text('Formulário protegido'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Formulário protegido'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        container.dispose();
      }
    }
  });
}
