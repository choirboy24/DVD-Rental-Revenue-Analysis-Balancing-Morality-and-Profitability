CREATE OR REPLACE FUNCTION public.restricted_update_no()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE rental_detail
  SET restricted_film = 'No' WHERE "Film Rating" = 'G' or "Film Rating" = 'PG' or "Film Rating" = 'PG-13';
END;
$$;