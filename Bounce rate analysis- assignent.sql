SELECT * FROM website_pageviews;

-- Temp table with minimum page view id / id with all the landing pages 
CREATE TEMPORARY TABLE first_pv_demo
SELECT 
	website_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_pageviews.created_at < '2012-06-12'
GROUP BY 
	website_pageviews.website_session_id;

-- Temp table with all the landing pages
CREATE TEMPORARY TABLE sessions_landing_pg    
SELECT 
	first_pv_demo.website_session_id,
    website_pageviews.pageview_url AS landing_pg
FROM first_pv_demo
	LEFT JOIN website_pageviews
    ON first_pv_demo.min_pageview_id = website_pageviews.website_pageview_id;

-- first find and count how many times users viewed on the landing page, then narrow them down to those with 1 time viewed landing page
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	sessions_landing_pg.website_session_id,
    sessions_landing_pg.landing_pg,
    COUNT(website_pageviews.website_pageview_id) AS ct_of_viewed_pages
FROM sessions_landing_pg
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_landing_pg.website_session_id

GROUP BY 
	sessions_landing_pg.website_session_id,
	sessions_landing_pg.landing_pg
HAVING
	COUNT(website_pageviews.website_pageview_id) =1;	-- count bounce on landing page
    
SELECT 
	sessions_landing_pg.landing_pg,
    sessions_landing_pg.website_session_id,
    bounced_sessions.website_session_id
FROM sessions_landing_pg
	LEFT JOIN bounced_sessions
		ON sessions_landing_pg.website_session_id = bounced_sessions.website_session_id
ORDER BY sessions_landing_pg.website_session_id;

-- final report 

SELECT 
	sessions_landing_pg.landing_pg,
    COUNT(DISTINCT sessions_landing_pg.website_session_id) AS sessions ,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_website_session_id
FROM sessions_landing_pg
	LEFT JOIN bounced_sessions
		ON sessions_landing_pg.website_session_id = bounced_sessions.website_session_id
ORDER BY sessions_landing_pg.website_session_id;