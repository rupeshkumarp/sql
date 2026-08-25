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

show events;

WITH customer_sales AS (
    SELECT
        c.region,
        c.customer,
        SUM(n.net_sales) AS sales
    FROM net_sales n
    JOIN dim_customer c
        ON n.customer_code = c.customer_code
    WHERE n.fiscal_year = 2021
    GROUP BY c.region, c.customer
)
SELECT
    customer,
    region,
    ROUND(sales, 2) AS sales
FROM customer_sales
WHERE sales > (
    SELECT AVG(sales)
    FROM customer_sales
);