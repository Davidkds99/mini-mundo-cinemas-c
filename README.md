# Mini Mundo Cinemas (SQL)

Simulação de uma rede de cinemas — implementação em SQL.  
Este repositório contém o modelo relacional, scripts de criação de esquema (schema), dados de exemplo (seed) e consultas úteis para simular operação de salas, sessões, vendas e ações de manutenção.

Sumário
- Descrição
- Objetivos
- Estrutura de dados (tabelas principais)
- Exemplo de schema (SQLite)
- Dados de exemplo (seed)
- Consultas / Relatórios úteis
- Como executar (SQLite / PostgreSQL / MySQL)
- Boas práticas e testes
- Como contribuir
- Licença
- Autor / Contato

Descrição
--------
O projeto modela as entidades de uma rede de cinemas (salas, filmes, sessões, ingressos, funcionários) usando SQL puro. Ideal para:
- Estudar modelagem relacional e integridade referencial;
- Praticar consultas SQL (joins, agregações, transações);
- Simular regras de negócio (capacidade, ocupação, manutenção).

Objetivos
---------
- Especificar um schema claro e normalizado para o domínio;
- Fornecer scripts reutilizáveis (CREATE TABLE, INSERT);
- Incluir consultas que simulam operações do dia a dia (venda de ingresso, relatório de ocupação, ações de zeladoria).

Estrutura de dados (tabelas principais)
--------------------------------------
- cinemas: unidades físicas (opcional se houver mais de uma localidade)
- salas: identificação, capacidade, estado (ativa, em_manutencao)
- filmes: título, duração, classificação
- sessoes: filme em uma sala num horário, capacidade disponível
- ingressos: venda por sessão
- funcionarios: diretor, zelador, etc.
- acoes_manutenção: registros de ações do zelador/diretor em salas

Observação: a modelagem abaixo visa ser simples e facilmente adaptável a diferentes SGBDs.

Exemplo de schema (SQLite)
--------------------------
```sql
-- schema.sql (exemplo para SQLite)
PRAGMA foreign_keys = ON;

CREATE TABLE cinemas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  endereco TEXT
);

CREATE TABLE salas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cinema_id INTEGER NOT NULL REFERENCES cinemas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  capacidade INTEGER NOT NULL CHECK(capacidade > 0),
  estado TEXT NOT NULL DEFAULT 'ativa' CHECK(estado IN ('ativa','em_manutencao','fechada')),
  descricao TEXT
);

CREATE TABLE filmes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo TEXT NOT NULL,
  duracao_min INTEGER,
  classificacao TEXT
);

CREATE TABLE sessoes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  filme_id INTEGER NOT NULL REFERENCES filmes(id) ON DELETE CASCADE,
  sala_id INTEGER NOT NULL REFERENCES salas(id) ON DELETE CASCADE,
  inicio DATETIME NOT NULL,
  preco REAL NOT NULL CHECK(preco >= 0),
  UNIQUE(sala_id, inicio) -- evita sessões duplicadas na mesma sala/horário
);

CREATE TABLE ingressos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sessao_id INTEGER NOT NULL REFERENCES sessoes(id) ON DELETE CASCADE,
  quantidade INTEGER NOT NULL CHECK(quantidade > 0),
  vendido_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE funcionarios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  cargo TEXT NOT NULL CHECK(cargo IN ('diretor','zelador','atendente','outro'))
);

CREATE TABLE acoes_manutencao (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  funcionario_id INTEGER NOT NULL REFERENCES funcionarios(id) ON DELETE SET NULL,
  sala_id INTEGER NOT NULL REFERENCES salas(id) ON DELETE CASCADE,
  acao TEXT NOT NULL,
  registrado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Índice para consultas frequentes
CREATE INDEX idx_sessoes_sala_inicio ON sessoes(sala_id, inicio);
CREATE INDEX idx_ingressos_sessao ON ingressos(sessao_id);
```

