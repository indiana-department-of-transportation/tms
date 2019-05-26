--- Vehicle
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
	speed INTEGER NOT NULL,
	heading INTEGER NOT NULL,
	gps_quality INTEGER NOT NULL,
	satellites INTEGER NOT NULL,
	altitude INTEGER NOT NULL,
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