DECLARE @Media decimal (5,2);
SET @Media = 
	(
		SELECT 
			AVG(TotalAll) Media
		FROM
		(
			SELECT 
				SUM(Total) TotalAll
				,CustomerId 
			FROM Chinook.dbo.Invoice Invoice
			GROUP BY CustomerId
		) main
	);
 
DECLARE @Mediana decimal (5,2);
SET @Mediana = 
	(
		SELECT DISTINCT
			(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY SUM(Total)) OVER ()) median
		FROM Chinook.dbo.Invoice Invoice
		GROUP BY CustomerId
	);
 
SELECT 
	ROW_NUMBER() OVER(ORDER BY SUM(Total) DESC) AS Ranking
	,@Media Media
	,@Mediana Mediana
	,SUM(Total) TotalAll
	,Invoice.CustomerId
	,Customer.FirstName
	,Customer.LastName
	,SUM(Total) - @Media "Diferença da Media"
	,CONVERT(DEC(5,2),(SUM(Total)*100/@Media)-100) "Diferença da Media [%]"
	,SUM(Total) - @Mediana "Diferença da Mediana"
	,CONVERT(DEC(5,2),(SUM(Total)*100/@Mediana)-100) "Diferença da Mediana [%]"
	,CASE WHEN (ROW_NUMBER() OVER(ORDER BY SUM(Total) DESC)) < 6 THEN 'X' ELSE null END "Cliente Premium"
FROM Chinook.dbo.Invoice Invoice
INNER JOIN Chinook.dbo.Customer Customer ON Invoice.CustomerId = Customer.CustomerId
GROUP BY Invoice.CustomerId, Customer.FirstName, Customer.LastName