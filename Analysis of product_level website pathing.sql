-- Creating A.Pre_products_2 and B.Post_products_2 based on requested time periods for later use
-- Difficulty ****
CREATE TEMPORARY TABLE products_pageviews
SELECT 
	website_session_id,
    website_pageview_id,
    created_at,
    CASE
		WHEN created_at < '2013-01-06' THEN 'A.Pre_products_2'
        WHEN created_at >= '2013-01-06' THEN 'B.Post_product_2'
        ELSE 'check logic'
        END AS time_period
FROM website_pageviews
WHERE created_at < '2013-04-06' 
	AND created_at > '2012-10-06'
    AND pageview_url = '/products';
    
 -- Find the next pageview id that happens after the product pageview
 CREATE TEMPORARY TABLE sessions_with_next_pageview_id
 SELECT 	
	products_pageviews.time_period,
    products_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id 
GROUP BY 1, 2;

-- Find the pageview url associated with applicable next pageview id
CREATE TEMPORARY TABLE session_with_next_pageview_url
SELECT 
	sessions_with_next_pageview_id.time_period,
    sessions_with_next_pageview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url 
FROM sessions_with_next_pageview_id
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = sessions_with_next_pageview_id.min_next_pageview_id
;
-- Summarize the data with analysis 
SELECT 
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) as w_next_page,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as pct_w_next_page,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-orfuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-orfuzzy' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_loverbear
    
FROM session_with_next_pageview_url
GROUP BY time_period