CREATE OR REPLACE FUNCTION public.update_rating()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE rental_detail
  SET "Film Rating" = 'G' WHERE ("Film Rating" = 'NC-17' or "Film Rating" = 'R') and ("Genre" = 'Family' or "Genre" = 'Children');
END;
$$;