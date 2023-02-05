SELECT * FROM website_sessions;

CREATE TEMPORARY TABLE session_level_02
SELECT 
	website_session_id,
    pageview_url,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM (
SELECT 
	website_sessions.website_session_id,
	website_pageviews.pageview_url
FROM website_pageviews
	LEFT JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand'
		AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
	) AS base_page
    ;

SELECT 
	COUNT(DISTINCT session_level_02.website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN session_level_02.products_page = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN session_level_02.mrfuzzy_page = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN session_level_02.cart_page = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN session_level_02.shipping_page = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN session_level_02.billing_page = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN session_level_02.thankyou_page = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
 FROM session_level_02
    