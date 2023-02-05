SELECT * FROM website_sessions;
SELECT * FROM website_pageviews;

-- creating minimum pageview id through JOIN and limiting searches by requirements. 
-- counting the quantity of pageview id  
CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT 
	website_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS min_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_pageviews
	INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_pageviews.created_at BETWEEN '2012-06-01' AND '2012-08-31'
WHERE utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id;


SELECT * FROM sessions_w_min_pv_id_and_view_count;

-- JOINing to the website_session table to query all the landing pages of each min_pageview_id and date 
CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at   
SELECT 
	sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.min_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews
		ON sessions_w_min_pv_id_and_view_count.min_pageview_id = website_pageviews.website_pageview_id;

-- creating the pivot table of home&lander session by week.
-- final report 
SELECT 
	MIN(DATE(session_created_at)),
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions,
	COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS bounce_rate
FROM sessions_w_counts_lander_and_created_at   	
GROUP BY 
	YEARWEEK(session_created_at)