/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month
-- And the running total of sales over time
SELECT
  order_month,
  total_sales,
  SUM(total_sales) OVER(PARTITION BY YEAR(order_month) ORDER BY order_month) AS running_total_sales,
  average_price,
  AVG(average_price) OVER(PARTITION BY YEAR(order_month) ORDER BY order_month) AS moving_average_price
FROM
(
  SELECT
  DATETRUNC(month, order_date) AS order_month,
  SUM(sales_amount) AS total_sales,
  AVG(price) AS average_price
  FROM gold.fact_sales
  WHERE order_date IS NOT NULL
  GROUP BY DATETRUNC(month, order_date)
)t
