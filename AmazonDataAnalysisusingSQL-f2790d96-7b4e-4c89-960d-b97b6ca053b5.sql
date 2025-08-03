
-- AMAZON DATA ANALYSIS


CREATE TABLE Customers(
customer_id VARCHAR(100) PRIMARY KEY,
customer_unique_id varchar(100),
customer_zip_code_prefix INT
) ;



create table orders (
    order_id varchar(100) primary key,
    customer_id varchar(100),
    order_status varchar(50),
    order_purchase_timestamp timestamp,
    order_approved_at timestamp,
    order_delivered_carrier_date timestamp,
    order_delivered_customer_date timestamp,
    order_estimated_delivery_date timestamp,
    foreign key (customer_id) references customers(customer_id)
);

create table payments(
order_id varchar(100),
payment_sequential int,
payment_type varchar(100),
payment_installments INT,
payment_value DECIMAL(10,2)

);

ALTER TABLE PAYMENTS
ADD CONSTRAINT fk_orderid FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID)
;


create table seller(
seller_id varchar(100) primary key,
seller_zip_code_prefix int );

create table order_items(
order_id varchar(100),
order_item_id int,
product_id varchar(100),
seller_id varchar(100),
shipping_limit_date timestamp,
price decimal(10,2),
freight_value decimal(10,2),
foreign key (order_id) references orders(order_id),
foreign key (seller_id) references seller(seller_id)
);


create table product(
product_id varchar(100) primary key,
product_category_name varchar(100),
product_name_lenght	int,
product_description_lenght	int,
product_photos_qty int,
product_weight_g int,
product_length_cm int,
product_height_cm int,
product_width_cm int
);


alter table order_items 
add constraint fk_product_id foreign key (product_id) references product(product_id)
;

-- DATA CLEANING

SELECT * FROM payments 
WHERE payment_type = 'not_defined' ;

DELETE FROM payments
WHERE payment_type = 'not_defined' AND payment_value = 0.00;


-- Analysis - I
/*
1. To simplify its financial reports, Amazon India needs to standardize payment values. 
Round the average payment values to integer (no decimal) for each payment type and display the results sorted in ascending order.
Output: payment_type, rounded_avg_payment
*/

SELECT 
    payment_type,
    ROUND(AVG(payment_value)) AS rounded_avg_payment
FROM 
    payments
GROUP BY 
    payment_type
ORDER BY 
    rounded_avg_payment;



/*
2.To refine its payment strategy, Amazon India wants to know the distribution of orders by payment type. 
Calculate the percentage of total orders for each payment type, rounded to one decimal place, and display them in descending order
Output: payment_type, percentage_orders
*/

SELECT 
    payment_type,
    ROUND(COUNT(order_id) * 100.0 / total_orders, 1) AS percentage_orders
FROM 
    payments,
    (SELECT COUNT(order_id) AS total_orders FROM payments) AS t
GROUP BY 
    payment_type, t.total_orders
ORDER BY 
    percentage_orders DESC;


/* 3.Amazon India seeks to create targeted promotions for products within specific price ranges.
Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in their name. 
Display these products, sorted by price in descending order.

Output: product_id, price */

SELECT 
    DISTINCT p.product_id,
    oi.price
FROM 
    product p
JOIN 
    order_items oi ON p.product_id = oi.product_id
WHERE 
    oi.price BETWEEN 100 AND 500
    AND p. product_category_name ILIKE '%smart%'
ORDER BY 
    oi.price DESC;


/* 4.To identify seasonal sales patterns, Amazon India needs to focus on the most successful months. 
Determine the top 3 months with the highest total sales value, rounded to the nearest integer.

Output: month, total_sales*/


SELECT 
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS order_month,
    SUM(payment_value) AS total_sales
FROM 
    orders o
JOIN 
    payments p ON o.order_id = p.order_id
GROUP BY 
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM')
ORDER BY 
    total_sales DESC
LIMIT 3;




/*
5.Amazon India is interested in product categories with significant price variations. 
Find categories where the difference between the maximum and minimum product prices is greater than 500 BRL.

Output: product_category_name, price_difference 
*/


SELECT 
    product_category_name,
    MAX(price) - MIN(price) AS price_difference
FROM 
    order_items oi
JOIN 
    product p ON p.product_id = oi.product_id
GROUP BY 
    product_category_name
HAVING 
    MAX(price) - MIN(price) > 500
	ORDER BY price_difference DESC;



/*
6.To enhance the customer experience, Amazon India wants to find which payment types have the most consistent transaction amounts. 
Identify the payment types with the least variance in transaction amounts, sorting by the smallest standard deviation first.

Output: payment_type, std_deviation 
*/

