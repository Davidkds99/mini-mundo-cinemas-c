-- schema.sql (MySQL / InnoDB, charset utf8mb4)
-- Cria o esquema do Mini Mundo Cinemas (MySQL)

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS ingressos;
DROP TABLE IF EXISTS acoes_manutencao;
DROP TABLE IF EXISTS sessoes;
DROP TABLE IF EXISTS filmes;
DROP TABLE IF EXISTS salas;
DROP TABLE IF EXISTS funcionarios;
DROP TABLE IF EXISTS cinemas;

SET FOREIGN_KEY_CHECKS = 1;

CREATE DATABASE IF NOT EXISTS mini_mundo
  DEFAULT CHARACTER SET = utf8mb4
  DEFAULT COLLATE = utf8mb4_unicode_ci;
USE mini_mundo;

CREATE TABLE cinemas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  endereco VARCHAR(512),
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE salas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cinema_id INT NOT NULL,
  nome VARCHAR(100) NOT NULL,
  capacidade INT NOT NULL CHECK (capacidade > 0),
  estado ENUM('ativa','em_manutencao','fechada') NOT NULL DEFAULT 'ativa',
  descricao VARCHAR(512),
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_salas_cinema FOREIGN KEY (cinema_id) REFERENCES cinemas(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE filmes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  duracao_min INT,
  classificacao VARCHAR(10),
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sessoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  filme_id INT NOT NULL,
  sala_id INT NOT NULL,
  inicio DATETIME NOT NULL,
  preco DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sessoes_filme FOREIGN KEY (filme_id) REFERENCES filmes(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_sessoes_sala FOREIGN KEY (sala_id) REFERENCES salas(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uq_sessao_sala_inicio UNIQUE (sala_id, inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE funcionarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  cargo ENUM('diretor','zelador','atendente','outro') NOT NULL DEFAULT 'outro',
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE acoes_manutencao (
  id INT AUTO_INCREMENT PRIMARY KEY,
  funcionario_id INT NULL,
  sala_id INT NOT NULL,
  acao VARCHAR(512) NOT NULL,
  registrado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_acoes_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_acoes_sala FOREIGN KEY (sala_id) REFERENCES salas(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ingressos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sessao_id INT NOT NULL,
  quantidade INT NOT NULL CHECK (quantidade > 0),
  vendido_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ingressos_sessao FOREIGN KEY (sessao_id) REFERENCES sessoes(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices frequentes
CREATE INDEX idx_sessoes_sala_inicio ON sessoes (sala_id, inicio);
CREATE INDEX idx_ingressos_sessao ON ingressos (sessao_id);
CREATE INDEX idx_acoes_manutencao_sala ON acoes_manutencao (sala_id);