# Arquitetura Oficial

Decisao em 19/07/2026: o projeto segue `feature-first + MVVM + Repository`.

Nao estamos usando Clean Architecture completa como padrao. A camada de `usecases` nao e parte da estrutura oficial do projeto.

## Estrutura por feature

```text
feature/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    services/
  presentation/
    pages/
    viewmodels/
    widgets/
```

`domain/services/` e opcional. Use apenas quando existir regra de negocio pura que precisa ser compartilhada, testada isoladamente ou removida da UI/data source.

## Responsabilidades

- `pages/`: montam a tela, escutam ViewModels e tratam efeitos visuais como navegacao, dialogs e snackbars.
- `widgets/`: componentes visuais sem regra de negocio.
- `viewmodels/`: guardam estado da tela, validam entradas, aplicam filtros, orquestram fluxo e chamam repositories/services.
- `domain/entities/`: objetos de negocio simples, sem Flutter, SQLite ou serializacao.
- `domain/repositories/`: contratos que a presentation pode consumir sem conhecer a origem dos dados.
- `domain/services/`: regras puras de dominio, sem acesso a banco, contexto Flutter ou side effects.
- `data/models/`: conversao entre entidade e formato de persistencia.
- `data/datasources/`: acesso direto a SQLite/APIs/arquivos.
- `data/repositories/`: implementam contratos do domain e coordenam data sources.

## Regra de dependencia

Fluxo padrao:

```text
Page/Widget -> ViewModel -> Repository contract -> Repository impl -> DataSource
```

Servicos de dominio entram quando ha regra reutilizavel ou complexa:

```text
ViewModel/Repository/DataSource -> Domain Service
```

A regra nao deve ficar inline em `page`, `widget` ou `datasource` quando ela puder ser nomeada e testada como regra de dominio.

## O que nao fazer

- Nao criar `UseCase` para apenas repassar uma chamada ao repository.
- Nao criar pasta `domain/usecases/` em novas features.
- Nao acessar `DataSource` diretamente a partir de `Page` ou `ViewModel`.
- Nao colocar SQL, maps de banco ou `BuildContext` dentro do domain.
- Nao misturar navegacao, snackbar ou dialog dentro de ViewModel.

## Quando criar um service

Crie um service em `domain/services/` quando a regra:

- for pura e independente de Flutter/SQLite;
- tiver condicional ou algoritmo relevante;
- precisar ser usada por mais de uma tela/fluxo;
- merecer teste unitario isolado.

Exemplos atuais:

- `BalancedTeamGenerator`: sorteio equilibrado dos times.
- `MatchQueueService`: regra de fila do evento.
- `PointEventNormalizer`: normalizacao dos eventos de ponto.
- `RotationCalculator`: calculo de rotacao.

## Quando chamar repository direto

Chame repository direto no ViewModel quando a acao for uma operacao de dados clara, como salvar sorteio, iniciar partida, editar nome, listar registros ou remover item.

Criar um wrapper chamado `UseCase` nesses casos so adiciona indirecao sem regra nova.