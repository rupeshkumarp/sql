-- joins 
select m.movie_id, currency,title,budget,revenue
from movies m
join financials f
using (movie_id);-- inner join

select f.movie_id,title ,currency,budget,revenue
from movies m
right join financials f
using (movie_id);-- right join

select m.movie_id,title, currency,budget,revenue
from movies m
left join financials f
using (movie_id);-- left join

select f.movie_id, currency,title,budget,revenue
from movies m
left join financials f
using (movie_id) 
union
select m.movie_id, currency,title,budget,revenue
from movies m
right join financials f
using (movie_id);-- whole join


select* from movies 
left join languages 
using (language_id) where name='kannada';

select l.name ,count(language_id) as count_realese_lang from movies m
left join languages l
using (language_id)
group by l.name order by count_realese_lang desc;-- count of movies per language
