-- Make query of total revenue and margins based on year and month
SELECT 
	YEAR(created_at) as yr,
    MONTH(created_at) as mo,
    COUNT(order_id) as number_of_sales,
    SUM(price_usd) as total_revenue,
    SUM(price_usd- cogs_usd) as total_margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 1, 2;

-- Analyzing monthly order volume and overall conversin rates, revenue per session and breakdown of sales by products.
SELECT 
	YEAR(website_sessions.created_at) as yr,
    MONTH(website_sessions.created_at) as mo,
    COUNT(DISTINCT website_sessions.website_session_id) as sessions,
    COUNT(DISTINCT orders.order_id) as orders,
    -- calculate conversion rate, website sessions to orders
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) as conv_rate,
    -- calculate revenue per website sessions
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) as revenue_per_session,
    COUNT(CASE WHEN primary_product_id= 1 THEN order_id ELSE NULL END) as product_one_orders,
    COUNT(CASE WHEN primary_product_id= 2 THEN order_id ELSE NULL END) as prodict_two_orders
  
FROM website_sessions
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-01'
GROUP BY 1, 2;