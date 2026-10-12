USE RetailSalesAnalysis;
GO

-- Seasonal Sales Analysis of a UK Online Retailer

-- Business Question 1: What is the total revenue generated?
-- Total revenue after excluding two confirmed fully
-- cancelled transactions is £10,398,907.22.

SELECT
	CAST(SUM(Quantity * UnitPrice) AS DECIMAL(18, 2)) -- CAST converts the result into decimal number
		AS Total_Revenue
FROM dbo.OnlineRetail
WHERE InvoiceNo NOT LIKE 'C%' -- to exclude "cancellations" 
	AND Quantity >0
	AND InvoiceNo NOT IN ('581483', '541431');

-- Business Question 2: Which month generated the highest revenue?
-- Finding: November 2011 had the highest revenue at £1,509,496.33
-- Note: December 2011 data is incomplete (available through December 9).
-- Data quality: Excluded two confirmed fully cancelled invoices (581483 and 541431).

SELECT
	YEAR(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) AS Sales_Year,
	MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) AS Sales_Month,
	CAST(SUM(Quantity * UnitPrice) AS DECIMAL(18, 2)) AS Monthly_Revenue
FROM dbo.OnlineRetail
WHERE InvoiceNo NOT LIKE 'C%'
	AND Quantity > 0
	AND InvoiceNo NOT IN ('581483', '541431')
GROUP BY
	YEAR(TRY_CONVERT(DATETIME2, InvoiceDate, 105)),
	MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105))
ORDER BY Monthly_Revenue DESC;

-- Business Question 3: Which month had the highest number of units sold?
-- Finding: November 2011 had the highest sales volume, with 771,598 units sold.
-- Note: December 2011 data is incomplete (available through December 9).
-- Data quality: Excluded two confirmed fully cancelled invoices (581483 and 541431).

SELECT
	YEAR(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) AS Sales_Year,
	MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) AS Sales_Month,
	SUM(Quantity) AS Total_Units_Sold
FROM dbo.OnlineRetail
WHERE InvoiceNo NOT LIKE 'C%'
	AND Quantity > 0
	AND InvoiceNo NOT IN ('581483', '541431')
GROUP BY
	YEAR(TRY_CONVERT(DATETIME2, InvoiceDate, 105)),
	MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105))
ORDER BY Total_Units_Sold DESC;

-- Business Question 4: Which products generated the most revenue?
-- Finding: REGENCY CAKESTAND 3 TIER ranked first, generating £174,484.74.
-- Excluded stock codes: DOT, POST, M.
-- Data quality: Excludes two confirmed fully cancelled invoices (581483 and 541431).

SELECT TOP 10
    StockCode,
    Description,
    CAST(SUM(Quantity * UnitPrice) AS DECIMAL(18, 2)) AS Product_Revenue
FROM dbo.OnlineRetail
WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    AND StockCode NOT IN ('DOT', 'POST', 'M')
    AND InvoiceNo NOT IN ('581483', '541431')
GROUP BY
    StockCode,
    Description
ORDER BY Product_Revenue DESC;

-- Business Question 5: Which countries generated the most revenue?
-- Finding: The United Kingdom generated the highest revenue at £8,757,444.76,
-- followed by the Netherlands and EIRE.
-- Data quality: Excludes two confirmed fully cancelled invoices (581483 and 541431).

SELECT TOP 10
	Country,
	CAST(SUM(Quantity * UnitPrice) AS DECIMAL(18, 2)) AS Country_Revenue
FROM dbo.OnlineRetail
WHERE InvoiceNo NOT LIKE 'C%'
	AND Quantity > 0
	AND InvoiceNo NOT IN ('581483', '541431')
GROUP BY Country
ORDER BY Country_Revenue DESC;

-- Business Question 6: Which products sold the most in each season?
-- Finding: The leading products by units sold varied by season.
-- Winter: WHITE HANGING HEART T-LIGHT HOLDER - 12,067 units.
-- Spring: WORLD WAR 2 GLIDERS ASSTD DESIGNS - 19,076 units.
-- Summer: JUMBO BAG RED RETROSPOT - 12,313 units.
-- Autumn: POPCORN HOLDER - 22,415 units.
-- Limitation: Winter data is incomplete and spans two calendar years.
-- Data quality: Excludes two confirmed fully cancelled invoices (581483 and 541431).

