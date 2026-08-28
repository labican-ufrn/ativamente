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

1. **Flutter SDK 3.47.1-stable** (Dart ^3.12) — veja o [guia de instalação](docs/instalacao-flutter.md) (Ubuntu direto ou via ASDF; o projeto fixa a versão no `.tool-versions`);
2. **Java OpenJDK 21** — necessário para os emuladores Firebase (via ASDF: `asdf plugin add java && asdf install java openjdk-21`);
3. **Node.js + npm** — necessário para o Firebase CLI;
4. **Firebase CLI** — necessário para rodar os emuladores locais:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
5. **FlutterFire CLI** — necessário para configurar Firebase em novos projetos:
   ```bash
   dart pub global activate flutterfire_cli
   ```
6. **Android Studio** ou VS Code com plugin Flutter/Dart;
7. **Emulador Android** ou dispositivo físico com depuração USB;

## Como executar localmente

> ⚠️ **IMPORTANTE:** O projeto Firebase oficial (`ativamente-97e20`) pertence a uma conta restrita. Enquanto a migração para a conta oficial do Labican não acontece (T1.3), cada desenvolvedor deve usar uma **conta pessoal Firebase** com emuladores locais. Veja o [guia completo de execução local](docs/execucao-local.md).

```bash
# 1. Clone o repositório
git clone git@github.com:labican-ufrn/ativamente.git
cd ativamente

# 2. Instale as dependências do sistema (se ainda não instalou)
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev \
  liblzma-dev libstdc++-12-dev jq

# 3. Instale os SDKs via ASDF (recomendado)
. ~/.asdf/asdf.sh          # inicializa o asdf no terminal se necessário
asdf plugin add flutter    # adiciona o plugin do Flutter
asdf plugin add java       # adiciona o plugin do Java (para emuladores)
asdf install               # lê .tool-versions e instala Flutter + Java

# 4. Instale o Firebase CLI e faça login
npm install -g firebase-tools
firebase login

# 5. Configure o FlutterFire CLI (primeira vez)
dart pub global activate flutterfire_cli
export PATH="$HOME/.pub-cache/bin:$PATH"  # adicione ao ~/.zshrc

# 6. Configure seu projeto Firebase pessoal
flutterfire configure   # crie um projeto novo (ex.: ativamente-dev-seuusuario)

# 7. Configure as variáveis de ambiente
cp .env.example .env    # ajuste FIREBASE_PROJECT_ID com o ID do seu projeto

# 8. Configure o firebase.json
cp firebase.json.example firebase.json

# 9. Inicie os emuladores (Terminal 1)
firebase emulators:start --project <seu-project-id>

# 10. Rode o app (Terminal 2)
flutter run -d web-server --web-port=3000 --dart-define-from-file=.env
```

Acesse `http://localhost:3000` no navegador.

### Primeiro acesso e dados de teste

O app inicia na tela de boas-vindas — crie sua conta em **"Criar conta"** ou entre com um usuário existente.

Para popular o banco com exercícios de exemplo e contas de teste:

1. Cadastre-se normalmente;
2. No Console do Firebase (`ativamente-97e20`), promova seu documento em `Pessoas/{seu-uid}` com o campo `role: "admin"`;
3. Faça login no app → **Perfil → Admin → Seed Database**.

Isso cria os exercícios de exemplo e as contas `ativamente@ativamente.org` / `personal@ativamente.org` (senha padrão `dev123456`) com papéis `admin` e `trainer`.

## Banco de dados para testes locais

**Não é necessário instalar nenhum banco de dados na máquina** (nada de PostgreSQL, SQLite etc.). O Firestore é um serviço gerenciado. Para testar sem tocar nos dados do projeto real, use o **Firebase Emulator Suite**:

> ⚠️ **Pré-requisito:** Java OpenJDK 21 instalado (via ASDF ou diretamente no Ubuntu). Veja o [guia de instalação](docs/instalacao-flutter.md#pré-requisitos-para-firebase-emuladores).

```bash
firebase login
firebase emulators:start --project <seu-project-id>
```

Isso sobe localmente Auth (:9099), Firestore (:8080), Hosting (:5000) e a UI de inspeção em http://localhost:4000.

Para executar o app conectado aos **emuladores** (dados locais, nada toca o projeto remoto):

```bash
flutter run -d web-server --web-port=3000 --dart-define-from-file=.env
```

- A flag `USE_FIREBASE_EMULATORS` só tem efeito em modo debug (`kDebugMode`); builds de release ignoram-na.
- O host padrão dos emuladores é `localhost` (Web) e `10.0.2.2` (Android — alias do host no emulador). Para outro destino, sobrescreva no `.env`:
  ```bash
  FIREBASE_EMULATOR_HOST=10.0.2.2
  ```
- O banco do emulador começa vazio: use **Perfil → Admin → Seed Database** para popular exercícios e contas de teste localmente.
- Com os emuladores ativos, o seed e o cadastro de usuários admin também são direcionados ao ambiente local.

## Comandos úteis

```bash
flutter pub get          # instalar dependências
flutter analyze          # análise estática (obrigatória antes do PR)
dart fix --apply         # corrigir lints mecânicos automaticamente
flutter test             # testes unitários/widget
flutter run -d web-server --web-port=3000 --dart-define-from-file=.env  # executar em debug
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
