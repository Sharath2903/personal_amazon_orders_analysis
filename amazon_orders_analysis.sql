-- Tables creation

DROP TABLE IF EXISTS order_history;

CREATE TABLE order_history
(
order_id  VARCHAR(30),
order_date	TIMESTAMP,
item_price DECIMAL(10, 2),	
tax_per_unit DECIMAL(10, 2),	
order_total	DECIMAL(10, 2),
order_status VARCHAR(15),
payment_method VARCHAR(100),
shipping_date TIMESTAMP ,
shipping_address VARCHAR(200),	
billing_address VARCHAR(200)
);

DROP TABLE IF EXISTS return_orders;

CREATE TABLE return_orders
(
tracking_id	BIGINT,
return_date	Timestamp,
order_id VARCHAR(30)
);

SELECT * FROM order_history;
SELECT * FROM return_orders;

--1. Percentage of Tax paid on each order

SELECT 
      order_id,
	  item_price,
	  tax_per_unit,
	  order_total,
      CONCAT(ROUND((tax_per_unit/item_price)*100, 2), '%') as tax_paid_each_order
FROM 
      order_history
WHERE
      order_status = 'Closed';

--2. Average Tax Paid

SELECT 
       CONCAT(ROUND(SUM(tax_per_unit)/SUM(item_price)*100, 2), '%') AS avg_tax_prcnt
FROM
       order_history
WHERE 
       order_status = 'Closed';

--3. Total orders placed and amount spent accross all Shipping address

SELECT 
      COUNT(order_id) as total_orders_per_sa,
	  SUM(order_total) as total_amount_spent,
	  shipping_address
FROM 
      order_history
GROUP BY
      shipping_address;

--4. Total orders placed and amount spent by each individaul 
SELECT 
      COUNT(order_id) as total_orders,
	  SUM(order_total) as total_amount_spent,
      customer_name
FROM 
(SELECT 
      *,
      SUBSTRING(billing_address, 1, POSITION(' ' IN billing_address)-1) as customer_name
FROM
      order_history) as t1
GROUP BY
      customer_name
ORDER BY 2 DESC, 1 DESC;

--5. Total amount spent per quarter

SELECT 
      EXTRACT(QUARTER FROM order_date::timestamp) AS quarter,
      SUM(order_total) AS total_amount_spent
FROM 
      order_history
GROUP BY
     quarter
ORDER BY
     quarter;

--6. Total amount spent yearly

SELECT  
      EXTRACT(Year FROM order_date::Timestamp) as year,
	  SUM(order_total) AS total_amount_spent
FROM 
      order_history
GROUP BY
      year
ORDER BY 
      year;
	  
--7. Total amount spent yearly
SELECT  
      TO_CHAR(order_date::timestamp, 'Month') AS month,
	  SUM(order_total) AS total_amount_spent
FROM 
      order_history
GROUP BY
      month,
	  EXTRACT(MONTH FROM order_date::timestamp)
ORDER BY 
      EXTRACT(MONTH FROM order_date::timestamp);

--8. Average time taken between order_date and shipping date

SELECT 
    FLOOR(EXTRACT(epoch FROM AVG(shipping_date - order_date)) / 3600) || ' hr ' ||
    FLOOR((EXTRACT(epoch FROM AVG(shipping_date - order_date)) % 3600) / 60) || ' mins ' ||
    FLOOR(EXTRACT(epoch FROM AVG(shipping_date - order_date)) % 60) || ' sec' AS avg_shipping_time
FROM 
    order_history;
------------OR----------------
SELECT 
     (AVG(AGE(shipping_date, order_date))) as avg_shipping_time
FROM
    order_history;

--9. Total number of COD orders compared to other mode of payments

SELECT
(SELECT COUNT(*) AS cod_orders FROM order_history WHERE payment_method = 'COD'),
(SELECT COUNT(*) AS other_orders FROM order_history WHERE payment_method != 'COD');

--10. Ratio between Closed and cancelled orders

SELECT 
      SUM(CASE WHEN order_status = 'Closed' THEN 1 else 0 END) as closed_orders,
	  SUM(CASE WHEN order_status = 'Cancelled' THEN 1 else 0 END) as cancelled_orders,
      SUM(CASE WHEN order_status = 'Closed' THEN 1 else 0 END)/
	  SUM(CASE WHEN order_status = 'Cancelled' THEN 1 else 0 END) AS closed_cancelled_ratio
FROM 
      order_history;

--11. Percentage of return orders

SELECT 
      CONCAT(ROUND(COUNT(r.order_id) *100.0/COUNT(o.order_id), 2), '%') as return_order_percentage
FROM  
     order_history o
LEFT JOIN
     return_orders r
	 ON o.order_id = r.order_id
WHERE 
     o.order_status = 'Closed';
     


	  