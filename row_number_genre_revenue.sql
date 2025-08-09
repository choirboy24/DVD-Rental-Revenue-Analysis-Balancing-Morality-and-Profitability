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