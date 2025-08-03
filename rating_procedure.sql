create procedure public.restricted_film()
language sql
as $procedure$
	update rental_detail
	set restricted_film = 'Yes'
	where rating = 'R' or rating = 'NC-17';
$procedure$;