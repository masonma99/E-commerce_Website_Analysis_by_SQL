SELECT * FROM website_sessions;
SELECT * FROM website_pageviews;
SELECT * FROM orders;


-- 1. Pull monthly trend for gsearch sessions and orders to showcase growth
SELECT 
website_sessions.utm_source,
MONTH(website_sessions.created_at) AS month_order,
COUNT(website_sessions.website_session_id) AS gsearch_ct,
COUNT(orders.order_id) AS order_ct
FROM website_sessions
	LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-03-27' AND '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY MONTH(website_sessions.created_at);

-- 2.Splitting our nonbrand and brand
SELECT 
MONTH(website_sessions.created_at) AS month_order,
COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_session,
COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_order,
COUNT(CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_session,
COUNT(CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_order

FROM website_sessions
	LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-03-27' AND '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY MONTH(website_sessions.created_at)
;    

-- 3. On gsearch and nonbrand, pulling out monthly sessions and orders by device type
SELECT 

MONTH(website_sessions.created_at) AS mo,
COUNT(CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS dt_session,
COUNT(CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS dt_order,
COUNT(CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END)/COUNT(CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS conv_rt_dt,
COUNT(CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_session,
COUNT(CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_order,
COUNT(CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END)/COUNT(CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS conv_rt_mobile
FROM website_sessions
	LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-03-27' AND '2012-11-27'
	AND website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY MONTH(website_sessions.created_at);

-- 4. Monthly trend for gsearch alongside each of other channels

-- check to see how many types of channel there are. (using distinct, excellent). 
-- gsearch+brand/nonbrand called gsearch paid sessions, bsearch+brand/nonbrand called bsearch paid session,
-- when all null it is called direct-typedin search, and when http_referer is has link it is called organic search.  
SELECT DISTINCT 
utm_source,
utm_campaign,
http_referer 
FROM website_sessions 
WHERE website_sessions.created_at < '2012-11-27';

-- create pivot table with CASE AND WHEN
SELECT 
	MONTH(website_sessions.created_at) AS mo,
	COUNT(CASE WHEN website_sessions.utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
	COUNT(CASE WHEN website_sessions.utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
	COUNT(CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT(CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_typedin_sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1;

-- website performance improvements and pull the sessions to order conversion rate

SELECT 
	MONTH(website_sessions.created_at) AS mo,
	COUNT(website_sessions.website_session_id) AS sessions,
	COUNT(orders.order_id) AS orders,
	COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) AS conv_rt
FROM 
	website_sessions
	LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1;

-- estimate revenue gsearch lander test earned. (use nonbrand sessions and revenue since then)

SELECT distinct pageview_url FROM website_pageviews;

SELECT 
SUM(price_usd) AS revenue

FROM (
SELECT 
	website_sessions.website_session_id,
	website_sessions.utm_source,
	website_sessions.utm_campaign,
	orders.price_usd
FROM website_sessions
	JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE 
	website_sessions.created_at < '2012-07-28' AND website_sessions.utm_campaign = 'nonbrand'
) AS base_table

LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = base_table.website_session_id
WHERE website_pageviews.pageview_url = '/lander-1'
;

-- codes from solution video
-- first find out the first test pageview id when lander-1 shows up 
SELECT 
	MIN(website_pageviews.website_pageview_id) AS first_test_pageview
FROM website_pageviews
WHERE website_pageviews.pageview_url = '/lander-1' ;

-- first test pageview id is 23504, which will be used in limitations below
-- INNER JOIN with website_sessions to find out minimum pageview id

CREATE TEMPORARY TABLE first_test_pageview
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview
FROM website_pageviews
	INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at < '2012-07-28'
    AND website_pageviews.website_pageview_id >= 23504
    AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.utm_source = 'gsearch'
GROUP BY website_pageviews.website_session_id;

-- bring landing page to each session
CREATE TEMPORARY TABLE nonbrand_test_sessions
SELECT 
	first_test_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageview
    LEFT JOIN website_pageviews 
    ON website_pageviews.website_pageview_id = first_test_pageview.min_pageview
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1') ;

-- make a table to bring in orders

SELECT
	nonbrand_test_sessions.landing_page,
	COUNT(DISTINCT nonbrand_test_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders
    
FROM nonbrand_test_sessions
LEFT JOIN orders
	ON orders.website_session_id = nonbrand_test_sessions.website_session_id
GROUP BY nonbrand_test_sessions.landing_page;


-- create temporary table with each each segament flagged when users made to it
CREATE TEMPORARY TABLE session_level_flagged
SELECT 
website_session_id,
MAX(home_page) AS saw_homepage,
MAX(custom_lander) AS saw_customer_lander,
MAX(product_page) AS made_to_product,
MAX(fuzzy_page) AS made_to_fuzzy,
MAX(cart_page) AS made_to_cart,
MAX(shipping_page) AS made_to_shpping,
MAX(billing_page) AS made_to_billing,
MAX(thank_you_page) AS made_to_thankyou

FROM(

SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at pageview_created_at,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
	CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page, 
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at < '2012-07-28'
    AND website_sessions.created_at > '2012-06-19'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS page_level

GROUP by 
website_session_id;


SELECT 
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_customer_lander = 1 THEN 'saw_custom_lander'
        ELSE 'no'
	END AS segment,
	COUNT(DISTINCT website_session_id) AS lander_click_rt,
	COUNT(DISTINCT CASE WHEN made_to_product = 1 THEN website_session_id ELSE 0 END) AS to_product_page, 
	COUNT(DISTINCT CASE WHEN made_to_fuzzy = 1 THEN website_session_id ELSE 0 END) AS to_fuzzy_page,
    COUNT(DISTINCT CASE WHEN made_to_cart = 1 THEN website_session_id ELSE 0 END) AS to_cart_page,
    COUNT(DISTINCT CASE WHEN made_to_shpping = 1 THEN website_session_id ELSE 0 END) AS to_shipping_page,
    COUNT(DISTINCT CASE WHEN made_to_billing = 1 THEN website_session_id ELSE 0 END) AS to_billing_page,
    COUNT(DISTINCT CASE WHEN made_to_thankyou = 1 THEN website_session_id ELSE 0 END) AS to_thank_you_page
FROM session_level_flagged
GROUP BY 1