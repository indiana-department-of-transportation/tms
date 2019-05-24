-- camera_module.sql
-- @author bfischer
-- @copyright INDOT, 2019
-- @license MIT
-- Sets up the required database and functions for the cameras schema

\connect tms

CREATE SCHEMA IF NOT EXISTS camera;
ALTER SCHEMA camera OWNER TO tms_app;

CREATE OR REPLACE FUNCTION public.execute(TEXT) RETURNS VOID AS $$
BEGIN EXECUTE $1; END;
$$ LANGUAGE plpgsql STRICT;

CREATE OR REPLACE FUNCTION public.table_exists(TEXT, TEXT) RETURNS bool as $$
    SELECT exists(SELECT 1 FROM information_schema.tables WHERE (table_schema, table_name, table_type) = ($1, $2, 'BASE TABLE'));
$$ language sql STRICT;

CREATE TABLE IF NOT EXISTS camera.manufacturer(
 id SERIAL PRIMARY KEY,
 manufacturer VARCHAR(128) NOT NULL
 );
ALTER TABLE camera.manufacturer OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS camera.model(
  id SERIAL PRIMARY KEY,
  manufacturer_id INTEGER NOT NULL REFERENCES camera.manufacturer(id),
  model VARCHAR(128) NOT NULL
);
ALTER TABLE camera.model OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS camera.control(
  id SERIAL PRIMARY KEY,
  control_protocol VARCHAR(128) NOT NULL
);
ALTER TABLE camera.control OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS camera.type(
  id SERIAL PRIMARY KEY,
  type VARCHAR(128) NOT NULL
);
ALTER TABLE camera.type OWNER to tms_app;

CREATE TABLE IF NOT EXISTS camera.channel (
  id SERIAL PRIMARY KEY,
  model_id INTEGER NOT NULL REFERENCES camera.model(id),
  channel_name VARCHAR(128),
  stillshot_url_extension VARCHAR(128),
  stillshot_protocol VARCHAR(128),
  stream_url_extension VARCHAR(128),
  stream_protocol VARCHAR(128)
);
ALTER TABLE camera.channel OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS camera.device (
  id SERIAL PRIMARY KEY,
  location_geometry public.geometry,
  control_id INTEGER NOT NULL REFERENCES camera.control(id),
  manufacturer_id INTEGER NOT NULL REFERENCES camera.manufacturer(id),
  model_id INTEGER  NOT NULL REFERENCES camera.model(id),
  type_id INTEGER NOT NULL REFERENCES camera.type(id),
  snapshot_channel_id INTEGER NOT NULL REFERENCES camera.channel(id),
  ipv4 INET,
  ipv6 INET,
  multicast INET,
  friendly_name VARCHAR(128) UNIQUE,
  description VARCHAR(128),
  camera_number INTEGER NOT NULL UNIQUE,
  physical_number INTEGER NOT NULL,
  publish_stream BOOLEAN DEFAULT FALSE,
  publish_snapshot BOOLEAN DEFAULT FALSE
);
ALTER TABLE camera.device OWNER TO tms_app;

