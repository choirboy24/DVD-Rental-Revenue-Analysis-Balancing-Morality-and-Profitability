select count(inventory.film_id), film.title
from inventory
inner join film
on inventory.film_id = film.film_id
group by film.title;