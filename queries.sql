-- queries.sql (consultas úteis / relatórios / procedimentos para MySQL)

USE mini_mundo;

-- 1) Ocupação atual de uma sessão
-- Parâmetro: :sessao_id
SELECT s.id AS sessao_id,
       f.titulo,
       COALESCE(SUM(i.quantidade), 0) AS ingressos_vendidos,
       sa.capacidade,
       ROUND(COALESCE(SUM(i.quantidade),0) * 100.0 / sa.capacidade, 2) AS ocupacao_pct
FROM sessoes s
JOIN filmes f ON s.filme_id = f.id
JOIN salas sa ON s.sala_id = sa.id
LEFT JOIN ingressos i ON i.sessao_id = s.id
WHERE s.id = /*sessao_id*/ 1
GROUP BY s.id, f.titulo, sa.capacidade;

-- 2) Sessões por sala (ordenado)
SELECT sa.nome AS sala, s.inicio, f.titulo, s.preco
FROM sessoes s
JOIN salas sa ON s.sala_id = sa.id
JOIN filmes f ON s.filme_id = f.id
ORDER BY sa.nome, s.inicio;

-- 3) Relatório de manutenção (mais recente primeiro)
SELECT a.registrado_em, COALESCE(func.nome,'(anônimo)') AS funcionario, sa.nome AS sala, a.acao
FROM acoes_manutencao a
LEFT JOIN funcionarios func ON func.id = a.funcionario_id
JOIN salas sa ON sa.id = a.sala_id
ORDER BY a.registrado_em DESC;

-- 4) Consulta: salas e status de ocupação para o dia X
-- Exemplo: listar ocupação por sessão em um dia
SELECT s.id AS sessao_id, f.titulo, sa.nome AS sala, s.inicio,
       COALESCE(SUM(i.quantidade),0) AS vendidos, sa.capacidade,
       ROUND(COALESCE(SUM(i.quantidade),0) * 100.0 / sa.capacidade, 2) AS ocupacao_pct
FROM sessoes s
JOIN filmes f ON s.filme_id = f.id
JOIN salas sa ON s.sala_id = sa.id
LEFT JOIN ingressos i ON i.sessao_id = s.id
WHERE DATE(s.inicio) = '2025-10-21'
GROUP BY s.id, f.titulo, sa.nome, s.inicio, sa.capacidade
ORDER BY sa.nome, s.inicio;

-- 5) Procedimento para vender ingressos com verificação de capacidade
-- Ele tenta inserir a venda se houver capacidade; retorna p_success = 1 em sucesso, 0 em falha.
DROP PROCEDURE IF EXISTS vender_ingressos;
DELIMITER $$
CREATE PROCEDURE vender_ingressos(
  IN p_sessao_id INT,
  IN p_qtd INT,
  OUT p_success TINYINT
)
BEGIN
  DECLARE v_cap INT;
  DECLARE v_vendidos INT;

  IF p_qtd <= 0 THEN
    SET p_success = 0;
    LEAVE proc_end;
  END IF;

  START TRANSACTION;

  -- Bloqueia a sala referenciada pela sessão para evitar oversell
  SELECT sa.capacidade
    INTO v_cap
    FROM sessoes s
    JOIN salas sa ON s.sala_id = sa.id
    WHERE s.id = p_sessao_id
    FOR UPDATE;

  -- Soma vendas já realizadas para essa sessão
  SELECT COALESCE(SUM(i.quantidade), 0)
    INTO v_vendidos
    FROM ingressos i
    WHERE i.sessao_id = p_sessao_id
    FOR UPDATE;

  IF v_vendidos + p_qtd <= v_cap THEN
    INSERT INTO ingressos (sessao_id, quantidade) VALUES (p_sessao_id, p_qtd);
    SET p_success = 1;
    COMMIT;
  ELSE
    SET p_success = 0;
    ROLLBACK;
  END IF;

  proc_end: BEGIN END;
END$$
DELIMITER ;

-- Uso (exemplo):
-- CALL vender_ingressos(1, 5, @ok); SELECT @ok; -- @ok = 1 (sucesso) ou 0 (falha)