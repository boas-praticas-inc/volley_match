# Volley Match

Aplicativo em Flutter para organizar partidas recreativas de volei com foco em sorteio equilibrado, placar por sets e guia visual de rotacoes taticas.

## Stack

- Flutter
- Dart
- Arquitetura `feature-first + MVVM + Repository`
- Alvo habilitado: `android`

## Estrutura

```text
lib/
  app.dart
  main.dart
  core/
    constants/
    database/
    router/
    theme/
    utils/
  shared/
    widgets/
  features/
    home/
    players/
    team_draw/
    scoreboard/
    rotation_guide/
    event/
    match/
```

Cada feature segue a divisao:

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

`domain/services/` e opcional e deve conter apenas regras de negocio puras.
O projeto nao usa `domain/usecases/` como padrao. A decisao arquitetural completa
esta em `docs/ARQUITETURA.md`.

## Mapeamento do escopo

- `players`: cadastro de atletas com nota, posicao e foto.
- `team_draw`: sorteio equilibrado com base nas notas.
- `scoreboard`: pontuacao, sets e historico.
- `rotation_guide`: apoio visual para 6x0 e 5x1.
- `event`: agrupamento de partidas e times.
- `match`: historico e resultado das partidas.

## Persistencia

O documento de modelagem aponta para persistencia local relacional. A base do projeto ja foi preparada em `lib/core/database/`.

A persistencia pode seguir diretamente para SQLite no Android, sem a necessidade de adaptar a arquitetura para navegador.

## Como rodar

```bash
flutter pub get
flutter run -d android
```
