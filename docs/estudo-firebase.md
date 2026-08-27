# Estudo de Firebase

Este documento registra a prática de Firebase feita no AtivaMente. Para não misturar dados do estudo com o ambiente oficial, use um projeto pessoal no Firebase Console.

## Configuração inicial

1. Crie um projeto pessoal em [Firebase Console](https://console.firebase.google.com/).
2. Ative **Authentication > Sign-in method > E-mail/senha**.
3. Crie o banco em **Firestore Database**. Para testes locais, o modo de teste é suficiente; antes de produção, publique regras restritivas.
4. Instale o FlutterFire CLI e autentique o Firebase CLI:

```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
flutter pub get
```

Escolha somente o projeto pessoal quando o `flutterfire configure` perguntar qual projeto usar. O comando atualiza `lib/firebase_options.dart` e os arquivos nativos da aplicação.

## CRUD praticado

A tela **Estudo Firebase**, disponível na home depois do login, usa a coleção `tarefas`:

- **Create:** botão `Nova tarefa`, que usa `collection.add(...)`.
- **Read em tempo real:** `tarefasProvider` usa `snapshots()` e atualiza a lista quando o Firestore muda.
- **Read pontual:** tocar em uma tarefa usa `doc(id).get()`.
- **Update:** menu da tarefa permite editar título e descrição ou alternar a conclusão com `update(...)`.
- **Delete:** menu da tarefa remove o documento com `delete()`.

Os dados possuem `titulo`, `descricao`, `concluida` e `criadaEm`. A coleção é deliberadamente separada de `Pessoas` e `Exercicios`, que pertencem ao domínio do app.

## Teste de autenticação

1. Abra **Cadastre-se**.
2. Informe nome, e-mail e uma senha válida.
3. Confirme que o usuário aparece em **Authentication > Users** e que o cadastro cria um documento em `Pessoas`.
4. Saia e entre novamente com o mesmo e-mail e senha.
5. Acesse **Estudo Firebase**, crie uma tarefa e valide a alteração no console do Firestore.

Para testar sem acessar um projeto remoto, inicie os emuladores e execute:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

No Android Emulator, o app usa `10.0.2.2` para alcançar a máquina host; no Web, usa `localhost`.

## Aprendizados

- `authStateChanges()` é útil para proteger rotas conforme o usuário entra ou sai.
- `snapshots()` representa uma assinatura contínua; `get()` faz uma consulta única.
- `add()` gera um ID automaticamente, enquanto `doc(id).update()` e `doc(id).delete()` atuam sobre um documento específico.
- As regras do Firestore são a camada que realmente deve autorizar leitura e escrita; a interface não substitui regras de segurança.