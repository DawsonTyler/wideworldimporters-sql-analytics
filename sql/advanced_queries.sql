USE WideWorldImporters


--1 



WITH YearlyIncome AS (
SELECT 
  YEAR(t1.OrderDate) AS [Year],
  SUM(t3.ExtendedPrice - t3.TaxAmount) AS IncomePerYear,
  COUNT(DISTINCT MONTH(t1.OrderDate)) AS NumberOfDistinctMonths,
  CAST(ROUND(12 * ((SUM(t3.ExtendedPrice - t3.TaxAmount))/COUNT(DISTINCT MONTH(t1.OrderDate))*1.00),2)AS DECIMAL(18,2)) AS YearlyLinearIncome
FROM Sales.Orders t1
JOIN Sales.Invoices t2 
ON t1.OrderID = t2.OrderID
JOIN Sales.InvoiceLines t3 
ON t2.InvoiceID = t3.InvoiceID
GROUP BY YEAR(t1.OrderDate)
)
SELECT 
t0.Year,
t0.IncomePerYear,
t0.NumberOfDistinctMonths,
t0.YearlyLinearIncome,
CAST((((t0.YearlyLinearIncome - t4.IncomePerYear) / t4.IncomePerYear) * 100) AS DECIMAL(18,2))
AS GrowthRate
FROM YearlyIncome t0
LEFT JOIN YearlyIncome t4 
ON t0.Year = t4.Year + 1
ORDER BY t0.Year;





--2


WITH NewOne AS (
    SELECT 
    YEAR(t1.OrderDate) AS TheYear,
    DATEPART(QUARTER, t1.OrderDate) AS TheQuarter,
    t2.CustomerName,
    SUM(t3.ExtendedPrice - t3.TaxAmount) AS IncomePerYear
FROM Sales.Orders t1
JOIN Sales.Invoices t4 ON t1.OrderID = t4.OrderID
JOIN Sales.InvoiceLines t3 ON t4.InvoiceID = t3.InvoiceID
JOIN Sales.Customers t2 ON t1.CustomerID = t2.CustomerID
GROUP BY YEAR(t1.OrderDate), DATEPART(QUARTER, t1.OrderDate), t2.CustomerName
),
RankedCustomers AS (
SELECT *,
DENSE_RANK() OVER (PARTITION BY TheYear, TheQuarter ORDER BY IncomePerYear DESC ) AS DNR
FROM NewOne
)
SELECT *
FROM RankedCustomers
WHERE DNR <= 5
ORDER BY TheYear, TheQuarter, DNR;


--3

SELECT TOP 10
    t3.StockItemID,
    t3.Description AS StockItemName,
    SUM(t3.ExtendedPrice - t3.TaxAmount) AS TotalProfit
FROM Sales.Orders t1
INNER JOIN Sales.Invoices t2
 ON t1.OrderID = t2.OrderID
INNER JOIN Sales.InvoiceLines t3 
ON t2.InvoiceID = t3.InvoiceID
GROUP BY t3.StockItemID, t3.Description
ORDER BY TotalProfit DESC;



--4
SELECT 
StockItemID,
StockItemName,
UnitPrice,
RecommendedRetailPrice,
RecommendedRetailPrice - UnitPrice AS NominalProductProfit,
DENSE_RANK() OVER (ORDER BY (RecommendedRetailPrice - UnitPrice) DESC) AS DNR
FROM Warehouse.StockItems
WHERE 1=1
AND ValidFrom < GETDATE()
AND ValidTo > GETDATE()
ORDER BY NominalProductProfit DESC;


--5

WITH SupplierCounts AS (
 SELECT 
 SupplierID,
 RANK() OVER (ORDER BY SupplierID) AS ProductCount
FROM Warehouse.StockItems
WHERE StockItemName IS NOT NULL
GROUP BY SupplierID
)

SELECT 
 CAST(t1.SupplierID AS VARCHAR) + ' - ' + t1.SupplierName AS SupplierDetails,
 STUFF(( SELECT ' /,' + CAST(t2.StockItemID AS VARCHAR) + ' ' + t2.StockItemName
FROM Warehouse.StockItems t2
WHERE t2.SupplierID = t1.SupplierID
AND t2.StockItemName IS NOT NULL
   FOR XML PATH('')), 1, 3, '') AS ProductDetails
FROM Purchasing.Suppliers t1
INNER JOIN SupplierCounts t3 
ON t1.SupplierID = t3.SupplierID
ORDER BY t3.ProductCount;

--6 

SELECT TOP 5
  t1.CustomerID,
  t3.CityName,
  t5.CountryName,
  t5.Continent,
  t5.Region,
  CAST (SUM(t6.ExtendedPrice) AS MONEY) AS TotalExtendedprice
FROM Sales.Invoices t1
LEFT JOIN Sales.Customers t2
ON t1.CustomerID=t2.CustomerID
LEFT JOIN Application.Cities t3
ON t2.DeliveryCityID=t3.CityID 
LEFT JOIN Application.StateProvinces t4
ON t3.StateProvinceID=t4.StateProvinceID
LEFT JOIN Application.Countries t5
ON t4.CountryID=t5.CountryID 
LEFT JOIN Sales.InvoiceLines t6
ON t1.InvoiceID=t6.InvoiceID
GROUP BY t3.CityName,t5.CountryName,t5.Continent,t5.Region, t1.CustomerID
ORDER BY TotalExtendedprice DESC

