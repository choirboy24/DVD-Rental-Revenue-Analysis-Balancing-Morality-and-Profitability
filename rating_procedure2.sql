create procedure public.restricted_film2()
language sql
as $procedure$
	update rental_detail
	set restricted_film = 'No'
	where rating = 'G' or rating = 'PG' or rating = 'PG-13';
$procedure$;