select studio,round(avg(imdb_rating),2) avg_rating,count(*)movie_count 
from movies group by studio order by avg_rating desc;

select name,(birth_year-2026)as age from actors where
((select name from actors where (birth_year-2026)>70),(select name from actors where (birth_year-2026)<85));

select*from (
select name, (year(curdate())-birth_year)age from actors) as actors_age  where age>70 and age<85;
