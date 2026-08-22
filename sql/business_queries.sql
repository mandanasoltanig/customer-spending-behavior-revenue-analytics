-- Business Question: Who are our top 10 customers by total revenue?
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

-- Business Question: Which countries generate the most revenue?
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

-- Business Question: Which product categories generate the most revenue?
SELECT 
    p.category,
    SUM(ii.revenue) AS total_revenue,
    COUNT(*) AS total_items_sold
FROM invoice_items ii
JOIN invoices i ON ii.invoice_id = i.invoice_id
JOIN products p ON ii.stock_code = p.stock_code
WHERE i.is_cancelled = 0
GROUP BY p.category
ORDER BY total_revenue DESC;


-- Business Question: Which high-spending customers also show notable cancellation activity?
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