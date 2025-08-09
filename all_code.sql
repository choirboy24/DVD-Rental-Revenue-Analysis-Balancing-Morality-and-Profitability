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

-- Create Indices --

create index idx_payment_rental_id on payment(rental_id);
create index idx_rental_inventory_id on rental(inventory_id);
create index idx_inventory_film_id on inventory(film_id);
create index idx_film_category_film_id on film_category(film_id);
create index idx_film_category_category_id on film_category(category_id);

-- Explain (Analyze) --

set enable_seqscan = off;

explain (analyze, buffers, timing) select film.title as "Film Title", film.rating as "Film Rating", film.restricted_film, category.name as "Genre", sum(payment.amount) as "Rental Amount"
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
group by film.title, film.rating, category.name, film.restricted_film
order by film.title, film.rating, category.name;

-- EXPLAIN ANALYZE before and after indexing: --

-- Before indexing: --

QUERY PLAN
GroupAggregate  (cost=2302.26..2813.12 rows=14596 width=149) (actual time=156.599..175.833 rows=14592 loops=1)
  Group Key: film.title, film.rating, category.name, film.rental_rate, inventory.inventory_id, rental.rental_id, film.restricted_film
  ->  Sort  (cost=2302.26..2338.75 rows=14596 width=123) (actual time=156.582..159.287 rows=14596 loops=1)
        Sort Key: film.title, film.rating, category.name, film.rental_rate, inventory.inventory_id, rental.rental_id, film.restricted_film
        Sort Method: quicksort  Memory: 1385kB
        ->  Hash Join  (cost=761.37..1292.70 rows=14596 width=123) (actual time=12.069..38.563 rows=14596 loops=1)
              Hash Cond: (inventory.film_id = film.film_id)
              ->  Hash Join  (cost=639.06..969.70 rows=14596 width=16) (actual time=9.178..27.954 rows=14596 loops=1)
                    Hash Cond: (rental.inventory_id = inventory.inventory_id)
                    ->  Hash Join  (cost=510.99..803.28 rows=14596 width=14) (actual time=7.110..18.748 rows=14596 loops=1)
                          Hash Cond: (payment.rental_id = rental.rental_id)
                          ->  Seq Scan on payment  (cost=0.00..253.96 rows=14596 width=10) (actual time=0.051..2.232 rows=14596 loops=1)
                          ->  Hash  (cost=310.44..310.44 rows=16044 width=8) (actual time=6.918..6.918 rows=16044 loops=1)
                                Buckets: 16384  Batches: 1  Memory Usage: 755kB
                                ->  Seq Scan on rental  (cost=0.00..310.44 rows=16044 width=8) (actual time=0.025..2.805 rows=16044 loops=1)
                    ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=2.021..2.021 rows=4581 loops=1)
                          Buckets: 8192  Batches: 1  Memory Usage: 234kB
                          ->  Seq Scan on inventory  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.035..0.885 rows=4581 loops=1)
              ->  Hash  (cost=109.81..109.81 rows=1000 width=115) (actual time=2.870..2.874 rows=1000 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 81kB
                    ->  Hash Join  (cost=87.86..109.81 rows=1000 width=115) (actual time=1.124..2.409 rows=1000 loops=1)
                          Hash Cond: (film_category.category_id = category.category_id)
                          ->  Hash Join  (cost=86.50..105.14 rows=1000 width=49) (actual time=1.012..1.900 rows=1000 loops=1)
                                Hash Cond: (film_category.film_id = film.film_id)
                                ->  Seq Scan on film_category  (cost=0.00..16.00 rows=1000 width=4) (actual time=0.024..0.262 rows=1000 loops=1)
                                ->  Hash  (cost=74.00..74.00 rows=1000 width=45) (actual time=0.966..0.967 rows=1000 loops=1)
                                      Buckets: 1024  Batches: 1  Memory Usage: 72kB
                                      ->  Seq Scan on film  (cost=0.00..74.00 rows=1000 width=45) (actual time=0.021..0.563 rows=1000 loops=1)
                          ->  Hash  (cost=1.16..1.16 rows=16 width=72) (actual time=0.092..0.093 rows=16 loops=1)
                                Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                ->  Seq Scan on category  (cost=0.00..1.16 rows=16 width=72) (actual time=0.073..0.077 rows=16 loops=1)
Planning Time: 4.624 ms
Execution Time: 177.646 ms

-- After indexing: --

QUERY PLAN
GroupAggregate  (cost=2302.26..2703.65 rows=14596 width=135) (actual time=110.746..118.597 rows=958 loops=1)
  Group Key: film.title, film.rating, category.name, film.restricted_film
  ->  Sort  (cost=2302.26..2338.75 rows=14596 width=109) (actual time=110.709..112.475 rows=14596 loops=1)
        Sort Key: film.title, film.rating, category.name, film.restricted_film
        Sort Method: quicksort  Memory: 1164kB
        ->  Hash Join  (cost=761.37..1292.70 rows=14596 width=109) (actual time=10.979..40.625 rows=14596 loops=1)
              Hash Cond: (inventory.film_id = film.film_id)
              ->  Hash Join  (cost=639.06..969.70 rows=14596 width=8) (actual time=7.870..29.205 rows=14596 loops=1)
                    Hash Cond: (rental.inventory_id = inventory.inventory_id)
                    ->  Hash Join  (cost=510.99..803.28 rows=14596 width=10) (actual time=5.644..18.717 rows=14596 loops=1)
                          Hash Cond: (payment.rental_id = rental.rental_id)
                          ->  Seq Scan on payment  (cost=0.00..253.96 rows=14596 width=10) (actual time=0.048..2.356 rows=14596 loops=1)
                          ->  Hash  (cost=310.44..310.44 rows=16044 width=8) (actual time=5.404..5.405 rows=16044 loops=1)
                                Buckets: 16384  Batches: 1  Memory Usage: 755kB
                                ->  Seq Scan on rental  (cost=0.00..310.44 rows=16044 width=8) (actual time=0.040..2.339 rows=16044 loops=1)
                    ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=2.129..2.130 rows=4581 loops=1)
                          Buckets: 8192  Batches: 1  Memory Usage: 234kB
                          ->  Seq Scan on inventory  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.055..0.891 rows=4581 loops=1)
              ->  Hash  (cost=109.81..109.81 rows=1000 width=109) (actual time=3.088..3.091 rows=1000 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 73kB
                    ->  Hash Join  (cost=87.86..109.81 rows=1000 width=109) (actual time=1.243..2.479 rows=1000 loops=1)
                          Hash Cond: (film_category.category_id = category.category_id)
                          ->  Hash Join  (cost=86.50..105.14 rows=1000 width=43) (actual time=1.128..1.897 rows=1000 loops=1)
                                Hash Cond: (film_category.film_id = film.film_id)
                                ->  Seq Scan on film_category  (cost=0.00..16.00 rows=1000 width=4) (actual time=0.021..0.187 rows=1000 loops=1)
                                ->  Hash  (cost=74.00..74.00 rows=1000 width=39) (actual time=1.080..1.081 rows=1000 loops=1)
                                      Buckets: 1024  Batches: 1  Memory Usage: 64kB
                                      ->  Seq Scan on film  (cost=0.00..74.00 rows=1000 width=39) (actual time=0.018..0.673 rows=1000 loops=1)
                          ->  Hash  (cost=1.16..1.16 rows=16 width=72) (actual time=0.083..0.084 rows=16 loops=1)
                                Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                ->  Seq Scan on category  (cost=0.00..1.16 rows=16 width=72) (actual time=0.060..0.065 rows=16 loops=1)
Planning Time: 2.121 ms
Execution Time: 119.386 ms

-- ROW_NUMBER() as Window Function.  Top film by revenue by genre --

with genre_ranked_films as (
	select 
		film.title as "Film Title", 
		film.rating as "Film Rating",
		category.name as "Film Genre", 
		sum(payment.amount) as "Rental Amount",
		row_number() over (
			partition by category.name 
			order by sum(payment.amount) desc
		) as row_num
	from payment 
	join rental using (rental_id) 
	join inventory using (inventory_id) 
	join film using (film_id) 
	join film_category using (film_id) 
	join category using (category_id)
	group by film.title, film.rating, category.name
)
select "Film Title", "Film Rating", "Film Genre", "Rental Amount"
from genre_ranked_films
where row_num = 1
order by "Film Rating";

-- ROW_NUMBER() as Window Function.  Top film by count by genre --

with genre_count as (
	select 
		film.title as "Film Title", 
		film.rating as "Film Rating",
		category.name as "Film Genre", 
		count(rental.rental_id) as "Rental Count",
		row_number() over (
			partition by category.name 
			order by sum(payment.amount) desc
		) as row_num
	from payment 
	join rental using (rental_id) 
	join inventory using (inventory_id) 
	join film using (film_id) 
	join film_category using (film_id) 
	join category using (category_id)
	group by film.title, film.rating, category.name
)
select "Film Title", "Film Rating", "Film Genre", "Rental Count"
from genre_ranked_films_count
where row_num = 1
order by "Film Rating";

-- Total count of films by genre and total revenue by genre --

select 
	category.name as "Film Genre",
	count(rental.rental_id) as "Total Rentals",
	sum(payment.amount) as "Total Revenue"
from payment 
join rental using (rental_id) 
join inventory using (inventory_id) 
join film using (film_id) 
join film_category using (film_id) 
join category using (category_id)
group by category.name
order by "Total Revenue" desc;