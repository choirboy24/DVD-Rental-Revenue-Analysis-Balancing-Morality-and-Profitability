select film.title, sum(payment.amount)
from film
left join inventory
on film.film_id = inventory.film_id
left join rental
on inventory.inventory_id = rental.inventory_id
left join payment
on rental.rental_id = payment.rental_id
group by film.title
limit 1000;