# Execução Local — AtivaMente

Guia completo para rodar o app localmente usando uma **conta pessoal Firebase** com emuladores, enquanto a migração para a conta oficial do Labican (T1.3) não é concluída.

> **Contexto:** O projeto Firebase oficial (`ativamente-97e20`) pertence a uma conta restrita. Cada desenvolvedor precisa configurar seu próprio projeto Firebase pessoal para testar localmente.

---

## 1. Pré-requisitos

Certifique-se de que todos os itens estão instalados:

```bash
# Dependências do sistema (Ubuntu)
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev \
  liblzma-dev libstdc++-12-dev nodejs npm

# SDKs via ASDF (recomendado)
asdf install    # lê .tool-versions e instala Flutter 3.47.1-stable + Java openjdk-21

# Firebase CLI
npm install -g firebase-tools

# FlutterFire CLI
dart pub global activate flutterfire_cli
export PATH="$HOME/.pub-cache/bin:$PATH"  # adicione ao ~/.zshrc
```

Para mais detalhes sobre instalação, veja o [guia de instalação do Flutter](instalacao-flutter.md).

### Configurar variáveis de ambiente

Copie o `.env.example` para `.env` e ajuste os valores:

```bash
cp .env.example .env
```

Conteúdo do `.env`:

```bash
# Firebase Emuladores
USE_FIREBASE_EMULATORS=true
FIREBASE_EMULATOR_HOST=localhost

# Firebase Projeto (referência — não afeta o app, apenas documentação)
FIREBASE_PROJECT_ID=ativamente-dev-seuusuario

# Porta do app web (usado no flutter run)
APP_WEB_PORT=3000
```

> ⚠️ O `.env` não é versionado (está no `.gitignore`). Cada desenvolvedor cria o seu localmente.

---

## 2. Configurar projeto Firebase pessoal

### 2.1 Fazer login no Firebase

```bash
firebase login
```

O navegador vai abrir para autenticar com sua conta Google.

### 2.2 Criar projeto via FlutterFire CLI

```bash
flutterfire configure
```

No wizard interativo:

1. **Reutilizar `firebase.json`?** → Responda **no** (quer criar um projeto novo)
2. **Selecione um projeto** → Crie um novo projeto (ex.: `ativamente-dev-seuusuario`)
3. **Plataformas** → Selecione pelo menos **web** e **android** (Linux não está disponível no FlutterFire CLI)

> O FlutterFire CLI vai atualizar automaticamente `lib/firebase_options.dart` com as credenciais do seu projeto.

### 2.3 Adicionar suporte a Linux (manual)

Como o FlutterFire CLI não suporta Linux como plataforma, adicione manualmente ao `lib/firebase_options.dart`:

1. Copie a configuração do **web** (mesmas credenciais)
2. Adicione uma constante `linux`:

```dart
static const FirebaseOptions linux = FirebaseOptions(
  apiKey: 'SUA_CHAVE_WEB',
  appId: 'SEU_APP_ID_WEB',
  messagingSenderId: 'SEU_SENDER_ID',
  projectId: 'seu-project-id',
  authDomain: 'seu-project-id.firebaseapp.com',
  storageBucket: 'seu-project-id.firebasestorage.app',
);
```

3. Atualize o `switch` para retornar `linux` em vez de lançar erro:

```dart
case TargetPlatform.linux:
  return linux;
```

---

## 3. Configurar Firebase CLI para o projeto

### 3.1 Configurar firebase.json

Copie o template e ajuste para seu projeto:

```bash
cp firebase.json.example firebase.json
```

> O `firebase.json` contém a configuração dos emuladores e hosting. A seção `flutter` será adicionada automaticamente pelo `flutterfire configure`.

### 3.2 Definir projeto ativo

```bash
firebase use --add
```

Selecione seu projeto na lista (ex.: `ativamente-dev-seuusuario`).

### 3.2 Verificar configuração

```bash
firebase projects:list
```

Deve listar seu projeto com o status ativo.

---

## 4. Executar o app

### Terminal 1 — Emuladores Firebase

```bash
firebase emulators:start --project <seu-project-id>
```

Isso inicia:
- **Auth** na porta `9099`
- **Firestore** na porta `8080`
- **Hosting** na porta `5000`
- **UI de inspeção** em `http://localhost:4000`

### Terminal 2 — App Flutter

```bash
flutter run -d web-server \
  --web-port=3000 \
  --dart-define-from-file=.env
```

Acesse `http://localhost:3000` no navegador.

---

## 5. Testar o app

1. Acesse `http://localhost:3000`
2. O app executa o **seed automático** no startup:
   - **Exercícios de exemplo:** O catálogo de `assets/data/exercises.json` é carregado no Firestore.
   - **Contas de teste padrão:** Criadas automaticamente no Auth:
     - **Admin:** `ativamente@ativamente.org` (senha: `dev123456`)
     - **Personal Trainer:** `personal@ativamente.org` (senha: `dev123456`)
3. Você também pode criar uma nova conta em **"Criar conta"** (os dados ficam armazenados no emulador local).

---

## 6. Solução de problemas

### Erro: "DefaultFirebaseOptions have not been configured for linux"

O `lib/firebase_options.dart` não tem a configuração para Linux. Siga o passo 2.3 para adicionar manualmente.

### Erro: "Unable to establish connection on channel"

Os emuladores Firebase não estão rodando. Execute `firebase emulators:start` no Terminal 1.

### Erro: "CORS" ao fazer login

O navegador está bloqueando requisições cross-origin. Verifique se os emuladores estão rodando na porta correta e se o app está conectado via `--dart-define=USE_FIREBASE_EMULATORS=true`.

### Erro: "No currently active project"

O Firebase CLI não encontrou o projeto ativo. Execute:

```bash
firebase use --add
```

e selecione seu projeto.

### Erro: "CMake was unable to find a build program corresponding to Ninja"

Faltam dependências do sistema para build Linux desktop:

```bash
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
```

### Erro: Java não encontrado para emuladores

```bash
asdf plugin add java
asdf install java openjdk-21
```

O `.tool-versions` do repositório já inclui `java openjdk-21` — basta rodar `asdf install` na pasta do projeto.

---

## 7. Notas importantes

- **Dados locais:** Todos os dados criados nos emuladores são locais e não afetam o projeto Firebase remoto.
- **Limpar dados:** Para reiniciar o banco do emulador, pare e reinicie `firebase emulators:start`.
- **Migração:** Quando a conta oficial do Labican estiver configurada (T1.3), todos os desenvolvedores deverão migrar para o projeto `ativamente-labican`. O `flutterfire configure` será executado uma única vez com a conta Labican.
- **VS Code:** Se o VS Code não encontrar o SDK, exporte no `~/.zshrc`:
  ```bash
  export FLUTTER_ROOT="$(asdf where flutter)"
  ```
