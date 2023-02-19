
SELECT 
		CASE 
        WHEN website_sessions.created_at < '2013-12-12' THEN 'A.Pre_cross_sell'
        WHEN website_sessions.created_at >= '2013-12-12' THEN 'B.Post_post_sell'
        ELSE 'check logic'
        END AS time_period,
        COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
        COUNT(DISTINCT orders.order_id) AS orders,
        COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt,
        SUM(orders.price_usd) AS total_revenue,
        SUM(orders.items_purchased) AS total_items_purcahsed,
        SUM(orders.order_id) AS total_products_sold,
        SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS aov,
        SUM(orders.items_purchased)/COUNT(DISTINCT orders.order_id) AS product_per_order,
		SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY time_period 


    CASE
