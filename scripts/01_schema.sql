-- =============================================================
-- Almoxarifado Industrial — Modelo físico (MariaDB 10.11+)
-- Autor: Prof. Eduardo Furlanetti
-- Destaques do MariaDB: SEQUENCE e tabelas com versionamento
-- de sistema (System-Versioned Tables).
-- =============================================================

DROP DATABASE IF EXISTS almoxarifado;
CREATE DATABASE almoxarifado CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE almoxarifado;

-- Sequência própria para códigos de requisição (recurso do MariaDB)
CREATE SEQUENCE seq_requisicao START WITH 1000 INCREMENT BY 1;

CREATE TABLE fornecedor (
    id_fornecedor INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    razao_social  VARCHAR(120) NOT NULL,
    cnpj          CHAR(14)     NOT NULL UNIQUE,
    cidade        VARCHAR(60)  NOT NULL
);

CREATE TABLE setor (
    id_setor INT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome     VARCHAR(60) NOT NULL UNIQUE
);

-- Tabela versionada: o MariaDB guarda automaticamente o histórico
-- de cada alteração (ideal para auditoria de preço e saldo).
CREATE TABLE material (
    id_material   INT           NOT NULL AUTO_INCREMENT PRIMARY KEY,
    codigo        VARCHAR(20)   NOT NULL UNIQUE,
    descricao     VARCHAR(120)  NOT NULL,
    unidade       VARCHAR(5)    NOT NULL,          -- UN, KG, M, L
    id_fornecedor INT           NOT NULL,
    custo_medio   DECIMAL(12,4) NOT NULL DEFAULT 0,
    saldo         DECIMAL(12,3) NOT NULL DEFAULT 0,
    estoque_min   DECIMAL(12,3) NOT NULL DEFAULT 0,
    CONSTRAINT fk_material_fornecedor FOREIGN KEY (id_fornecedor)
        REFERENCES fornecedor (id_fornecedor),
    CONSTRAINT ck_material_saldo CHECK (saldo >= 0)
) WITH SYSTEM VERSIONING;

CREATE TABLE movimentacao (
    id_mov       BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_material  INT           NOT NULL,
    tipo         ENUM('ENTRADA','SAIDA') NOT NULL,
    quantidade   DECIMAL(12,3) NOT NULL,
    custo_unit   DECIMAL(12,4) NULL,               -- obrigatório na entrada
    id_setor     INT           NULL,               -- obrigatório na saída
    requisicao   INT           NULL,
    data_mov     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mov_material FOREIGN KEY (id_material) REFERENCES material (id_material),
    CONSTRAINT fk_mov_setor    FOREIGN KEY (id_setor)    REFERENCES setor (id_setor),
    CONSTRAINT ck_mov_qtd      CHECK (quantidade > 0),
    CONSTRAINT ck_mov_regras   CHECK (
        (tipo = 'ENTRADA' AND custo_unit IS NOT NULL) OR
        (tipo = 'SAIDA'   AND id_setor   IS NOT NULL)
    )
);

CREATE INDEX ix_mov_material_data ON movimentacao (id_material, data_mov);
