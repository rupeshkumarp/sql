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


select
	fs.date,fs.product_code,
    dp.product,dp.variant,fs.sold_quantity,fg.gross_price,
    round((fs.sold_quantity* fg.gross_price),2) as gross_price_total
from fact_sales_monthly fs
join dim_product dp
on fs.product_code=dp.product_code and 
get_financial_year(fs.date)
join fact_gross_price fg
on fs.product_code=fg.product_code
where fs.customer_code=90002002 and 
get_financial_q(date)='q4';

-- monthly sales of croma (customer_code=90002002)
select 
	s.date,
    sum(g.gross_price*s.sold_quantity) as gross_profit
from fact_sales_monthly s
join fact_gross_price g on
g.product_code=s.product_code and
g.fiscal_year=get_financial_year(s.date)
where customer_code=90002002
group by s.date
order by s.date asc;

SELECT
    s.date,
    s.product_code,
    SUM(g.gross_price) AS sum_total,
    SUM(g.gross_price * s.sold_quantity) AS gross_profit
FROM fact_sales_monthly s
JOIN fact_gross_price g
    ON s.product_code = g.product_code
   AND g.fiscal_year = get_financial_year(s.date)
GROUP BY
    s.date,
    s.product_code
ORDER BY
    s.date,
    sum_total,
    gross_profit;
    
-- yearly sales of croma customer_code=90002002
select 
	year(s.date) as years,
    sum(g.gross_price*s.sold_quantity) as gross_profit
from fact_sales_monthly s
join fact_gross_price g on
g.product_code=s.product_code and
g.fiscal_year=get_financial_year(s.date)
where customer_code=90002002
group by years;


select *from dim_customer 
where customer like '%amaz%' and market ='india';-- anazon has 2 id,they are 90002008 and 90002026

select 
	s.date,
    sum(round(g.gross_price*s.sold_quantity,2)) as monthly_sales
from fact_sales_monthly s
join fact_gross_price g on
g.product_code=s.product_code and
g.fiscal_year=get_financial_year(s.date)
where customer_code in (90002008 , 90002016)
group by s.date;


--  CREATING STORED PROCEDURES
-- USE `gdb0041`;
-- DROP procedure IF EXISTS `get_monthly_gross_scales_for_customer`;

-- USE `gdb0041`;
-- DROP procedure IF EXISTS `gdb0041`.`get_monthly_gross_scales_for_customer`;
-- ;

-- DELIMITER $$
-- USE `gdb0041`$$
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_gross_scales_for_customer`(
-- 	in_customer_code text
-- )
-- BEGIN
-- 	select 
-- 		s.date,
-- 		sum(g.gross_price*s.sold_quantity) as gross_profit
-- 	from fact_sales_monthly s
-- 	join fact_gross_price g on
-- 	g.product_code=s.product_code and
-- 	g.fiscal_year=get_financial_year(s.date)
-- 	where find_in_set(s.customer_code,in_customer_code)>0
-- 	group by s.date;
-- END$$

-- DELIMITER ;
-- ;



select
	d.market,
    sum(fg.gross_price*f.sold_quantity) as profit,
    sum(f.sold_quantity) as total_sold_quentity,
    CASE
        WHEN sum(fg.gross_price*f.sold_quantity) > 5000000 THEN 'GOLD'
        ELSE 'silver'
    END AS sales_category
from fact_sales_monthly f
join  dim_customer d
on f.customer_code=d.customer_code
join fact_gross_price fg
on f.product_code=fg.product_code
where get_financial_year(f.date)=2021
group by d.market ;


select
	sum(sold_quantity)as total_qty
from fact_sales_monthly s
join dim_customer c
on s.customer_code=c.customer_code
where get_financial_year(s.date)=2021 and c.market='india'
group by c.market;


-- GIVES A MARKET BADGE OF GOLD OR SILVER BASED ON ITS TOTAL SALES QUENTITY OF AN PARTICULAR FISICAL YEAR
-- USE `gdb0041`;
-- DROP procedure IF EXISTS `get_market_badge`;

-- USE `gdb0041`;
-- DROP procedure IF EXISTS `gdb0041`.`get_market_badge`;
-- ;

-- DELIMITER $$
-- USE `gdb0041`$$
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `get_market_badge`(
-- 	in in_market varchar(45),
--     in in_fiscal_year year,
-- 	out out_badge varchar(45)
-- )
-- BEGIN
-- 	declare qty int default 0;
--     #set deafult market to be india
--     if in_market='' then 
-- 		set in_market='india';
-- 	end if;
-- 	# retrieve total qty for a given market+fiscal year
-- 	select
-- 		sum(sold_quantity) into qty
-- 	from fact_sales_monthly s
-- 	join dim_customer c
-- 	on s.customer_code=c.customer_code
-- 	where get_financial_year(s.date)=in_fisical_year and
--     c.market=in_market
-- 	group by c.market;
--     
--     if qty>5000000 then
-- 		set out_badge='Gold';
-- 	else 
-- 		set out_badge='Silver';
-- 	end if;
-- END$$

-- DELIMITER ;
-- ;


-- net company sales in countrys;
select
    dc.market,
    SUM(fs.sold_quantity) AS total_sold_quantity,
    round(SUM(fp.gross_price * fs.sold_quantity),2) AS gross_sales
from fact_sales_monthly fs
join fact_pre_invoice_deductions pre
on fs.customer_code=pre.customer_code and
pre.fiscal_year=get_financial_year(fs.date)
JOIN fact_gross_price fp on
 fp.product_code=fs.product_code and
fp.fiscal_year=get_financial_year(fs.date)
join dim_customer dc
on dc.customer_code=fs.customer_code
where get_financial_year(fs.date)=2021 
group by dc.market;


-- Fetches product sales, gross price, and discount details for financial year 2021.
select 
	s.date,s.product_code,
	p.product,p.variant,
    s.sold_quantity*g.gross_price as gross_prise_per_item,
    round(s.sold_quantity*g.gross_price,2) as gross_price_total,
    pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p on
s.product_code=p.product_code
join fact_gross_price g 
on g.product_code=p.product_code and
g.fiscal_year=get_financial_year(s.date)
join fact_pre_invoice_deductions pre
on pre.customer_code=s.customer_code and
pre.fiscal_year=get_financial_year(s.date)
where  get_financial_year(s.date)=2021
limit 1000000;

explain analyze
select 
	s.date,s.product_code,
	p.product,p.variant,
    s.sold_quantity*g.gross_price as gross_prise_per_item,
    round(s.sold_quantity*g.gross_price,2) as gross_price_total,
    pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p on
s.product_code=p.product_code
join fact_gross_price g 
on g.product_code=p.product_code and
g.fiscal_year=get_financial_year(s.date)
join fact_pre_invoice_deductions pre
on pre.customer_code=s.customer_code and
pre.fiscal_year=get_financial_year(s.date)
where  get_financial_year(s.date)=2021
limit 1000000;