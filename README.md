# Amazon orders analysis using SQL 

![Amazon logo](https://github.com/Sharath2903/personal_amazon_orders_analysis/blob/main/amazon_logo.jpg)

## Overview
This project involves a comprehensive analysis of my Friend's Amazon online orders, aiming to extract valuable insights and answer key questions based on my order history. The following README provides a detailed overview of the project's objectives, challenges, solutions, findings, and conclusions.

## Objectives

- Analyze Spending Trends: Examine spending over different periods of the year to identify seasonal patterns, peak spending
  times, and budget opportunities.
- User-Specific Order Patterns: Identify the most frequent orderer on the account and analyze each person’s contribution to 
  overall order volume.
- Tax Analysis: Calculate the total tax paid on each order to assess the impact of taxes on overall spending.
- Comparison of COD Orders vs Other Payment Methods

## Schema

```sql
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

```

## Business Problems and Solutions

### 1. Calculate the Percentage of Tax Paid on Each Order

```sql
SELECT 
    order_id,
    item_price,
    tax_per_unit,
    order_total,
    CONCAT(ROUND((tax_per_unit / item_price) * 100, 2), '%') AS tax_percentage
FROM 
    order_history
WHERE
    order_status = 'Closed';
```

**Objective:** Determine the percentage of tax paid per item on each order for completed (closed) transactions.

### 2. Compute Average Tax Percentage for All Orders


```sql
SELECT 
    CONCAT(ROUND((SUM(tax_per_unit) / SUM(item_price)) * 100, 2), '%')
    AS avg_tax_percentage
FROM 
    order_history
WHERE 
    order_status = 'Closed';

```

**Objective:** Calculate the average percentage of tax paid on all closed orders.

### 3. Total Orders and Spending by Shipping Address
```sql
SELECT 
    shipping_address,
    COUNT(order_id) AS total_orders,
    SUM(order_total) AS total_amount_spent
FROM 
    order_history
GROUP BY 
    shipping_address
```

**Objective:**  Summarize the total number of orders and the total amount spent across different shipping addresses.

### 4. Total Orders and Spending by Each Customer

```sql
SELECT 
    customer_name,
    COUNT(order_id) AS total_orders,
    SUM(order_total) AS total_amount_spent
FROM 
    (SELECT 
         order_id,
         order_total,
         SUBSTRING(billing_address, 1, POSITION(' ' IN billing_address) - 1) AS customer_name
     FROM 
         order_history) AS customer_orders
GROUP BY 
    customer_name
ORDER BY 
    total_amount_spent DESC, total_orders DESC;
```

**Objective:**  Identify the total number of orders and the total spending amount for each individual.


### .5 Calculate the total amount spent for each month, ordered chronologically.

```sql
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
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 6. Yearly Spending Summary

```sql
SELECT  
    EXTRACT(YEAR FROM order_date::timestamp) AS year,
    SUM(order_total) AS total_amount_spent
FROM 
    order_history
GROUP BY 
    year
ORDER BY 
    year;
```

**Objective:** Calculate the total amount spent each year.

### 7. Quarterly Spending Summary.

```sql
SELECT 
    EXTRACT(QUARTER FROM order_date::timestamp) AS quarter,
    SUM(order_total) AS total_amount_spent
FROM 
    order_history
GROUP BY 
    quarter
ORDER BY 
    quarter;
```

**Objective:** Calculate the total amount spent in each quarter.

### 8. Average Shipping Time for Orders

```sql
SELECT 
    CONCAT
	(
    FLOOR(EXTRACT(EPOCH FROM AVG(shipping_date - order_date)) / 3600), 
	'hr ',
    FLOOR((EXTRACT(EPOCH FROM AVG(shipping_date - order_date)) % 3600) / 60),
	'mins ',
    FLOOR(EXTRACT(EPOCH FROM AVG(shipping_date - order_date)) % 60),
	'sec' 
	) AS avg_shipping_time
FROM 
    order_history;
```

**Objective:** Calculate the average time taken from order placement to shipping.

### 9.Comparison of COD Orders vs Other Payment Methods

```sql
SELECT 
    COUNT(CASE WHEN payment_method = 'COD' THEN 1 END) AS cod_orders,
    COUNT(CASE WHEN payment_method != 'COD' THEN 1 END) AS other_orders
FROM 
    order_history;

```

**Objective:** Comparison of COD Orders vs Other Payment Methods.


### 10. Percentage of Return Orders

```sql
SELECT 
    CONCAT(ROUND(COUNT(r.order_id) * 100.0 / NULLIF(COUNT(o.order_id), 0), 2), '%') AS return_order_percentage
FROM  
    order_history o
LEFT JOIN
    return_orders r ON o.order_id = r.order_id
WHERE 
    o.order_status = 'Closed';
```
### 11. Ratio of Closed to Cancelled Orders

```sql
SELECT 
    SUM(CASE WHEN order_status = 'Closed' THEN 1 ELSE 0 END) AS closed_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN order_status = 'Closed' THEN 1 ELSE 0 END) * 1.0 / 
          NULLIF(SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END), 0), 2) AS closed_to_cancelled_ratio
FROM 
    order_history;
```
**Objective:** Calculate the ratio between closed and cancelled orders to understand order completion trends.


## Findings

1. **Average Tax Paid:**
- The average tax percentage across closed orders is approximately 13.35%.
  
2. **Spending and Orders by Shipping Address:**
- Sam preetish's address had the highest spending, totaling around ₹112,297 from 63 orders.
-  Bhanu placed 164 orders with a total spend of ₹108,076 across different addresses.
  
3. **Spending and Orders by Customer:**
- Sam spent the most, with ₹378,504 across 149 orders.
- Bhanu placed 216 orders, spending a total of ₹132,520.

4. **Quarterly Spending Trends:**
- The second quarter (April - June) had the highest spending, reaching ₹265,833.
- The lowest spending occurred in the fourth quarter (October - December) with ₹59,418.

5. **Yearly Spending Trends:**
- Spending has increased significantly over the years, with the highest recorded in 2024 at ₹133,972.

6. **Monthly Spending Trends:**

- The highest spend was in April (₹123,721) and May (₹130,073), suggesting potential seasonal trends.
- Spending dropped during winter months, particularly in November (₹7,372).

7. **Average Shipping Time:**
- The average time between order and shipping was approximately 24 hours.

8. **COD Orders vs. Other Payments:**
- COD is the preferred payment method, with 271 COD orders versus 113 other payment types.
  
9. **Order Status (Closed vs. Cancelled):**
- The ratio of closed to canceled orders is 5:1, indicating a high completion rate for orders.

10. **Return Orders:**
- About 5.68% of all orders were returned.


The analysis reveals key spending patterns, customer preferences, and order behaviors. Sam and Bhanu emerge as the primary customers, contributing the most orders and spending. Seasonal trends are noticeable, with peak spending during spring and summer, and reduced spending in winter. COD remains a highly favored payment method, while a low return rate reflects customer satisfaction and accurate order processing.


This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

