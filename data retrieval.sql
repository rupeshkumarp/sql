use r_db;
select*from movies;
select*from movies where language_id=3;
select * from movies where industry='bollywood';
select count(distinct release_year)  from movies;
select *from movies where title like '%avenger%';
select*from movies where title='the godfather';
select distinct(studio)from movies where industry='bollywood' and imdb_rating<5;
select *from movies where release_year=2022 or release_year=2019;
select *from movies where imdb_rating between 5 and 8.5;

select*from movies order by release_year desc;
select*from movies where release_year>2020 and imdb_rating>8;
select*from movies where studio like '%marvel studio%'or studio like'%hombale%';
select*from movies where title like '%thor%' order by release_year;

select industry,count(industry) as ct,round(avg(imdb_rating),2)as avg_rating
 from movies group by industry order by avg_rating desc;
 
select*from movies where release_year between 2015 and 2022;
select min(release_year),max(release_year) from movies;
select release_year,count(release_year) as ct from  movies group by release_year order by ct desc;
 
 
 select* ,year(curdate())-birth_year as age from actors;
 select * ,revenue-budget as profit from financials;
 ALTER TABLE financials
ADD COLUMN profit DECIMAL(15,2);
 UPDATE financials
SET profit = revenue - budget;
 select*, if (currency='USD',revenue*95,revenue) as revenue_inr from financials;
 
 select distinct unit from financials;
 
 select *,case
 when unit='Thousands' then revenue/1000
 when unit='Billions'then revenue*1000
 when unit='Millions' then revenue 
 end as revenue_mle
 from financials;
 
 SELECT *,
       ROUND((profit / revenue) * 100, 2) AS profit_percentage
FROM financials where ((profit / revenue) * 100) between 50 and 100;

SELECT m.title,f.revenue,f.budget,f.revenue - f.budget AS profit
FROM movies m
JOIN financials f
    ON m.movie_id = f.movie_id
ORDER BY profit DESC
LIMIT 5;

SELECT a.name,COUNT(*) AS movie_count
FROM actors a
JOIN movie_actor ma
    ON a.actor_id = ma.actor_id
GROUP BY a.actor_id, a.name
HAVING COUNT(*) = (
    SELECT MAX(movie_count)
    FROM (
        SELECT COUNT(*) AS movie_count
        FROM movie_actor
        GROUP BY actor_id
    ) AS actor_counts
);

SELECT m1.studio,
       m1.title,
       m1.imdb_rating
FROM movies m1
WHERE m1.imdb_rating = (
    select MAX(m2.imdb_rating)
    from movies m2
    where m2.studio = m1.studio
);


insert into movies values(141,'Bahuballi','Bollywood',2030,9.0,'Arka Media works',2);
 -- when we have enough data for the row
insert into movies (movie_id,title,industry,language_id)
values (142,'googly','Bollywood',3);

insert into movies values
(143,'bahuballi 3','bollywood',2030,8.5,'raj studio',2),
(144,'Toxic','bollywood',2026,8.8,'KVN production',3);


