-- Questão 3

USE Chinook;

-- Clientes que mais compram por mês
WITH TopClientesMes AS (
    SELECT 
        FORMAT(InvoiceDate, 'MM-yyyy') AS Mes_Ano,
        CustomerId AS IDcliente,
        SUM(Total) AS TotalGasto,
        RANK() OVER (PARTITION BY FORMAT(InvoiceDate, 'MM-yyyy') ORDER BY SUM(Total) DESC) AS PosicaoRank
    FROM Invoice
    GROUP BY FORMAT(InvoiceDate, 'MM-yyyy'), CustomerId
)
SELECT * 
FROM TopClientesMes
WHERE PosicaoRank <= 3
ORDER BY Mes_Ano, PosicaoRank;

-- Clientes fiéis
WITH TopClientesMes AS (
    SELECT 
        FORMAT(InvoiceDate, 'MM-yyyy') AS Mes_Ano,
        CustomerId AS IDcliente,
        SUM(Total) AS TotalGasto,
        RANK() OVER (PARTITION BY FORMAT(InvoiceDate, 'MM-yyyy') ORDER BY SUM(Total) DESC) AS PosicaoRank
    FROM Invoice
    GROUP BY FORMAT(InvoiceDate, 'MM-yyyy'), CustomerId
)

SELECT IDcliente, COUNT(*) AS Top3_Aparicoes
FROM TopClientesMes
WHERE PosicaoRank <= 3
GROUP BY IDcliente
ORDER BY Top3_Aparicoes DESC;
