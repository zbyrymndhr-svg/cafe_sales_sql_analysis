select * from cafe_sales_clean;
---Product Performance:
select
      item_name as "product name",
	  sum(quantity) as "total quantity sold",
	  sum(total_spent) as "total revenue ($)"
from cafe_sales_clean
group by item_name
order by 3 desc;
---Location Performance:
SELECT 
    location AS "Branch Location",
    COUNT(transaction_id) AS "Total Transactions",
    SUM(quantity) AS "Total Items Sold",
    SUM(total_spent) AS "Total Revenue ($)"
FROM cafe_sales_clean
GROUP BY location
ORDER BY 4 DESC; 
---Monthly Sales Trend:
SELECT 
    TO_CHAR(transaction_date, 'YYYY-MM') AS "الشر والسنة",
    COUNT(transaction_id) AS "عدد الفواتير",
    SUM(quantity) AS "إجمالي القطع المباعة",
    SUM(total_spent) AS "إجمالي مبيعات الشهر ($)"
FROM cafe_sales_clean
GROUP BY TO_CHAR(transaction_date, 'YYYY-MM')
ORDER BY 1 ASC; 
---Payment Method Analysis:
SELECT 
    payment_method AS "طريقة الدفع",
    COUNT(transaction_id) AS "عدد العمليات",
    SUM(total_spent) AS "إجمالي المبالغ المستلمة ($)",
    ROUND(AVG(total_spent), 2) AS "متوسط قيمة الفاتورة الواحدة ($)"
FROM cafe_sales_clean
GROUP BY payment_method
ORDER BY 3 DESC;