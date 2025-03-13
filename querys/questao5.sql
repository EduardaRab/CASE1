WITH TotalGastoPorCliente AS (
    -- Total gasto por cada cliente
    SELECT 
        c.CustomerId, 
        c.FirstName + ' ' + c.LastName AS Cliente,
        ROUND(SUM(i.Total), 2) AS ValorTotalGasto
    FROM Invoice i
    JOIN Customer c ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName
),
MedianaCalculo AS (
    SELECT 
        ValorTotalGasto, 
        ROW_NUMBER() OVER (ORDER BY ValorTotalGasto) AS RowNum,
        COUNT(*) OVER () AS TotalRows
    FROM TotalGastoPorCliente
),
Estatisticas AS (
    -- Média e Mediana
    SELECT 
        ROUND(AVG(ValorTotalGasto), 2) AS MediaGasto,
        ROUND(
            (SELECT AVG(ValorTotalGasto * 1.0) 
             FROM MedianaCalculo 
             WHERE RowNum BETWEEN (TotalRows / 2) AND ((TotalRows / 2) + 1)
            ), 2
        ) AS MedianaGasto
    FROM TotalGastoPorCliente
),
TotalVendas AS (
    -- Total geral de vendas
    SELECT ROUND(SUM(ValorTotalGasto), 2) AS TotalGeral 
    FROM TotalGastoPorCliente
),
DistribuicaoVendas AS (
    -- Percentual de vendas e análise estatística
    SELECT 
        t.Cliente, 
        t.ValorTotalGasto,
        ROUND((t.ValorTotalGasto * 1.0 / v.TotalGeral) * 100, 2) AS PercentualVenda,
        ROUND(SUM((t.ValorTotalGasto * 1.0 / v.TotalGeral) * 100) OVER (ORDER BY t.ValorTotalGasto DESC), 2) AS PercentualAcumulado,
        e.MediaGasto,
        e.MedianaGasto,
        CASE 
            WHEN t.ValorTotalGasto > e.MediaGasto THEN 'Acima da Média' 
            ELSE 'Abaixo da Média' 
        END AS ComparacaoMedia,
        CASE 
            WHEN t.ValorTotalGasto > e.MedianaGasto THEN 'Acima da Mediana' 
            ELSE 'Abaixo da Mediana' 
        END AS ComparacaoMediana
    FROM TotalGastoPorCliente t
    CROSS JOIN Estatisticas e
    CROSS JOIN TotalVendas v
)
SELECT 
    Cliente,
    FORMAT(ValorTotalGasto, 'N2') AS ValorTotalGasto,
    FORMAT(PercentualVenda, 'N2') AS PercentualVenda,
    FORMAT(PercentualAcumulado, 'N2') AS PercentualAcumulado,
    FORMAT(MediaGasto, 'N2') AS MediaGasto,
    FORMAT(MedianaGasto, 'N2') AS MedianaGasto,
    ComparacaoMedia,
    ComparacaoMediana
FROM DistribuicaoVendas
ORDER BY ValorTotalGasto DESC;