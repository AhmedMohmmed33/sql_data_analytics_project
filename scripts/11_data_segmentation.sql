/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

-- Segment products into cost range and count how many products fall into each segment

WITH product_segments AS
(
	SELECT
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
	     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	     WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	     ELSE 'Above 1000'
	END AS cost_range
	FROM gold.dim_products
)
SELECT
	COUNT(product_name) AS total_products,
	cost_range
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


/*
Group customers into three segments on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group.
*/

WITH customer_spending AS
(
	SELECT
		c.customer_key,
		SUM(s.sales_amount) AS total_spending,
		MIN(s.order_date) AS first_order,
		MAX(s.order_date) AS last_order,
		DATEDIFF(month, MIN(s.order_date), MAX(s.order_date)) AS lifespan
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
		ON c.customer_key = s.customer_key
	GROUP BY c.customer_key
)
,segmented_customers AS
(
	SELECT
		customer_key,
		lifespan,
		total_spending,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		     WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		     ELSE 'New'
		END AS customer_segment
	FROM customer_spending
)
SELECT
  COUNT(customer_key) AS total_customer,
  customer_segment
FROM segmented_customers
GROUP BY customer_segment
ORDER BY total_customer DESC;
