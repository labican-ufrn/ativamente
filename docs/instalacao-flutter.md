# Instalação do Flutter — AtivaMente

O projeto utiliza **Flutter 3.47.1-stable** (Dart ^3.12.2). Escolha **um** dos métodos abaixo para instalar o SDK na sua máquina (Ubuntu).

> Após instalar por qualquer método, valide com:
>
> ```bash
> flutter --version   # deve mostrar 3.47.1
> flutter doctor      # resolve as pendências apontadas (!)
> ```

---

## Método 1 — Instalação direta no Ubuntu

### 1. Dependências do sistema

```bash
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa \
  clang cmake git ninja-build pkg-config libgtk-3-dev
```

### 2. Baixar e extrair o SDK

```bash
mkdir -p ~/development && cd /tmp
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.1-stable.tar.xz
tar xf flutter_linux_3.47.1-stable.tar.xz -C ~/development
```

### 3. Adicionar ao PATH

Adicione ao final do `~/.zshrc` (ou `~/.bashrc`):

```bash
export PATH="$PATH:$HOME/development/flutter/bin"
```

Recarregue o shell (`source ~/.zshrc`) e rode `flutter doctor`.

### Alternativa via Snap

```bash
sudo snap install flutter --classic
sudo snap alias flutter.dart dart
```

> ⚠️ Se optar pelo Snap **não** use também o método ASDF na mesma máquina sem remover um deles antes — PATHs duplicados causam conflitos de versão.

---

## Método 2 — Instalação via ASDF (recomendado para a equipe)

Gerencia a versão do Flutter por projeto via arquivo `.tool-versions` — este repositório já contém o fix em `3.47.1-stable`, então toda a equipe usa exatamente a mesma versão.

### 1. Pré-requisitos

- [asdf](https://asdf-vm.com/guide/getting-started.html) instalado;
- Dependência do plugin: `jq`:

  ```bash
  sudo apt-get install -y jq
  ```

### 2. Instalar o plugin e o SDK

```bash
asdf plugin add flutter
cd ativamente            # pasta do projeto (com .tool-versions)
asdf install             # lê .tool-versions e instala 3.47.1-stable
```

Para instalar manualmente uma versão específica:

```bash
asdf list all flutter | grep stable | tail   # versões disponíveis
asdf install flutter 3.47.1-stable
```

### 3. Ativar a versão

O repositório já traz o `.tool-versions`, que ativa automaticamente a versão dentro da pasta do projeto. Para definir globalmente (opcional):

```bash
asdf global flutter 3.47.1-stable
```

### 4. Ajustes finos

- O plugin fornece os shims de **`flutter` e `dart`** juntos.
- **VS Code** não encontrando o SDK: exporte no `~/.zshrc`:

  ```bash
  export FLUTTER_ROOT="$(asdf where flutter)"
  ```

- Equipe usando FVM? O asdf pode ler `.fvmrc` ativando `legacy_version_file = yes` no `~/.asdfrc`.
- Alternativa equivalente: [mise](https://mise.jdx.dev/) (compatível com plugins e `.tool-versions` do asdf).

---

## Próximos passos

Com o SDK instalado, siga o passo a passo de execução local no [`README.md`](../README.md#como-executar-localmente).
