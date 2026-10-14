# Changelog

Todas as mudanças relevantes do AtivaMente são registradas neste arquivo.

## [1.0.0-qa.20261009] - 2026-10-09

### Documentação e qualidade

- adiciona a matriz completa de QA da iteração para Android e Web;
- registra os resultados automatizados, os bloqueios de ambiente e as pendências de integração;
- atualiza o status das histórias de usuário para refletir o branch avaliado;
- documenta o gate de release e os itens que precisam de issue antes da publicação.

### Funcionalidades disponíveis no branch avaliado

- autenticação, cadastro, logout e papéis administrativos;
- catálogo de exercícios e filtros por categoria;
- cronômetro básico de treino;
- edição de dados biométricos;
- leitura de tela e modo de alto contraste;
- seed idempotente do catálogo em ambiente Firebase configurado.

### Pendências conhecidas

- integrar e validar os fluxos de detalhe e execução marcada;
- implementar os alertas de tempo previsto;
- persistir o registro de conclusão do exercício;
- corrigir o fallback do nome do usuário;
- executar a matriz em Android e Web com `firebase_options.dart` disponível.

