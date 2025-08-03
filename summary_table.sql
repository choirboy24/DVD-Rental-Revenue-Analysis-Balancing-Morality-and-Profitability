create table rental_summary
as
select "Film Rating", sum("Rental Amount") as "Rental_Sales", count(rental_id) as "Total Rentals",
count(inventory_id) as "Total Inventory"
from rental_detail
group by "Film Rating"
order by "Film Rating";