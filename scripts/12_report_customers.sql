/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
	
WITH base_query AS
(	
	/*---------------------------------------------------------
	(1) Base Query: Retrive core columns from tables
	---------------------------------------------------------*/
	SELECT
		s.order_number,
		s.product_key,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		s.price,
		s.quantity,
		s.sales_amount,
		s.order_date,
		DATEDIFF(year, c.birthdate, GETDATE()) AS age
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
		ON c.customer_key = s.customer_key
	WHERE s.order_date IS NOT NULL
)
, Customer_Aggregation AS
(
	/*---------------------------------------------------------------------------
	2) Customer Aggregations: Summarizes key metrics at the customer level
	---------------------------------------------------------------------------*/
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT product_key) AS total_products,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		MAX(order_date) AS last_order,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM base_query
	GROUP BY
		customer_key,
		customer_number,
		customer_name,
		age
)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE WHEN age < 20 THEN 'Below 20'
	     WHEN age BETWEEN 20 AND 29 THEN '20-29'
	     WHEN age BETWEEN 30 AND 39 THEN '30-39'
	     WHEN age BETWEEN 40 AND 49 THEN '40-49'
	     ELSE '50 and Above'
	END AS age_group,
	CASE WHEN lifespan >= 12 and total_sales > 5000 THEN 'VIP'
	     WHEN lifespan >= 12 and total_sales <= 5000 THEN 'Regular'
	     ELSE 'New'
	END AS customer_segment,
	last_order,
	DATEDIFF(month, last_order, GETDATE()) AS recency,
	total_orders,
	total_products,
	total_sales,
	total_quantity,
	lifespan,
	-- Compute average order value (AVO)
	CASE WHEN total_sales = 0 THEN 0
	     ELSE total_sales / total_orders
	END AS avg_order_value,
	-- Compute average monthly spend
	CASE WHEN lifespan = 0 THEN total_sales
	     ELSE total_sales / lifespan
	END AS avg_monthly_spending
FROM Customer_Aggregation;