SELECT 
    payment_type, 
    STDDEV(payment_value) AS std_deviation
FROM 
    payments
GROUP BY 
    payment_type
ORDER BY 
    std_deviation ASC;



/*7.Amazon India wants to identify products that may have incomplete name in order to fix it from their end.
Retrieve the list of products where the product category name is missing or contains only a single character.

Output: product_id, product_category_name */


SELECT 
    product_id, 
    product_category_name
FROM 
    product
WHERE 
    product_category_name IS NULL 
    OR CHAR_LENGTH(product_category_name) = 1;



	

-- Analysis - II


/*
1. Amazon India wants to understand which payment types are most popular across different order value segments (e.g., low, medium, high). 
Segment order values into three ranges: orders less than 200 BRL, between 200 and 1000 BRL, and over 1000 BRL. 
Calculate the count of each payment type within these ranges and display the results in descending order of count
*/

SELECT 
    CASE 
        WHEN payment_value < 200 THEN 'Low'
        WHEN payment_value BETWEEN 200 AND 1000 THEN 'Medium'
        WHEN payment_value > 1000 THEN 'High'
    END AS order_value_segment,
    payment_type, 
    COUNT(*) AS count
FROM 
    payments
GROUP BY 
    payment_type, 
    order_value_segment
ORDER BY 
    count DESC;

/*2.Amazon India wants to analyse the price range and average price for each product category. 
Calculate the minimum, maximum, and average price for each category, and list them in descending order by the average price.

Output: product_category_name, min_price, max_price, avg_price

*/
SELECT 
    product_category_name, 
    MIN(price) AS min_price, 
    MAX(price) AS max_price, 
    ROUND(AVG(price), 2) AS avg_price
FROM 
    product
JOIN 
    order_items ON product.product_id = order_items.product_id
GROUP BY 
    product_category_name
ORDER BY 
    avg_price DESC;



/*3.Amazon India wants to identify the customers who have placed multiple orders over time. 
Find all customers with more than one order, and display their customer unique IDs along with 
the total number of orders they have placed.

Output: customer_unique_id, total_orders

*/

Select customer_id, count(*) as total_orders
from orders
group by customer_id
having count(*) > 1
order by total_orders desc;


/*
Amazon India wants to categorize customers into different types ('New – order qty. = 1' ; 
'Returning' –order qty. 2 to 4;  'Loyal' – order qty. >4) based on their purchase history. 
Use a temporary table to define these categories and join it with the customers table to update and display the customer types.

Output: customer_id, customer_type
*/


CREATE TEMPORARY TABLE customer_types AS
SELECT 
  o.customer_id,
  CASE 
    WHEN COUNT(o.order_id) = 1 THEN 'New'
    WHEN COUNT(o.order_id) BETWEEN 2 AND 4 THEN 'Returning'
    WHEN COUNT(o.order_id) > 4 THEN 'Loyal'
  END AS customer_type
FROM orders o
GROUP BY o.customer_id;



SELECT 
  customer_id,
  customer_type
FROM customer_types ;

SELECT CUSTOMER_TYPE,COUNT(*) AS COUNT
FROM CUSTOMER_TYPES
GROUP BY CUSTOMER_TYPE ;

/*
5.Amazon India wants to know which product categories generate the most revenue. 
Use joins between the tables to calculate the total revenue for each product category.
Display the top 5 categories.

Output: product_category_name, total_revenue
*/

SELECT 
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;



Analysis - III
/*1.The marketing team wants to compare the total sales between different seasons. Use a subquery to calculate total sales for each season (Spring, Summer, Autumn, Winter) based on order purchase dates, and display the results. Spring is in the months of March, April and May. Summer is from June to August and Autumn is between September and November and rest months are Winter. 

Output: season, total_sales
*/

SELECT 
  CASE 
    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (3, 4, 5) THEN 'Spring'
    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (6, 7, 8) THEN 'Summer'
    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (9, 10, 11) THEN 'Autumn'
    ELSE 'Winter'
  END AS season,
  SUM(oi.price) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY season;


/*2.The inventory team is interested in identifying products that have sales volumes above the overall average. 
Write a query that uses a subquery to filter products with a total quantity sold above the average quantity.

Output: product_id, total_quantity_sold
*/
SELECT 
  product_id, 
  COUNT(*) AS total_quantity_sold
FROM order_items
GROUP BY product_id
HAVING COUNT(*) > (
  SELECT AVG(product_sales) 
  FROM (
    SELECT COUNT(*) AS product_sales
    FROM order_items
    GROUP BY product_id
  ) AS avg_subquery
)ORDER BY TOTAL_QUANTITY_SOLD DESC;

