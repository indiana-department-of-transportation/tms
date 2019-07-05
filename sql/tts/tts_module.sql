-- avl_module.sql
-- @author bfischer
-- @copyright INDOT, 2019
-- @license MIT
-- Sets up the required database and fuctions for the Travel Time schema 
\connect tms

CREATE SCHEMA IF NOT EXISTS tts;
ALTER SCHEMA tts owner TO tms_app;

CREATE TABLE IF NOT EXISTS tts.source(
	id SERIAL PRIMARY KEY,
	source VARCHAR(128) NOT NULL
);
ALTER TABLE tts.source OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS tts.route(
	id SERIAL PRIMARY KEY,
	dms_device_id INTEGER NOT NULL REFERENCES dms.device(id),
	tts_source_id INTEGER NOT NULL REFERENCES tts.source(id),
  route_geometry public.geometry,
  direction FLOAT8 NOT NULL,
  destination_friendly_name VARCHAR(128),
  base_minutes INTEGER,
  sign_position INTEGER,
  publish_route BOOLEAN DEFAULT FALSE
);
ALTER TABLE tts.route OWNER TO tms_app;

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
	"DMS Friendly Name" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" INTEGER,
	"Sign Position" INTEGER,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	dms_device_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	sign_position,
	publish_route,
	route_geometry,
  direction
	) VALUES(
	(SELECT id FROM  dms.device WHERE friendly_name = $1),
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	$6,
	(SELECT ST_SetSRID(
		ST_MakeLine(
			 ST_MakePoint($7, $8),
			 ST_MakePoint($9, $10)
			),4326)
		),
  (SELECT degrees(
    ST_Azimuth(
      ST_MakePoint($7,$8),
      ST_MakePoint($9, $10)
      )
    )
	)
) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"DMS Friendly Name" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" INTEGER,
	"Sign Position" INTEGER,
	"Publish Route" BOOLEAN,
	"Origin Longitude" FLOAT8,
	"Origin Latitude" FLOAT8,
	"Waypoint_1 Longitude" FLOAT8,
	"Waypoint_1 Latitude" FLOAT8,
	"Destination Longitude" FLOAT8,
	"Destination Latitude" FLOAT8
) RETURNS BOOLEAN AS $$
INSERT INTO tts.route(
	dms_device_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	sign_position,
	publish_route,
	route_geometry,
  direction
	) VALUES(
	(SELECT id FROM  dms.device WHERE friendly_name = $1),
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	$6,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($7, $8),
			 ST_MakePoint($9, $10),
			 ST_MakePoint($11, $12)]
			),4326)
		),
  (SELECT degrees(
    ST_Azimuth(
      ST_MakePoint($7,$8),
      ST_MakePoint($11, $12)
      )
    )
	)
) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"DMS Friendly Name" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" INTEGER,
	"Sign Position" INTEGER,
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
	dms_device_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	sign_position,
	publish_route,
	route_geometry,
  direction
	) VALUES(
	(SELECT id FROM  dms.device WHERE friendly_name = $1),
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	$6,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($7, $8),
			 ST_MakePoint($9, $10),
			 ST_MakePoint($11, $12),
			 ST_MakePoint($13, $14)]
			),4326)
		),
  (SELECT degrees(
    ST_Azimuth(
      ST_MakePoint($7,$8),
      ST_MakePoint($13, $14)
      )
    )
	)
) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"DMS Friendly Name" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" INTEGER,
	"Sign Position" INTEGER,
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
	dms_device_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	sign_position,
	publish_route,
	route_geometry,
  direction
	) VALUES(
	(SELECT id FROM  dms.device WHERE friendly_name = $1),
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	$6,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($7, $8),
			 ST_MakePoint($9, $10),
			 ST_MakePoint($11, $12),
			 ST_MakePoint($13, $14),
			 ST_MakePoint($15, $16)]
			),4326)
		),
  (SELECT degrees(
    ST_Azimuth(
      ST_MakePoint($7,$8),
      ST_MakePoint($15, $16)
      )
    )
	)
) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"DMS Friendly Name" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" INTEGER,
	"Sign Position" INTEGER,
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
	dms_device_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	sign_position,
	publish_route,
	route_geometry,
  direction
	) VALUES(
	(SELECT id FROM  dms.device WHERE friendly_name = $1),
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	$6,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($7, $8),
			 ST_MakePoint($9, $10),
			 ST_MakePoint($11, $12),
			 ST_MakePoint($13, $14),
			 ST_MakePoint($15, $16),
			 ST_MakePoint($17, $18)]
			),4326)
		),
  (SELECT degrees(
    ST_Azimuth(
      ST_MakePoint($7,$8),
      ST_MakePoint($17, $18)
      )
    )
	)
) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"DMS Friendly Name" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" INTEGER,
	"Sign Position" INTEGER,
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
	dms_device_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	sign_position,
	publish_route,
	route_geometry,
  direction
	) VALUES(
	(SELECT id FROM  dms.device WHERE friendly_name = $1),
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	$6,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($7, $8),
			 ST_MakePoint($9, $10),
			 ST_MakePoint($11, $12),
			 ST_MakePoint($13, $14),
			 ST_MakePoint($15, $16),
			 ST_MakePoint($17, $18),
			 ST_MakePoint($19, $20)]
			),4326)
		),
  (SELECT degrees(
    ST_Azimuth(
      ST_MakePoint($7,$8),
      ST_MakePoint($19, $20)
      )
    )
	)
) RETURNING true;
	$$ language sql STRICT;

CREATE OR REPLACE FUNCTION tts.add_route(
	"DMS Friendly Name" TEXT,
	"Traveltime Source" TEXT,
	"Destination Friendly Name" TEXT,
	"Base Minutes" INTEGER,
	"Sign Position" INTEGER,
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
	dms_device_id,
	tts_source_id,
	destination_friendly_name,
	base_minutes,
	sign_position,
	publish_route,
	route_geometry,
  direction
	) VALUES(
	(SELECT id FROM  dms.device WHERE friendly_name = $1),
	(SELECT id from tts.source WHERE source = $2),
	$3,
	$4,
	$5,
	$6,
	(SELECT ST_SetSRID(
		ST_MakeLine(ARRAY[
			 ST_MakePoint($7, $8),
			 ST_MakePoint($9, $10),
			 ST_MakePoint($11, $12),
			 ST_MakePoint($13, $14),
			 ST_MakePoint($15, $16),
			 ST_MakePoint($17, $18),
			 ST_MakePoint($19, $20),
			 ST_MakePoint($21, $22)]
			),4326)
		),
  (SELECT degrees(
    ST_Azimuth(
      ST_MakePoint($7,$8),
      ST_MakePoint($21, $22)
      )
    )
	)
) RETURNING true;
	$$ language sql STRICT;

-- Retrieve route
CREATE OR REPLACE FUNCTION tts.get_published_routes()
RETURNS TABLE (
	dms_friendly_name VARCHAR(128),
	direction FLOAT8,
	destination_friendly_name VARCHAR(128),
	base_minutes INTEGER,
	sign_position INTEGER,
	route_geometry public.geometry
) AS $$ SELECT
	dms.device.friendly_name,
	route.direction,
	route.destination_friendly_name,
	route.base_minutes,
	route.sign_position,
	route.route_geometry
FROM
	tts.route
	INNER JOIN dms.device ON route.dms_device_id = device.id
WHERE
	publish_route = TRUE;
$$ LANGUAGE SQL STRICT;
