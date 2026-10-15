-- =============================================================
-- Almoxarifado Industrial — Regras de negócio no banco
-- Toda movimentação passa por procedures, que atualizam saldo
-- e custo médio ponderado dentro de uma transação.
-- =============================================================
USE almoxarifado;

DELIMITER $$

-- Entrada de material: recalcula o custo médio ponderado
CREATE OR REPLACE PROCEDURE sp_entrada(
    IN p_material INT,
    IN p_qtd      DECIMAL(12,3),
    IN p_custo    DECIMAL(12,4),
    IN p_data     DATETIME
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;
        UPDATE material
           SET custo_medio = (saldo * custo_medio + p_qtd * p_custo) / (saldo + p_qtd),
               saldo       = saldo + p_qtd
         WHERE id_material = p_material;

        INSERT INTO movimentacao (id_material, tipo, quantidade, custo_unit, data_mov)
        VALUES (p_material, 'ENTRADA', p_qtd, p_custo, COALESCE(p_data, NOW()));
    COMMIT;
END$$

-- Saída por requisição de um setor: valida saldo disponível
CREATE OR REPLACE PROCEDURE sp_saida(
    IN p_material INT,
    IN p_qtd      DECIMAL(12,3),
    IN p_setor    INT,
    IN p_data     DATETIME,
    OUT p_requisicao INT
)
BEGIN
    DECLARE v_saldo DECIMAL(12,3);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;
        SELECT saldo INTO v_saldo FROM material
         WHERE id_material = p_material FOR UPDATE;

        IF v_saldo < p_qtd THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente para a requisição';
        END IF;

        SET p_requisicao = NEXT VALUE FOR seq_requisicao;

        UPDATE material SET saldo = saldo - p_qtd WHERE id_material = p_material;

        INSERT INTO movimentacao (id_material, tipo, quantidade, id_setor, requisicao, data_mov)
        VALUES (p_material, 'SAIDA', p_qtd, p_setor, p_requisicao, COALESCE(p_data, NOW()));
    COMMIT;
END$$

DELIMITER ;
