# Mini Mundo Cinemas (MySQL)

This repository contains MySQL scripts to model and simulate a small cinema chain:
- schema.sql — creation of tables (MySQL / InnoDB / utf8mb4)
- seed.sql — example data (cinemas, rooms, movies, sessions, staff, tickets)
- queries.sql — useful queries, reports and a stored procedure to sell tickets

Sumário
- Sobre
- Requisitos
- Como aplicar os scripts (MySQL)
- Procedimento para venda (exemplo)
- Consultas úteis
- Contribuição
- Licença
- Autor / Contato

Sobre
-----
Modelagem relacional para representar salas, sessões, filmes, ingressos e ações de manutenção. Scripts prontos para rodar em MySQL/InnoDB.

Requisitos
----------
- MySQL 5.7+ (recomendado 8.0) com suporte a InnoDB.
- cliente mysql (CLI) ou ferramenta GUI (MySQL Workbench, DBeaver, etc).

Como aplicar os scripts (linha de comando)
------------------------------------------
1. Clone o repositório e mude para a branch (se estiver usando a branch sugerida):
   git checkout sql-mysql-scripts

2. Criar o banco e carregar schema + seed:
   mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS mini_mundo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   mysql -u root -p mini_mundo < schema.sql
   mysql -u root -p mini_mundo < seed.sql

   (ou, em uma única linha:)
   mysql -u root -p -D mini_mundo < schema.sql
   mysql -u root -p -D mini_mundo < seed.sql

3. Carregar consultas/rotinas (opcional):
   mysql -u root -p mini_mundo < queries.sql

Procedimento para vender ingressos (exemplo)
-------------------------------------------
No arquivo queries.sql há um procedimento armazenado chamado `vender_ingressos(p_sessao_id, p_qtd, p_success_out)`:
- Ele usa transação e locks para evitar oversell.
- Exemplo de uso:
  CALL vender_ingressos(1, 5, @ok);
  SELECT @ok; -- 1 = sucesso, 0 = falha (capacidade insuficiente ou entrada inválida)

Consultas úteis
---------------
Veja queries.sql para exemplos:
- Ocupação atual por sessão
- Sessões por sala
- Relatório de manutenção
- Relatório de ocupação por dia

Licença (tornar explícita)
---------------------------
Este repositório está licenciado sob a MIT License — veja o arquivo LICENSE para o texto completo.

Se você deseja outra licença (por exemplo, Apache-2.0, GPL-3.0), avise e eu atualizo o arquivo LICENSE.

Boas práticas
------------
- Use transações ao inserir vendas (já exemplificado).
- Valide entradas na camada da aplicação (quantidade > 0, sessão existente).
- Monitore índices (sessoes por sala, ingressos por sessao) para desempenho.
- Em ambientes concorrentes, considere filas ou mecanismos de reserva para UX (reservas temporárias).

Como contribuir
---------------
1. Abra uma issue descrevendo a sugestão ou bug.
2. Faça um fork e crie uma branch com nome descritivo (ex: feat/mysql-procs).
3. Submeta um PR com descrição das mudanças e como testar.

Autor / Contato
---------------
Davidkds99 — repositório: mini-mundo-cinemas-c

Commit details: add LICENSE (MIT) and update README.md to reference license explicitly.