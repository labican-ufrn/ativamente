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

## 3. Fluxo de Release (GitFlow Simplificado para Fase 0.x.y)

Durante o desenvolvimento inicial (versões `0.x.y`), adota-se um **GitFlow simplificado**: as releases são criadas diretamente via Pull Request de `dev` para `main`. Branches dedicadas (`release/vX.Y.Z`) são reservadas apenas para versões *Release Candidate* (RC) e a partir da `v1.0.0`.

```mermaid
gitGraph
    commit id: "dev"
    commit id: "feat: intensidade"
    commit id: "chore(release): prepara versao v0.1.0"
    checkout main
    merge dev tag: "v0.1.0"
```

### Passo a Passo da Release (Fase 0.x.y):

1. **Atualizar versão e changelog na branch `dev` (ou em feature de release):**
   ```bash
   git checkout dev
   git pull origin dev

   # Incrementa versão no pubspec.yaml e atualiza CHANGELOG.md
   dart run tool/bump_version.dart [patch|minor|major]

   # Commita as alterações
   git add pubspec.yaml CHANGELOG.md
   git commit -m "chore(release): prepara versao v0.1.0"
   git push origin dev
   ```

2. **Abrir Pull Request de `dev` para `main`:**
   * Título do PR: `Release v0.1.0` (ou a versão correspondente).
   * Validação obrigatória do CI (`flutter analyze`, testes e SonarQube Quality Gate).
   * Fazer o merge do PR na branch `main`.

3. **Criar e enviar a tag de release na `main`:**
   ```bash
   git checkout main
   git pull origin main
   git tag -a v0.1.0 -m "Release v0.1.0"
   git push origin v0.1.0
   ```

4. **Branches dedicadas `release/vX.Y.Z`:**
   * Ficam reservadas para versões estáveis maiores (ex.: `v1.0.0-rc.1`, `v1.0.0`), quando o app atingir maturidade para publicação nas lojas oficiais.

---

## 4. Automação CI/CD no GitHub Actions

O repositório conta com o workflow `.github/workflows/release.yml`.

### Como Funciona:
1. **Gatilho**: Ao receber um push de tag com prefixo `v*` (ex.: `git push origin v0.1.0`), ou via disparo manual no GitHub Actions (`workflow_dispatch`).
2. **Validação**: Verifica se a release provém da branch `main`, executa `flutter analyze` e a suíte de testes `flutter test`.
3. **Compilação de Artefatos**:
   * Gera o pacote de distribuição Web: `ativamente-web-v0.1.0.zip` (o acesso ao sistema é realizado via navegador no endereço de deploy oficial do Firebase Hosting; a compilação de APKs fica reservada para etapas futuras).
4. **Publicação no GitHub Releases**:
   * Extrai automaticamente as notas do `CHANGELOG.md` referentes à versão.
   * Cria a **Release Oficial** no GitHub com o changelog e anexa o pacote Web para download e arquivamento.

### Segredos do Repositório (Repository Secrets) para Releases

Para que o workflow consiga compilar a aplicação Web de produção e gerar as credenciais oficiais sem expô-las no repositório Git, configure o seguinte segredo em **Settings > Secrets and variables > Actions**:

| Segredo | Obrigatório | Descrição |
|---|---|---|
| `FIREBASE_OPTIONS_DART` | Sim | Conteúdo integral do arquivo `lib/firebase_options.dart` oficial gerado pelo comando `flutterfire configure` apontando para o projeto Firebase de produção (`ativamente-labican-ufrn`). |

---

## 5. Política de Deploy em Produção

* **Branch Oficial:** O deploy do aplicativo em produção (Firebase Hosting e releases públicas acessíveis por usuários externos) é realizado **exclusivamente a partir da branch `main`**.
* **Integridade:** Nenhum deploy para a URL pública oficial (`https://ativamente-labican-ufrn.web.app`) deve ser realizado a partir de branches de feature ou desenvolvimento sem que o código tenha sido previamente integrado e aprovado na `main`.
* **Canais de Pré-visualização (opcional):** Caso seja necessário testar alterações antes do merge na `main`, utiliza-se o canal de preview do Firebase Hosting (`firebase hosting:channel:deploy <canal>`), preservando a URL principal intacta.

