CREATE PROCEDURE public.table_refresh()
LANGUAGE sql
AS $BODY$

TRUNCATE rental_detailed;
TRUNCATE rental_summary;
		
INSERT INTO rental_detail
SELECT film.title, film.rating, category.name, film.rental_rate, sum(payment.amount)
FROM payment
INNER JOIN rental
ON payment.rental_id = rental.rental_id
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film
ON inventory.film_id = film.film_id
INNER JOIN film_category
ON film.film_id = film_category.film_id
INNER JOIN category
ON film_category.category_id = category.category_id
GROUP BY film.title, film.rating, category.name, film.rental_rate
ORDER BY film.title, film.rating, category.name;

INSERT INTO rental_summary
select "Film Rating", sum("Rental Amount") as "Rental_Sales", count(rental_id) as "Total Rentals",
count(inventory_id) as "Total Inventory"
from rental_detail
group by "Film Rating"
order by "Film Rating";
$BODY$;