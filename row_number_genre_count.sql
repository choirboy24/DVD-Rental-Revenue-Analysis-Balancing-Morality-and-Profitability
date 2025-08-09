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