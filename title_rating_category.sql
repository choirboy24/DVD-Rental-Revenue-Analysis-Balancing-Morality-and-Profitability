select film.title, film.rating, category.name, film.rental_rate
from film
inner join film_category
on film.film_id = film_category.film_id
inner join category
on film_category.category_id = category.category_id
group by film.title, film.rating, category.name, film.rental_rate
order by film.title, film.rating