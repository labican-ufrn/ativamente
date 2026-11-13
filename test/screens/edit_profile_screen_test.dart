import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_academia/models/pessoa.dart';
import 'package:app_academia/providers/auth_provider.dart';
import 'package:app_academia/providers/firestore_provider.dart';
import 'package:app_academia/providers/tts_provider.dart';
import 'package:app_academia/screens/profile/edit_profile_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late List<String> lidos;

  final pessoa = Pessoa(
    id: 'uid-1',
    nome: 'Maria',
    numTelefone: '(84) 99999-9999',
    dataNascimento: '25/12/1950',
    peso: 60.5,
    altura: 1.6,
  );

  Future<void> pumpEdit(
    WidgetTester tester, {
    User? usuario,
    Stream<Pessoa?>? dados,
  }) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    firestore = FakeFirebaseFirestore();
    lidos = [];
    final container = novoContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
        authStateProvider.overrideWith((ref) => Stream.value(usuario)),
        userDataProvider.overrideWith((ref) => dados ?? Stream.value(pessoa)),
        readScreenProvider.overrideWith(
          (ref, text) =>
              () => lidos.add(text),
        ),
      ],
    );
    container.listen(authStateProvider, (_, _) {});
    await pumpTelaComRouter(
      tester,
      rotaInicial: '/edit-profile',
      tela: const EditProfileScreen(),
      container: container,
    );
  }

  Finder campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

  String texto(WidgetTester tester, String rotulo) =>
      tester.widget<TextFormField>(campo(rotulo)).controller!.text;

  Future<void> salvar(WidgetTester tester) async {
    await tester.tap(find.text('Salvar Alterações'));
    await tester.pumpAndSettle();
  }

  testWidgets('preenche o formulário com os dados atuais da Pessoa', (
    tester,
  ) async {
    await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));

    expect(texto(tester, 'Nome Completo'), 'Maria');
    expect(texto(tester, 'Data de Nascimento (DD/MM/AAAA)'), '25/12/1950');
    expect(texto(tester, 'Telefone com DDD'), '(84) 99999-9999');
    expect(texto(tester, 'Peso (kg)'), '60.5');
    expect(texto(tester, 'Altura (m)'), '1.6');
  });

  testWidgets('peso e altura zerados ficam vazios no formulário', (
    tester,
  ) async {
    await pumpEdit(
      tester,
      usuario: FakeUser(uid: 'uid-1'),
      dados: Stream.value(Pessoa(id: 'uid-1', nome: 'Ana')),
    );

    expect(texto(tester, 'Peso (kg)'), '');
    expect(texto(tester, 'Altura (m)'), '');
  });

  testWidgets('salvar grava no documento Pessoas com merge e volta', (
    tester,
  ) async {
    await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));
    await firestore.collection('Pessoas').doc('uid-1').set({
      'role': 'admin',
      'nome': 'Maria',
    });

    await tester.enterText(campo('Nome Completo'), '  Maria Clara ');
    await tester.enterText(campo('Peso (kg)'), '62,5');
    await tester.enterText(campo('Altura (m)'), '1,62');
    await salvar(tester);

    final doc = await firestore.collection('Pessoas').doc('uid-1').get();
    expect(doc.data()!['nome'], 'Maria Clara');
    expect(doc.data()!['peso'], 62.5);
    expect(doc.data()!['altura'], 1.62);
    expect(doc.data()!['dataNascimento'], '25/12/1950');
    // merge: campos não editados (como role) são preservados.
    expect(doc.data()!['role'], 'admin');

    expect(find.text('Perfil atualizado com sucesso!'), findsOneWidget);
    expect(find.text(rotuloRota('/')), findsOneWidget);
  });

  testWidgets('peso/altura vazios não são gravados', (tester) async {
    await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));

    await tester.enterText(campo('Peso (kg)'), '');
    await tester.enterText(campo('Altura (m)'), '');
    await salvar(tester);

    final dados = (await firestore.collection('Pessoas').doc('uid-1').get())
        .data()!;
    expect(dados.containsKey('peso'), isFalse);
    expect(dados.containsKey('altura'), isFalse);
  });

  testWidgets('sem usuário autenticado avisa e não grava', (tester) async {
    await pumpEdit(tester);

    await salvar(tester);

    expect(find.text('Usuário não autenticado.'), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect((await firestore.collection('Pessoas').get()).size, 0);
  });

  group('validações', () {
    Future<void> validar(
      WidgetTester tester,
      String rotulo,
      String valor,
      String mensagem,
    ) async {
      await tester.enterText(campo(rotulo), valor);
      await salvar(tester);
      expect(find.text(mensagem), findsOneWidget, reason: '$rotulo="$valor"');
    }

    testWidgets('nome obrigatório', (tester) async {
      await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));
      await validar(tester, 'Nome Completo', '', 'Informe seu nome');
    });

    testWidgets('data de nascimento: vazia, incompleta, inválida, futura e '
        'idade mínima', (tester) async {
      await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));
      const rotulo = 'Data de Nascimento (DD/MM/AAAA)';
      final hoje = DateTime.now();
      String data(DateTime d) =>
          '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

      await validar(tester, rotulo, '', 'Informe a data de nascimento');
      await validar(tester, rotulo, '1205', 'Formato inválido. Use DD/MM/AAAA');
      await validar(tester, rotulo, '31022000', 'Data inválida');
      await validar(
        tester,
        rotulo,
        data(DateTime(hoje.year + 1, 1, 1)).replaceAll('/', ''),
        'Data de nascimento não pode ser no futuro',
      );
      await validar(
        tester,
        rotulo,
        data(DateTime(hoje.year - 10, 1, 1)).replaceAll('/', ''),
        'Idade mínima é 14 anos',
      );
    });

    testWidgets('telefone precisa de DDD e número', (tester) async {
      await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));
      await validar(
        tester,
        'Telefone com DDD',
        '8499',
        'Telefone deve ter DDD e número válido',
      );
    });

    testWidgets('peso entre 20 e 300 kg', (tester) async {
      await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));
      await validar(
        tester,
        'Peso (kg)',
        '10',
        'Insira um peso entre 20kg e 300kg',
      );
    });

    testWidgets('altura entre 0.50 e 2.50 m', (tester) async {
      await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));
      await validar(
        tester,
        'Altura (m)',
        'abc',
        'Insira uma altura entre 0.50m e 2.50m',
      );
    });
  });

  testWidgets('erro ao carregar o perfil é exibido', (tester) async {
    await pumpEdit(
      tester,
      usuario: FakeUser(uid: 'uid-1'),
      dados: Stream.error(Exception('offline')),
    );

    expect(find.textContaining('Erro ao carregar perfil'), findsOneWidget);
  });

  testWidgets('botão Ler tela descreve a edição de perfil', (tester) async {
    await pumpEdit(tester, usuario: FakeUser(uid: 'uid-1'));

    await tester.tap(find.byTooltip('Ler tela'));
    await tester.pump();

    expect(lidos.single, contains('edição de perfil'));
  });
}
