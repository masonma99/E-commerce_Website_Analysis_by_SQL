-- 1. find the first website_pageview_id for relevant sessions


SELECT 
	website_pageviews.website_session_id, 
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
	website_pageviews.website_session_id;


CREATE TEMPORARY TABLE first_pageviews_demo
SELECT 
	website_pageviews.website_session_id, 
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
	website_pageviews.website_session_id;

-- Bring in the landing pages to each session 
CREATE TEMPORARY TABLE session_w_landing_page_demo
SELECT 
	first_pageviews_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo 
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pageview_id;
        
SELECT * FROM session_w_landing_page_demo;

-- CREATE temporary Table bounced_sessions_only 
SELECT 
	session_w_landing_page_demo.website_session_id,
    session_w_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM session_w_landing_page_demo
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = session_w_landing_page_demo.website_session_id
GROUP BY
	session_w_landing_page_demo.website_session_id,
    session_w_landing_page_demo.landing_page;
    
-- HAVING and COUNT website_pageview_id = 1
CREATE Temporary table bounced_session_only
SELECT 
	session_w_landing_page_demo.website_session_id,
    session_w_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM session_w_landing_page_demo
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = session_w_landing_page_demo.website_session_id
GROUP BY
	session_w_landing_page_demo.website_session_id,
    session_w_landing_page_demo.landing_page
HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;
    
SELECT * FROM bounced_session_only;

SELECT 
	session_w_landing_page_demo.landing_page,
    session_w_landing_page_demo.website_session_id,
    bounced_session_only.website_session_id AS bounced_website_session_id
FROM session_w_landing_page_demo
	LEFT JOIN bounced_session_only
		ON session_w_landing_page_demo.website_session_id = bounced_session_only.website_session_id
ORDER BY
	session_w_landing_page_demo.website_session_id