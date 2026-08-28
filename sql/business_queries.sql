-- Business Question 1 : Who are our top 10 customers by total revenue?

SELECT 
    c.customer_id,
    c.country,
    SUM(ii.revenue) AS total_revenue
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
WHERE i.is_cancelled = 0
GROUP BY c.customer_id, c.country
ORDER BY total_revenue DESC
LIMIT 10;

-- Insight: Revenue is strongly concentrated among a small number of high value customers.
-- Customer 18102 is the highest revenue customer at £580,987.04, followed by customer
-- 14646 at £526,751.52. The top customers also come from multiple markets, including
-- the United Kingdom, Netherlands, and EIRE, showing that major customer value is not
-- limited to the UK market.

-- Business Question 2: Which countries generate the most revenue?

SELECT 
    c.country,
    SUM(ii.revenue) AS total_revenue,
    COUNT(DISTINCT i.invoice_id) AS total_orders
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
WHERE i.is_cancelled = 0
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Insight: UK generates £14.29M (85.5% of revenue) from 33,371 orders. EIRE, Netherlands,
-- and Germany are the largest international markets, though all remain small relative
-- to the UK confirming international growth as an underdeveloped opportunity.

-- Business Question 3: Which product categories generate the most revenue?

SELECT 
    p.category,
    SUM(ii.revenue) AS total_revenue,
    SUM(ii.quantity) AS total_items_sold
FROM invoice_items ii
JOIN invoices i ON ii.invoice_id = i.invoice_id
JOIN products p ON ii.stock_code = p.stock_code
WHERE i.is_cancelled = 0
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Insight: Kitchen & Dining is the highest revenue category at £4.50M,
-- followed by Home Decor & Lighting at £3.97M. Together, these two categories
-- generate approximately £8.47M in completed revenue, making them the strongest
-- product categories in the business. This indicates that revenue is concentrated
-- in a relatively small number of product categories.

-- Business Question 4: Which high-spending customers also show notable cancellation activity?

SELECT 
    c.customer_id,
    c.country,
    SUM(CASE WHEN i.is_cancelled = 0 THEN ii.revenue ELSE 0 END) AS completed_revenue,
    COUNT(DISTINCT CASE WHEN i.is_cancelled = 1 THEN i.invoice_id END) AS cancelled_orders,
    COUNT(DISTINCT i.invoice_id) AS total_orders,
    ROUND(COUNT(DISTINCT CASE WHEN i.is_cancelled = 1 THEN i.invoice_id END) 
          / COUNT(DISTINCT i.invoice_id) * 100, 2) AS cancellation_rate_pct
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
GROUP BY c.customer_id, c.country
HAVING completed_revenue > 1000 AND cancellation_rate_pct > 0
ORDER BY completed_revenue DESC
LIMIT 20;

-- Insight: Several high value customers also show substantial cancellation activity.
-- Customer 14156 generated £303,069.88 in completed revenue with a 24.21% cancellation
-- rate, while Customer 14911 generated £272,252.79 with a 23.09% cancellation rate.
-- These customers should be prioritized for further analysis to understand the drivers
-- of their cancellations and identify opportunities to protect revenue.

-- Business Question 5: How do customers rank by completed revenue within their country?
SELECT
c.customer_id, c.country, 
ROUND(SUM(ii.revenue), 2)AS total_revenue,
RANK() OVER (
PARTITION BY c.country
ORDER BY SUM(ii.revenue) DESC ) 
AS revenue_rank_in_country
FROM customers c
JOIN invoices i 
     ON c.customer_id = i.customer_id
JOIN invoice_items ii
    ON i.invoice_id = ii.invoice_id
WHERE i.is_cancelled = 0 
GROUP BY c.customer_id, c.country
ORDER BY c.country, revenue_rank_in_country;

-- Insight: Ranking customers within each country identifies high-value customers who
-- may not appear in the global top-customer ranking. For example, Customer 12415
-- ranks first in Australia with £144,033.37 in completed revenue, substantially
-- exceeding the other Australian customers shown. Country-level rankings can help
-- identify locally important customers for market-specific retention strategies.

-- Business Question 6:Which customers generate more revenue than the average customer?

SELECT
    customer_id,
    country,
    total_revenue
FROM (
    SELECT
        c.customer_id,
        c.country,
        ROUND(SUM(ii.revenue), 2) AS total_revenue
    FROM customers c
    JOIN invoices i
        ON c.customer_id = i.customer_id
    JOIN invoice_items ii
        ON i.invoice_id = ii.invoice_id
    WHERE i.is_cancelled = 0
    GROUP BY c.customer_id, c.country
) AS customer_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM (
        SELECT
            SUM(ii.revenue) AS total_revenue
        FROM customers c
        JOIN invoices i
            ON c.customer_id = i.customer_id
        JOIN invoice_items ii
            ON i.invoice_id = ii.invoice_id
        WHERE i.is_cancelled = 0
        GROUP BY c.customer_id
    ) AS revenue_per_customer
)
ORDER BY total_revenue DESC;

SELECT 
    ROUND(AVG(total_revenue), 2) AS avg_completed_revenue
FROM (
    SELECT
        c.customer_id,
        SUM(ii.revenue) AS total_revenue
    FROM customers c
    JOIN invoices i
        ON c.customer_id = i.customer_id
    JOIN invoice_items ii
        ON i.invoice_id = ii.invoice_id
    WHERE i.is_cancelled = 0
    GROUP BY c.customer_id
) AS customer_revenue;

-- Insight: The average completed revenue per customer is £2,916.75.
-- Customers exceeding this benchmark represent an above average value segment.
-- The highest revenue customers substantially exceed this threshold, showing
-- that customer revenue is unevenly distributed and highlighting the importance
-- of retaining and nurturing high value customers.

-- Business Question 7: How does the cancellation rate change month to month?

SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS invoice_month,
    COUNT(*) AS total_invoices,
    SUM(CASE WHEN is_cancelled = 1 THEN 1 ELSE 0 END) AS cancelled_invoices,
    ROUND(
        SUM(CASE WHEN is_cancelled = 1 THEN 1 ELSE 0 END) 
        / COUNT(*) * 100, 
        2
    ) AS cancellation_rate_pct
FROM invoices
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY DATE_FORMAT(invoice_date, '%Y-%m');

-- Insight: The cancellation rate fluctuates month to month rather than following
-- a consistent upward or downward trend. January 2010 had a cancellation rate
-- of 22.17%, while February 2010 had a rate of 16.79%. This indicates that
-- cancellation behaviour varies over time and that periods with unusually high
-- cancellation rates should be investigated further.