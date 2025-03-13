-- Criar tabela temporária para contar quantos gêneros cada cliente consumiu
SELECT 
    i.CustomerId AS IdCliente, 
    COUNT(DISTINCT t.GenreId) AS QtdGeneros
INTO #GenerosPorCliente
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY i.CustomerId;
 
-- Criar tabela temporária para contar quantos clientes têm cada quantidade de gêneros consumidos
SELECT 
    QtdGeneros, 
    COUNT(IdCliente) AS QtdClientes
INTO #DistribuicaoGeneros
FROM #GenerosPorCliente
GROUP BY QtdGeneros
ORDER BY QtdGeneros;
 
-- Calcular o total de clientes
DECLARE @TotalClientes FLOAT;
SELECT @TotalClientes = COUNT(*) FROM Customer;
 
-- Criar tabela temporária para armazenar o resultado final
CREATE TABLE #DistribuicaoFinal (
    QtdGeneros INT,
    QtdClientes INT,
    PercentualTotal FLOAT,
    AcumuladoClientes INT,
    PercentualAcumulado FLOAT
);
 
-- Preencher a tabela final com os cálculos
INSERT INTO #DistribuicaoFinal (QtdGeneros, QtdClientes, PercentualTotal, AcumuladoClientes, PercentualAcumulado)
SELECT 
    d.QtdGeneros,
    d.QtdClientes,
    (d.QtdClientes * 100.0) / @TotalClientes AS PercentualTotal,
    SUM(d.QtdClientes) OVER (ORDER BY d.QtdGeneros) AS AcumuladoClientes,
    (SUM(d.QtdClientes) OVER (ORDER BY d.QtdGeneros) * 100.0) / @TotalClientes AS PercentualAcumulado
FROM #DistribuicaoGeneros d;
 
-- Mostrar resultado final
SELECT * FROM #DistribuicaoFinal ORDER BY QtdGeneros;
 
-- Limpar tabelas temporárias
DROP TABLE #GenerosPorCliente;
DROP TABLE #DistribuicaoGeneros;
DROP TABLE #DistribuicaoFinal;