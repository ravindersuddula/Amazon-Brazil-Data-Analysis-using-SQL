# 📊 Amazon Brazil Data Analysis using PostgreSQL

### 📝 Overview
This project analyzes **Amazon Brazil's e-commerce data** to uncover trends and behaviors that Amazon India can leverage to improve customer experience, pricing, and retention. The analysis uses **PostgreSQL** and covers everything from data cleaning and aggregations to CTEs and window functions.

---

## 🎯 Objectives
- Analyze customer demographics and behavior
- Identify top product categories by revenue and price variation
- Track seasonal sales and monthly trends
- Understand payment preferences and segment customers
- Provide actionable insights for Amazon India's strategy

---

## 🗃️ Data Schema
The analysis is based on 7 related tables:

| Table | Description |
|-------|-------------|
| `customers` | Customer details and location |
| `orders` | Order status and timestamps |
| `order_items` | Item-level pricing and shipping |
| `products` | Product category and attributes |
| `sellers` | Seller location and ID |
| `payments` | Payment method and value |
| `geolocation` *(optional)* | Regional insights (not used in SQL yet) |

All tables were imported into **PostgreSQL**, linked via foreign keys, and analyzed using SQL.

---

## 🧹 Data Cleaning
- Removed records with `payment_type = 'not_defined'` and `payment_value = 0.00` to improve accuracy.
```sql
DELETE FROM payments
WHERE payment_type = 'not_defined' AND payment_value = 0.00;
```
📈 Key Analyses & SQL Topics Covered

🔹 Analysis - I (Basic SQL + Aggregations)

Avg. payment value per type (rounded)
Distribution of orders by payment type (percentages)
Filter products by price & name (ILIKE '%smart%')
Top 3 months by sales
Identify categories with high price variation
Find consistent payment types (low std deviation)
Detect incomplete/missing product categories

🔹 Analysis - II (Joins + Grouping + Case)

Payment popularity by order value segments
Min/Max/Avg price by product category
Customers with >1 orders
Categorize customers: New, Returning, Loyal (temp table)
Top 5 revenue-generating product categories

🔹 Analysis - III (CTEs, Window Functions, Subqueries)

Seasonal sales comparison using CASE
Products with above-average quantity sold
Monthly revenue trends for 2018
Customer segmentation (Occasional, Regular, Loyal)
Rank top 20 customers by avg order value
Monthly cumulative product sales (recursive CTE)
MoM sales growth by payment method using LAG()

📝 Example Query: Rank Top 20 Customers by Avg Order Value
sql
Copy
Edit
WITH order_totals AS (
  SELECT o.customer_id, o.order_id, SUM(oi.price) AS order_value
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.customer_id, o.order_id
),
customer_avg_order AS (
  SELECT customer_id, AVG(order_value) AS avg_order_value
  FROM order_totals
  GROUP BY customer_id
)
SELECT customer_id, avg_order_value,
  RANK() OVER (ORDER BY avg_order_value DESC) AS customer_rank
FROM customer_avg_order
LIMIT 20;

📁 Project Files
|File	|Description|
|-------|-------------|
|AmazonDataAnalysisusingSQL.sql	|Full SQL script for all analyses |
|AmazonDataAnalysisusingSQL.docx	|Report with query screenshots, business insights, and recommendations |


📌 Recommendations Summary
💳 Credit cards dominate → promote for higher-value orders

📦 Focus on high-performing product categories like beauty, sports, tech

📆 Spring is the best season for revenue → align campaigns accordingly

🧾 Fix missing category data and validate product tags

🎯 Incentivize “New” customers to become “Returning” or “Loyal”

📊 Leverage smart pricing strategies based on product and customer behavior

📬 Contact
Ravinder Suddula
LinkedIn | GitHub
