WITH GenreSales AS (
    SELECT 
        g.Name AS Genre,
        SUM(il.UnitPrice * il.Quantity) AS TotalRevenue
    FROM InvoiceLine il
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY g.Name
),
RankedGenres AS (
    SELECT 
        Genre,
        TotalRevenue,
        SUM(TotalRevenue) OVER (ORDER BY TotalRevenue DESC) AS CumulativeRevenue,
        SUM(TotalRevenue) OVER () AS TotalSales
    FROM GenreSales
)
SELECT * INTO #TempRankedGenres FROM RankedGenres;  -- Salva os dados em uma tabela tempor�ria
 
-- G�neros com menor venda
SELECT * FROM #TempRankedGenres ORDER BY TotalRevenue ASC; -- tabela tempor�ria ao inv�s de CTE
 
-- Distribui��o das vendas por g�nero
SELECT * FROM #TempRankedGenres ORDER BY TotalRevenue DESC;
 
-- Quantidade de g�neros respons�veis por 80% do faturamento
SELECT COUNT(*) AS GenresFor80Percent 
FROM #TempRankedGenres 
WHERE CumulativeRevenue <= (0.8 * TotalSales);
 
-- Limpeza da tabela tempor�ria
DROP TABLE #TempRankedGenres;