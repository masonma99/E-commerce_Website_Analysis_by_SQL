SELECT *
FROM order_item_refunds;

SELECT 
YEAR(order_items.created_at) AS yr,
MONTH(order_items.created_at) AS mo,
COUNT(CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p_1,
COUNT(CASE WHEN product_id = 1 THEN order_item_refunds.order_item_id ELSE NULL END)/COUNT(CASE WHEN product_id = 1 THEN 1 ELSE NULL END) AS p1_refund_rt,
COUNT(CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p_2,
COUNT(CASE WHEN product_id = 2 THEN order_item_refunds.order_item_id ELSE NULL END)/COUNT(CASE WHEN product_id = 2 THEN 1 ELSE NULL END) AS p1_refund_rt,
COUNT(CASE WHEN product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p_3,
COUNT(CASE WHEN product_id = 3 THEN order_item_refunds.order_item_id ELSE NULL END)/COUNT(CASE WHEN product_id = 3 THEN 1 ELSE NULL END) AS p1_refund_rt,
COUNT(CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p_4,
COUNT(CASE WHEN product_id = 4 THEN order_item_refunds.order_item_id ELSE NULL END)/COUNT(CASE WHEN product_id = 4 THEN 1 ELSE NULL END) AS p1_refund_rt

FROM order_items
	LEFT JOIN order_item_refunds 
    ON order_item_refunds.order_item_id = order_items.order_item_id
WHERE order_items.created_at < '2014-10-30'
GROUP BY 1, 2
