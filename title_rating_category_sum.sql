select film.title, film.rating, category.name, film.rental_rate, sum(payment.amount)
from payment
inner join rental
on payment.rental_id = rental.rental_id
inner join inventory
on rental.inventory_id = inventory.inventory_id
inner join film
on inventory.film_id = film.film_id
inner join film_category
on film.film_id = film_category.film_id
inner join category
on film_category.category_id = category.category_id
group by film.title, film.rating, category.name, film.rental_rate
order by film.title, film.rating, category.name;