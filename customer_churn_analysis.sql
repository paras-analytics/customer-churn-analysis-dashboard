
-- =============================================
-- CUSTOMER CHURN & REVENUE ANALYSIS PROJECT
-- SQL Data Cleaning + KPI + Business Insights
-- =============================================

-- =============================================
--  INITIAL SQL CONFIGURATION
-- =============================================
SET SQL_SAFE_UPDATES = 0;

-- =============================================
--  COLUMN NAME CLEANING
-- =============================================

-- Fix hidden BOM character in imported CSV column name
ALTER TABLE Customers
RENAME COLUMN `ï»¿CustomerID` TO CustomerID;

-- =============================================
-- DATA CLEANING & DATE CONVERSION

-- Schema Validation / Data Type Check
DESC Churn;
DESC Customers;
DESC Subscriptions;
DESC Transactions;

-- =====================================
--  Raw Data Validation (Check Date Format)
-- =====================================
SELECT * FROM Churn LIMIT 10;
SELECT * FROM Customers LIMIT 10;
SELECT * FROM Subscriptions LIMIT 10;
SELECT * FROM Transactions LIMIT 10;

-- =====================================
--  Convert Text Date to SQL Date Format
-- =====================================

-- ChurnDate: format = YYYY-DD-MM
UPDATE Churn
SET ChurnDate = STR_TO_DATE(ChurnDate, '%Y-%d-%m')
WHERE ChurnDate IS NOT NULL;

-- =====================================
--  Change Data Type to DATE
-- =====================================
ALTER TABLE Churn
MODIFY ChurnDate DATE;

ALTER TABLE Customers
MODIFY JoinDate DATE;

ALTER TABLE Subscriptions
MODIFY StartDate DATE,
MODIFY EndDate DATE;

ALTER TABLE Transactions
MODIFY TransactionDate DATE;

-- BASIC KPIs
-- =============================================

-- Total Customers
SELECT COUNT(*) AS Total_Customers
FROM Customers;

-- Active vs Inactive Customers
SELECT 
    Status,
    COUNT(*) AS Customer_Count
FROM Customers
GROUP BY Status;

-- Total Revenue
SELECT 
    ROUND(SUM(Amount), 2) AS Total_Revenue
FROM Transactions;

-- Total Transactions
SELECT 
    COUNT(*) AS Total_Transactions
FROM Transactions;

-- =============================================
--  CHURN ANALYSIS
-- =============================================

-- Total Churned Customers
SELECT 
    COUNT(DISTINCT CustomerID) AS Churned_Customers
FROM Churn;

-- Churn Rate (%)
SELECT 
    ROUND(
        (SELECT COUNT(DISTINCT CustomerID) FROM Churn) * 100.0 /
        (SELECT COUNT(*) FROM Customers),
        2
    ) AS Churn_Rate_Percentage;

-- Churn by Reason
SELECT 
    Reason,
    COUNT(*) AS Churn_Count
FROM Churn
GROUP BY Reason
ORDER BY Churn_Count DESC;

-- Churn by Region
SELECT 
    c.Region,
    COUNT(*) AS Churn_Count
FROM Churn ch
JOIN Customers c
    ON ch.CustomerID = c.CustomerID
GROUP BY c.Region
ORDER BY Churn_Count DESC;

-- Monthly Churn Trend
SELECT 
    DATE_FORMAT(ChurnDate, '%Y-%m') AS Month,
    COUNT(*) AS Churn_Count
FROM Churn
GROUP BY Month
ORDER BY Month;

-- =============================================
--  REVENUE ANALYSIS
-- =============================================

-- Monthly Revenue Trend
SELECT 
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    ROUND(SUM(Amount), 2) AS Revenue
FROM Transactions
GROUP BY Month
ORDER BY Month;

-- Revenue by Subscription Plan
SELECT 
    s.PlanType,
    ROUND(SUM(t.Amount), 2) AS Revenue
FROM Transactions t
JOIN Subscriptions s
    ON t.CustomerID = s.CustomerID
GROUP BY s.PlanType
ORDER BY Revenue DESC;

-- Revenue by Region
SELECT 
    c.Region,
    ROUND(SUM(t.Amount), 2) AS Revenue
FROM Transactions t
JOIN Customers c
    ON t.CustomerID = c.CustomerID
GROUP BY c.Region
ORDER BY Revenue DESC;

-- =============================================
-- ADVANCED BUSINESS METRICS
-- =============================================

-- ARPU (Average Revenue Per User)
SELECT 
    ROUND(
        SUM(Amount) / COUNT(DISTINCT CustomerID),
        2
    ) AS ARPU
FROM Transactions;

-- Revenue per Customer
SELECT 
    CustomerID,
    ROUND(SUM(Amount), 2) AS Total_Revenue
FROM Transactions
GROUP BY CustomerID
ORDER BY Total_Revenue DESC;

-- Top 10 Customers by Revenue
SELECT 
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    ROUND(SUM(t.Amount), 2) AS Revenue
FROM Customers c
JOIN Transactions t
    ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, FullName
ORDER BY Revenue DESC
LIMIT 10;

-- =============================================
-- SUBSCRIPTION ANALYSIS
-- =============================================

-- Active Subscriptions by Plan
SELECT 
    PlanType,
    COUNT(*) AS Subscription_Count
FROM Subscriptions
GROUP BY PlanType;

-- Subscription Duration
SELECT 
    CustomerID,
    DATEDIFF(EndDate, StartDate) AS Subscription_Days
FROM Subscriptions;

-- =============================================
--   BUSINESS INSIGHT
-- =============================================

-- Customers with No Transactions
SELECT 
    c.CustomerID
FROM Customers c
LEFT JOIN Transactions t
    ON c.CustomerID = t.CustomerID
WHERE t.CustomerID IS NULL;

