SELECT
MIN(DATE(created_at)) AS wk_start_date, -- week start date
COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN user_id ELSE NULL END) AS dtop_session,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN user_id ELSE NULL END) AS mob_session -- COUNT 'CASE and WHEN' to create pivot table

FROM website_sessions
WHERE 
	created_at between '2012-04-15' and '2012-06-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at)