--7


/*
I used the 'Invoices' table instead of the 'Orders' table because I thought Invoices
would provide a more accurate result for the question, which is seeking to sum and calculate
a total order amount for every year and month.

Unlike Orders, which still hold the possibility of not going through fully, 
Invoices carry more weight because they are issued only after an order has been confirmed
*/


SELECT
Yearly AS OrderYear,
CASE
  WHEN Monthly = 13 THEN 'Grand Total'
  ELSE CAST(Monthly AS VARCHAR(2)) 
  END  AS OrderMonth,
 MonthlyTotal,
  CASE 
  WHEN Monthly = 13      
  THEN MonthlyTotal
  ELSE SUM(MonthlyTotal) OVER (PARTITION BY Yearly ORDER BY Monthly )
    END  AS CumulativeTotal
FROM (
SELECT 
  YEAR(t1.InvoiceDate)  AS Yearly,
  MONTH(t1.InvoiceDate) AS Monthly,
  SUM(t2.ExtendedPrice - t2.TaxAmount) AS MonthlyTotal
FROM   Sales.Invoices     AS t1
JOIN   Sales.InvoiceLines AS t2
ON t2.InvoiceID = t1.InvoiceID
GROUP BY YEAR(t1.InvoiceDate), MONTH(t1.InvoiceDate)

 UNION ALL

SELECT 
  YEAR(t1.InvoiceDate)  AS Yearly,
  13  AS Monthly,
  SUM(t2.ExtendedPrice - t2.TaxAmount) AS MonthlyTotal
FROM   Sales.Invoices     AS t1
JOIN   Sales.InvoiceLines AS t2
ON t2.InvoiceID = t1.InvoiceID
GROUP BY YEAR(t1.InvoiceDate)) AS t4
ORDER BY Yearly, Monthly;




--8


SELECT
    MONTH(OrderDate) AS OrderMonth,
    SUM(CASE 
    WHEN YEAR(OrderDate)=2013 
    THEN 1 END)    AS [2013],
    SUM(CASE 
    WHEN YEAR(OrderDate)=2014 
    THEN 1 END)    AS [2014],
    SUM(CASE 
    WHEN YEAR(OrderDate)=2015 
    THEN 1 END)    AS [2015],
    ISNULL( SUM(CASE 
    WHEN YEAR(OrderDate)=2016 
    THEN 1 END),0)   AS [2016]
FROM Sales.Orders
WHERE 1=1
GROUP BY MONTH(OrderDate)
ORDER BY OrderMonth;

--9




WITH DayGaps AS (
SELECT  
t1.CustomerID,
t2.CustomerName,
t1.InvoiceDate,
LAG(t1.InvoiceDate) OVER (PARTITION BY t1.CustomerID ORDER BY t1.InvoiceDate) AS PrevDate
FROM    Sales.Invoices  AS t1
JOIN    Sales.Customers AS t2
ON t2.CustomerID = t1.CustomerID
),

AVGPerCus AS (
 SELECT
 CustomerID,
 CustomerName,
 DATEDIFF( DAY, MAX(CASE WHEN rn = 1 THEN PrevDate END),
           MAX(CASE WHEN rn = 1 THEN InvoiceDate END) )   AS DayDiffBetweenOrders,
 AVG(DATEDIFF(DAY, PrevDate, InvoiceDate)) AS AvgDaysBetweenOrders
FROM (
SELECT  *,
ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY InvoiceDate DESC) AS rn
FROM    DayGaps 
WHERE   PrevDate IS NOT NULL ) AS t4
GROUP BY CustomerID, CustomerName
)

SELECT
CustomerID,
CustomerName,
DayDiffBetweenOrders,
AvgDaysBetweenOrders,
IIF(DayDiffBetweenOrders > 2 * AvgDaysBetweenOrders,
    'Potential Churn',         
    'Active')   AS CustomerStatus
FROM  AVGPerCus
ORDER BY CustomerID;



/*
I used the 'Invoices' table instead of the 'Orders' table because I thought Invoices
would provide a more accurate result for the question, which is seeking to sum and calculate
a total order amount for every year and month.

Unlike Orders, which still hold the possibility of not going through fully, 
Invoices carry more weight because they are issued only after an order has been confirmed
*/




--10

SELECT
 t2.CustomerCategoryName,
 COUNT(DISTINCT COALESCE(BillToCustomerID,CustomerID))  AS CustomerCount,
 SUM(COUNT(DISTINCT COALESCE(BillToCustomerID,CustomerID))) OVER ()  AS TotalCustCount,
 CAST(CAST(100.0 * COUNT(DISTINCT COALESCE(BillToCustomerID,CustomerID)) / SUM(COUNT(DISTINCT COALESCE(BillToCustomerID,CustomerID)))  OVER () AS MONEY) AS VARCHAR)+ '%'  AS DistributionFactor
FROM Sales.Customers    AS t1
INNER JOIN  Sales.CustomerCategories AS t2
ON t2.CustomerCategoryID = t1.CustomerCategoryID
GROUP BY t2.CustomerCategoryName
ORDER BY t2.CustomerCategoryName;


/* In my opinion and based on the customer spread in its own category and as up to 22.43% 
out of the total customers pie, seems like the 'Novelty Shop' Category is the highest risk 
out of them all.
And especially because there are two main customers (which own multiple branches)
that populates the majority of that category.*/




