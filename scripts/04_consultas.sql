-- =============================================================
-- Almoxarifado Industrial — Consultas e relatórios gerenciais
-- =============================================================
USE almoxarifado;

-- 1. Posição de estoque com valor imobilizado
SELECT codigo, descricao, unidade, saldo,
       ROUND(custo_medio, 2)         AS custo_medio,
       ROUND(saldo * custo_medio, 2) AS valor_em_estoque
FROM material
ORDER BY valor_em_estoque DESC;

-- 2. Itens abaixo do estoque mínimo (lista de compras)
SELECT codigo, descricao, saldo, estoque_min,
       estoque_min - saldo AS comprar_no_minimo
FROM material
WHERE saldo < estoque_min;

-- 3. Consumo por setor, valorizado pelo custo médio atual do material
SELECT s.nome AS setor,
       ROUND(SUM(m.quantidade * mt.custo_medio), 2) AS consumo_valor
FROM movimentacao m
JOIN setor s     ON s.id_setor     = m.id_setor
JOIN material mt ON mt.id_material = m.id_material
WHERE m.tipo = 'SAIDA'
GROUP BY s.nome
ORDER BY consumo_valor DESC;

-- 4. Kardex (ficha de estoque) com saldo acumulado — função de janela
SELECT mt.codigo, m.data_mov, m.tipo, m.quantidade,
       SUM(CASE WHEN m.tipo = 'ENTRADA' THEN m.quantidade ELSE -m.quantidade END)
           OVER (PARTITION BY m.id_material ORDER BY m.data_mov, m.id_mov) AS saldo_apos
FROM movimentacao m
JOIN material mt ON mt.id_material = m.id_material
ORDER BY mt.codigo, m.data_mov;

-- 5. Curva ABC do consumo (A ≈ 80% do valor, B ≈ 15%, C ≈ 5%)
WITH consumo AS (
    SELECT mt.codigo, mt.descricao,
           SUM(m.quantidade * mt.custo_medio) AS valor
    FROM movimentacao m
    JOIN material mt ON mt.id_material = m.id_material
    WHERE m.tipo = 'SAIDA'
    GROUP BY mt.codigo, mt.descricao
), acumulado AS (
    SELECT codigo, descricao, valor,
           SUM(valor) OVER (ORDER BY valor DESC) / SUM(valor) OVER () AS perc_acum
    FROM consumo
)
SELECT codigo, descricao, ROUND(valor, 2) AS valor,
       ROUND(perc_acum * 100, 1) AS perc_acumulado,
       CASE WHEN perc_acum <= 0.80 THEN 'A'
            WHEN perc_acum <= 0.95 THEN 'B'
            ELSE 'C' END AS classe
FROM acumulado
ORDER BY valor DESC;

-- 6. Recurso do MariaDB: histórico de versões de um material
--    (cada UPDATE gerou uma versão; repare na variação do custo médio)
SELECT codigo, saldo, ROUND(custo_medio, 4) AS custo_medio, row_start, row_end
FROM material FOR SYSTEM_TIME ALL
WHERE codigo = 'ROL-6205'
ORDER BY row_start;

-- 7. Recurso do MariaDB: números de requisição gerados pela SEQUENCE
SELECT m.requisicao, s.nome AS setor, mt.codigo, m.quantidade, m.data_mov
FROM movimentacao m
JOIN setor s     ON s.id_setor     = m.id_setor
JOIN material mt ON mt.id_material = m.id_material
WHERE m.tipo = 'SAIDA'
ORDER BY m.requisicao;

-- 8. Testando a regra de negócio: esta chamada deve falhar
--    com "Saldo insuficiente para a requisição"
-- CALL sp_saida(4, 100, 1, NULL, @r);
