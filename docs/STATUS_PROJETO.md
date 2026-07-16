# Status do Projeto - Volley Match

Atualizado em 16/07/2026.

## Objetivo do app

O `Volley Match` e um aplicativo Flutter para organizar partidas recreativas de volei com foco em:
- cadastro de jogadores;
- sorteio equilibrado de times;
- controle de placar por sets;
- apoio visual para rotacoes taticas;
- historico de partidas e eventos.

## O que ja foi feito

### Base do projeto
- Projeto Flutter inicializado e configurado para `android`.
- Dependencias principais adicionadas em `pubspec.yaml`: `sqflite` e `path`.
- Tema global configurado com `Material 3` em `lib/core/theme/`.
- Roteamento centralizado em `lib/core/router/`.
- Estrutura arquitetural `feature-first + MVVM` criada para todas as features.
- Componentes compartilhados criados em `lib/shared/widgets/`.

### Navegacao e shell do app
- `main.dart` inicializa o app com `WidgetsFlutterBinding.ensureInitialized()`.
- `app.dart` centraliza `MaterialApp`, tema, rota inicial e `onGenerateRoute`.
- `FeatureNavBar` ja conecta as rotas principais de `home`, `players`, `team_draw` e `scoreboard`.
- As paginas de `event`, `match` e `rotation_guide` ja existem e podem ser acessadas por rota.

### Persistencia local
- Banco SQLite preparado em `lib/core/database/app_database.dart`.
- Abertura singleton do banco implementada.
- Tabela `players` ja criada no `onCreate`.
- `DatabaseTables` ja antecipa as tabelas futuras:
  - `events`
  - `matches`
  - `sets`
  - `players`
  - `teams`
  - `match_teams`
  - `player_teams`

### Feature de jogadores
Esta e a parte mais madura do projeto neste momento.

Ja existe implementacao funcional para:
- listagem de jogadores;
- busca por nome;
- filtro por posicao;
- cadastro de jogador;
- edicao de jogador;
- remocao de jogador;
- persistencia dos jogadores em SQLite;
- separacao entre `entity`, `model`, `repository`, `datasource`, `viewmodel` e `pages/widgets`.

Detalhes importantes:
- `PlayerEntity` define a entidade de dominio.
- `PlayerModel` faz o mapeamento `entity <-> map` para o banco.
- `PlayersLocalDataSource` executa CRUD na tabela `players`.
- `PlayersRepositoryImpl` conecta dados locais ao dominio.
- `PlayersViewModel` controla carregamento, erro, busca, filtro e atualizacao de estado da tela.
- `PlayerForm` ja padroniza formulario de cadastro/edicao.

Campos atualmente suportados para jogador:
- `id`
- `name`
- `position`
- `skill_rating`
- `photo_path`

Observacao:
- o campo de foto existe no modelo e no banco, mas a selecao real da imagem ainda esta em placeholder.

### Feature de sorteio de times
Ja existe uma base funcional parcial.

Ja foi feito:
- tela de sorteio criada;
- carregamento real dos jogadores a partir do repositorio;
- selecao/deselecao de jogadores presentes;
- resumo da quantidade selecionada;
- habilitacao do botao de sorteio quando existe selecao.

Ainda nao foi feito:
- algoritmo de balanceamento dos times;
- definicao de quantidade de times;
- exibicao do resultado do sorteio;
- persistencia do sorteio ou vinculacao com partida/evento.

### Home
Ja foi feito:
- tela inicial com acoes rapidas;
- atalho para sorteio;
- atalho para iniciar partida;
- secao de partidas recentes.

Estado atual:
- os itens de partidas recentes ainda sao mockados no `HomeViewModel`.

### Features preparadas, mas ainda em placeholder
As features abaixo ja possuem pastas, paginas e viewmodels iniciais, mas ainda nao possuem regra de negocio implementada:
- `scoreboard`
- `rotation_guide`
- `event`
- `match`

Hoje elas funcionam como casca de interface para indicar responsabilidade futura.

### Testes
- Existe um teste de widget basico em `test/widget_test.dart`.
- O teste atual valida renderizacao da home e da entrada `Jogadores`.
- Ainda nao existem testes de repositorio, banco, viewmodel ou fluxo de CRUD.

## Padrao do projeto

## Arquitetura
O projeto segue o padrao `feature-first + MVVM`.

Cada feature deve ficar isolada em sua propria pasta dentro de `lib/features/`.

Estrutura padrao:

```text
feature/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    pages/
    viewmodels/
    widgets/
```

Responsabilidades por camada:
- `data`: acesso a banco, mapeamento de modelos e implementacao de repositorios.
- `domain`: entidades e contratos de negocio.
- `presentation`: telas, widgets e viewmodels.

