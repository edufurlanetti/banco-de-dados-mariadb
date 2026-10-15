# Lista de exercícios — Almoxarifado Industrial (MariaDB)

Execute antes os scripts `01` a `03` da pasta `scripts/`.

1. Liste os materiais de cada fornecedor com o valor total em estoque por fornecedor.
2. Mostre a quantidade de requisições atendidas por setor em cada mês.
3. Qual material teve a maior quantidade retirada em fevereiro de 2026?
4. Registre uma nova entrada de 100 graxas EP2 a R$ 35,00 usando `sp_entrada` e explique o novo custo médio obtido.
5. Consulte o histórico versionado da graxa EP2 e identifique o custo médio **antes** da entrada do exercício 4.
6. Crie uma *view* `vw_reposicao` que mostre material, saldo, mínimo e a quantidade sugerida de compra (2 × mínimo − saldo).
7. Crie uma procedure `sp_ajuste_inventario(material, saldo_contado)` que registre a diferença do inventário físico como entrada ou saída.

As soluções estão em [`solucoes.sql`](solucoes.sql).
