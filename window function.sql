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
    ROUND(net_sales/ 1000000, 2) AS net_sales_mln,
    ROUND(
        net_sales * 100 /
        SUM(net_sales) OVER (PARTITION BY region),2) AS plt
from  cte2 
order by region , net_sales_mln desc;