# AtivaMente 🏃‍♂️

Aplicativo Flutter para auxiliar **idosos** na prática de exercícios físicos de forma saudável e segura, desenvolvido pelo [Labican/UFRN](https://github.com/labican-ufrn). O projeto segue as orientações do *Manual do Idoso* e visa promover atividades físicas adaptadas, contribuindo para a saúde e qualidade de vida na terceira idade.

- **App publicado (Web):** https://ativamente-97e20.web.app
- **Documentação:** [`docs/user-stories.md`](docs/user-stories.md) · [`docs/plano-sprints.md`](docs/plano-sprints.md) · [`docs/equipe.md`](docs/equipe.md)
- **Modelo conceitual da API:** [`ativamente-api/docs/modelo-conceitual.md`](https://github.com/labican-ufrn/ativamente-api/blob/dev/docs/modelo-conceitual.md)

## Stack

| Camada | Tecnologia |
|---|---|
| Frontend | Flutter 3.x / Dart |
| Estado | Riverpod |
| Navegação | go_router |
| Backend | Firebase — Authentication + Cloud Firestore |
| Acessibilidade | flutter_tts (leitura de tela em voz alta) |

## Pré-requisitos

1. **Flutter SDK** (canal estável, Dart ^3.12) — ver [instalação](https://docs.flutter.dev/get-started/install);
2. **Android Studio** ou VS Code com plugin Flutter/Dart;
3. **Emulador Android** ou dispositivo físico com depuração USB;
4. *(Opcional)* **Node.js + Firebase CLI**, apenas se for usar os emuladores locais ou fazer deploy:
   ```bash
   npm install -g firebase-tools
   ```

## Como executar localmente

```bash
# 1. Clone o repositório
git clone git@github.com:labican-ufrn/ativamente.git
cd ativamente

# 2. Instale as dependências
flutter pub get

# 3. Verifique o ambiente (opcional)
flutter doctor

# 4. Rode em um emulador/dispositivo conectado
flutter run
```

> A configuração do Firebase já está incluída no repositório (`lib/firebase_options.dart`), apontando para o projeto `ativamente-97e20`. **Não é necessário rodar `flutterfire configure`** para executar o app.

### Primeiro acesso e dados de teste

O app inicia na tela de boas-vindas — crie sua conta em **"Criar conta"** ou entre com um usuário existente.

Para popular o banco com exercícios de exemplo e contas de teste:

1. Cadastre-se normalmente;
2. No Console do Firebase (`ativamente-97e20`), promova seu documento em `Pessoas/{seu-uid}` com o campo `role: "admin"`;
3. Faça login no app → **Perfil → Admin → Seed Database**.

Isso cria os exercícios de exemplo e as contas `ativamente@ativamente.org` / `personal@ativamente.org` (senha padrão `dev123456`) com papéis `admin` e `trainer`.

## Banco de dados para testes locais

**Não é necessário instalar nenhum banco de dados na máquina** (nada de PostgreSQL, SQLite etc.). O Firestore é um serviço gerenciado. Para testar sem tocar nos dados do projeto real, use o **Firebase Emulator Suite**:

```bash
firebase login
firebase emulators:start
```

Isso sobe localmente Auth (:9099), Firestore (:8080), Hosting (:5000) e a UI de inspeção em http://localhost:4000.

Para executar o app conectado aos **emuladores** (dados locais, nada toca o projeto remoto):

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

- A flag só tem efeito em modo debug (`kDebugMode`); builds de release ignoram-na.
- O host padrão dos emuladores é `localhost` (Web) e `10.0.2.2` (Android — alias do host no emulador). Para outro destino, sobrescreva:
  ```bash
  flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
  ```
- O banco do emulador começa vazio: use **Perfil → Admin → Seed Database** para popular exercícios e contas de teste localmente.
- Com os emuladores ativos, o seed e o cadastro de usuários admin também são direcionados ao ambiente local.

## Comandos úteis

```bash
flutter pub get          # instalar dependências
flutter analyze          # análise estática (obrigatória antes do PR)
dart fix --apply         # corrigir lints mecânicos automaticamente
flutter test             # testes unitários/widget
flutter run              # executar em debug
flutter build apk        # build Android
flutter build web        # build Web
firebase deploy --only hosting  # publicar Web (requer firebase login)
```

## Estrutura do projeto

```
lib/
├── main.dart            # inicialização Firebase + ProviderScope
├── routes.dart          # go_router + guarda de rotas públicas/privadas
├── theme.dart           # tema visual do app
├── models/              # modelos com fromJson/toJson (Pessoa, Exercicio…)
├── providers/           # Riverpod (auth, firestore, tts, seed)
└── screens/
    ├── auth/            # welcome, login, cadastro
    ├── home/            # tela inicial com tipos de treino
    ├── workout/         # treino com cronômetro e lista de exercícios
    ├── profile/         # perfil, acessibilidade e área admin
    └── admin/           # cadastro de usuários com papéis
```

## Contribuição

1. Siga o fluxo **GitFlow**: crie branches `feature/nome-da-feature` a partir de `dev`;
2. Use **Conventional Commits** (ex.: `feat: adiciona tela de detalhe do exercício`);
3. Abra PRs apontando para `dev`;
4. Toda a documentação é escrita em **português brasileiro**.

Diretrizes completas para agentes de IA e pessoas: [`AGENTS.md`](AGENTS.md).
