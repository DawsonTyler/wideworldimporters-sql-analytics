# WideWorldImporters Advanced SQL Analytics

This project uses the WideWorldImporters database to perform **real business analytics** using advanced SQL only.  
The goal is to simulate tasks done by Data Analysts in retail/eCommerce companies, focusing on customers, revenue, products, and churn.

---

## 🧰 Tech Stack
- SQL Server
- Window Functions (RANK, LAG, DENSE_RANK)
- CTEs
- Date/Time Aggregations
- Business Logic in SQL

---

## 📁 Repository Structure

wideworldimporters-sql-analytics/
│
├── sql/
│ └── advanced_queries.sql ← Full suite of analytical SQL queries
│
└── README.md


---

## 📊 Project Overview

Using multiple schemas inside WideWorldImporters (Sales, Warehouse, Application), this project answers real analytical questions including:

### ✔ Revenue Trends
- Revenue by year and month  
- Year-over-year comparisons  
- Quarterly performance patterns  

### ✔ Top Customers per Quarter
- Identifying high-value customers using `DENSE_RANK()`  
- Understanding repeat purchase behavior  

### ✔ Product Profitability
- Top 10 most profitable products  
- Pareto-style concentration (20% of products driving 80% of revenue)

### ✔ Pricing Inefficiencies
- Detecting underpriced items by comparing Unit Price vs Recommended Retail Price  

### ✔ Churn Modeling (using `LAG()`)
- Flagging customers who have gone longer than their average purchase window  
- Distinguishing Active vs Potential Churn customers  

### ✔ Regional Insights
- Cities and countries with highest sales  
- Geographic buying patterns  

---

## ▶️ How to Use

1. Install WideWorldImporters sample DB in SQL Server.  
2. Open `sql/advanced_queries.sql`.  
3. Run each section independently to explore different business questions.  

The queries are grouped by theme (revenue, churn, customers, products, etc.).

---

## 🔗 Full Project Write-Up

Full explanations, breakdowns, and portfolio version:  
[👉 **[View full project on my Notion Portfolio](https://healthy-scowl-eac.notion.site/Tyler-Dawson-Data-Portfolio-2c3388b7f1a6806da9e9e365aaefd466?source=copy_link)
**]

---

## 📬 Contact
For questions or collaboration:  
Dawsonty8@gmail.com