WITH SeasonSales AS (
	SELECT
		CASE
			WHEN MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) IN (12, 1, 2)
				THEN 'Winter'
			WHEN MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) IN (3, 4, 5)
				THEN 'Spring'
			WHEN MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) IN (6, 7, 8)
				THEN 'Summer'
			ELSE 'Autumn'
		END AS Season,
		StockCode,
		Description,
		SUM(Quantity) AS Units_Sold
	FROM dbo.OnlineRetail
	WHERE InvoiceNo NOT LIKE 'C%'
		AND Quantity > 0
		AND StockCode NOT IN ('DOT', 'POST', 'M')
		AND InvoiceNo NOT IN ('581483', '541431')
	GROUP BY
		CASE
			WHEN MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) IN (12, 1, 2)
				THEN 'Winter'
			WHEN MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) IN (3, 4, 5)
				THEN 'Spring'
			WHEN MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) in (6, 7, 8)
				THEN 'Summer'
			ELSE 'Autumn'
		END,
		StockCode,
		Description
),
RankedProducts AS (
	SELECT
		Season,
		StockCode,
		Description,
		Units_Sold,
		ROW_NUMBER() OVER (
			PARTITION BY Season
			ORDER BY Units_Sold DESC
		) AS Product_Rank
	FROM SeasonSales
)
SELECT
	Season,
	StockCode,
	Description,
	Units_Sold
FROM RankedProducts
WHERE Product_Rank = 1
ORDER BY 
	CASE Season
		WHEN 'Winter' THEN 1
		WHEN 'Spring' THEN 2
		WHEN 'Summer' THEN 3
		WHEN 'Autumn' THEN 4
	END;

-- Business Question 7: Which products generated the most revenue
-- in November and December?
--
-- Preliminary Findings:
-- November 2011: RABBIT NIGHT LIGHT ranked first,
-- generating £34,556.72 in revenue.
-- December 2010: REGENCY CAKESTAND 3 TIER ranked first,
-- generating £27,869.96 in revenue.
-- December 2011: RABBIT NIGHT LIGHT ranked first,
-- generating £9,643.02 in revenue.
-- Both confirmed fully cancelled invoices are excluded.
--
-- Data Quality Notes:
-- December 2011 data is incomplete, ending on 9 December 2011.
-- AMAZONFEE appears in the December 2010 results and is a fee,
-- not a physical product.
-- Confirmed fully cancelled invoices 581483 and 541431 are excluded.
-- Other possible cancellation-related data quality issues have
-- not been fully investigated.
-- These results describe the available dataset and do not prove
-- recurring seasonal trends.

WITH MonthlyProductSales AS (
	SELECT
		YEAR(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) AS Sales_Year,
		MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) AS Sales_Month,
		StockCode,
		Description,
		SUM(Quantity * UnitPrice) AS Product_Revenue
	FROM dbo.OnlineRetail
	WHERE InvoiceNo NOT LIKE 'C%'
		AND Quantity > 0
		AND StockCode NOT IN ('DOT', 'POST', 'M')
		AND MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) IN (11, 12)
		AND InvoiceNo NOT IN ('581483', '541431')
	GROUP BY
		YEAR(TRY_CONVERT(DATETIME2, InvoiceDate, 105)),
		MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)),
		StockCode,
		Description
),
RankedProducts AS (
	SELECT
		Sales_Year,
		Sales_Month,
		StockCode,
		Description,
		CAST(Product_Revenue AS DECIMAL(18, 2)) AS Product_Revenue,
		ROW_NUMBER() OVER (
			PARTITION BY Sales_Year, Sales_Month
			ORDER BY Product_Revenue DESC
		) AS Product_Rank
	FROM MonthlyProductSales
)
SELECT
	Sales_Year,
	Sales_Month,
	StockCode,
	Description,
	Product_Revenue
FROM RankedProducts
WHERE Product_Rank <= 5
ORDER BY Sales_Year, Sales_Month, Product_Rank;

