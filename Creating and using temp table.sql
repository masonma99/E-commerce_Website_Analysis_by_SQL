CREATE TEMPORARY TABLE first_pg_view
SELECT 
	website_pageview_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;


SELECT 
	first_pg_view.website_pageview_id,
    COUNT(DISTINCT first_pg_view.website_pageview_id) AS sessions,
    website_pageviews.pageview_url AS landing_page
FROM first_pg_view
	LEFT JOIN website_pageviews
		ON first_pg_view.min_pv_id = website_pageviews.website_pageview_id
GROUP BY 
	website_pageviews.pageview_url