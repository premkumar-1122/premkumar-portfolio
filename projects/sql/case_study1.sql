use case_study1;

## Renaming column names

alter table customer_profiles
rename column ï»¿CustomerID to CustomerID;

alter table product_inventory
rename column ï»¿ProductID to ProductID;

alter table sales_transaction
rename column ï»¿TransactionID to TransactionID;

## Data Cleaning

## Removing Duplicate transactions

SELECT TransactionID, COUNT(*)
FROM sales_transaction
GROUP BY TransactionID
HAVING COUNT(*) > 1;

CREATE TABLE sales_transaction_nodup AS
SELECT DISTINCT * 
FROM sales_transaction;

DROP TABLE sales_transaction;

ALTER TABLE sales_transaction_nodup 
RENAME to sales_transaction;

## identify and fix incorrect price in sales_transaction

SELECT st.TransactionID, st.price AS TransactionPrice, pi.price AS ProductPrice
FROM sales_transaction st
JOIN product_inventory pi ON st.productId = pi.productId
WHERE st.price != pi.price;

UPDATE sales_transaction st
SET st.price = ( 
	SELECT pi.price 
	FROM Product_inventory pi
	WHERE st.ProductID = pi.ProductID
)
WHERE st.ProductID IN (
	SELECT ProductID 
    FROM product_inventory
	WHERE st.price <> product_inventory.Price
);

# Identify and Update null values 

SELECT COUNT(*) 
FROM customer_profiles
WHERE Location IS NULL OR Location = "";

UPDATE customer_profiles
SET Location = "Unknown"
WHERE Location IS NULL OR Location = "";

## Clean the Date column

CREATE TABLE sales_transaction_updated AS 
SELECT *, STR_TO_DATE(TransactionDate,'%d/%m/%y') AS TransactionDate_updated
FROM sales_transaction;

SELECT * FROM sales_transaction_updated;

DROP TABLE sales_transaction;

ALTER TABLE sales_transaction_updated RENAME TO sales_transaction;

## EDA
## summarize the total sales and quantities sold per product

SELECT ProductID, SUM(QuantityPurchased) AS TotalUnitsSold,
ROUND(SUM(QuantityPurchased*Price),2) AS TotalSales
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalSales DESC;


# purchase frequency.

SELECT CustomerID, COUNT(*) AS NumberOfTransaction
FROM sales_transaction
GROUP BY CustomerID
ORDER BY NumberOfTransaction DESC;

# Product Categories Performance

SELECT pi.Category, SUM(st.QuantityPurchased) AS TotalUnitsSold,
ROUND(SUM(st.QuantityPurchased * st.Price),2) AS TotalSales
FROM product_inventory pi
JOIN sales_transaction st ON pi.ProductID = st.ProductID
GROUP BY pi.Category
ORDER BY TotalSales DESC;

## High Sales Products

SELECT ProductID, ROUND(SUM(QuantityPurchased*Price),2) AS TotalRevenue
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalRevenue DESC
LIMIT 10;

## Low Sales Products

SELECT ProductID, SUM(QuantityPurchased) AS TotalUnitsSold
FROM sales_transaction
GROUP BY ProductID
HAVING TotalUnitsSold > 0
ORDER BY TotalUnitsSold
LIMIT 10;

## Sales Trend

SELECT TransactionDate as DATETRANS,
COUNT(*) AS Transaction_count,
SUM(QuantityPurchased) AS TotalUnitsSold,
SUM(QuantityPurchased * Price) AS TotalSales
FROM sales_transaction
GROUP BY TransactionDate
ORDER BY DATETRANS DESC ;

## growth trend of the company

WITH monthly_sales as (
    SELECT MONTH(TransactionDate) as month, 
    ROUND(SUM(QuantityPurchased*Price),2) AS total_sales
    FROM sales_transaction
    GROUP BY MONTH(TransactionDate)
)
SELECT month, total_sales, 
LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY month)) / 
LAG(total_sales) OVER (ORDER BY month)) * 100, 2) AS mom_growth_percentage
FROM monthly_sales;

## high frequency purchase customers in the company

SELECT CustomerID, COUNT(*) AS NumberOfTransactions,
SUM(QuantityPurchased * Price) AS TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions > 10 AND TotalSpent > 1000
ORDER BY TotalSpent DESC;

## customers with low purchase frequency in the company

SELECT CustomerID, COUNT(*) AS NumberOfTransactions,
SUM(QuantityPurchased * Price) AS TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions <= 2 
ORDER BY NumberOfTransactions ASC, TotalSpent DESC;

##  repeat customers in the company

SELECT CustomerID, ProductID,
COUNT(*) AS TimesPurchased
FROM sales_transaction
GROUP BY CustomerID, ProductID
HAVING TimesPurchased > 1
ORDER BY TimesPurchased DESC
























