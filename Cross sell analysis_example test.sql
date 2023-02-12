-- Left join with order_items and Set conditions for is_primary_item to find those products that are cross-sold
-- use select all to analyse table and find out how to count and pivot
-- Use count distinct order_id and group by primary_product_id to find the total oders.
-- Use case and when to make pivot table and show cross_sell product 1, 2 and 3. 

SELECT 
	orders.primary_product_id,
    COUNT(DISTINCT orders.order_id) AS orders, 
    COUNT(CASE WHEN order_items.product_id = 1 THEN orders.order_id ELSE NULL END) AS x_sell_prod1,
    COUNT(CASE WHEN order_items.product_id = 2 THEN orders.order_id ELSE NULL END) AS x_sell_prod2, 
    COUNT(CASE WHEN order_items.product_id = 3 THEN orders.order_id ELSE NULL END) AS x_sell_prod3,
    
	COUNT(CASE WHEN order_items.product_id = 1 THEN orders.order_id ELSE NULL END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod1_rt,
    COUNT(CASE WHEN order_items.product_id = 2 THEN orders.order_id ELSE NULL END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod2_rt, 
    COUNT(CASE WHEN order_items.product_id = 3 THEN orders.order_id ELSE NULL END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod3_rt
FROM orders 
	LEFT JOIN order_items
    ON order_items.order_id = orders.order_id
    AND order_items.is_primary_item = 0
WHERE orders.order_id BETWEEN 10000 AND 11000
GROUP BY 1