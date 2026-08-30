-- logical operators
select *from movies where imdb_rating>8 and release_year>2015;
select *from movies where imdb_rating>8 and release_year between  2015 and 2018;
select*from actors where birth_year between 1970 and 1985;
select *from movies where studio in('Marvel Studios', 'Warner Bros. Pictures', 'Paramount Pictures');
select *from financials where currency='inr' and unit='billions' and profit between 1 and 5;


-- comparison operators
select *from movies where industry='hollywood' order by imdb_rating desc;
select *,case 
when unit='thousands' then round(revenue/1000,2)
when unit='billions' then round(revenue*1000,2)
when unit='millions' then round(revenue,2)
end as revenue_mle  from financials order by revenue_mle desc;


-- aggregate functions
select industry,count(industry)from movies group by industry;
select round(avg(imdb_rating),2) as avg_r,language_id,group_concat(title separator' | ')
 from movies group by language_id having avg_r>8 order by avg_r;
select studio,count(studio)as count_s from movies group by studio having count_s>3;
SELECT
    FLOOR(birth_year / 10) * 10 AS decade,
    COUNT(*) AS actor_count
FROM actors
GROUP BY FLOOR(birth_year / 10) * 10
ORDER BY decade;
select m.industry, avg(f.budget) as avg_b from movies m
join financials f on m.movie_id=f.movie_id
where currency='USD' group by industry having avg_b>100;


-- case statements
select *, case
  when imdb_rating >= 8 then 'Blockbuster'
  when imdb_rating between 6 and 8 then 'Average'
  else 'Below Average'
end as movie_category
from movies;
select *,year(curdate())-birth_year as age,case
when birth_year <1950 then 'senior'
when birth_year between 1950 and 1985 then 'mid'
when birth_year>1985 then 'young'
end as actor_cetogary from actors;
select *,if(budget>200,'high budget','low budget') as budget_category from financials;


-- joins
select count(*) as counts,group_concat(m.title separator ' | ') as titles,l.name from movies m
join languages l on m.language_id=l.language_id group by l.name;
select f.revenue,f.budget,f.currency,f.unit,m.title,(revenue-budget)as profit from movies m
left join financials f on m.movie_id=f.movie_id;
select group_concat(a.name separator ' | ') as actors,m.title from movies m
join movie_actor ma on m.movie_id=ma.movie_id
join actors a on ma.actor_id=a.actor_id group by m.movie_id;
SELECT
    a.actor_id,
    a.name
FROM actors a
LEFT JOIN movie_actor ma
    ON a.actor_id = ma.actor_id
WHERE ma.movie_id IS NULL;


-- subqueries
select*from movies where imdb_rating> (select avg(imdb_rating)from movies);
select*from actors where birth_year=(select min(birth_year) from actors);
select*from financials f where f.movie_id not in(select m.movie_id from movies m where m.movie_id=f.movie_id);
SELECT
    m.movie_id,
    m.title
FROM movies m
WHERE NOT EXISTS (
    SELECT 1
    FROM financials f
    WHERE f.movie_id = m.movie_id
);
select studio from movies  where imdb_rating=(select max(imdb_rating) from movies);
select a.name ,m.title from movies m
join movie_actor ma on m.movie_id=ma.movie_id
join actors a on ma.actor_id=a.actor_id
where imdb_rating=(select max(imdb_rating) from movies m);
select *from movies where industry='bollywood' and imdb_rating>some
(select imdb_rating from movies);
SELECT
    title,
    imdb_rating
FROM movies
WHERE industry = 'bollywood'
AND imdb_rating > ALL (
    SELECT imdb_rating
    FROM movies
    WHERE industry = 'hollywood');
SELECT *
FROM movies
WHERE industry = 'bollywood'
AND imdb_rating >(
    SELECT max(imdb_rating)
    FROM movies);



-- correlated subqueries
SELECT
    m1.title,
    m1.industry,
    m1.imdb_rating,
    CASE WHEN m1.imdb_rating >
            (
                SELECT AVG(m2.imdb_rating)
                FROM movies m2
                WHERE m2.industry = m1.industry
            )
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS rating_status
FROM movies m1;

select a.name ,group_concat(m.title separator ' | ')as titles from movies m
join movie_actor ma on m.movie_id=ma.movie_id
join actors a on ma.actor_id=a.actor_id 
 where (SELECT COUNT(*) FROM movie_actor ma WHERE ma.actor_id = a.actor_id) > 1 group by a.name;
select m.title,m.imdb_rating,l.name ,l.language_id from movies m
join languages l on m.language_id=l.language_id
where imdb_rating=(select max(imdb_rating) from movies m2 where m2.language_id = m.language_id);
SELECT
    m1.title,
    m1.studio,
    m1.imdb_rating
FROM movies m1
WHERE m1.imdb_rating >
(
    SELECT AVG(m2.imdb_rating)
    FROM movies m2
    WHERE m2.studio = m1.studio
);

-- list all distinct market
select count(*),market from dim_customer group by market;

select variant,product,count(segment) over(partition by variant) as count from dim_product order by count asc;

select*from fact_sales_monthly order by sold_quantity desc limit 10;

-- List all customers in the "Retailer" channel located in "India"
select *from dim_customer where channel='retailer' and market='india';

-- Rank products within each division by total sold quantity
with cte1 as(
select d.division,d.product,sum(f.sold_quantity) as total_sold_qua from fact_sales_monthly f 
join dim_product d
using(product_code)
group by d.division, d.product)
select division,product,total_sold_qua,
rank() over(partition by division order by total_sold_qua desc) as `rank`
from cte1 order by division, `rank`
limit 10;


-- Calculate a 3-month moving average of sold quantity for each product
select
    fisical_year,
    month(date) as month,
    sum(sold_quantity) as monthly_sales,
    round(
        avg(sum(sold_quantity)) over (
            order by fisical_year, month(date)
            rows between 2 preceding and current row
        ),
        2
    ) as moving_avg_3_month
from fact_sales_monthly
group by fisical_year, month(date)
order by fisical_year, month;


-- Calculate forecast accuracy (forecast_quantity vs sold_quantity) by product for FY2021.
with cte1 as(
select f.product_code,f.fiscal_year,
sum(f.sold_quantity)as total_sold,
sum(ff.forecast_quantity) as sum_forecast
from fact_sales_monthly f
join fact_forecast_monthly ff
using (product_code,customer_code,fiscal_year)
where f.fiscal_year=2021
group by f.product_code,f.fiscal_year)
select *, 
round(100 - (abs(sum_forecast - total_sold) * 100/ nullif(sum_forecast, 0)),2) as forecast_accuracy 
from cte1 