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