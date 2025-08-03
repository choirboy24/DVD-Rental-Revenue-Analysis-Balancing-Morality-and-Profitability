CREATE OR REPLACE FUNCTION public.restricted_update_yes()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE rental_detail
  SET restricted_film = 'Yes' WHERE "Film Rating" = 'R' or "Film Rating" = 'NC-17';
END;
$$;