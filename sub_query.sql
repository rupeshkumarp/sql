select studio,round(avg(imdb_rating),2) avg_rating,count(*)movie_count 
from movies group by studio order by avg_rating desc;

select name,(birth_year-2026)as age from actors where
((select name from actors where (birth_year-2026)>70),(select name from actors where (birth_year-2026)<85));


select*from (
select name, (year(curdate())-birth_year)age from actors) as actors_age  where age>70 and age<85; -- calculating age of actors

select movie_id ,title,group_concat(name separator ' | ') as actors
 from (
	select m.movie_id,m.title,a.name from movies m
	join movie_actor ma on ma.movie_id=m.movie_id
	join actors a on a.actor_id=ma.actor_id )
as act
where  movie_id in (101,110,121) group by movie_id ; -- accessing movie actor acted in particular movie 

select*from movies where imdb_rating > some(
select imdb_rating from movies 
where studio='marvel studios'); -- use case of some

select*from movies where imdb_rating > all(
select imdb_rating from movies 
where studio='marvel studios'); -- use case of all

select  studio,avg(imdb_rating) from movies group by studio having avg(imdb_rating)> (select avg(imdb_rating) from movies where 
 studio='marvel studios'); -- selecting studios which have imdb rating higher the marvel studios
 
select ma.actor_id,a.name,count(*)as movie_count from movie_actor ma
join actors a on ma.actor_id=a.actor_id group by ma.actor_id order by movie_count desc; -- counting number of movies actors have acted

select actor_id,name,(select count(*)from movie_actor where actor_id=actors.actor_id)as movie_count
from actors order by movie_count desc;-- counting number of movies actors have acted with correlation subquery

select*from movies where release_year<some(select max(release_year) from movies);

select*from movies where release_year>some(select min(release_year) from movies);

select *from movies where imdb_rating>all(select avg(imdb_rating) from movies where studio='marvel studios');

select m.title,m.imdb_rating,(f.revenue-f.budget)*100/f.budget as ptc_profit
from movies m join financials f on m.movie_id=f.movie_id
having ptc_profit>=500 and imdb_rating<(select avg(imdb_rating)from movies );

-- common table expression CTE
with actor_age (actor_name,age)as (select name , year(curdate())-birth_year from actors)
select actor_name,age from actor_age where age>70 and age<85;
-- movies that produced 500% profit and their rating was less then avg rating from all movies
with per_profit as (
	select m.title,m.imdb_rating,(f.revenue-f.budget)*100/f.budget as ptc_profit
    from movies m join financials f on m.movie_id=f.movie_id
)select title, imdb_rating,ptc_profit from per_profit
where ptc_profit>=500 and imdb_rating<(select avg(imdb_rating) from per_profit );

with hollywood as (select m.title,m.industry,m.release_year,f.profit
 from movies m join financials f on m.movie_id=f.movie_id )
select title,industry,release_year,profit from hollywood where industry='hollywood' and profit>500;

with movie_profit as (
    select m.title,
           f.revenue,
           f.budget,
           f.revenue - f.budget AS profit
    from movies m
    join financials f on m.movie_id = f.movie_id
)
select*from movie_profit;

WITH movie_profit AS (
    SELECT m.title,
           m.imdb_rating,
           (f.revenue - f.budget) * 100 / f.budget AS profit_percentage
    FROM movies m
    JOIN financials f
        ON m.movie_id = f.movie_id
)
SELECT *FROM movie_profit where profit_percentage > 500
  and imdb_rating < (
      select avg(imdb_rating) from movie_profit
  );
  
WITH studio_rating AS (
    SELECT studio,
           AVG(imdb_rating) AS avg_rating
    from movies
    group by studio
)
select *from studio_rating where avg_rating > (
    select avg_rating from studio_rating
    where studio = 'Marvel Studios'
);