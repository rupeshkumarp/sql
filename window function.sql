select category,sum(amount)
from expenses  group by category;
select*,
	round(amount*100/sum(amount) over(),2)as plt
from expenses order by category;

-- partition 
select*,
	round(amount*100/sum(amount) over(partition by category),2)as plt
from expenses order by category;

-- cumulative sum
select*,
	sum(amount) over(partition by category order by date) as total_expences_till_date
from expenses order by category,date;


-- cumulative percentage of customer
with cte1 as(
select
	dc.customer,
    ROUND(SUM(n.net_sales) / 1000000, 2) AS net_sales_mln
FROM net_sales n join
dim_customer dc on
n.customer_code=dc.customer_code 
WHERE n.fiscal_year = 2021
GROUP BY dc.customer
order by net_sales_mln)
select *,sum(net_sales_mln) over() from  cte1;




-- Calculate each customer's net sales and their percentage contribution to the total sales of their region.
with cte2 as(
select
	dc.customer,
	dc.region,
    sum(net_sales) as net_sales
FROM net_sale n join
dim_customer dc on
n.customer_code=dc.customer_code 
WHERE n.fiscal_year = 2021
GROUP BY dc.region, dc.customer
)
select 
	customer,
    region,
    ROUND(
        net_sales * 100 /
        SUM(net_sales) OVER (PARTITION BY region),2) AS plt
from  cte2 
order by plt desc;



with cte3 as(
select
	dc.customer,
	dc.region,
    round(sum(n.net_sales)/10000,2)as net_sales_mln
FROM nat_sales n join
dim_customer dc on
n.customer_code=dc.customer_code 
WHERE n.fiscal_year = 2021
GROUP BY dc.customer,dc.region) 
SELECT
    *,
    ROUND(
        net_sales_mln * 100 /
        SUM(net_sales_mln) OVER (PARTITION BY region),
        2
    ) AS pct_shared_region
FROM cte3
ORDER BY region, net_sales_mln DESC;




use random_tables;
-- row_number() window function
with cte as(select*,
	row_number() over(partition by category order by amount desc) as rn
from expenses order by category
)select*from cte where rn<=2;

-- rank() window function
select*,
	rank() over(partition by category order by amount desc) as rnk
from expenses order by category;

-- dense_rank()
select*,
	dense_rank() over(partition by category order by amount desc) as drnk
from expenses order by category;


-- top 2 expenses in each category
with cte as(select*,
	dense_rank() over(partition by category order by amount desc) as rn
from expenses order by category
)select*from cte where rn<=2;


-- distrubuting books to student with highest marks
with cte as(select*,
	dense_rank() over(order by marks desc) as drnk,# use when u have n number of books
    row_number() over(order by marks desc) as rnk,# use only when u have 5 books
    rank() over(order by marks desc) as rn# use only when u need to distrubute books for  5 student only
    from student_marks)select*from cte where drnk<=5;
    

use gdb0041;

-- Rank products by total quantity sold within each division for fiscal year 2021.
with cte as(
		select 
			sum(s.sold_quantity) as total_sold_q,
			p.product,
			s.fisical_year,
			p.division
		from fact_sales_monthly s 
		join dim_product p
		 on s.product_code=p.product_code
		 where s.fisical_year=2021
         group by p.product,p.division,s.fisical_year),
cte1 as(
		select*,
        dense_rank() over (partition by division order by total_sold_q desc)as product_rank
        from cte
        )
 select division,
	product,
    total_sold_q,
    product_rank
from cte1 
where product_rank<=3;

#CREATING AN STORED PROCEDURES
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `get_top_n_products_per_division_by_qty_sold`(
-- in_fisical_year int ,
-- in_top_n int)
-- BEGIN
-- 	with cte as(
-- 		select 
-- 			sum(s.sold_quantity) as total_sold_q,
-- 			p.product,
-- 			s.fisical_year,
-- 			p.division
-- 		from fact_sales_monthly s 
-- 		join dim_product p
-- 		 on s.product_code=p.product_code
-- 		 where s.fisical_year=in_fisical_year
--          group by p.product,p.division,s.fisical_year),
-- cte1 as(
-- 		select*,
--         dense_rank() over (partition by division order by total_sold_q desc)as product_rank
--         from cte
--         )
--  select division,
-- 	product,
--     total_sold_q,
--     product_rank
-- from cte1 
-- where product_rank<=in_top_n;

-- END



-- Rank products by total quantity sold within each market and region for fiscal year 2021.
with cte as(
		select 
			round(sum(s.net_sales)/10000,2) as total_net_sales,
			c.region,
            c.market,
			s.fiscal_year
		from nat_sales s 
		join dim_customer c
		 on s.customer_code=c.customer_code and
         s.market=c.market
		 where s.fiscal_year=2021
         group by c.region,c.market,s.fiscal_year),
cte1 as(
		select*,
        dense_rank() over (partition by region order by total_net_sales desc)as product_rank
        from cte
        )
 select market,
	region,
    total_net_sales,
    product_rank
from cte1 
where product_rank<=5;
