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
select *,sum(net_sales_mln) over() from  cte1



