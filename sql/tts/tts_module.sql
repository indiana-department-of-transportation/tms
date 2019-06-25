-- avl_module.sql
-- @author bfischer
-- @copyright INDOT, 2019
-- @license MIT
-- Sets up the required database and fuctions for the Travel Time schema 
\connect tms

CREATE SCHEMA IF NOT EXISTS tts;
ALTER SCHEMA tts owner TO tms_app;

CREATE TABLE IF NOT EXISTS tts.sign(
	id SERIAL PRIMARY KEY,
	dms_device_id INTEGER NOT NULL REFERENCES dms.device(id)
);
ALTER TABLE tts.sign OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS tts.source(
	id SERIAL PRIMARY KEY,
	source VARCHAR(128) NOT NULL
);
ALTER TABLE tts.source OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS tts.route(
	id SERIAL PRIMARY KEY,
	tts_sign_id INTEGER NOT NULL REFERENCES tts.sign(id),
	tts_source_id INTEGER NOT NULL REFERENCES tts.source(id),
  route_geometry public.geometry,
  destination_friendly_name VARCHAR(128),
  base_minutes INTEGER,
  publish_route BOOLEAN DEFAULT FALSE
);
ALTER TABLE tts.route OWNER TO tms_app;

CREATE OR REPLACE FUNCTION tts.add_sign(
	"DMS Device ID" INTEGER
	) RETURNS BOOLEAN AS $$
INSERT INTO tts.sign(
	dms_device_id
) VALUES (
	$1
) RETURNING true;
$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_source(
	"Source" TEXT
) RETURNS BOOLEAN AS $$
INSERT INTO tts.source(
	source
) VALUES (
	$1
) RETURNING true;
$$ language sql STRICT;

-- Begin Overloaded Functions for creating routes
CREATE OR REPLACE FUNCTION tts.add_route(
	"Traveltime Sign ID" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" TEXT,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	tts_sign_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	publish_route,
	route_geometry
	) VALUES(
	$1,
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	(SELECT ST_SetSRID(
		ST_MakeLine(
			 ST_MakePoint($6, $7),
			 ST_MakePoint($8, $9)
			),4326)
		)
	) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"Traveltime Sign ID" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" TEXT,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Waypoint_1 Longitude" FLOAT8,
	"Waypoint_1 Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	tts_sign_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	publish_route,
	route_geometry
	) VALUES(
	$1,
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($6, $7),
			 ST_MakePoint($8, $9),
			 ST_MakePoint($10, $11)]
			),4326)
		)
	) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"Traveltime Sign ID" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" TEXT,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Waypoint_1 Longitude" FLOAT8,
	"Waypoint_1 Latitude" FLOAT8,
	"Waypoint_2 Longitude" FLOAT8,
	"Waypoint_2 Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	tts_sign_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	publish_route,
	route_geometry
	) VALUES(
	$1,
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($6, $7),
			 ST_MakePoint($8, $9),
			 ST_MakePoint($10, $11),
			 ST_MakePoint($12, $13)]
			),4326)
		)
	) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"Traveltime Sign ID" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" TEXT,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Waypoint_1 Longitude" FLOAT8,
	"Waypoint_1 Latitude" FLOAT8,
	"Waypoint_2 Longitude" FLOAT8,
	"Waypoint_2 Latitude" FLOAT8,
	"Waypoint_3 Longitude" FLOAT8,
	"Waypoint_3 Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	tts_sign_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	publish_route,
	route_geometry
	) VALUES(
	$1,
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($6, $7),
			 ST_MakePoint($8, $9),
			 ST_MakePoint($10, $11),
			 ST_MakePoint($12, $13),
			 ST_MakePoint($14, $15)]
			),4326)
		)
	) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"Traveltime Sign ID" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" TEXT,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Waypoint_1 Longitude" FLOAT8,
	"Waypoint_1 Latitude" FLOAT8,
	"Waypoint_2 Longitude" FLOAT8,
	"Waypoint_2 Latitude" FLOAT8,
	"Waypoint_3 Longitude" FLOAT8,
	"Waypoint_3 Latitude" FLOAT8,
	"Waypoint_4 Longitude" FLOAT8,
	"Waypoint_4 Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	tts_sign_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	publish_route,
	route_geometry
	) VALUES(
	$1,
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($6, $7),
			 ST_MakePoint($8, $9),
			 ST_MakePoint($10, $11),
			 ST_MakePoint($12, $13),
			 ST_MakePoint($14, $15),
			 ST_MakePoint($16, $17)]
			),4326)
		)
	) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"Traveltime Sign ID" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" TEXT,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Waypoint_1 Longitude" FLOAT8,
	"Waypoint_1 Latitude" FLOAT8,
	"Waypoint_2 Longitude" FLOAT8,
	"Waypoint_2 Latitude" FLOAT8,
	"Waypoint_3 Longitude" FLOAT8,
	"Waypoint_3 Latitude" FLOAT8,
	"Waypoint_4 Longitude" FLOAT8,
	"Waypoint_4 Latitude" FLOAT8,
	"Waypoint_5 Longitude" FLOAT8,
	"Waypoint_5 Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	tts_sign_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	publish_route,
	route_geometry
	) VALUES(
	$1,
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($6, $7),
			 ST_MakePoint($8, $9),
			 ST_MakePoint($10, $11),
			 ST_MakePoint($12, $13),
			 ST_MakePoint($14, $15),
			 ST_MakePoint($16, $17),
			 ST_MakePoint($18, $19)]
			),4326)
		)
	) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"Traveltime Sign ID" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" TEXT,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Waypoint_1 Longitude" FLOAT8,
	"Waypoint_1 Latitude" FLOAT8,
	"Waypoint_2 Longitude" FLOAT8,
	"Waypoint_2 Latitude" FLOAT8,
	"Waypoint_3 Longitude" FLOAT8,
	"Waypoint_3 Latitude" FLOAT8,
	"Waypoint_4 Longitude" FLOAT8,
	"Waypoint_4 Latitude" FLOAT8,
	"Waypoint_5 Longitude" FLOAT8,
	"Waypoint_5 Latitude" FLOAT8,
	"Waypoint_6 Longitude" FLOAT8,
	"Waypoint_6 Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	tts_sign_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	publish_route,
	route_geometry
	) VALUES(
	$1,
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($6, $7),
			 ST_MakePoint($8, $9),
			 ST_MakePoint($10, $11),
			 ST_MakePoint($12, $13),
			 ST_MakePoint($14, $15),
			 ST_MakePoint($16, $17),
			 ST_MakePoint($18, $19),
			 ST_MakePoint($20, $21)]
			),4326)
		)
	) RETURNING true;
	$$ language sql STRICT;