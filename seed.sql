-- seed.sql (dados de exemplo para MySQL)
USE mini_mundo;

-- Cinemas
INSERT INTO cinemas (nome, endereco) VALUES
  ('Mini Mundo Centro', 'Rua A, 123'),
  ('Mini Mundo Norte', 'Av. B, 456');

-- Salas
INSERT INTO salas (cinema_id, nome, capacidade, estado, descricao) VALUES
  (1, 'Sala A', 120, 'ativa', 'Tela grande, som 7.1'),
  (1, 'Sala B', 80, 'ativa', 'Sala pequena'),
  (2, 'Sala C', 60, 'ativa', 'Sala íntima');

-- Filmes
INSERT INTO filmes (titulo, duracao_min, classificacao) VALUES
  ('Viagem ao C', 110, '12'),
  ('Aventura X', 95, '10'),
  ('Documentário Y', 55, 'Livre');

-- Sessões
INSERT INTO sessoes (filme_id, sala_id, inicio, preco) VALUES
  (1, 1, '2025-10-21 19:30:00', 20.00),
  (2, 2, '2025-10-21 18:00:00', 18.00),
  (3, 3, '2025-10-22 15:00:00', 12.00);

-- Funcionários
INSERT INTO funcionarios (nome, cargo) VALUES
  ('Carlos Diretor', 'diretor'),
  ('Mariana Zeladora', 'zelador'),
  ('João Atendente', 'atendente');

-- Ações de manutenção
INSERT INTO acoes_manutencao (funcionario_id, sala_id, acao) VALUES
  (2, 1, 'Limpeza após sessão'),
  (2, 2, 'Verificação de projetor');

-- Vendas de ingressos (simulação)
INSERT INTO ingressos (sessao_id, quantidade) VALUES
  (1, 45),
  (1, 10),
  (2, 30);