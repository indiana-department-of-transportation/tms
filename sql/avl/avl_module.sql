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

CREATE TABLE IF NOT EXISTS avl.vehicle_type(
	id SERIAL PRIMARY KEY,
	vehicle_type VARCHAR(128) NOT NULL
);
ALTER TABLE avl.vehicle_type OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS avl.vehicle(
	id SERIAL PRIMARY KEY,
	region_id INTEGER NOT NULL REFERENCES avl.region(id),
	vehicle_type_id INTEGER NOT NULL REFERENCES avl.vehicle_type(id),
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
	"Region Name" TEXT
) RETURNS BOOLEAN AS $$
INSERT INTO avl.region(
	region
) VALUES (
	$1
) RETURNING true;
$$ language sql STRICT;

CREATE OR REPLACE FUNCTION avl.add_vehicle_type(
	"Vehicle Type" TEXT
) RETURNS BOOLEAN AS $$
INSERT INTO avl.vehicle_type(
	vehicle_type
) VALUES (
	$1
) RETURNING TRUE;
$$ language sql STRICT;

CREATE OR REPLACE FUNCTION avl.add_vehicle(
	"Region Name" TEXT,
	"Vehicle Type" TEXT,
	"Vehicle Identifier" TEXT,
	"License Plate" TEXT,
	"Publish Vehicle" Bool
) RETURNS BOOLEAN AS $$
INSERT INTO avl.vehicle(
	region_id,
	vehicle_type_id,
	vehicle_identifier,
	license_plate,
	publish_vehicle
) VALUES (
	(SELECT id from avl.region WHERE region = $1),
	(SELECT id from avl.vehicle_type WHERE vehicle_type = $2),
	$3,
	$4,
	$5
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

CREATE OR REPLACE FUNCTION avl.get_published_vehicles() RETURNS TABLE(
vehicle_identifier VARCHAR(128),
license_plate VARCHAR(128),
region VARCHAR(128),
vehicle_type VARCHAR(128)
) AS $$ SELECT
vehicle.vehicle_identifier,
vehicle.license_plate,
region.region,
vehicle_type.vehicle_type
FROM
avl.vehicle
INNER JOIN avl.region ON vehicle.region_id = region.id
INNER JOIN avl.vehicle_type ON vehicle.vehicle_type_id = vehicle_type.id
WHERE
vehicle.publish_vehicle = TRUE;
$$ LANGUAGE SQL STRICT;

-- Per vehicle functions
CREATE OR REPLACE FUNCTION avl.get_recent_gps_by_vehicle_identifier(
	"Vehicle Identifier" TEXT
) RETURNS TABLE (
	"longitude" FLOAT8,
	"latitude" FLOAT8,
	"timestamp" Timestamp,
	"speed" FLOAT8,
	"heading" FLOAT8,
	"gps_uality" FLOAT8,
	"satellites" INTEGER,
	"altitude" FLOAT8
) AS $$ SELECT
	ST_X(gps_record.location_geometry) AS longitude,
	ST_Y(gps_record.location_geometry) AS latitude,
	gps_record.timestamp,
	gps_record.speed,
	gps_record.heading,
	gps_record.gps_quality,
	gps_record.satellites,
	gps_record.altitude
FROM
	avl.gps_record
WHERE
	vehicle_identifier_id = (
		SELECT
			id
		FROM
			avl.vehicle
		WHERE
			vehicle_identifier = $1
		)
ORDER BY timestamp DESC LIMIT 1;
$$ LANGUAGE SQL STRICT;

CREATE OR REPLACE FUNCTION avl.get_recent_x_gps_by_vehicle_identifier(
	"Vehicle Identifier" TEXT,
	"Number of records" INTEGER
) RETURNS TABLE (
	"longitude" FLOAT8,
	"latitude" FLOAT8,
	"timestamp" Timestamp,
	"speed" FLOAT8,
	"heading" FLOAT8,
	"gps_quality" FLOAT8,
	"satellites" INTEGER,
	"altitude" FLOAT8
) AS $$ SELECT
	ST_X(gps_record.location_geometry) AS longitude,
	ST_Y(gps_record.location_geometry) AS latitude,
	gps_record.timestamp,
	gps_record.speed,
	gps_record.heading,
	gps_record.gps_quality,
	gps_record.satellites,
	gps_record.altitude
FROM
	avl.gps_record
WHERE
	vehicle_identifier_id = (
		SELECT
			id
		FROM
			avl.vehicle
		WHERE
			vehicle_identifier = $1
		)
ORDER BY timestamp DESC LIMIT $2;
$$ LANGUAGE SQL STRICT;

CREATE OR REPLACE FUNCTION avl.get_records_in_period_by_vehicle_identifier(
	"Vehicle Identifier" TEXT,
	"Begin Time" TIMESTAMP,
	"End Time"  TIMESTAMP
) RETURNS TABLE (
	"longitude" FLOAT8,
	"latitude" FLOAT8,
	"timestamp" Timestamp,
	"speed" FLOAT8,
	"heading" FLOAT8,
	"gps_quality" FLOAT8,
	"satellites" INTEGER,
	"altitude" FLOAT8
) AS $$ SELECT
	ST_X(gps_record.location_geometry) AS longitude,
	ST_Y(gps_record.location_geometry) AS latitude,
	timestamp,
	speed,
	heading,
	gps_quality,
	satellites,
	altitude
FROM
	avl.gps_record
WHERE
	timestamp >= $2 AND timestamp <= $3
	AND vehicle_identifier_id = (
		SELECT
			id
		FROM
			avl.vehicle
		WHERE
		 vehicle_identifier = $1)
ORDER BY timestamp ASC;
$$ LANGUAGE SQL STRICT;

-- All vehicle functions
CREATE OR REPLACE FUNCTION avl.get_recent_gps_active_vehicles() RETURNS TABLE (
	"vehicle_identifier" TEXT,
	"longitude" FLOAT8,
	"latitude" FLOAT8,
	"timestamp" Timestamp,
	"speed" FLOAT8,
	"heading" FLOAT8,
	"gps_quality" FLOAT8,
	"satellites" INTEGER,
	"altitude" FLOAT8
) AS $$ SELECT DISTINCT ON (vehicle_identifier_id)
	vehicle.vehicle_identifier,
	ST_X(gps_record.location_geometry) AS longitude,
	ST_Y(gps_record.location_geometry) AS latitude,
	gps_record.timestamp,
	gps_record.speed,
	gps_record.heading,
	gps_record.gps_quality,
	gps_record.satellites,
	gps_record.altitude
FROM
	avl.gps_record
	INNER JOIN avl.vehicle ON gps_record.vehicle_identifier_id = vehicle.id
WHERE
	vehicle_identifier_id IN (
		SELECT
			id
		FROM
			avl.vehicle
		WHERE
			publish_vehicle = TRUE
		)
ORDER BY vehicle_identifier_id,timestamp DESC;
$$ LANGUAGE SQL STRICT;

-- Speed Functions
CREATE OR REPLACE FUNCTION avl.get_records_above_speed(
	"Speed" INTEGER
) RETURNS TABLE (
	"vehicle_identifier" TEXT,
	"longitude" FLOAT8,
	"latitude" FLOAT8,
	"timestamp" Timestamp,
	"speed" FLOAT8,
	"heading" FLOAT8,
	"gps_quality" FLOAT8,
	"satellites" INTEGER,
	"altitude" FLOAT8
) AS $$ SELECT
	vehicle.vehicle_identifier,
	ST_X(gps_record.location_geometry) AS longitude,
	ST_Y(gps_record.location_geometry) AS latitude,
	timestamp,
	speed,
	heading,
	gps_quality,
	satellites,
	altitude
FROM
	avl.gps_record
	INNER JOIN avl.vehicle ON gps_record.vehicle_identifier_id = vehicle.id
WHERE
	speed >= $1
ORDER BY speed DESC;
$$ LANGUAGE SQL STRICT;

CREATE OR REPLACE FUNCTION avl.get_records_above_speed_in_period(
	"Speed" INTEGER,
	"Begin Time" TIMESTAMP,
	"End Time"  TIMESTAMP
) RETURNS TABLE (
	"vehicle_identifier" TEXT,
	"longitude" FLOAT8,
	"latitude" FLOAT8,
	"timestamp" Timestamp,
	"speed" FLOAT8,
	"heading" FLOAT8,
	"gps_quality" FLOAT8,
	"satellites" INTEGER,
	"altitude" FLOAT8
) AS $$ SELECT
	vehicle.vehicle_identifier,
	ST_X(gps_record.location_geometry) AS longitude,
	ST_Y(gps_record.location_geometry) AS latitude,
	timestamp,
	speed,
	heading,
	gps_quality,
	satellites,
	altitude
FROM
	avl.gps_record
	INNER JOIN avl.vehicle ON gps_record.vehicle_identifier_id = vehicle.id
WHERE
	timestamp >= $2 AND timestamp <= $3
	AND speed >= $1
ORDER BY speed DESC;
$$ LANGUAGE SQL STRICT;

CREATE OR REPLACE FUNCTION avl.get_records_above_speed_by_vehicle_identifier(
	"Vehicle Identifier" TEXT,
	"Speed" INTEGER
) RETURNS TABLE (
	"longitude" FLOAT8,
	"latitude" FLOAT8,
	"timestamp" Timestamp,
	"speed" FLOAT8,
	"heading" FLOAT8,
	"gps_quality" FLOAT8,
	"satellites" INTEGER,
	"altitude" FLOAT8
) AS $$ SELECT
	ST_X(gps_record.location_geometry) AS longitude,
	ST_Y(gps_record.location_geometry) AS latitude,
	timestamp,
	speed,
	heading,
	gps_quality,
	satellites,
	altitude
FROM
	avl.gps_record
WHERE
	vehicle_identifier_id = (
		SELECT
			id
		FROM
			avl.vehicle
		WHERE
			vehicle_identifier = $1
		) AND speed >= $2
ORDER BY speed DESC;
$$ LANGUAGE SQL STRICT;

CREATE OR REPLACE FUNCTION avl.get_records_above_speed_in_period_by_vehicle_identifier(
	"Vehicle Identifier" TEXT,
	"Speed" INTEGER,
	"Begin Time" TIMESTAMP,
	"End Time"  TIMESTAMP
) RETURNS TABLE (
	"longitude" FLOAT8,
	"latitude" FLOAT8,
	"timestamp" Timestamp,
	"speed" FLOAT8,
	"heading" FLOAT8,
	"gps_quality" FLOAT8,
	"satellites" INTEGER,
	"altitude" FLOAT8
) AS $$ SELECT
	ST_X(gps_record.location_geometry) AS longitude,
	ST_Y(gps_record.location_geometry) AS latitude,
	timestamp,
	speed,
	heading,
	gps_quality,
	satellites,
	altitude
FROM
	avl.gps_record
WHERE
	vehicle_identifier_id = (
		SELECT
			id
		FROM
			avl.vehicle
		WHERE
			vehicle_identifier = $1
		) AND speed >= $2
	AND timestamp >= $3 AND timestamp <= $4
ORDER BY speed DESC;
$$ LANGUAGE SQL STRICT;