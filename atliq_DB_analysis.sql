SELECT * FROM dim_customer;
select distinct market from dim_customer;
select distinct channel from dim_customer;
select distinct region from dim_customer;

select*from dim_product;
select distinct division from dim_product;
select distinct segment from dim_product;
select distinct category from dim_product;

-- finding customer code
select*from dim_customer where customer like "%croma%";

select sum(sold_quantity),product_code from fact_sales_monthly where customer_code=90002002 group by product_code;

-- selecting sales of customer_code for financial year 2025
select *from fact_sales_monthly 
where customer_code=90002002 and
year(date_add(date ,interval 4 month))=2021;

-- CREATE DEFINER=`root`@`localhost` FUNCTION `get_fiscal_year`(calender_date date) RETURNS int
--     DETERMINISTIC
-- BEGIN
-- 	declare fiscal_year int;
--     set fiscal_year=year(date_add(cleander_date ,interval 4 month));
-- 		RETURN fiscal_year;
-- END

-- using declared variable  
select*from fact_sales_monthly 
where customer_code=90002002 and
get_financial_year(date)=2020;


-- CREATE DEFINER=`root`@`localhost` FUNCTION `get_financial_q`(
-- calender_date date) RETURNS char(2) CHARSET utf8mb4
--     DETERMINISTIC
-- BEGIN
-- declare m tinyint;
-- declare qtr char(2);
-- set m=month(calender_date);
--       case 
-- 		when m in (9,10,11)then set qtr='q1';
--         when m in (12,1,2)then set qtr='q2';
--         when m in (3,4,5)then set qtr='q3';
-- 		else set qtr='q4';
-- 	end case;
--     return qtr;
-- END
-- selecting q4 sales info of customer_code 90002002
select*from fact_sales_monthly where customer_code=90002002 and 
get_financial_q(date)='q4';

