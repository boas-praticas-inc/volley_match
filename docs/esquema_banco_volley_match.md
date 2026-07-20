# Esquema concreto do banco - Volley Match

Este documento define um esquema SQLite inicial para sustentar as features de jogadores, sorteio de times, partidas, placar por sets, eventos e historico.

## Premissas

- O app usa SQLite local via `sqflite`.
- `players` sao globais no app.
- `events` agrupam encontros/babas.
- `teams` pertencem a um evento e podem ser usados em uma ou mais partidas daquele evento.
- `matches` pertencem a um evento.
- `match_teams` define quais times jogaram uma partida e em qual lado.
- `player_teams` define quais jogadores compoem cada time.
- `sets` guarda o placar final de cada set.
- `match_points` e opcional, mas recomendada se o app for registrar ponto a ponto.

## Tabelas

### players

Guarda a base geral de jogadores cadastrados.

```sql
CREATE TABLE players (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  position TEXT NOT NULL,
  skill_rating INTEGER NOT NULL CHECK (skill_rating BETWEEN 1 AND 10),
  photo_path TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

Campos principais:
- `position`: exemplos: `Ponteiro`, `Levantador`, `Central`, `Oposto`, `Libero`.
- `skill_rating`: nota de habilidade usada para balancear sorteios.
- `is_active`: permite esconder jogador sem apagar historico.

### events

Agrupa partidas e times de um encontro.

```sql
CREATE TABLE events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  event_date TEXT NOT NULL,
  location TEXT,
  status TEXT NOT NULL DEFAULT 'scheduled',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

Valores sugeridos para `status`:
- `scheduled`
- `in_progress`
- `finished`
- `cancelled`

### teams

Representa times sorteados ou criados dentro de um evento.

```sql
CREATE TABLE teams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  color TEXT,
  origin TEXT NOT NULL DEFAULT 'draw',
  created_at TEXT NOT NULL,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);
```

Valores sugeridos para `origin`:
- `draw`: time gerado por sorteio.
- `manual`: time montado manualmente.

### player_teams

Tabela de associacao entre jogadores e times.

```sql
CREATE TABLE player_teams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  team_id INTEGER NOT NULL,
  player_id INTEGER NOT NULL,
  is_present INTEGER NOT NULL DEFAULT 1,
  is_captain INTEGER NOT NULL DEFAULT 0,
  rotation_order INTEGER,
  assigned_position TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
  FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE RESTRICT,
  UNIQUE (team_id, player_id)
);
```

Uso:
- `is_present`: registra se o jogador estava presente naquele evento/time.
- `rotation_order`: pode apoiar o guia de rotacao.
- `assigned_position`: permite registrar a posicao usada naquele time sem alterar o cadastro global do jogador.

### matches

Representa uma partida dentro de um evento.

```sql
CREATE TABLE matches (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGER NOT NULL,
  scheduled_at TEXT,
  started_at TEXT,
  finished_at TEXT,
  status TEXT NOT NULL DEFAULT 'scheduled',
  winner_team_id INTEGER,
  sets_to_win INTEGER NOT NULL DEFAULT 2,
  best_of_sets INTEGER NOT NULL DEFAULT 3,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (winner_team_id) REFERENCES teams(id) ON DELETE SET NULL
);
```

Valores sugeridos para `status`:
- `scheduled`
- `in_progress`
- `finished`
- `cancelled`

Observacao:
- Evite persistir apenas `result` como texto. Resultado textual pode ser calculado a partir de `sets` e `winner_team_id`.

### match_teams

Define os times que participam de uma partida.

```sql
CREATE TABLE match_teams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  match_id INTEGER NOT NULL,
  team_id INTEGER NOT NULL,
  side TEXT NOT NULL,
  draw_order INTEGER,
  FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE RESTRICT,
  UNIQUE (match_id, team_id),
  UNIQUE (match_id, side)
);
```

Valores sugeridos para `side`:
- `home`
- `away`

### sets

Guarda o placar final de cada set.

```sql
CREATE TABLE sets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  match_id INTEGER NOT NULL,
  set_number INTEGER NOT NULL,
  home_team_id INTEGER NOT NULL,
  away_team_id INTEGER NOT NULL,
  home_score INTEGER NOT NULL DEFAULT 0,
  away_score INTEGER NOT NULL DEFAULT 0,
  winner_team_id INTEGER,
  is_tiebreak INTEGER NOT NULL DEFAULT 0,
  finished_at TEXT,
  FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
  FOREIGN KEY (home_team_id) REFERENCES teams(id) ON DELETE RESTRICT,
  FOREIGN KEY (away_team_id) REFERENCES teams(id) ON DELETE RESTRICT,
  FOREIGN KEY (winner_team_id) REFERENCES teams(id) ON DELETE SET NULL,
  UNIQUE (match_id, set_number)
);
```

Observacao:
- Este formato evita criar uma linha por time dentro do set.
- Consultas como `25 x 22 no set 2` ficam diretas.

### match_points

Opcional. Use se o app precisar registrar ponto a ponto e permitir desfazer ponto, historico detalhado ou estatisticas futuras.

```sql
CREATE TABLE match_points (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  match_id INTEGER NOT NULL,
  set_id INTEGER NOT NULL,
  sequence_number INTEGER NOT NULL,
  scoring_team_id INTEGER NOT NULL,
  home_score_after INTEGER NOT NULL,
  away_score_after INTEGER NOT NULL,
  event_type TEXT NOT NULL DEFAULT 'point',
  created_at TEXT NOT NULL,
  FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
  FOREIGN KEY (set_id) REFERENCES sets(id) ON DELETE CASCADE,
  FOREIGN KEY (scoring_team_id) REFERENCES teams(id) ON DELETE RESTRICT,
  UNIQUE (set_id, sequence_number)
);
```

Valores sugeridos para `event_type`:
- `point`
- `undo`
- `adjustment`

## Indices recomendados

```sql
CREATE INDEX idx_players_name ON players(name COLLATE NOCASE);
CREATE INDEX idx_players_position ON players(position);
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_teams_event_id ON teams(event_id);
CREATE INDEX idx_player_teams_team_id ON player_teams(team_id);
CREATE INDEX idx_player_teams_player_id ON player_teams(player_id);
CREATE INDEX idx_matches_event_id ON matches(event_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_match_teams_match_id ON match_teams(match_id);
CREATE INDEX idx_sets_match_id ON sets(match_id);
CREATE INDEX idx_match_points_set_id ON match_points(set_id);
```

## Ordem de criacao

1. `players`
2. `events`
3. `teams`
4. `player_teams`
5. `matches`
6. `match_teams`
7. `sets`
8. `match_points`
9. indices
