select  product_id,sum(sales_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10;

--
-- find top 5 highest selling products in each region
with cte as (
    select region, product_id, sum(sales_price) as sales
    from df_orders
    group by region, product_id
),
ranked as (
    select *,
           row_number() over (partition by region order by sales desc) as rn
    from cte
)
select * from ranked where rn <= 5;




-- find month over month growth comparison for 2022 and 2023 sales eg jan 2022 vs jan 2023
with cte as (
    select year(order_date) as order_year,
           month(order_date) as order_month,
           sum(sales_price) as sales
    from df_orders
    group by year(order_date), month(order_date)
)
select order_month,
       sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
       sum(case when order_year = 2023 then sales else 0 end) as sales_2023,
       round(
           (sum(case when order_year = 2023 then sales else 0 end)
          - sum(case when order_year = 2022 then sales else 0 end)) * 100.0
          / nullif(sum(case when order_year = 2022 then sales else 0 end), 0),
       2) as growth_pct
from cte
group by order_month
order by order_month;
-- -for each category which month had highest sales
WITH cte AS (
    SELECT
        category,
        DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
        SUM(sales_price) AS sales
    FROM df_orders
    GROUP BY
        category,
        DATE_FORMAT(order_date, '%Y%m')
)
SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY category
        ORDER BY sales DESC
    ) AS rn
FROM cte;


-- which sub category had highest growth by profit in 2023 compare to 2022

WITH cte AS (
    SELECT
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(profit) AS total_profit
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023
    FROM cte
    GROUP BY sub_category
)
SELECT *,
       profit_2023 - profit_2022 AS profit_growth
FROM cte2
ORDER BY profit_growth DESC;