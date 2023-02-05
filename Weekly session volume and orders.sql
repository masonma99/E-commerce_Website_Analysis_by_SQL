SELECT *
FROM orders;
SELECT * 
FROM website_sessions;

SELECT 
YEAR(website_sessions.created_at) as yr,
-- MONTH(website_sessions.created_at) as mo,
WEEK(website_sessions.created_at) as wk,
MIN(DATE(website_sessions.created_at)) as wk_start,
COUNT(website_sessions.website_session_id) as sessions, -- count all website_session_id happened in that period rather than the ones belong to orders
COUNT(orders.order_id) as orders

FROM website_sessions
	LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at <= '2012-12-31'
GROUP by 1, 2