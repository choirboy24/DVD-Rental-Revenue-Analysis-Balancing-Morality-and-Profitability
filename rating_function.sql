create function restricted_film()
returns void
as
begin
	update rental_detail
	set restricted_film = 'Yes'
	where rating = 'R' or rating = 'NC-17'
end;