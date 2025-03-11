USE sales_data;

DESCRIBE Customer;
DESCRIBE prod_cat_info;
DESCRIBE Transactions;

SELECT * FROM transactions LIMIT 100;
SELECT * FROM Customer LIMIT 100;
SELECT * FROM prod_cat_info;

-- number of reperitions
SELECT COUNT(transaction_id) - COUNT(DISTINCT transaction_id) AS n_repetitions
FROM Transactions;

-- Date overview
SELECT 
    MIN(tran_date) AS StartDate,
    MAX(tran_date) AS EndDate,
    DATEDIFF(MAX(tran_date), MIN(tran_date)) AS TotalDays,
    TIMESTAMPDIFF(MONTH, MIN(tran_date), MAX(tran_date)) AS TotalMonths,
    TIMESTAMPDIFF(YEAR, MIN(tran_date), MAX(tran_date)) AS TotalYears
FROM Transactions;

-- Most popular store type
SELECT store_type, COUNT(*) AS Count FROM transactions
GROUP BY store_type
ORDER BY COUNT(*) DESC;

-- Male/ Female count
SELECT GENDER, COUNT(*) AS Count FROM customer
GROUP BY GENDER;

-- City with max count of customers
SELECT city_code, COUNT(*) AS Count FROM customer
GROUP BY city_code
ORDER BY Count DESC;

-- Books subcategories
SELECT DISTINCT prod_subcat FROM prod_cat_info
WHERE prod_cat = 'books';

-- Max quantity ever ordered
SELECT * FROM transactions
ORDER BY QTY DESC, total_amt DESC;

-- Net revenue in electronics & books
SELECT SUM(total_amt) - SUM(tax) AS Net_revenue FROM transactions AS t
JOIN prod_cat_info AS pci ON pci.prod_cat_code = t.prod_cat_code
WHERE pci.prod_cat in ('BOOKS', 'ELECTRONICS');

-- Amount of Customers who have over 10 trancactions, excluding returns
SELECT COUNT(cust_id) AS Customers10Plus FROM (
SELECT cust_id, COUNT(DISTINCT transaction_id) AS count FROM transactions
GROUP BY cust_id ) AS subquery -- Must perform alias
WHERE count > 10;

-- Combined revenue from electronics & clothing, in flagship stores
SELECT SUM(total_amt) - SUM(Tax) AS Total_revenue_ele_clothing_flagship FROM transactions t
JOIN prod_cat_info as pci ON pci.prod_cat_code = t.prod_cat_code
WHERE t.Store_type LIKE '%flag%' AND pci.prod_cat IN ('electronics', 'clothing');

-- The AND is important since there are combinations of cat and sub_cat (no unique ID)
-- Gross revenue per prod sub category, in electronics, among Male
SELECT pci.prod_subcat AS Subcategory, SUM(t.total_amt) AS Total_revenue FROM transactions AS t
JOIN prod_cat_info as pci ON pci.prod_cat_code = t.prod_cat_code
  AND pci.prod_sub_cat_code = t.prod_subcat_code -- Ensure correct subcategory match
JOIN customer as c ON c.customer_Id = t.cust_id
WHERE pci.prod_cat = 'electronics' AND c.Gender = 'M'
GROUP BY pci.prod_subcat
ORDER BY Total_revenue DESC;

-- Percentage of sales and returns, by sub-categories, TOP 5
SELECT 
    p.prod_subcat Sub_category, 
    (SUM(t.total_amt) * 100.0) / (SELECT SUM(total_amt) FROM Transactions) AS SalesPercentage,
    (SUM(CASE WHEN t.Qty < 0 THEN 1 ELSE 0 END) * 100.0) / SUM(ABS(t.Qty)) AS PercentageOfReturn
FROM Transactions t
JOIN prod_cat_info p 
    ON t.prod_cat_code = p.prod_cat_code 
    AND t.prod_subcat_code = p.prod_sub_cat_code
GROUP BY p.prod_subcat
ORDER BY SalesPercentage DESC
LIMIT 5;

-- Among 25-35 years old customers, net total revenue per store type in the last 30 days avaiable in the data :
SELECT Store_type, SUM(total_amt) FROM customer c
JOIN transactions t ON t.cust_id = c.customer_Id
WHERE (YEAR(CURDATE()) - YEAR(c.DOB)) BETWEEN 25 AND 35
AND t.tran_date >= (
    SELECT MAX(tran_date) 
    FROM transactions
) - INTERVAL 30 DAY
GROUP BY Store_type;

-- In the last 3 months avaiable in the data, the categories with most returns
SELECT p.prod_cat, COUNT(t.transaction_id) AS Returns_Count  -- Count the number of returns (negative Rate)
FROM transactions AS t
JOIN prod_cat_info AS p ON t.prod_cat_code = p.prod_cat_code 
    AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE t.Rate < 0  -- Filter for returns (negative Rate)
AND t.tran_date >= ( -- Last 3 months avaiable in the data
    SELECT DATE_SUB(MAX(tran_date), INTERVAL 3 MONTH)
    FROM Transactions
)
GROUP BY p.prod_cat
ORDER BY Returns_Count DESC;

-- The type of store that sells max(n_products) products, orderd by value of sales per category, then by quantity sold
SELECT t.Store_type, SUM(t.Qty) Total_quantity, SUM(t.total_amt) Total_sales FROM transactions t
JOIN prod_cat_info p ON p.prod_cat_code = t.prod_cat_code
	AND t.prod_subcat_code = p.prod_sub_cat_code
JOIN customer c ON c.customer_Id = t.cust_id
GROUP BY Store_type
ORDER BY Total_sales DESC, Total_quantity ;

-- The categories for which AVG(revenue) is above overall AVG
SELECT p.prod_cat Category, AVG(t.total_amt) AS Avg_Revenue
FROM transactions t
JOIN prod_cat_info p ON p.prod_cat_code = t.prod_cat_code
GROUP BY Category
HAVING AVG(t.total_amt) > (SELECT AVG(total_amt) FROM transactions);
