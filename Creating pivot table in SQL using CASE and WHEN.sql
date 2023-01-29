-- 1. Use CASE WHEN to find out orders with 1 items purchaed and 2 items purchased individually
-- 2. Use COUNT DISTINCT and GROUP BY (order_id) to see every record of 1 and 2 items purchaed from each order. for every 1 item purchased ct_single_item_order will count 1
-- 3. Remove 'item_purchased' and 'order_id' and GROUP by 'primary_product_id'
SELECT 
	primary_product_id,
	
	COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS ct_single_item_orders, 
    COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS ct_double_item_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1