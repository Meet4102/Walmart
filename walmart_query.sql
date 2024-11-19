create database walmart_db;
use walmart_db;
select count(*) from walmart;
select * from walmart;

# Howmany transactions done of each payment method
select 
	payment_method,
	count(*)
from walmart
group by payment_method;

#distinct count of branch
select count(distinct branch)
from walmart;

#max quantity 
select max(quantity) from walmart;

# Business problem
-- Q.1 Find different payment method method and number of transactions and number of QTY sold
select 
	payment_method,
    count(*) as no_of_payments,
    sum(quantity) as no_qty_sold
from walmart
group by payment_method
order by no_qty_sold desc;

-- Q.2 Indetify the highest-rated category in each branch and displaying the branch, 
-- category & avg rating 

select * 
from
(
select  
	branch,
    category,
    avg(rating) as avg_rating,
    rank() over(partition by branch order by avg(rating) desc) as ranking
from walmart
group by 1,2) as cte
where ranking = 1 ;

-- Q.3 Indentify the busiest day for each branch on the number of transaction
select * from walmart;
select * 
from
(
SELECT 
    branch,
    dayname(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
    count(invoice_id) as no_transaction,
    rank() over(partition by branch order by count(invoice_id) desc) as ranking
FROM walmart
group by 1,2
) as cte
where ranking=1;

-- Q.4 
-- Calculate the total quantity of items old per payment method. List Paymetn method and total_quantity
select 
	payment_method,
    sum(quantity) as no_qty_sold
from walmart
group by 1
order by 2 desc;

-- Q.5
-- Determine the average,minimum,maximum rating of category for ecach city
-- list the city , avg_rating, min_rating, max_rating

select 
	city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by 1,2;

-- Q.6
-- Calculate total profit fror each category by considering total_profit as
-- (unit_price * quantity * profit_margin)
-- List category and total_profit, order from highest to lowest profit.
select * from walmart;
select
	category,
    sum(Total) as total_revenue,
    sum(Total * profit_margin) as profit
from walmart
group by 1
order by 3 desc;

-- Q.7
-- Determine the most common payment method for each branch. Display Branch and preferred_payment_method.
select * from walmart;

with cte
as
(
select
	branch,
    payment_method,
    count(*) as total_transaction,
    rank() over(partition by branch order by count(*) desc) as ranking
from walmart
group by 1,2
)
select * from cte
where ranking = 1;

-- Q.8
-- Categorize  sales into 3  group Morning,Afternoon,Evening
-- Find out the each shift and number of invoices
select * from walmart;
SELECT
	branch,
    CASE 
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) < 12 THEN 'Morning'
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    count(*) as no_of_invoice
FROM walmart
group by 1,2
order by 1,3 desc;

-- Q.9 
-- Indentify 5 branch with highest decrese ratio in revenue
-- compare to last year (Current year 2023 and last year 2022)
-- rdr == last_year_rev - current_year_rev/last_year_rev*100
select * from walmart;
select *,
year(STR_TO_DATE(date, '%d/%m/%Y')) as formated_date
from walmart;

-- 2022 sales for each branch
with rev_2022
as
(
	select
		branch,
		sum(Total) as revenue
	from walmart
	where year(STR_TO_DATE(date, '%d/%m/%Y')) = 2022 
	group by 1
),
rev_2023 
as
(
	SELECT
        branch,
        SUM(Total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
select
	ls.branch,
    ls.revenue as revenue_2022,
    cr.revenue as revenue_2023,
    round((ls.revenue-cr.revenue)/ls.revenue*100,2) as rev_dec_ratio
from rev_2022 as ls
join rev_2023 as cr
on ls.branch = cr.branch
where ls.revenue > cr.revenue
order by 4 desc
limit 5;