Dados de exemplo (seed)
-----------------------
```sql
-- seed.sql (exemplos)
INSERT INTO cinemas (nome, endereco) VALUES ('Mini Mundo Centro', 'Rua A, 123');

INSERT INTO salas (cinema_id, nome, capacidade) VALUES (1, 'Sala A', 120);
INSERT INTO salas (cinema_id, nome, capacidade) VALUES (1, 'Sala B', 80);

INSERT INTO filmes (titulo, duracao_min, classificacao) VALUES ('Viagem ao C', 110, '12');
INSERT INTO filmes (titulo, duracao_min, classificacao) VALUES ('Aventura X', 95, '10');

INSERT INTO sessoes (filme_id, sala_id, inicio, preco) VALUES (1, 1, '2025-10-21 19:30:00', 20.0);
INSERT INTO sessoes (filme_id, sala_id, inicio, preco) VALUES (2, 2, '2025-10-21 18:00:00', 18.0);

INSERT INTO funcionarios (nome, cargo) VALUES ('Carlos Diretor', 'diretor');
INSERT INTO funcionarios (nome, cargo) VALUES ('Mariana Zeladora', 'zelador');

-- venda de ingressos
INSERT INTO ingressos (sessao_id, quantidade) VALUES (1, 45);
INSERT INTO ingressos (sessao_id, quantidade) VALUES (1, 10);
INSERT INTO ingressos (sessao_id, quantidade) VALUES (2, 30);
```

Consultas / Relatórios úteis
----------------------------
- Ocupação atual de uma sessão:
```sql
SELECT s.id AS sessao_id, f.titulo,
       SUM(COALESCE(i.quantidade,0)) AS ingressos_vendidos,
       sa.capacidade,
       ROUND( SUM(COALESCE(i.quantidade,0)) * 100.0 / sa.capacidade, 2) AS ocupacao_pct
FROM sessoes s
JOIN filmes f ON s.filme_id = f.id
JOIN salas sa ON s.sala_id = sa.id
LEFT JOIN ingressos i ON i.sessao_id = s.id
WHERE s.id = ? -- id da sessão
GROUP BY s.id, f.titulo, sa.capacidade;
```

- Sessões por sala:
```sql
SELECT sa.nome AS sala, s.inicio, f.titulo
FROM sessoes s
JOIN salas sa ON s.sala_id = sa.id
JOIN filmes f ON s.filme_id = f.id
ORDER BY sa.nome, s.inicio;
```

- Vender ingresso (transação, exemplo conceitual):
```sql
-- Exemplo para SGBD que suporta transações (Postgres, MySQL, SQLite)
BEGIN;
-- verificar capacidade disponível (implementar com SELECT FOR UPDATE em SGBDs que suportam)
-- inserir no ingresso quando houver disponibilidade
INSERT INTO ingressos (sessao_id, quantidade) VALUES (?, ?);
COMMIT;
```

- Relatório de manutenção:
```sql
SELECT a.registrado_em, func.nome, sa.nome AS sala, a.acao
FROM acoes_manutencao a
JOIN funcionarios func ON func.id = a.funcionario_id
JOIN salas sa ON sa.id = a.sala_id
ORDER BY a.registrado_em DESC;
```

Como executar (exemplos)
------------------------
Requisitos: um SGBD (SQLite, PostgreSQL ou MySQL) instalado.

SQLite (rápido, sem servidor)
```bash
# criar banco e carregar schema + seed
sqlite3 mini_mundo.db < schema.sql
sqlite3 mini_mundo.db < seed.sql

# abrir CLI
sqlite3 mini_mundo.db
```

PostgreSQL (exemplo)
```bash
# criar DB (PSQL)
createdb mini_mundo
psql mini_mundo -f schema.sql
psql mini_mundo -f seed.sql
```

MySQL (exemplo)
```bash
mysql -u root -p -e "CREATE DATABASE mini_mundo;"
mysql -u root -p mini_mundo < schema.sql
mysql -u root -p mini_mundo < seed.sql
```

Boas práticas e testes
---------------------
- Use transações ao manipular vendas para evitar oversell (vender mais que a capacidade).
- Validar entradas (quantidade > 0, horários coerentes).
- Testes manuais sugeridos:
  - Criar muitas vendas até lotação e validar cálculo de ocupação;
  - Registrar manutenção e verificar mudança de estado da sala;
  - Testar exclusão em cascata (deletar filme -> sessoes -> ingressos).

Como contribuir
---------------
1. Abra uma issue descrevendo bug ou melhoria.
2. Proponha alterações no schema.sql/seed.sql em uma branch.
3. Inclua exemplos de consultas e casos de teste.
4. Faça PR com descrição clara de mudanças e impactos no modelo.

Licença
-------
Se desejar, recomendamos MIT para facilitar contribuições. Adicione um arquivo LICENSE com o texto da MIT License.

Autor / Contato
---------------
Davidkds99 — repositório: mini-mundo-cinemas-c

Arquivos que posso gerar para você (opcional):
- schema.sql (versão completa para o seu SGBD preferido)
- seed.sql (dados de exemplo)
- queries.sql (conjunto de consultas e relatórios)
Quer que eu crie esses arquivos prontos para o repositório?
