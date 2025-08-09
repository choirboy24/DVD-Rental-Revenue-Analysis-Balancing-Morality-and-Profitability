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