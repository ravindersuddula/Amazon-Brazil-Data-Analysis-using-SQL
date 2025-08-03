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

🔍 Key SQL Concepts Used
Basic SELECTs & Aggregations

Joins across multiple tables

CASE statements and segmentation

CTEs (Common Table Expressions)

Window Functions (RANK, LAG)

Recursive CTE for monthly cumulative sales

Subqueries for above-average filters

🧪 Highlight Analyses
Topic	Description
Payment Preferences	Avg payment, distribution, std deviation
Customer Segmentation	New, Returning, Loyal using order count
Product Insights	Price range, missing category names
Seasonal Trends	Sales by month and season
Revenue Ranking	Top 5 categories and high-value customers
Growth Analysis	MoM sales growth by payment type

📂 Files Included
File	Description
AmazonDataAnalysisusingSQL.sql	Full SQL queries for all 3 analyses
AmazonDataAnalysisusingSQL.docx	Report with query outputs, business insights, and recommendations

💡 Sample Insight
💳 Credit cards make up 73.9% of all orders, while vouchers are used for small consistent purchases — a valuable insight for Amazon India’s payment strategy.

📈 Visualization Ideas (Excel/Power BI)
Pie chart: Customer segments (Occasional, Regular, Loyal)

Bar chart: Avg price by product category

Line chart: Monthly revenue trends

✍️ Author
Ravinder Suddula
LinkedIn ([url](https://www.linkedin.com/in/ravindersuddula) |  GitHub ([url](https://github.com/ravindersuddula)
