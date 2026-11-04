# Integração Contínua (CI) e Análise de Qualidade com SonarQube

Este documento descreve a infraestrutura de CI/CD e análise estática de código configurada para o projeto **AtivaMente** (UFRN/Labican), atendendo aos critérios da **Issue #36**.

---

## 1. Visão Geral

A pipeline automatizada do GitHub Actions executa em:
- **Pushes** nas branches `dev` e `main`.
- **Pull Requests** direcionados a `dev` e `main`.
- **Disparo manual** (`workflow_dispatch`).

O pipeline realiza os seguintes passos:
1. **Checkout completo** do repositório (`fetch-depth: 0`), necessário para cálculo de blame, novas linhas de código e histórico no SonarQube.
2. **Setup do Java 21** e **Flutter 3.47.1-stable** (alinhado com o `.tool-versions`).
3. **Instalação de dependências:** `flutter pub get`.
4. **Análise estática:** `flutter analyze` garantindo conformidade com o linter (`analysis_options.yaml`).
5. **Execução de testes e cobertura:** `flutter test --coverage`, gerando `coverage/lcov.info`.
6. **SonarQube Scan:** Execução do scanner com avaliação bloqueante do Quality Gate no SonarQube (modo unificado compatível com a Community Edition).

---

## 2. Configurações do SonarQube

O arquivo `sonar-project.properties` na raiz do repositório é a fonte da verdade da configuração do Sonar:

```properties
sonar.projectKey=labican-ufrn_ativamente
sonar.projectName=ativamente
sonar.projectVersion=1.0.0
sonar.sourceEncoding=UTF-8

sonar.sources=lib
sonar.tests=test

# Exclusões espelhadas a partir de .ypa/review.yml
sonar.exclusions=**/test/**,lib/firebase_options.dart,**/*.g.dart,**/*.freezed.dart,build/**,.dart_tool/**
sonar.coverageExclusions=**/test/**,lib/firebase_options.dart,**/*.g.dart,**/*.freezed.dart,build/**,.dart_tool/**

# Cobertura LCOV gerada por `flutter test --coverage`
# (sonar.dart.lcov.reportPaths é a propriedade oficial do analisador Dart/Flutter)
sonar.dart.lcov.reportPaths=coverage/lcov.info
sonar.dart.coverage.reportPaths=coverage/lcov.info

# Bloqueio até avaliação do Quality Gate
sonar.qualitygate.wait=true
```

### Exclusões de Análise e Cobertura
Arquivos gerados automaticamente (`*.g.dart`, `*.freezed.dart`), configurações de plataforma (`lib/firebase_options.dart`), diretórios de build (`build/**`, `.dart_tool/**`) e testes (`test/**`) são excluídos da análise de código de produção e do cômputo de cobertura, evitando ruído e métricas distorcidas.

---

## 3. Segredos no GitHub (Repository Secrets)

Para que a pipeline consiga autenticar e enviar os dados para o servidor do SonarQube ou SonarCloud, devem ser configurados em **Settings > Secrets and variables > Actions**:

| Segredo | Obrigatório | Descrição |
|---|---|---|
| `SONAR_TOKEN` | Sim | Token de autenticação gerado na conta/organização do Sonar. |
| `SONAR_HOST_URL` | Se On-Premise | URL do servidor SonarQube (ex.: `https://sonar.labican.imd.ufrn.br`). Se estiver utilizando o SonarCloud oficial (`https://sonarcloud.io`), este campo pode ser omitido ou configurado com a URL do SonarCloud. |

---

## 4. Análise com SonarQube Community Edition

A action utiliza a versão oficial segura `SonarSource/sonarqube-scan-action@v6`. Como o servidor utilizado é o **SonarQube Community Edition** (que não possui suporte nativo a múltiplos branches/PRs sem plugins adicionais proprietários), a esteira executa a análise de qualidade de forma unificada:
- O scan é executado em eventos de `push` e `pull_request` para validar a saúde do código e a cobertura LCOV.
- Não são enviados parâmetros comerciais como `-Dsonar.pullrequest.*` ou `-Dsonar.branch.name`, evitando rejeição por falta de licença comercial no servidor Community Edition.
- Com `-Dsonar.qualitygate.wait=true`, o job aguarda a avaliação das métricas no servidor antes de concluir a execução, garantindo que qualquer violação do Quality Gate falhe a esteira no GitHub com **barra vermelha**.
- Em branches protegidas (`main` e `dev`), a presença do `SONAR_TOKEN` é obrigatória; caso ausente, a esteira falha imediatamente.

---

## 5. Configuração do Quality Gate e Proteção de Branches

Para assegurar o piso de **65% de cobertura** e a obrigatoriedade da esteira:

### 5.1. No SonarQube / SonarCloud (Quality Gate)
> **Responsável pela configuração no servidor:** Taciano Silva ([@tacianosilva](https://github.com/tacianosilva) / Labican).

O parâmetro de 65% de cobertura não é configurável client-side no `sonar-project.properties`; ele deve ser confirmado no próprio painel do SonarQube:
1. Acesse o projeto no SonarQube e navegue até **Project Settings > Quality Gate**.
2. Garanta que o Quality Gate associado ao projeto inclua as seguintes condições:
   - **Coverage on New Code** (ou **Overall Coverage**): `is less than 65.0%` → **Error** (bloqueia o gate e falha a pipeline).
   - **Bugs**, **Vulnerabilities** e **Security Hotspots**: sem ocorrências críticas.

### 5.2. No SonarQube / SonarCloud (Quality Profile de Dart)
O projeto segue o padrão oficial do **Effective Dart** (`prefer_single_quotes: true`), padronizando o uso de aspas simples:
1. No menu **Quality Profiles** do SonarQube/SonarCloud, foi criado e associado ao projeto o perfil customizado **`Dart Ativamente`**.
2. A regra `prefer_double_quotes` foi **desativada**.
3. O código no repositório segue a regra alinhada com o [`analysis_options.yaml`](../analysis_options.yaml).

### 5.3. No GitHub (Branch Protection Rules)
Para que a reprovação no Quality Gate bloqueie efetivamente o botão de merge:
1. No GitHub, acesse **Settings > Branches**.
2. Em **Branch protection rules**, configure regras para `dev` e `main`:
   - Marque **Require status checks to pass before merging**.
   - Em **Status checks that are required**, selecione o check: `Build, Test & SonarQube Analysis`.
   - Marque **Require branches to be up to date before merging**.

---

## 6. Execução Manual / Local (Opcional)

Se você tiver o `sonar-scanner` instalado localmente ou via container Docker, pode executar a análise localmente após rodar os testes:

```bash
# 1. Gerar arquivo de cobertura lcov
flutter test --coverage

# 2. Executar sonar-scanner via Docker (exemplo)
docker run --rm \
  -e SONAR_HOST_URL="<HOST_URL>" \
  -e SONAR_TOKEN="<SEU_TOKEN>" \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli
```
