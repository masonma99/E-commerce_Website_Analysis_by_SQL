SELECT 
	COUNT(website_sessions.website_session_id) AS sessions,
	COUNT(orders.order_id) AS orders,
	COUNT(order_id) / COUNT(website_sessions.website_session_id) AS session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders
    	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY utm_source, utm_campaign 
	
  
