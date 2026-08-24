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
update fact_act_est 
set forecast_quantity=0
where forecast_quantity is null