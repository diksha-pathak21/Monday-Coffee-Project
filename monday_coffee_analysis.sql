--Reports and Data Analysis

--question 1: How many people in each city are estimated to consume coffe, given that 25% of the population does?
select city_name,
ROUND((population*0.25)/1000000,2) as total_people_in_millions,-- divide by millionns krke round to 2 decimal placs krdi
city_rank
from city --its given that 25% people consume coffe, so we does 25% of the given population
order by 2 desc --order by 2nd column

--Question 2: What is the total revenue generated from coffe sales across all cities in the last quarter of 2023?
select 
ci.city_name,
sum(s.total) as total_revenue
from sales as s
join customers as c
on s.customer_id=c.customer_id
join city as ci
on ci.city_id=c.city_id
where 
EXTRACT(YEAR FROM s.sale_date)=2023
AND
EXTRACT(quarter FROM s.sale_date)=4
group by 1
order by 2 desc


--Question 3 How many units of each coffee product have been sold?
select p.product_name,
count(s.sale_id) as total_orders
from products as p
left join
sales as s
on s.product_id=p.product_id
group by 1
order by 2 desc

--Question-4  What is the average sales amount per coutsomer in each city?
 --hint: first we'll find each city with its total sale and total number of cutsomers in that city, then total sale/total customer will give average amount spent by a customer
select 
ci.city_name,
(sum(s.total)/count(distinct(c.customer_id))) as average_per_customer
from sales as s
join customers as c
on s.customer_id=c.customer_id
join city as ci
on ci.city_id=c.city_id 
group by 1
order by 2 desc

--Question-5:what are the top 3 selling products in each city based on sales volume?
select * from 
(
select 
ci.city_name, 
p.product_name,
count(s.sale_id) as total_orders,
DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
from sales as s
join products as p
on s.product_id=p.product_id
join customers as c
on c.customer_id=s.customer_id
join city as ci
on ci.city_id=c.city_id
group by 1,2 ) as t1-- we get one row per city–product combination.
where rank<=3

--Question-6: How many unique customers are there in each city who have purchased coffee products?
--from products table 1-14 are there coffee products, rest are merchandise
select 
ci.city_name,
count(distinct(c.customer_id)) as unique_customer
from city as ci
Left join 
customers as c
on c.city_id=ci.city_id
join sales as s
on s.customer_id=c.customer_id
where 
s.product_id IN(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by 1
order by 2 desc

--Question-7:find each city and their average sale per customer and average rent per customer
SELECT 
    ci.city_name,
    SUM(s.total) / COUNT(DISTINCT c.customer_id) AS average_sale_per_customer,
    ci.estimated_rent / COUNT(DISTINCT c.customer_id) AS average_rent_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON ci.city_id = c.city_id
GROUP BY ci.city_name, ci.estimated_rent
ORDER BY average_sale_per_customer DESC;

--Question-8 Calculate the percentage growth (or decline) in sales over different sales over different time periods(monthly) by each city
SELECT
    ci.city_name,
    EXTRACT(YEAR FROM s.sale_date) AS year,
    EXTRACT(MONTH FROM s.sale_date) AS month,
    SUM(s.total) AS total_sales,

    LAG(SUM(s.total)) OVER(
        PARTITION BY ci.city_name
        ORDER BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
    ) AS previous_month_sales,

    ROUND(
        (
            SUM(s.total) -
            LAG(SUM(s.total)) OVER(
                PARTITION BY ci.city_name
                ORDER BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
            )
        )::numeric
        /
        NULLIF(
            LAG(SUM(s.total)) OVER(
                PARTITION BY ci.city_name
                ORDER BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
            )::numeric, 
            0
        )
        * 100, 
    2
    ) AS percentage_growth --(current - previous) / previous * 100


FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON ci.city_id = c.city_id
GROUP BY ci.city_name, year, month
ORDER BY ci.city_name, year, month;

--Question 9 Identify top 3 cities based on highest sales, return city names, total sale, total rent, total customers, estimated coffe consumers.
SELECT
    ci.city_name,

    -- total sales in that city
    SUM(s.total) AS total_sales,

    ci.estimated_rent AS total_rent,

    -- unique customers in that city
    COUNT(DISTINCT c.customer_id) AS total_customers,

    -- average sale per customer
    SUM(s.total) / COUNT(DISTINCT c.customer_id) AS avg_sale_per_customer,

    -- average rent per customer
    ci.estimated_rent / COUNT(DISTINCT c.customer_id) AS avg_rent_per_customer,

    -- estimated coffee consumers (25% of population)
    ci.population * 0.25 AS estimated_coffee_consumers

FROM city ci
LEFT JOIN customers c 
    ON ci.city_id = c.city_id
LEFT JOIN sales s 
    ON s.customer_id = c.customer_id

GROUP BY 
    ci.city_name,
    ci.estimated_rent,
    ci.population
ORDER BY  
    total_sales DESC



--RECOMENDATION

--CITY 1: PUNE
--Average rent per customer is less
--It has highest total revenue 
--It's average sale is also very high

--CITY 2: DELHI
--Highest coffe consumer which is 7.7M
--Total customers are high which is 68
--average rent per customer is 330(less than 500)

--CITY 3: JAIPUR
--Highest number of customers
--average rent per customer is less (156)
--average sale per customer is better 

















 
 
 


