# Versionamento Semântico e Gestão de Releases — AtivaMente

Este documento descreve as diretrizes de **Versionamento Semântico (SemVer 2.0.0)**, convenção de **tags Git** e o fluxo de **Releases** no aplicativo AtivaMente.

---

## 1. Padrão de Versionamento no Flutter

No ecossistema Flutter, a versão é definida no arquivo `pubspec.yaml`:

```yaml
version: MAJOR.MINOR.PATCH+BUILD_NUMBER
# Exemplo inicial: 0.1.0+1
```

### Componentes da Versão:

| Componente | Exemplo | Finalidade no Flutter/Lojas | Quando Incrementar |
|---|---|---|---|
| **`MAJOR`** | **0**.1.0 | Versão maior visível ao usuário | Alterações que quebram compatibilidade (`BREAKING CHANGE` ou `feat!:`) |
| **`MINOR`** | 0.**2**.0 | Nova funcionalidade visível | Novas telas, recursos e fluxos sem quebra (`feat:`) |
| **`PATCH`** | 0.1.**1** | Correção de bug visível | Ajustes finos, correções de bugs (`fix:`) |
| **`+BUILD_NUMBER`** | 0.1.0+**2** | Número sequencial inteiro | **Obrigatório a cada release** (`versionCode` no Android, `CFBundleVersion` no iOS) |

> ℹ **Fase Inicial `0.x.y`:**  
> O projeto inicia na versão `0.1.0+1`. Versões com `MAJOR = 0` indicam desenvolvimento inicial ativo, onde a API e os fluxos de usuário ainda estão sendo estabilizados até a primeira grande entrega estável (`v1.0.0`).

---

## 2. Ferramentas e Plugins para Dart/Flutter

No ecossistema Dart/Flutter, existem ferramentas consolidadas para SemVer:

1. **Script do Projeto (`tool/bump_version.dart`)** *(Recomendado para o dia a dia)*:
   * Script em Dart nativo incluído no repositório.
   * Não requer instalação de pacotes globais nem ferramentas externas.
   * Atualiza simultaneamente o `pubspec.yaml` e adiciona o bloco da versão no `CHANGELOG.md`.
2. **`cider` ([pub.dev/packages/cider](https://pub.dev/packages/cider))**:
   * CLI popular em Dart para gerenciar versão e manter `CHANGELOG.md` segundo o padrão *Keep a Changelog*.
   * Pode ser ativado via: `dart pub global activate cider`.
3. **`pub_semver` ([pub.dev/packages/pub_semver](https://pub.dev/packages/pub_semver))**:
   * Biblioteca oficial do time Dart utilizada internamente pelo gerenciador `pub` para manipulação programática de SemVer 2.0.0.

---

## 3. Passo a Passo do Fluxo de Release (GitFlow)

O processo de release integra o padrão GitFlow do projeto (`dev` → `release/vX.Y.Z` → `main`):

```mermaid
gitGraph
    commit id: "dev"
    commit id: "feat: intensidade"
    branch release/v0.2.0
    checkout release/v0.2.0
    commit id: "chore(release): prepara versao v0.2.0"
    checkout main
    merge release/v0.2.0 tag: "v0.2.0"
    checkout dev
    merge release/v0.2.0
```

### Passo 1: Criar a branch de release a partir de `dev`

Garanta que a branch `dev` local está atualizada:
```bash
git checkout dev
git pull origin dev
```

Crie a branch de release:
```bash
git checkout -b release/v0.2.0
```

### Passo 2: Executar o script de versionamento

Execute o script especificando o tipo de incremento (`patch`, `minor` ou `major`):

```bash
# Para correções de bugs (ex.: 0.1.0+1 -> 0.1.1+2)
dart run tool/bump_version.dart patch

# Para novas funcionalidades (ex.: 0.1.0+1 -> 0.2.0+2)
dart run tool/bump_version.dart minor

# Para grandes entregas / quebra (ex.: 0.9.0+9 -> 1.0.0+10)
dart run tool/bump_version.dart major
```

O script atualizará automaticamente o `pubspec.yaml` e adicionará a entrada no `CHANGELOG.md`.

### Passo 3: Revisar o `CHANGELOG.md` e commitar

Edite o `CHANGELOG.md` para descrever os itens entregues sob a seção recém-criada (`Adicionado`, `Modificado`, `Corrigido`).

Faça o commit seguindo os Conventional Commits:
```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): prepara versao v0.2.0"
git push origin release/v0.2.0
```

### Passo 4: Abrir Pull Request para `main`

* Abra o PR com destino à branch `main`.
* Título do PR: `Release v0.2.0`.
* Após aprovação e aprovação do SonarQube Quality Gate, faça o merge do PR na `main`.

### Passo 5: Criar e enviar a tag de release

Na branch `main` atualizada após o merge:
```bash
git checkout main
git pull origin main
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin v0.2.0
```

### Passo 6: Back-merge em `dev`

Sincronize a branch `dev` com as atualizações de versão e changelog:
```bash
git checkout dev
git merge main
git push origin dev
```

---

## 4. Automação CI/CD no GitHub Actions

O repositório conta com o workflow `.github/workflows/release.yml`.

### Como Funciona:
1. **Gatilho**: Ao receber um push de tag com prefixo `v*` (ex.: `git push origin v0.2.0`), ou via disparo manual no GitHub Actions (`workflow_dispatch`).
2. **Validação**: Roda `flutter analyze` e a suite de testes `flutter test`.
3. **Compilação de Artefatos**:
   * Gera o APK Android otimizado: `build/app/outputs/flutter-apk/ativamente-v0.2.0.apk`.
   * Gera o pacote Web compactado: `ativamente-web-v0.2.0.zip`.
4. **Publicação no GitHub Releases**:
   * Extrai automaticamente as notas do `CHANGELOG.md` referentes àquela versão.
   * Cria a **Release Oficial** no GitHub com o changelog e anexa os artefatos compilados para download direto.

---

## 5. Política de Deploy em Produção

* **Branch Oficial:** O deploy do aplicativo em produção (Firebase Hosting e releases públicas acessíveis por usuários externos) é realizado **exclusivamente a partir da branch `main`**.
* **Integridade:** Nenhum deploy para a URL pública oficial (`https://ativamente-labican-ufrn.web.app`) deve ser realizado a partir de branches de feature ou desenvolvimento sem que o código tenha sido previamente integrado e aprovado na `main`.
* **Canais de Pré-visualização (opcional):** Caso seja necessário testar alterações antes do merge na `main`, utiliza-se o canal de preview do Firebase Hosting (`firebase hosting:channel:deploy <canal>`), preservando a URL principal intacta.

