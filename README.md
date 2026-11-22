
# Retail Orders Analysis | Python, SQL & Jupyter Notebook

## Project Overview

This project analyzes retail order data from 2022 and 2023 using Python, SQL, and Jupyter Notebook. It examines sales performance, product rankings, regional performance, category trends, and profit growth to generate actionable business insights.

### Project Objectives
- Identify the top-performing products based on sales.
- Analyze product performance across different regions.
- Compare monthly sales between 2022 and 2023.
- Identify the highest-sales month for each product category.
- Evaluate sub-category profit growth and decline.

## Dataset

The dataset contains **9,994 retail orders** with the following information:

- Order date, region, and shipping mode
- Customer segment
- Product category and sub-category
- Product ID
- Cost price, list price, and quantity
- Discount, sales price, and profit

## Tools & Technologies

- Python
- Pandas
- NumPy
- Jupyter Notebook
- SQL (MySQL)
- CSV
- Git & GitHub

## Business Questions & Key Findings

### 1. What are the Top 10 Products by Sales?

**Key Findings:**
- TEC-CO-10004722 was the highest-selling product, generating sales of 59,514.
- OFF-BI-10003527 ranked second with sales of 26,525.30.
- Technology products accounted for several of the highest-selling products.

| Product ID | Sales |
|---|---:|
| TEC-CO-10004722 | 59,514.00 |
| OFF-BI-10003527 | 26,525.30 |
| TEC-MA-10002412 | 21,734.40 |
| FUR-CH-10002024 | 21,096.20 |
| OFF-BI-10001359 | 19,090.20 |
| OFF-BI-10000545 | 18,249.00 |
| TEC-CO-10001449 | 18,151.20 |
| TEC-MA-10001127 | 17,906.40 |
| OFF-BI-10004995 | 17,354.80 |
| OFF-SU-10000151 | 16,325.80 |

**SQL Query:**

```sql
SELECT product_id,
       SUM(sales_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;
```

### 2. What Are the Top Five Products in Each Region?

**Key Findings:**
- Product sales vary across regions.
- Regional product rankings help identify high-demand products.
- These insights can support inventory planning and targeted marketing.

**SQL Query:**

```sql
WITH product_sales AS (
    SELECT region,
           product_id,
           SUM(sales_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
),
ranked_products AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY region
               ORDER BY sales DESC
           ) AS rn
    FROM product_sales
)
SELECT *
FROM ranked_products
WHERE rn <= 5;
```

### 3. How Did Monthly Sales Compare Between 2022 and 2023?

**Key Findings:**
- February recorded the highest growth, increasing by **42.22%**.
- June experienced the largest decline, with sales decreasing by **26.75%**.
- August declined by 16.29%, while November declined by 10.44%.
- February, April, and July showed strong year-over-year growth.

| Month | 2022 Sales | 2023 Sales | Growth |
|---|---:|---:|---:|
| January | 94,712.50 | 88,632.60 | -6.42% |
| February | 90,091.00 | 128,124.20 | 42.22% |
| March | 80,106.00 | 82,512.30 | 3.00% |
| April | 95,451.60 | 111,568.60 | 16.88% |
| May | 79,448.30 | 86,447.90 | 8.81% |
| June | 94,170.50 | 68,976.50 | -26.75% |
| July | 78,652.20 | 90,563.80 | 15.14% |
| August | 104,808.00 | 87,733.60 | -16.29% |
| September | 79,142.20 | 76,658.60 | -3.14% |
| October | 118,912.70 | 121,061.50 | 1.81% |
| November | 84,225.30 | 75,432.80 | -10.44% |
| December | 95,869.90 | 102,556.10 | 6.97% |

**SQL Query:**

```sql
WITH monthly_sales AS (
    SELECT YEAR(order_date) AS order_year,
           MONTH(order_date) AS order_month,
           SUM(sales_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month,
       SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023,
       ROUND(
           (
               SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END)
               - SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END)
           ) * 100.0
           / NULLIF(
               SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END),
               0
           ),
           2
       ) AS growth_pct
FROM monthly_sales
GROUP BY order_month
ORDER BY order_month;
```

### 4. Which Month Had the Highest Sales for Each Category?

**Key Findings:**

| Category | Highest-Sales Month | Sales |
|---|---|---:|
| Furniture | October 2022 | 42,888.90 |
| Office Supplies | February 2023 | 44,118.50 |
| Technology | October 2023 | 53,000.10 |

