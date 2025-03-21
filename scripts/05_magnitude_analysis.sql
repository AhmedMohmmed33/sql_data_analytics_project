/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- Find total customers by countries
SELECT
	country,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Find total customers by gender
SELECT
	gender,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total products by categories
SELECT
	category,
	COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- What is the average costs in each category?
SELECT
	category,
	AVG(cost) AS average_costs
FROM gold.dim_products
GROUP BY category
ORDER BY average_costs DESC;

-- What is the total revenue generated for each category?
SELECT
	p.category,
	SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products P
	ON p.product_key = s.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- What is the total revenue generated by each custmer?
SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
	ON c.customer_key = s.customer_key
GROUP BY
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC;

-- What is the distribution of sold items across countries?
SELECT
	c.country,
	SUM(s.quantity) AS total_sold_items
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
	ON c.customer_key = s.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;
