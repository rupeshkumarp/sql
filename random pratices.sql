select *from movies where imdb_rating>8 and release_year>2015;
select *from movies where imdb_rating>8 and release_year between  2015 and 2018;
select*from actors where birth_year between 1970 and 1985;
select *from movies where studio in('Marvel Studios', 'Warner Bros. Pictures', 'Paramount Pictures');
select *from financials where currency='inr' and unit='billions' and profit between 1 and 5;


select *from movies where industry='hollywood' order by imdb_rating desc;
select *,case 
when unit='thousands' then round(revenue/1000,2)
when unit='billions' then round(revenue*1000,2)
when unit='millions' then round(revenue,2)
end as revenue_mle  from financials order by revenue_mle desc;


select industry,count(industry)from movies group by industry;
select round(avg(imdb_rating),2) as avg_r,language_id,group_concat(title separator' | ')
 from movies group by language_id having avg_r>8 order by avg_r;
select studio,count(studio)as count_s from movies group by studio having count_s>3;
SELECT
    FLOOR(birth_year / 10) * 10 AS decade,
    COUNT(*) AS actor_count
FROM actors
GROUP BY FLOOR(birth_year / 10) * 10
ORDER BY decade;
select m.industry, avg(f.budget) as avg_b from movies m
join financials f on m.movie_id=f.movie_id
where currency='USD' group by industry having avg_b>100;


select *, case
  when imdb_rating >= 8 then 'Blockbuster'
  when imdb_rating between 6 and 8 then 'Average'
  else 'Below Average'
end as movie_category
from movies;
select *,year(curdate())-birth_year as age,case
when birth_year <1950 then 'senior'
when birth_year between 1950 and 1985 then 'mid'
when birth_year>1985 then 'young'
end as actor_cetogary from actors;
select *,if(budget>200,'high budget','low budget') as budget_category from financials;

select count(*) as counts,group_concat(m.title separator ' | ') as titles,l.name from movies m
join languages l on m.language_id=l.language_id group by l.name;
select f.revenue,f.budget,f.currency,f.unit,m.title,(revenue-budget)as profit from movies m
left join financials f on m.movie_id=f.movie_id;
select group_concat(a.name separator ' | ') as actors,m.title from movies m
join movie_actor ma on m.movie_id=ma.movie_id
join actors a on ma.actor_id=a.actor_id group by m.movie_id;
SELECT
    a.actor_id,
    a.name
FROM actors a
LEFT JOIN movie_actor ma
    ON a.actor_id = ma.actor_id
WHERE ma.movie_id IS NULL;

select*from movies where imdb_rating> (select avg(imdb_rating)from movies);
select*from actors where birth_year=(select min(birth_year) from actors);
select*from financials f where f.movie_id not in(select m.movie_id from movies m where m.movie_id=f.movie_id);
SELECT
    m.movie_id,
    m.title
FROM movies m
WHERE NOT EXISTS (
    SELECT 1
    FROM financials f
    WHERE f.movie_id = m.movie_id
);
select studio from movies  where imdb_rating=(select max(imdb_rating) from movies);
select a.name ,m.title from movies m
join movie_actor ma on m.movie_id=ma.movie_id
join actors a on ma.actor_id=a.actor_id
where imdb_rating=(select max(imdb_rating) from movies m);
select *from movies where industry='bollywood' and imdb_rating>some
(select imdb_rating from movies);
SELECT
    title,
    imdb_rating
FROM movies
WHERE industry = 'bollywood'
AND imdb_rating > ALL (
    SELECT imdb_rating
    FROM movies
    WHERE industry = 'hollywood');
SELECT *
FROM movies
WHERE industry = 'bollywood'
AND imdb_rating >(
    SELECT max(imdb_rating)
    FROM movies);


SELECT
    m1.title,
    m1.industry,
    m1.imdb_rating,
    CASE WHEN m1.imdb_rating >
            (
                SELECT AVG(m2.imdb_rating)
                FROM movies m2
                WHERE m2.industry = m1.industry
            )
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS rating_status
FROM movies m1;

select a.name ,group_concat(m.title separator ' | ')as titles from movies m
join movie_actor ma on m.movie_id=ma.movie_id
join actors a on ma.actor_id=a.actor_id 
 where (SELECT COUNT(*) FROM movie_actor ma WHERE ma.actor_id = a.actor_id) > 1 group by a.name;
select m.title,m.imdb_rating,l.name ,l.language_id from movies m
join languages l on m.language_id=l.language_id
where imdb_rating=(select max(imdb_rating) from movies m2 where m2.language_id = m.language_id);
SELECT
    m1.title,
    m1.studio,
    m1.imdb_rating
FROM movies m1
WHERE m1.imdb_rating >
(
    SELECT AVG(m2.imdb_rating)
    FROM movies m2
    WHERE m2.studio = m1.studio
);
