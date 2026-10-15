-- =============================================================
-- Almoxarifado Industrial — Dados de exemplo
-- As movimentações usam as procedures, como na aplicação real.
-- =============================================================
USE almoxarifado;

INSERT INTO fornecedor (razao_social, cnpj, cidade) VALUES
('Metalúrgica Paulista Ltda',  '11222333000144', 'Limeira'),
('Elétrica Industrial S.A.',   '22333444000155', 'Campinas'),
('Lubrificantes do Brasil',    '33444555000166', 'Sorocaba');

INSERT INTO setor (nome) VALUES
('Manutenção'), ('Usinagem'), ('Montagem'), ('Ferramentaria');

INSERT INTO material (codigo, descricao, unidade, id_fornecedor, estoque_min) VALUES
('PAR-M8',   'Parafuso sextavado M8 x 30',      'UN', 1, 500),
('ROL-6205', 'Rolamento 6205 2RS',              'UN', 1, 20),
('CAB-2.5',  'Cabo flexível 2,5 mm²',           'M',  2, 200),
('CON-25A',  'Contator tripolar 25 A',          'UN', 2, 5),
('OLE-68',   'Óleo hidráulico ISO VG 68',       'L',  3, 100),
('GRA-EP2',  'Graxa EP2',                       'KG', 3, 10);

-- Entradas (compras)
CALL sp_entrada(1, 2000,  0.35, '2026-01-05 08:00:00');
CALL sp_entrada(2,   50, 28.90, '2026-01-05 08:10:00');
CALL sp_entrada(3, 1000,  3.20, '2026-01-06 09:00:00');
CALL sp_entrada(4,   12, 145.00,'2026-01-06 09:30:00');
CALL sp_entrada(5,  400, 18.50, '2026-01-07 10:00:00');
CALL sp_entrada(6,   40, 32.00, '2026-01-07 10:15:00');
CALL sp_entrada(2,   30, 31.50, '2026-02-10 08:00:00');  -- muda o custo médio

-- Saídas (requisições dos setores)
CALL sp_saida(1, 600, 3, '2026-01-12 13:00:00', @r);
CALL sp_saida(2,  18, 1, '2026-01-15 07:30:00', @r);
CALL sp_saida(3, 850, 1, '2026-01-20 14:00:00', @r);
CALL sp_saida(5, 220, 2, '2026-01-25 10:00:00', @r);
CALL sp_saida(6,  35, 1, '2026-02-03 08:45:00', @r);
CALL sp_saida(4,   8, 1, '2026-02-12 15:20:00', @r);
CALL sp_saida(1, 900, 3, '2026-02-20 11:00:00', @r);
