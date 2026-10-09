# Matriz de QA — Iteração 4

**Data da execução:** 09/10/2026  
**Branch avaliado:** `14-docs-qa-de-regressão-atualização-de-documentação-e-release`  
**Plataformas previstas:** Android e Web

## Legenda

| Status | Significado |
|---|---|
| ✅ | Executado e aprovado |
| ⚠️ | Parcial, com limitação registrada |
| ❌ | Falhou ou não está implementado |
| ⏸️ | Bloqueado por ambiente ou integração ausente |

## Pré-condições e evidências

- `flutter analyze`: ⏸️ bloqueado pela ausência de `lib/firebase_options.dart`, arquivo gerado pelo FlutterFire e ignorado pelo repositório. Foram identificados 2 erros de compilação relacionados a essa configuração.
- `flutter test`: ⏸️ bloqueado pelo requisito de symlink do Flutter no Windows (Developer Mode desativado). A suíte existente contém 14 testes em 3 arquivos.
- Não foi possível executar um dispositivo Android nem iniciar o Web com Firebase nesta estação: não há configuração local do FlutterFire nem emuladores ativos.
- O branch avaliado não contém as rotas/telas de detalhe, alertas ou registro. Os branches remotos `origin/feat/detalhes-exercicio` e `origin/feat/marcacao-exercicio-timer` contêm trabalho não integrado; não foram considerados aprovados nesta release.

## Matriz funcional

| Fluxo | Android | Web | Evidência/observação |
|---|---:|---:|---|
| Abertura e tela de boas-vindas | ⏸️ | ⏸️ | Bloqueado pela configuração Firebase |
| Cadastro com dados válidos | ⏸️ | ⏸️ | Fluxo implementado; exige Auth configurado |
| Cadastro com e-mail inválido/duplicado e senha fraca | ⚠️ | ⚠️ | Cobertura automatizada de mensagens em `test/utils/auth_errors_test.dart`; execução Flutter bloqueada |
| Login válido | ⏸️ | ⏸️ | Exige Auth configurado |
| Login inválido e mensagem acessível | ⚠️ | ⚠️ | Traduções cobertas por teste unitário; execução Flutter bloqueada |
| Guarda de rotas privadas | ⚠️ | ⚠️ | Implementado em `lib/routes.dart`; sem teste de integração executável |
| Logout e bloqueio após logout | ⏸️ | ⏸️ | Exige Auth configurado |
| Home, navegação inferior e perfil | ⏸️ | ⏸️ | Exige Auth/Firestore configurados |
| Nome do usuário na Home e no Perfil (US05) | ❌ | ❌ | Ainda há fallback genérico `Usuário` e erro bruto `Erro` |
| Edição de dados biométricos (US06) | ⚠️ | ⚠️ | Código presente no branch; sem execução visual por falta de ambiente |
| Seed idempotente do catálogo (US09) | ⚠️ | ⚠️ | Implementado com emulador/Firestore, mas sem execução nesta QA |
| Listagem por categoria Coração/Músculo (US07) | ⏸️ | ⏸️ | UI presente; catálogo depende do Firestore |
| Detalhe do exercício (US08) | ❌ | ❌ | Rota e tela não estão integradas neste branch |
| Voltar do treino para Home (US10) | ⚠️ | ⚠️ | Código usa `context.pop()`; precisa validação manual de navegação |
| Marcar exercício em execução (US11) | ❌ | ❌ | Provider e integração existem apenas em branch remoto não integrado |
| Cronômetro básico | ⚠️ | ⚠️ | Implementado com `Timer.periodic`; sem validação em device |
| Tempo previsto e diálogo de conclusão (US12) | ❌ | ❌ | Não implementado no branch avaliado |
| Alertas visuais e sonoros após o tempo (US12) | ❌ | ❌ | Não implementado no branch avaliado |
| Registro da conclusão no Firestore (US13) | ❌ | ❌ | Não há chamada de persistência para `RegistroAtivDia` |
| TTS “Ler tela” (US14) | ⚠️ | ⚠️ | Botões/providers presentes; exige validação de áudio em Android e Web |
| Alto contraste e persistência (US15) | ⚠️ | ⚠️ | Testes de provider/widget presentes; execução Flutter bloqueada |
| Acesso de administrador e criação de usuários | ⏸️ | ⏸️ | Exige Auth/Firestore configurados |

## Regressão por plataforma

| Plataforma | Resultado | Bloqueio |
|---|---|---|
| Android | ⏸️ Não executado | Sem dispositivo/emulador disponível e sem `firebase_options.dart` |
| Web | ⏸️ Não executado | Sem configuração FlutterFire local e sem servidor/emulador Firebase |

## Bugs e pendências convertidos em acompanhamento

1. **Crítico — configuração de release não reproduzível:** `firebase_options.dart` não está disponível para análise/build. Deve ser gerado por `flutterfire configure` em cada ambiente e validado no pipeline sem versionar credenciais privadas.
2. **Crítico — escopo da iteração não integrado:** detalhe, execução marcada, alertas e registro não estão no branch avaliado. A release não pode ser considerada funcional até os branches correspondentes serem integrados e testados.
3. **Alto — US05:** nome do usuário ainda pode aparecer como `Usuário` e falhas de leitura como `Erro`, contrariando o fallback previsto.
4. **Alto — QA multiplataforma pendente:** Android e Web precisam ser executados com emuladores/Firestore configurados antes do fechamento da iteração.

Não foi criada uma issue remota automaticamente porque o ambiente não disponibiliza permissão de escrita na API do GitHub. Os itens acima devem ser abertos no repositório antes do merge.

## Gate da release

**Resultado: NÃO APROVADO para produção.** A matriz não possui evidência suficiente para declarar ausência de itens críticos: há configuração de build ausente e funcionalidades críticas da Sprint 3 não integradas. O tag gerado para esta entrega deve ser tratado somente como candidato de QA até que os bloqueios sejam resolvidos.
