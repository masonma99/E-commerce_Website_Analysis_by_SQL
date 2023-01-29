SELECT 
device_type,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions, 
COUNT(DISTINCT order_id) AS orders, 
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
FROM website_sessions

LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 1