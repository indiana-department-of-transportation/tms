-- Used to return a table of longs and lats from a linestring in order
CREATE OR REPLACE FUNCTION public.get_points(
  "Geometry" geometry
) RETURNS TABLE (
  "longitude" FLOAT8,
  "latitude" FLOAT8
) AS $$ SELECT
  ST_X(ST_AsText(
  ST_pointN(
    column1,
    generate_series(1, ST_NPoints(column1))
  ))) AS longitude,
  ST_Y(ST_AsText(
  ST_pointN(
    column1,
    generate_series(1, ST_NPoints(column1))
  ))) AS latitude
FROM (VALUES ($1) ) AS foo;
$$ LANGUAGE SQL STRICT;
