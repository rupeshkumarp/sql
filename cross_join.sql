use food_db;
select*from items cross join variants;

select*,
	concat(name,' - ',variant_name) as full_name,
	(price+variant_price) as full_price 
from  items cross join variants;

select *,f.revenue-f.budget as profit from movies m 
left join financials f
on m.movie_id=f.movie_id;

select industry,avg(imdb_rating) as avg_rating
 from movies group by industry;
 
select m.movie_id,m.title,f.budget,f.revenue,f.currency,f.unit,
case
 when f.unit='Thousands' then (revenue-budget)/1000
 when f.unit='Billions'then (revenue-budget)*1000
 when f.unit='Millions' then (revenue-budget)
end as profit_mle 
 from movies m 
join financials f 
on m.movie_id=f.movie_id order by profit_mle desc ;


select m.movie_id,m.title,group_concat(a.name) as actors from movies m
join movie_actor ma on ma.movie_id=m.movie_id
join actors a on a.actor_id=ma.actor_id group by m.movie_id;

select a.name,group_concat(m.title separator ' `and` ') as movies,count(m.title) as NoOf_count from movies m
join movie_actor ma on ma.movie_id=m.movie_id
join actors a on a.actor_id=ma.actor_id group by a.name order by NoOf_count desc ;

select m.title,f.revenue,f.currency,f.unit,case 
when f.unit='thousands' then round(f.revenue/1000,2)
when f.unit='billions' then round(f.revenue*1000,2)
when f.unit='millions' then round(f.revenue,2)
end as revenue_mle from movies m
join financials f on m.movie_id=f.movie_id 
where m.industry='bollywood' order by revenue_mle desc;

select count(*)from movies where industry='bollywood';

select m.title,group_concat(a.name separator ' `and` ') as actors,count(a.name)as actores_count from movies m  join movie_actor ma on m.movie_id=ma.movie_id
join actors a on ma.actor_id=a.actor_id group by m.title;

select studio ,group_concat(title separator' | ') ,count(*) as studio_c 
from movies  where  industry='bollywood' group by studio order by studio_c desc;

select avg(f.profit) avg_profit,m.studio from financials f 
join movies m on f.movie_id=m.movie_id 
group by studio having avg_profit>10 order by avg_profit desc; 
