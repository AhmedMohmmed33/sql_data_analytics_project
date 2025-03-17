/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which categories contribute the most to overall sales?

WITH category_sales AS
(
	SELECT
		p.category,
		SUM(s.sales_amount) AS total_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
		on p.product_key = s.product_key
	GROUP BY p.category
)
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT( ROUND( ( CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() ) * 100 , 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- Which categories and subcategories contribute the most to total number of orders?

WITH category_orders AS
(
	SELECT
		p.category,
		p.subcategory,
		SUM(s.price) AS price,
		COUNT(s.order_number) AS total_orders
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
		on p.product_key = s.product_key
	GROUP BY p.category, p.subcategory
)
SELECT
	category,
	subcategory,
	price,
	total_orders,
	SUM(total_orders) OVER() AS overall_orders,
	CONCAT( ROUND( ( CAST(total_orders AS FLOAT) / SUM(total_orders) OVER() ) * 100 , 2), '%') AS percentage_of_total
FROM category_orders
ORDER BY category, total_orders DESC;
