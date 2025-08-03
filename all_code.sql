-- Begin Section C:
--Create detailed table:

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

-- Create summary table:

create table rental_summary
as
select "Film Rating", sum("Rental Amount") as "Rental_Sales", count(rental_id) as "Total Rentals",
count(inventory_id) as "Total Inventory"
from rental_detail
group by "Film Rating"
order by "Film Rating";

-- Begin Section B:

CREATE OR REPLACE FUNCTION public.restricted_update_yes()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE rental_detail
  SET restricted_film = 'Yes' WHERE "Film Rating" = 'R' or "Film Rating" = 'NC-17';
END;
$$;

select restricted_update_yes();

select * from rental_detail where restricted_film = 'Yes';

CREATE OR REPLACE FUNCTION public.restricted_update_no()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE rental_detail
  SET restricted_film = 'No' WHERE "Film Rating" = 'G' or "Film Rating" = 'PG' or "Film Rating" = 'PG-13';
END;
$$;

select restricted_update_no();

CREATE OR REPLACE FUNCTION public.update_rating()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE rental_detail
  SET "Film Rating" = 'G' WHERE ("Film Rating" = 'NC-17' or "Film Rating" = 'R') and ("Genre" = 'Family' or "Genre" = 'Children');
END;
$$;

select update_rating();

select * from rental_detail;

-- Begin Section D:

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

-- Begin Section E:

create or replace function update_summary()
  returns trigger
  language plpgsql
as $$
begin
  truncate table rental_summary;
  
  insert into rental_summary
  select "Film Rating", sum("Rental Amount") as "Rental Sales", count(rental_id) as "Total Rentals",
  count(inventory_id) as "Total Inventory"
  from rental_detail
  group by "Film Rating"
  order by "Film Rating";
  
end;
$$

create trigger rental_trigger
after insert on rental_detail
for each row
execute procedure update_summary();

-- Begin Section F (Refresh both tables):

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