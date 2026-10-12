SELECT COUNT(*) AS Total_Rows
FROM dbo.OnlineRetail;

SELECT TOP 10 InvoiceDate, UnitPrice
FROM dbo.OnlineRetail;

SELECT
	COUNT(CASE WHEN InvoiceDate IS NULL THEN 1 END) AS Missing_Dates,
	COUNT(CASE WHEN UnitPrice IS NULL THEN 1 END) AS Missing_Prices
FROM dbo.OnlineRetail;

SELECT
	COUNT(*) AS Total_Rows,
	COUNT(TRY_CONVERT(datetime2, InvoiceDate, 105))
		AS Successfully_Coverted,
	MIN(TRY_CONVERT(datetime2, InvoiceDate, 105))
		AS Earliest_Date,
	MAX(TRY_CONVERT(datetime2, InvoiceDate, 105))
		AS Latest_Date
FROM dbo.OnlineRetail;