# ☕️ Cafe Sales Data Cleaning & Analysis (PostgreSQL)

## 📌 Project Overview
This project simulates the real-world role of a Data Analyst handling raw, messy business data. The initial dataset was received as an unformatted and noisy CSV file containing structural typos, corrupted records (like 'ERROR' and 'UNKNOWN' strings in numerical fields), random leading/trailing whitespaces, and incorrect text data types used for transactional dates and product prices.

The goal was to design and execute a robust data cleaning pipeline using PostgreSQL, transform the chaotic rows into a structured relational schema, and then run analytical queries to extract actionable business insights for management.

---

## 📁 Repository Structure
* cafe_sales_clean_sql.sql : Contains the analytical query scripts used for the project reports.
* README.md : Comprehensive documentation of the project pipeline, engineering fixes, and business queries.

---

## 🛠️ Phase 1: Data Cleaning & Transformation

### 1. Identified Issues in the Raw Dataset:
* Garbage Values: Corrupted rows contained string values like 'ERROR' and 'UNKNOWN' inside numeric columns (quantity, price_per_unit, total_spent).
* Whitespace Noise: Text fields and primary keys had inconsistent leading/trailing spaces (e.g., "  Coffee  ").
* Incorrect Data Types: Transaction dates and numerical values were entirely stored as text/character varying fields.
* Missing Calculations: Several transactional rows had blank or broken total_spent fields despite having valid item quantities and unit prices.

### 2. Production Pipeline Implementation (The Cleaning Script):
A production table (cafe_sales_clean) was built with strict, normalized data types. The raw data was programmatically parsed, cleansed, and mathematically reconciled using targeted UPDATE scripts with explicit type-casting (::), conditional statements (CASE WHEN), and text normalization tools (TRIM):

`sql
UPDATE cafe_sales_clean c
SET 
    -- 1. Cleaning and casting item quantities
    quantity = CASE 
        WHEN r.quantity IN ('ERROR', 'UNKNOWN', '') THEN NULL 
        ELSE r.quantity::INTEGER 
    END,
    
    -- 2. Cleaning and casting item unit prices
    price_per_unit = CASE 
        WHEN r.price_per_unit IN ('ERROR', 'UNKNOWN', '') THEN NULL 
        ELSE r.price_per_unit::NUMERIC 
    END,
    
    -- 3. Handling and recalculating transactional total spent to bypass raw row anomalies
    total_spent = CASE 
        WHEN r.total_spent NOT IN ('ERROR', 'UNKNOWN', '') THEN r.total_spent::NUMERIC
        WHEN r.quantity NOT IN ('ERROR', 'UNKNOWN', '') AND r.price_per_unit NOT IN ('ERROR', 'UNKNOWN', '') 
        THEN r.quantity::INTEGER * r.price_per_unit::NUMERIC
        ELSE 0.00
    END
FROM cafe_sales_raw r
WHERE c.transaction_id = TRIM(r.transaction_id);
 