-- Insert function for manufacturer
CREATE OR REPLACE FUNCTION camera.add_manufacturer(
  "Manufacturer" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.manufacturer (
    manufacturer
) VALUES(
  $1
) RETURNING true;
$$ language sql STRICT;

-- Insert function for model
CREATE OR REPLACE FUNCTION camera.add_model (
  "Manufacturer" TEXT,
  "Model" TEXT
)  RETURNS BOOLEAN AS $$
  INSERT INTO camera.model(
    manufacturer_id,
    model
) VALUES(
  (SELECT id from camera.manufacturer WHERE manufacturer = $1),
  $2
  ) RETURNING true;
$$ language sql STRICT;

-- Insertion function for device
CREATE OR REPLACE FUNCTION "camera"."add_device"(
  "longitude" float8,
  "latitude" float8,
  "control protocol" text,
  "manufacturer" text,
  "model" text,
  "type" text,
  "snapshot_channel" text,
  "IPv4 Address" inet,
  "IPv6 Address" inet,
  "Multicast Address" inet,
  "Friendly name" text,
  "Description" text,
  "Camera number" int4,
  "Physical number" int4,
  "Publish stream" bool,
  "Publish snapshot" bool
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.device (
    location_geometry,
    control_id,
    manufacturer_id,
    model_id,
    type_id,
    snapshot_channel_id,
    ipv4,
    ipv6,
    multicast,
    friendly_name,
    description,
    camera_number,
    physical_number,
    publish_stream,
    publish_snapshot
) VALUES (
  (SELECT ST_SetSRID(ST_Makepoint($1, $2),4326)),
  (SELECT id from camera.control WHERE control_protocol = $3),
  (SELECT id from camera.manufacturer WHERE manufacturer = $4),
  (SELECT id from camera.model WHERE model = $5 and manufacturer_id = (
    SELECT id from camera.manufacturer WHERE manufacturer = $4)),
  (SELECT id from camera.type WHERE type = $6 ),
  (SELECT id from camera.channel WHERE model_id = (
    SELECT id from camera.model WHERE model = $5
  ) and channel.channel_name = $7),
  $8,
  $9,
  $10,
  $11,
  $12,
  $13,
  $14,
  $15,
  $16
) RETURNING true;
$$ language sql STRICT;



-- Insertion function for control protocols
CREATE OR REPLACE FUNCTION camera.add_control_protocol(
  "Control protocol" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.control (
    control_protocol
) VALUES (
  $1
) RETURNING true;
$$ language sql STRICT;

-- Insertion function for channel
CREATE OR REPLACE FUNCTION camera.add_channel(
  "Model" TEXT,
  "Channel name" TEXT,
  "Stillshot URL Extension" TEXT,
  "Stillshot protocl" TEXT,
  "Stream URL extension" TEXT,
  "Stream protocol" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.channel (
    model_id,
    channel_name,
    stillshot_url_extension,
    stillshot_protocol,
    stream_url_extension,
    stream_protocol
) VALUES (
  (SELECT id from camera.model WHERE model = $1),
  $2,
  $3,
  $4,
  $5,
  $6
) RETURNING true;
$$ language sql STRICT;

CREATE OR REPLACE FUNCTION camera.add_type(
  "Type" TEXT
) RETURNS BOOLEAN AS $$
INSERT INTO camera.type(
  type
) VALUES (
  $1
) RETURNING true;
$$ language sql STRICT;

CREATE OR REPLACE FUNCTION camera.get_all_cameras () RETURNS TABLE (
    longitude FLOAT8,
    latitude FLOAT8,
    control_protocol VARCHAR ( 128 ),
    manufacturer VARCHAR ( 128 ),
    model VARCHAR ( 128 ),
    stillshot_protocol VARCHAR ( 128 ),
    stillshot_url_extension VARCHAR ( 128 ),
    stream_protocol VARCHAR ( 128 ),
    stream_url_extension VARCHAR ( 128 ),
    ipv4 INET,
    ipv6 INET,
    multicast INET,
    friendly_name VARCHAR ( 128 ),
    description VARCHAR ( 128 ),
    camera_number INT4,
    publish_stream BOOL,
    publish_snapshot BOOL 
  ) AS $$ SELECT
  ST_X ( device.location_geometry ) AS longitude,
  ST_Y ( device.location_geometry ) AS latitude,
  control.control_protocol,
  manufacturer.manufacturer,
  model.model,
  channel.stillshot_protocol,
  channel.stillshot_url_extension,
  channel.stream_protocol,
  channel.stream_url_extension,
  device.ipv4,
  device.ipv6,
  device.multicast,
  device.friendly_name,
  device.description,
  device.camera_number,
  device.publish_stream,
  device.publish_snapshot 
FROM
  device
  INNER JOIN control ON device.control_id = control.
  ID INNER JOIN manufacturer ON device.manufacturer_id = manufacturer.
  ID INNER JOIN model ON device.model_id = model.
  ID INNER JOIN channel ON device.snapshot_channel_id = channel.ID 
WHERE
  device.publish_stream = TRUE 
  OR device.publish_snapshot = TRUE;
$$ LANGUAGE SQL STRICT;