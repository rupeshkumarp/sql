select*from fact_act_est where fiscal_year=2020 limit 100000;-- duretion time 0.109

explain analyze 
select*from fact_act_est where fiscal_year=2020 limit 100000;


-- indexing column fiscal_year
-- ALTER TABLE `gdb0041`.`fact_act_est` 
-- ADD INDEX `idx_fyear` (`fiscal_year` ASC) VISIBLE;

-- after indexing time cost
explain analyze 
select*from fact_act_est where fiscal_year=2020 limit 100000;

select*from fact_act_est where fiscal_year=2020 limit 100000;-- duration time 0.00

show indexes in fact_act_est;


-- 	COMPOSITE INDEX
explain
select*from fact_act_est
where product_code='a0118150101'
limit 500000; -- without index in column product_code,it is rendering in 1422040 rows

explain
select*from fact_act_est
where product_code='a0118150101'
limit 500000;-- with index in column product_code,it is rendering 6005 rows


explain
select*from fact_act_est
where product_code='a0118150101'
and customer_code=70002017
limit 500000; -- rendering 6005 rows

-- CREATING COMPOSITE INDEX
-- ALTER TABLE `gdb0041`.`fact_act_est` 
-- DROP INDEX `idx_product_code` ,
-- ADD INDEX `idx_product_code` (`product_code` ASC, `customer_code` ASC) VISIBLE;
-- ;


explain
select*from fact_act_est
where product_code='a0118150101'
and customer_code=70002017
limit 500000;-- rendering 36 rows after composite indexesing

-- FULL TEXT INDEX
SELECT * FROM film
where description like "%car" or 
description like'%boat%';-- rendering 1000 rows

select*from film
where match(description) against('car boat')
limit 10000; -- rendering 224 rows