## Convencoes de implementacao
- Novas features devem seguir a mesma estrutura de pastas ja criada.
- Regras de acesso a dados devem passar por `repository`, nao diretamente pela UI.
- A UI deve conversar com `viewmodels`, nao com `datasources`.
- Entidades de dominio devem permanecer simples e independentes da camada visual.
- Modelos de dados devem ser responsaveis por serializacao e desserializacao.
- Widgets reutilizaveis devem ir para `shared/widgets/` quando fizerem sentido fora de uma feature.
- Strings globais e configuracoes comuns devem ficar em `core/`.
- Rotas novas devem ser centralizadas em `app_routes.dart` e `app_router.dart`.
- O projeto usa `flutter_lints`; novas alteracoes devem manter o codigo compativel com `flutter analyze`.

## Padrao visual atual
- Tema centralizado em `lib/core/theme/app_theme.dart`.
- Paleta centralizada em `lib/core/theme/app_colors.dart`.
- Uso de `Material 3`.
- Cards com bordas arredondadas.
- Inputs com fundo preenchido e bordas suaves.
- Navegacao principal baseada em `NavigationBar`.

## Decisoes tecnicas ja assumidas
- Persistencia local com SQLite no Android.
- Sem necessidade atual de adaptacao para web.
- Banco local como fonte principal para jogadores e, futuramente, partidas/eventos.
- Estrutura preparada para expandir gradualmente cada modulo sem refatoracao grande de pastas.

## Plano de desenvolvimento seguido ate agora

A sequencia natural que o projeto ja demonstra hoje e esta:

### Fase 1 - Fundacao do app
Status: concluida em grande parte.

Entregas:
- estrutura Flutter inicial;
- arquitetura base;
- tema;
- rotas;
- componentes compartilhados;
- configuracao inicial do banco.

### Fase 2 - Cadastro de jogadores
Status: funcional.

Entregas:
- entidade de jogador;
- tabela `players`;
- CRUD local;
- listagem com busca e filtro;
- cadastro e edicao.

Pendencias ainda ligadas a esta fase:
- selecao real de foto;
- testes automatizados do fluxo de jogadores;
- eventual validacao extra de formulario.

### Fase 3 - Sorteio de times
Status: em andamento.

O que ja entrou:
- leitura dos jogadores cadastrados;
- selecao de presentes;
- estado da tela de sorteio.

Proximo passo objetivo desta fase:
- implementar o algoritmo de balanceamento com base em `skillRating` e, se necessario, em `position`.

### Fase 4 - Placar e fluxo de partida
Status: ainda nao iniciada de forma funcional.

Escopo previsto:
- pontuacao por rally;
- controle de sets;
- definicao do vencedor;
- registro do resultado da partida.

### Fase 5 - Eventos e historico
Status: ainda nao iniciada de forma funcional.

Escopo previsto:
- criar eventos/babas;
- associar partidas a eventos;
- manter historico de encontros e resultados.

### Fase 6 - Guia de rotacoes
Status: ainda nao iniciada de forma funcional.

Escopo previsto:
- representar sistemas `6x0` e `5x1`;
- mostrar rotacao por posicao;
- servir como apoio visual durante a partida.

## Ordem recomendada para o time continuar

Para evitar retrabalho, a ordem mais consistente neste momento e:
1. concluir `team_draw` com algoritmo real e tela de resultado;
2. implementar `scoreboard` com estado de partida e sets;
3. modelar `match` usando os dados do placar final;
4. modelar `event` para agrupar partidas;
5. finalizar `rotation_guide`;
6. expandir testes automatizados nas camadas de viewmodel, repositorio e widget.

## Divisao sugerida para varios desenvolvedores

Se mais pessoas forem atuar ao mesmo tempo, a divisao mais segura e por feature:
- Pessoa 1: `players` e ajustes de base de dados.
- Pessoa 2: `team_draw`.
- Pessoa 3: `scoreboard` + `match`.
- Pessoa 4: `event` + `rotation_guide`.

Regra importante:
- mudancas em `core/`, `shared/`, rotas e banco devem ser combinadas antes para evitar conflito de arquitetura.

## Pontos de atencao
- Hoje apenas a tabela `players` existe fisicamente no banco; as demais tabelas estao apenas planejadas.
- A home ainda usa dados mockados para partidas recentes.
- Algumas strings aparecem com problema de codificacao em partes do codigo atual; vale padronizar tudo em UTF-8 nas proximas alteracoes.
- O botao `Sortear times` ainda nao executa a regra principal da feature.
- As features de `scoreboard`, `event`, `match` e `rotation_guide` ainda nao devem ser tratadas como prontas, apenas estruturadas.

## Referencias do repositorio
- `README.md`: visao geral do projeto.
- `docs/Escopo_Aplicativo_Volei.pdf`: documento de escopo funcional.
- `docs/modelagem_dos_dados_volleyMatch.pdf`: referencia de modelagem dos dados.
- `docs/Telas de Alto Nível/`: material de alto nivel das telas.

## Proxima acao sugerida

Se o time for continuar a partir do estado atual, o proximo marco tecnico mais importante e fechar `team_draw`, porque ele aproveita o cadastro de jogadores ja pronto e prepara o caminho para `match` e `scoreboard`.
