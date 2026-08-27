select max(date) from fact_forecast_monthly;-- 2022-08-01

select max(date) from fact_sales_monthly;-- 2021-12-01

-- FEATURE ENGINEERING
-- creating table fact_act_est
create table fact_act_est
(
	select 
		s.date as date,
		s.fisical_year as fiscal_year,
		s.product_code as product_code,
		s.customer_code as customer_code,
		s.sold_quantity as sold_quantity,
		f.forecast_quantity
	from fact_sales_monthly s
	left join fact_forecast_monthly f
	using(date,product_code,customer_code)
	union
	select 
		f.date as date,
		f.fiscal_year as fiscal_year,
		f.product_code as product,
		f.customer_code as customer_code,
		s.sold_quantity as sold_quantity,
		f.forecast_quantity as forecast_quantity
	from fact_forecast_monthly f
	left join fact_sales_monthly s
	using(date,product_code,customer_code)
);

-- changing null values to 0 in column sold_quantity
update fact_act_est
set sold_quantity=0
where sold_quantity is null;


-- changing null values to 0 in column forecast_quantity
-- update fact_act_est 
-- set forecast_quantity=0
-- where forecast_quantity is null

-- -- trigger creation
-- DROP TRIGGER IF EXISTS `gdb0041`.`fact_act_est_AFTER_INSERT`;

-- DELIMITER $$
-- USE `gdb0041`$$
-- CREATE DEFINER = CURRENT_USER TRIGGER `gdb0041`.`fact_act_est_AFTER_INSERT` AFTER INSERT ON `fact_act_est` FOR EACH ROW
-- BEGIN
-- 	insert into fact_act_est
-- 		(date,product_code,customer_code,sold_quantity)
--     values(
-- 		new.date,
--         new.product_code,
-- 		new.customer_code,
--         new.sold_quantity
-- 	)
--     on duplicate key update
--     sold_quantity=values(sold_quantity);
-- END$$
-- DELIMITER ;

-- display trigger
show triggers;

insert into fact_sales_monthly(
	date,product_code,customer_code,sold_quantity)
values('2025-09-01','ram',2003,28);
select*from fact_sales_monthly where customer_code=2003;

select*from fact_act_est where customer_code=2003;-- trigger is working fine,here forecast_quantity is null
-- drop TRIGGER trigger_name;

-- created trigger in forecast_monthly table
insert into fact_forecast_monthly
(date,product_code,customer_code,forecast_quantity)
values('2025-09-01','ram',2003,43);

select*from fact_act_est where customer_code=2003;


use random_table;
CREATE TABLE random_tables.session_logs (ts DATETIME, session_id INT, user_id INT, log TEXT);

INSERT INTO random_tables.session_logs  (ts, session_id, user_id, log) 
VALUES 
('2022-10-04 08:14:07', '898812', '523', 'CLICKED | Courses Buttom'),
('2022-10-14 08:18:35', '898812', '523', 'NAVIAGE BACK | Python course page , codebasics.io'),
('2022-10-16 12:07:00', '965345', '523', 'REVIEW GENERATED | Data analytics in power bi'),
('2022-10-22 14:09:22', '188567', '707', 'NEW LOGIN | New login, user name: tasty@jalebi.com'),
('2022-10-22 18:10:06', '188567', '707', 'COURSE PURCHASED | Data analytics in power bi, user name: tasty@jalebi.com');

select*from session_logs;

show variables like '%event%';

-- creating event
delimiter $
create event e_daily_log_purge
on schedule 
	every 5 second
    comment 'purge logs that are 5 days or older'
do begin
delete from session_logs
where date(ts)<date('2021-10-18')-interval 5 day;
end $
delimiter ;

with cte as( 
select
    customer_code,
	sum(abs((forecast_quantity-sold_quantity)))as abs_error,
    sum(abs((forecast_quantity-sold_quantity)))*100/sum(forecast_quantity) as abs_erro_pct
from fact_act_est f
where f.fiscal_year=2021
group by customer_code
order by abs_erro_pct desc)
select
	e.*,
    c.customer,
	if(e.abs_erro_pct>100,0,100-e.abs_erro_pct) as forecast_accuracy
from cte e
join dim_customer c
using(customer_code)
order by forecast_accuracy asc;


-- creating an stored procedures for forecast accuracy
-- USE `gdb0041`;
-- DROP procedure IF EXISTS `get_forecast_accuracy`;

-- DELIMITER $$
-- USE `gdb0041`$$
-- CREATE PROCEDURE `get_forecast_accuracy` (
-- 	in_fiscal_year int)
-- BEGIN
-- 	with cte as( 
-- select
--     customer_code,
-- 	sum(abs((forecast_quantity-sold_quantity)))as abs_error,
--     sum(abs((forecast_quantity-sold_quantity)))*100/sum(forecast_quantity) as abs_erro_pct
-- from fact_act_est f
-- where f.fiscal_year=in_fiscal_year
-- group by customer_code
-- order by abs_erro_pct desc)
-- select
-- 	e.*,
--     c.customer,
-- 	if(e.abs_erro_pct>100,0,100-e.abs_erro_pct) as forecast_accuracy
-- from cte e
-- join dim_customer c
-- using(customer_code)
-- order by forecast_accuracy asc;
-- END$$

-- DELIMITER ;

create temporary table forecast_accuracy # create an temporary table for the present session
	select
		customer_code,
		sum(abs((forecast_quantity-sold_quantity)))as abs_error,
		sum(abs((forecast_quantity-sold_quantity)))*100/sum(forecast_quantity) as abs_erro_pct
	from fact_act_est f
	where f.fiscal_year=2021
	group by customer_code
	order by abs_erro_pct desc;
    


-- Compare customer forecast accuracy between 2020 and 2021 and identify customers whose accuracy declined.
with cte1 as(
select
		customer_code,
		sum(abs((forecast_quantity-sold_quantity)))as abs_error_2021,
		sum(abs((forecast_quantity-sold_quantity)))*100/sum(forecast_quantity) as abs_error_pct_2021
	from fact_act_est f
	where f.fiscal_year=2021
	group by customer_code),
cte2 as(select
		customer_code,
		sum(abs((forecast_quantity-sold_quantity)))as abs_error_2020,
		sum(abs((forecast_quantity-sold_quantity)))*100/sum(forecast_quantity) as abs_error_pct_2020
	from fact_act_est f
	where f.fiscal_year=2020
	group by customer_code),
cte3 as(select
	c.customer_code,
	if(cc.abs_error_pct_2020>100,0,100- cc.abs_error_pct_2020) as forecast_accuracy_2020,
    if(c.abs_error_pct_2021>100,0,100- c.abs_error_pct_2021) as forecast_accuracy_2021
    from cte1 c join cte2 cc
    on c.customer_code=cc.customer_code)
select  c3.customer_code,
    d.customer,
    d.market,
    round(c3.forecast_accuracy_2020, 2) as forecast_accuracy_2020,
    round(c3.forecast_accuracy_2021, 2) as forecast_accuracy_2021
from cte3 c3 
join dim_customer d
on c3.customer_code=d.customer_code
where c3.forecast_accuracy_2021 < c3.forecast_accuracy_2020
order by forecast_accuracy_2021 asc;


with monthly_sales as (
    select
        customer_code,
        month(date) as month,
        sum(sold_quantity) as monthly_quantity
    from fact_sales_monthly
    where fisical_year = 2021
    group by customer_code, month(date)
)
select
    customer_code,
    month,
    monthly_quantity,
    lag(monthly_quantity) over (
        partition by customer_code
        order by month) as previous_month_quantity
from monthly_sales;