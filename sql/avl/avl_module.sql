-- avl_module.sql
-- @author bfischer
-- @copyright INDOT, 2019
-- @license MIT
-- Sets up the required database adn fuctions for the automated vehicle location schema 
\connect tms

CREATE SCHEMA IF NOT EXISTS avl;
ALTER SCHEMA avl owner TO tms_app;

CREATE TABLE IF NOT EXISTS avl.region(
	id SERIAL PRIMARY KEY,
	region VARCHAR(128) NOT NULL
);
ALTER TABLE avl.region OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS avl.vehicle(
	id SERIAL PRIMARY KEY,
	region_id INTEGER NOT NULL REFERENCES avl.region(id),
	vehicle_identifier VARCHAR(128) NOT NULL,
	license_plate VARCHAR(10) NOT NULL,
	publish_vehicle BOOLEAN DEFAULT FALSE
);
ALTER TABLE avl.vehicle OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS avl.gps_record(
	id SERIAL PRIMARY KEY,
	vehicle_identifier_id INTEGER NOT NULL REFERENCES avl.vehicle(id),
	location_geometry public.geometry,
	"timestamp" TIMESTAMP NOT NULL,
	speed DOUBLE PRECISION NOT NULL,
	heading DOUBLE PRECISION NULL,
	gps_quality DOUBLE PRECISION NOT NULL,
	satellites INTEGER NOT NULL,
	altitude DOUBLE PRECISION NOT NULL,
	source_ip INET
	);
ALTER TABLE avl.gps_record OWNER TO tms_app;

CREATE OR REPLACE FUNCTION avl.add_region(
	"Region Name" TEXT,
) RETURNS BOOLEAN AS $$
INSERT INTO avl.region(
	region
) VALUES (
	$1
) RETURNING true;
$$ langauge sql STRICT;

CREATE OR REPLACE FUNCTION avl.add_vehicle(
	"Region Name" TEXT,
	"Vehicle Identifier" TEXT,
	"License Plate" TEXT,
	"Publish Vehicle" Bool
) RETURNS BOOLEAN AS $$
INSERT INTO avl.vehicle(
	region_id,
	vehicle_identifier,
	license_plate,
	publish_vehicle
) VALUES (
	(SELECT id from avl.region WHERE region = $1),
	$2,
	$3,
	$4
) RETURNING true;
$$ language sql STRICT;

CREATE OR REPLACE FUNCTION avl.add_gps_record(
	"Vehicle Identifer" TEXT,
	"Longitude" DOUBLE PRECISION,
	"Latitude" DOUBLE PRECISION,
	"Timestamp" TIMESTAMP,
	"Speed" DOUBLE PRECISION,
	"Heading" DOUBLE PRECISION,
	"GPS Quality" DOUBLE PRECISION,
	"Satellites" INTEGER,
	"Altitude" DOUBLE PRECISION,
	"Source IP" INET
) RETURNS BOOLEAN AS $$
INSERT INTO avl.gps_record(
	vehicle_identifier_id,
	location_geometry,
	timestamp,
	speed,
	heading,gps_quality,
	satellites,
	altitude,
	source_ip
) VALUES (
	(SELECT id from avl.vehicle WHERE vehicle_identifier = $1),
	(SELECT ST_SetSRID(ST_Makepoint($2, $3), 4326)),
	$4,
	$5,
	$6,
	$7,
	$8,
	$9,
	$10
) RETURNING true;
$$ language sql STRICT;