create table rental_detail
as
select film.title as "Film Title", film.rating as "Film Rating", film.restricted_film, category.name as "Genre", sum(payment.amount) as "Rental Amount",
inventory.inventory_id, rental.rental_id
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
group by film.title, film.rating, category.name, film.rental_rate, inventory.inventory_id, rental.rental_id, film.restricted_film
order by film.title, film.rating, category.name;