/*3.To understand seasonal sales patterns, the finance team is analysing the monthly revenue trends over the past year (year 2018). 
Run a query to calculate total revenue generated each month and identify periods of peak and low sales. 
Export the data to Excel and create a graph to visually represent revenue changes across the months. 

Output: month, total_revenue
*/

SELECT 
  TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS month,
  SUM(oi.price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
ORDER BY month;

/*4.A loyalty program is being designed  for Amazon India. 
Create a segmentation based on purchase frequency: ‘Occasional’ for customers with 1-2 orders, ‘Regular’ for 3-5 orders,
and ‘Loyal’ for more than 5 orders. 
Use a CTE to classify customers and their count and generate a chart in Excel to show the proportion of each segment.

Output: customer_type, count
*/
WITH order_counts AS (
  SELECT 
    customer_id,
    COUNT(order_id) AS order_count
  FROM orders
  GROUP BY customer_id
),
customer_segments AS (
  SELECT 
    customer_id,
    CASE 
      WHEN order_count BETWEEN 1 AND 2 THEN 'Occasional'
      WHEN order_count BETWEEN 3 AND 5 THEN 'Regular'
      ELSE 'Loyal'
    END AS customer_type
  FROM order_counts
)
SELECT 
  customer_type,
  COUNT(*) AS count
FROM customer_segments
GROUP BY customer_type;


/*5.Amazon wants to identify high-value customers to target for an exclusive rewards program. 
You are required to rank customers based on their average order value (avg_order_value) to find the top 20 customers.

Output: customer_id, avg_order_value, and customer_rank*/

WITH order_totals AS (
  SELECT 
    o.customer_id,
    o.order_id,
    SUM(oi.price) AS order_value
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.customer_id, o.order_id
),
customer_avg_order AS (
  SELECT 
    customer_id,
    AVG(order_value) AS avg_order_value
  FROM order_totals
  GROUP BY customer_id
)
SELECT 
  customer_id,
  avg_order_value,
  RANK() OVER (ORDER BY avg_order_value DESC) AS customer_rank
FROM customer_avg_order
LIMIT 20;


/*6.Amazon wants to analyze sales growth trends for its key products over their lifecycle. 
Calculate monthly cumulative sales for each product from the date of its first sale. 
Use a recursive CTE to compute the cumulative sales (total_sales) for each product month by month.

Output: product_id, sale_month, and total_sales
*/

WITH recursive product_sales AS (
  SELECT 
    oi.product_id,
    DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
    SUM(oi.price) AS monthly_sales
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  GROUP BY oi.product_id, DATE_TRUNC('month', o.order_purchase_timestamp)
),
recursive_sales AS (

  SELECT 
    ps.product_id,
    ps.sale_month,
    ps.monthly_sales,
    ps.monthly_sales AS total_sales
  FROM product_sales ps
  WHERE NOT EXISTS (
    SELECT 1 FROM product_sales ps2 
    WHERE ps2.product_id = ps.product_id 
      AND ps2.sale_month < ps.sale_month
  )

  UNION ALL

  SELECT 
    ps.product_id,
    ps.sale_month,
    ps.monthly_sales,
    rs.total_sales + ps.monthly_sales AS total_sales
  FROM product_sales ps
  JOIN recursive_sales rs 
    ON ps.product_id = rs.product_id 
    AND ps.sale_month = rs.sale_month + INTERVAL '1 month'
)

SELECT 
  product_id, 
  sale_month, 
  total_sales
FROM recursive_sales
ORDER BY product_id, sale_month;


/*7.To understand how different payment methods affect monthly sales growth, 
Amazon wants to compute the total sales for each payment method and calculate the month-over-month growth rate 
for the past year (year 2018). 
Write query to first calculate total monthly sales for each payment method, then compute the percentage change from the previous month.

Output: payment_type, sale_month, monthly_total, monthly_change.
*/

WITH monthly_sales AS (
  SELECT 
    payment_type,
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS sale_month,
    SUM(p.payment_value) AS monthly_total
  FROM payments p
  JOIN orders o ON p.order_id = o.order_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
  GROUP BY payment_type, TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
),
sales_with_lag AS (
  SELECT 
    payment_type,
    sale_month,
    monthly_total,
    LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month) AS prev_month_total
  FROM monthly_sales
)
SELECT 
  payment_type,
  sale_month,
  monthly_total,
  ROUND(
    100.0 * (monthly_total - COALESCE(prev_month_total, 0)) / NULLIF(prev_month_total, 0), 
    2
  ) AS monthly_change
FROM sales_with_lag
ORDER BY payment_type, sale_month;
