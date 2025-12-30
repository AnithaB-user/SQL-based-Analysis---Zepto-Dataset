/* ============================================================
   Project: Zepto Data Analysis
   Database: MySQL
   Description:
   - Table creation
   - Data exploration
   - Data cleaning
   - Business insights using SQL
   ============================================================ */

USE sqlproject;


1. TABLE SETUP

DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(8,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(8,2),
    weightInGms INT,
    outOfStock BOOLEAN,
    quantity INT
);


2. DATA EXPLORATION

-- Total number of records
SELECT COUNT(*) AS total_records
FROM zepto;

-- Sample data
SELECT *
FROM zepto
LIMIT 10;

-- Check for NULL values
SELECT *
FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- Distinct product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- In-stock vs Out-of-stock products
SELECT outOfStock, COUNT(*) AS product_count
FROM zepto
GROUP BY outOfStock;

-- Products appearing multiple times (different SKUs)
SELECT name, COUNT(*) AS number_of_skus
FROM zepto
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY number_of_skus DESC;

 3. DATA CLEANING

-- Identify invalid price records
SELECT *
FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- Remove invalid records
DELETE
FROM zepto
WHERE mrp = 0;

-- Convert prices from paise to rupees
UPDATE zepto
SET mrp = mrp / 100,
    discountedSellingPrice = discountedSellingPrice / 100;


 4. BUSINESS INSIGHTS
  
-- Q1: Top 10 best-value products by discount percentage
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2: High-MRP products that are out of stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE
  AND mrp > 300
ORDER BY mrp DESC;

-- Q3: Estimated revenue per category
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Q4: Products with MRP > ₹500 and discount < 10%
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5: Top 5 categories by highest average discount
SELECT category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6: Price per gram for products above 100g
SELECT DISTINCT name,
       weightInGms,
       discountedSellingPrice,
       ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7: Weight-based product classification
SELECT DISTINCT name,
       weightInGms,
       CASE
           WHEN weightInGms < 1000 THEN 'Low'
           WHEN weightInGms < 5000 THEN 'Medium'
           ELSE 'Bulk'
       END AS weight_category
FROM zepto;

-- Q8: Total inventory weight per category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight DESC;

--Q9: Percentage of High-MRP Products That Are Out of Stock
SELECT
  ROUND(
    (SUM(CASE WHEN outOfStock = TRUE THEN 1 ELSE 0 END) * 100.0) /
    COUNT(*), 2
  ) AS out_of_stock_percentage
FROM zepto
WHERE mrp > 500;

--Q10: Percentage of Total Revenue from Products with ≥20% Discount
SELECT
  ROUND(
    (SUM(CASE WHEN discountPercent >= 20
              THEN discountedSellingPrice * availableQuantity
              ELSE 0 END) * 100.0) /
    SUM(discountedSellingPrice * availableQuantity), 2
  ) AS high_discount_revenue_percentage
FROM zepto;