-- Business Question 8: Which customers contributed the most revenue?
--
-- Preliminary Finding:
-- Customer 14646 generated the highest revenue,
-- totaling £280,206.02 after excluding the two confirmed
-- fully cancelled transactions.
--
-- Data Quality Notes:
-- Invoices 581483 and 541431 were fully cancelled by
-- credit-note invoices C581484 and C541433, respectively.
-- Both original invoices are excluded from this analysis.
-- Other possible cancellation-related data quality issues
-- have not been fully investigated.

SELECT TOP 10
	CustomerID,
	CAST(SUM(Quantity * UnitPrice) AS DECIMAL(18, 2)) AS Customer_Revenue
FROM dbo.OnlineRetail
WHERE InvoiceNo NOT LIKE 'C%'
	AND Quantity > 0 
	AND CustomerID IS NOT NULL
	AND InvoiceNo NOT IN ('581483', '541431')
GROUP BY CustomerID
ORDER BY Customer_Revenue DESC;


-- Data Quality Check: PAPER CRAFT, LITTLE BIRDIE
-- Investigate the unusually high original transaction in December 2011.
-- This query intentionally includes invoice 581483 for investigation.
-- The invoice is excluded from the main sales analyses because it was
-- confirmed to be fully cancelled by credit note C581484.

SELECT
    InvoiceNo,
    InvoiceDate,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS Line_Revenue
FROM dbo.OnlineRetail
WHERE StockCode = '23843'
    AND YEAR(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) = 2011
	AND MONTH(TRY_CONVERT(DATETIME2, InvoiceDate, 105)) = 12
    AND InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
ORDER BY Quantity * UnitPrice DESC;

SELECT *
FROM dbo.OnlineRetail
WHERE InvoiceNo = '581483';

SELECT TOP 10
	InvoiceNo,
	InvoiceDate,
	Quantity,
	UnitPrice,
	Quantity * UnitPrice AS Line_Revenue
FROM dbo.OnlineRetail
WHERE StockCode = '23843'
	AND InvoiceNo <> '581483'
	AND InvoiceDate NOT LIKE 'C%'
	AND Quantity > 0
ORDER BY Quantity DESC;

SELECT
	InvoiceNo,
	StockCode,
	Description,
	Quantity,
	InvoiceDate,
	UnitPrice
FROM dbo.OnlineRetail
WHERE StockCode = '23843'
ORDER BY InvoiceDate;

SELECT TOP 10
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    Quantity * UnitPrice AS Line_Revenue
FROM dbo.OnlineRetail
WHERE InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
ORDER BY Quantity DESC;

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
FROM dbo.OnlineRetail
WHERE StockCode = '23166'
ORDER BY InvoiceDate;

SELECT
    InvoiceNo,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS Line_Revenue,
    InvoiceDate
FROM dbo.OnlineRetail
WHERE StockCode = '23166'
    AND InvoiceNo IN ('541431', 'C541433')
ORDER BY InvoiceDate;

-- Investigation only: matching attributes identify possible
-- cancellation pairs, not necessarily confirmed cancellations.
-- Review invoice dates and transaction details before excluding
-- any additional original invoices from the main analyses.

SELECT
    S.InvoiceNo AS Original_Invoice,
    C.InvoiceNo AS Cancellation_Invoice,
    S.StockCode,
    S.Description,
    S.Quantity AS Original_Quantity,
    C.Quantity AS Cancelled_Quantity,
    S.UnitPrice,
    S.CustomerID,
    S.InvoiceDate AS Original_Date,
    C.InvoiceDate AS Cancellation_Date
FROM dbo.OnlineRetail AS S
INNER JOIN dbo.OnlineRetail AS C
    ON S.StockCode = C.StockCode
    AND S.Quantity = -C.Quantity
    AND S.UnitPrice = C.UnitPrice
    AND (
        S.CustomerID = C.CustomerID
        OR (S.CustomerID IS NULL AND C.CustomerID IS NULL)
    )
WHERE S.InvoiceNo NOT LIKE 'C%'
    AND C.InvoiceNo LIKE 'C%'
    AND S.Quantity > 0
ORDER BY S.Quantity DESC;
