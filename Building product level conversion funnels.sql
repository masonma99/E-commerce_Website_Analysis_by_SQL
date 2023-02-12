SELECT * FROM website_pageviews WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10';

-- Narrow down the pageview_url to 'fuzzy' and 'lovebear', time to required timeframe. Build a temporary table for later use.
CREATE TEMPORARY TABLE sessions_seeing_product_pages_revised
SELECT 
	website_session_id,
    website_pageview_id,
    pageview_url as product_page_seen
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10' AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
;


CREATE TEMPORARY TABLE sessions_product_level_made_it_flag

SELECT 
	website_session_id,
    CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'checklogic'
        END AS product_seen,
	-- use MAX to see how far each session go
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
    
FROM(
    
-- Left join website_pageview and use condition (last one) to pick out the pageview url happened after 'fuzzy' and 'lovebear'
-- Flag these four sessions with 1 and 0 
SELECT
	sessions_seeing_product_pages_revised.website_session_id,
    sessions_seeing_product_pages_revised.product_page_seen,
    CASE WHEN pageview_url= '/cart' THEN 1 ELSE 0 END as cart_page,
    CASE WHEN pageview_url= '/shipping' THEN 1 ELSE 0 END as shipping_page,
    CASE WHEN pageview_url= '/billing-2' THEN 1 ELSE 0 END as billing_page,
    CASE WHEN pageview_url= '/thank-you-for-your-order' THEN 1 ELSE 0 END as thankyou_page
FROM sessions_seeing_product_pages_revised
	LEFT JOIN website_pageviews
    ON website_pageviews.website_session_id= sessions_seeing_product_pages_revised.website_session_id
    AND website_pageviews.website_pageview_id > sessions_seeing_product_pages_revised.website_pageview_id
ORDER BY 
	sessions_seeing_product_pages_revised.website_session_id,
    website_pageviews.created_at
) as pageview_level

GROUP BY -- Group by first 2 in the select 
	website_session_id,
    CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'checklogic'
        END
;

-- count each session
SELECT 
	product_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_shipping,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_thankyou
FROM sessions_product_level_made_it_flag
GROUP BY product_seen 