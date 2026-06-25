----------------------------------------------------------------------
-- PHASE 1: DATABASE INITIALIZATION & DATA CLEANING PIPELINE
----------------------------------------------------------------------

-- 1. Create the clean production table with strict data types
DROP TABLE IF EXISTS cafe_sales_clean;

CREATE TABLE cafe_sales_clean (
    transaction_id VARCHAR(100) PRIMARY KEY, -- معرف فريد لا يتكرر
    transaction_date DATE,                   -- نوع تاريخ حقيقي
    item_name VARCHAR(150),                  -- اسم المنتج منسق
    quantity INTEGER,                        -- عدد صحيح
    price_per_unit NUMERIC(10,2),            -- رقم عشري دقيق للسعر
    total_spent NUMERIC(10,2),               -- رقم عشري للإجمالي
    payment_method VARCHAR(50),              -- طريقة الدفع
    location VARCHAR(50)                     -- موقع الفرع
);

-- 2. Execute Data Cleaning & Programmatic Financial Recovery
UPDATE cafe_sales_clean c
SET 
    -- Clean and cast item quantities, filtering out corrupt strings
    quantity = CASE 
        WHEN r.quantity IN ('ERROR', 'UNKNOWN', '') THEN NULL 
        ELSE r.quantity::INTEGER 
    END,
    
    -- Clean and cast unit prices, filtering out corrupt strings
    price_per_unit = CASE 
        WHEN r.price_per_unit IN ('ERROR', 'UNKNOWN', '') THEN NULL 
        ELSE r.price_per_unit::NUMERIC 
    END,
    
    -- Handle missing values and programmatically recalculate Total Spent
    total_spent = CASE 
        WHEN r.total_spent NOT IN ('ERROR', 'UNKNOWN', '') THEN r.total_spent::NUMERIC
        WHEN r.quantity NOT IN ('ERROR', 'UNKNOWN', '') AND r.price_per_unit NOT IN ('ERROR', 'UNKNOWN', '') 
        THEN r.quantity::INTEGER * r.price_per_unit::NUMERIC
        ELSE 0.00
    END
FROM cafe_sales_raw r
WHERE c.transaction_id = TRIM(r.transaction_id);


----------------------------------------------------------------------
-- PHASE 2: BUSINESS INTELLIGENCE & ANALYTICAL REPORTS
----------------------------------------------------------------------

-- Report 1: Product Performance Report (Top-Selling Items)
SELECT 
    item_name AS "Product Name",
    SUM(quantity) AS "Total Quantity Sold",
    SUM(total_spent) AS "Total Revenue ($)"
FROM cafe_sales_clean
GROUP BY item_name
ORDER BY 3 DESC;

-- Report 2: Location & Operational Efficiency
SELECT 
    location AS "Branch Location",
    COUNT(transaction_id) AS "Total Transactions",
    SUM(quantity) AS "Total Items Sold",
    SUM(total_spent) AS "Total Revenue ($)"
FROM cafe_sales_clean
GROUP BY location
ORDER BY 4 DESC;

-- Report 3: Monthly Sales Trends (Time-Series Growth Analysis)
SELECT 
    TO_CHAR(transaction_date, 'YYYY-MM') AS "Year-Month",
    COUNT(transaction_id) AS "Invoice Count",
    SUM(total_spent) AS "Monthly Revenue ($)"
FROM cafe_sales_clean
GROUP BY TO_CHAR(transaction_date, 'YYYY-MM')
ORDER BY 1 ASC;

-- Report 4: Payment Methods & Consumer Behavior
SELECT 
    payment_method AS "Payment Method",
    COUNT(transaction_id) AS "Transaction Count",
    SUM(total_spent) AS "Total Revenue ($)",
    ROUND(AVG(total_spent), 2) AS "Average Order Value ($)"
FROM cafe_sales_clean
GROUP BY payment_method
ORDER BY 3 DESC;
