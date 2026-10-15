-- Soluções — Almoxarifado Industrial (MariaDB)
USE almoxarifado;

-- 1
SELECT f.razao_social, ROUND(SUM(m.saldo * m.custo_medio), 2) AS valor_estoque
FROM fornecedor f
JOIN material m ON m.id_fornecedor = f.id_fornecedor
GROUP BY f.razao_social
ORDER BY valor_estoque DESC;

-- 2
SELECT DATE_FORMAT(m.data_mov, '%Y-%m') AS mes, s.nome AS setor, COUNT(*) AS requisicoes
FROM movimentacao m
JOIN setor s ON s.id_setor = m.id_setor
WHERE m.tipo = 'SAIDA'
GROUP BY mes, s.nome
ORDER BY mes, requisicoes DESC;

-- 3
SELECT mt.codigo, mt.descricao, SUM(m.quantidade) AS retirado
FROM movimentacao m
JOIN material mt ON mt.id_material = m.id_material
WHERE m.tipo = 'SAIDA' AND m.data_mov >= '2026-02-01' AND m.data_mov < '2026-03-01'
GROUP BY mt.codigo, mt.descricao
ORDER BY retirado DESC
LIMIT 1;

-- 4
CALL sp_entrada(6, 100, 35.00, NULL);
SELECT codigo, saldo, ROUND(custo_medio, 4) AS custo_medio FROM material WHERE codigo = 'GRA-EP2';
-- Custo médio ponderado: (5 × 32,00 + 100 × 35,00) / 105 = 34,8571

-- 5
SELECT saldo, ROUND(custo_medio, 4) AS custo_medio, row_start, row_end
FROM material FOR SYSTEM_TIME ALL
WHERE codigo = 'GRA-EP2'
ORDER BY row_start;
-- A penúltima versão mostra o custo de 32,0000, válido até o row_start da última.

-- 6
CREATE OR REPLACE VIEW vw_reposicao AS
SELECT codigo, descricao, saldo, estoque_min,
       GREATEST(2 * estoque_min - saldo, 0) AS sugestao_compra
FROM material;

SELECT * FROM vw_reposicao WHERE sugestao_compra > 0;

-- 7
DELIMITER $$
CREATE OR REPLACE PROCEDURE sp_ajuste_inventario(IN p_material INT, IN p_contado DECIMAL(12,3))
BEGIN
    DECLARE v_saldo DECIMAL(12,3);
    DECLARE v_custo DECIMAL(12,4);
    DECLARE v_req   INT;

    SELECT saldo, custo_medio INTO v_saldo, v_custo
    FROM material WHERE id_material = p_material;

    IF p_contado > v_saldo THEN
        CALL sp_entrada(p_material, p_contado - v_saldo, v_custo, NULL);
    ELSEIF p_contado < v_saldo THEN
        -- setor 1 (Manutenção) representa a perda de inventário
        CALL sp_saida(p_material, v_saldo - p_contado, 1, NULL, v_req);
    END IF;
END$$
DELIMITER ;

CALL sp_ajuste_inventario(1, 480);   -- inventário encontrou 20 parafusos a menos
SELECT codigo, saldo FROM material WHERE id_material = 1;