- Furniture achieved its highest sales in October 2022.
- Office Supplies performed best in February 2023.
- Technology recorded its highest sales in October 2023.

**SQL Query:**

```sql
WITH monthly_category_sales AS (
    SELECT category,
           DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
           SUM(sales_price) AS sales
    FROM df_orders
    GROUP BY category, DATE_FORMAT(order_date, '%Y%m')
),
ranked_sales AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY sales DESC
           ) AS rn
    FROM monthly_category_sales
)
SELECT *
FROM ranked_sales
WHERE rn = 1;
```

### 5. Which Sub-Category Had the Highest Profit Growth in 2023?

**Key Findings:**
- Machines recorded the highest profit growth of 3,635.30.
- Phones ranked second, with profit growth of 2,318.90.
- Binders ranked third, with profit growth of 1,837.60.
- Copiers and Appliances experienced the largest profit declines.

| Sub-Category | 2022 Profit | 2023 Profit | Profit Growth |
|---|---:|---:|---:|
| Machines | 7,243.20 | 10,878.50 | 3,635.30 |
| Phones | 13,024.70 | 15,343.60 | 2,318.90 |
| Binders | 8,685.50 | 10,523.10 | 1,837.60 |
| Storage | 8,907.40 | 10,630.60 | 1,723.20 |
| Appliances | 6,374.40 | 3,893.30 | -2,481.10 |
| Copiers | 8,780.30 | 5,718.60 | -3,061.70 |

**SQL Query:**

```sql
WITH yearly_profit AS (
    SELECT sub_category,
           YEAR(order_date) AS order_year,
           SUM(profit) AS total_profit
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
profit_comparison AS (
    SELECT sub_category,
           SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
           SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023
    FROM yearly_profit
    GROUP BY sub_category
)
SELECT *,
       profit_2023 - profit_2022 AS profit_growth
FROM profit_comparison
ORDER BY profit_growth DESC;
```

## Key Business Recommendations

1. **Inventory Optimization:** Prioritize high-performing products and categories.
2. **Marketing Strategy:** Investigate February's strong sales growth and identify opportunities to replicate successful campaigns.
3. **Sales Performance:** Investigate the factors contributing to sales declines in June and August.
4. **Profitability Improvement:** Focus on Machines and Phones due to their positive profit growth.
5. **Pricing Strategy:** Review pricing and discount strategies for Copiers and Appliances.
6. **Regional Strategy:** Use regional product rankings to develop targeted promotions and optimize inventory distribution.

## Repository Structure

```text
Retail-Orders-Analysis/
│
├── orders.csv
├── retail_data_project.ipynb
├── retail.sql
│
├── Comparing monthly sales between 2022 and 2023.csv
├── Determining the highest-sales month for each category.csv
├── Finding the subcategory with the highest profit growth.csv
├── Finding the top five products in each region.csv
├── Identifying the top 10 products by sales.csv
│
└── README.md
```

## How to Run This Project

### 1. Clone the Repository

```bash
git clone <your-github-repository-url>
```

### 2. Navigate to the Project Directory

```bash
cd Retail-Orders-Analysis
```

### 3. Install Required Libraries

```bash
pip install pandas numpy jupyter
```

### 4. Load the Dataset

```python
import pandas as pd

df = pd.read_csv("orders.csv")
```

### 5. Run Jupyter Notebook

```bash
jupyter notebook
```

Open `retail_data_project.ipynb` and execute the notebook cells.

### 6. Execute SQL Queries

Open `retail.sql` in MySQL or your preferred SQL environment. Ensure the `df_orders` table is available before executing the queries.

## Future Improvements

- Develop visualizations for monthly sales trends and category performance.
- Build an interactive dashboard using Power BI or Tableau.
- Perform customer and regional segmentation analysis.
- Investigate the impact of discounts on sales and profitability.
- Develop predictive models for future sales and profit forecasting.
- Implement automated tests to validate data cleaning and analytical calculations.
- Add a data dictionary and document project assumptions.

## Author

**Samarth Degaonkar**

Power BI Data Analyst | SQL | Python

- LinkedIn: [LinkedIn Profile](https://www.linkedin.com/)
- Email: [Email Address](mailto:your-email@example.com)

---

*This project demonstrates practical data analytics skills, including Python-based data preparation, SQL business analysis, and translating analytical results into actionable business recommendations.*
