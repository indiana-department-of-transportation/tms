-- create_tms_user.sql
-- @author bfischer
-- @copyright INDOT, 2019
-- @license MIT
-- Create the tms user for the TMS application


DO
$do$
BEGIN
  IF NOT EXISTS (
    SELECT
    FROM pg_catalog.pg_roles
    WHERE rolename = 'tms_app') THEN
    CREATE ROLE tms_app LOGIN PASSWORD 'abadpassword';
  END IF;
END
$do$;