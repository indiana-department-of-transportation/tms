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

CREATE TABLE IF NOT EXISTS camera.authentication_type (
  id SERIAL PRIMARY KEY,
  authentication_type VARCHAR(128)
);
ALTER TABLE camera.authentication_type OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS camera.authentication_credentials (
  id SERIAL PRIMARY KEY,
  credential_name VARCHAR(128),
  username VARCHAR(128),
  password VARCHAR(128)
);
ALTER TABLE camera.authentication_type OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS camera.device (
  id SERIAL PRIMARY KEY,
  location_geometry public.geometry,
  control_id INTEGER NOT NULL REFERENCES camera.control(id),
  manufacturer_id INTEGER NOT NULL REFERENCES camera.manufacturer(id),
  model_id INTEGER  NOT NULL REFERENCES camera.model(id),
  type_id INTEGER NOT NULL REFERENCES camera.type(id),
  snapshot_channel_id INTEGER NOT NULL REFERENCES camera.channel(id),
  authentication_type_id INTEGER NOT NULL REFERENCES camera.authentication_type(id),
  authentication_credentials_id INTEGER REFERENCES camera.authentication_credentials(id),
  ipv4 INET,
  ipv6 INET,
  multicast INET,
  friendly_name VARCHAR(128) UNIQUE,
  description VARCHAR(128),
  camera_number INTEGER NOT NULL UNIQUE,
  physical_number INTEGER NOT NULL,
  publish_stream BOOLEAN DEFAULT FALSE,
  publish_snapshot BOOLEAN DEFAULT FALSE,
  latency INTEGER NOT NULL
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

-- Insert for authentication type
CREATE OR REPLACE FUNCTION camera.add_authentication_type (
  "Authentication" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.authentication_type(
    authentication_type
  ) VALUES(
    $1
  ) RETURNING true;
  $$ language sql STRICT;

-- Insert for credentials
CREATE OR REPLACE FUNCTION camera.add_authentication_credentials (
  "Credential name" TEXT,
  "Username" TEXT,
  "Password" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.authentication_credentials(
    credential_name,
    username,
    password
) VALUES(
  $1,
  $2,
  $3
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
  "Authentication type" text,
  "Authentication credentials" text,
  "IPv4 Address" inet,
  "IPv6 Address" inet,
  "Multicast Address" inet,
  "Friendly name" text,
  "Description" text,
  "Camera number" int4,
  "Physical number" int4,
  "Publish stream" bool,
  "Publish snapshot" bool,
  "Latency" int4
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.device (
    location_geometry,
    control_id,
    manufacturer_id,
    model_id,
    type_id,
    snapshot_channel_id,
    authentication_type_id,
    authentication_credentials_id,
    ipv4,
    ipv6,
    multicast,
    friendly_name,
    description,
    camera_number,
    physical_number,
    publish_stream,
    publish_snapshot,
    latency
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
  (SELECT id from camera.authentication_type WHERE authentication_type = $8),
  (SELECT id from camera.authentication_credentials WHERE credential_name = $9),
  $10,
  $11,
  $12,
  $13,
  $14,
  $15,
  $16,
  $17,
  $18,
  $19
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

CREATE OR REPLACE FUNCTION camera.get_auth_types () RETURNS TABLE(
  id INT,
  authentication_type VARCHAR(128)
) AS $$ SELECT
  id,
  authentication_type
FROM
  camera.authentication_type
$$ LANGUAGE SQL STRICT;

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
    authentication_type VARCHAR(128),
    username VARCHAR(128),
    password VARCHAR(128),
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
  authentication_type.authentication_type,
  authentication_credentials.username,
  authentication_credentials.password,
  device.ipv4,
  device.ipv6,
  device.multicast,
  device.friendly_name,
  device.description,
  device.camera_number,
  device.publish_stream,
  device.publish_snapshot 
FROM
  camera.device
  INNER JOIN camera.control ON device.control_id = control.id
  INNER JOIN camera.manufacturer ON device.manufacturer_id = manufacturer.id
  INNER JOIN camera.model ON device.model_id = model.id
  INNER JOIN camera.channel ON device.snapshot_channel_id = channel.id
  INNER JOIN camera.authentication_type ON device.authentication_type_id = authentication_type.id
  INNER JOIN camera.authentication_credentials ON device.authentication_credentials_id = authentication_credentials.id
WHERE
  device.publish_stream = TRUE 
  OR device.publish_snapshot = TRUE;
$$ LANGUAGE SQL STRICT;


-- Begin Monitor Related SQL
CREATE TABLE IF NOT EXISTS camera.video_driver(
 id SERIAL PRIMARY KEY,
 driver VARCHAR(128) NOT NULL
);
ALTER TABLE camera.video_driver OWNER to tms_app;

-- Conflicted if this table should reside in cctv, or public.
-- Could be used in permission management
CREATE TABLE IF NOT EXISTS camera.monitor_group(
 id SERIAL PRIMARY KEY,
 name VARCHAR(128) NOT NULL,
 location VARCHAR(128)
);
ALTER TABLE camera.monitor_group OWNER to tms_app;

CREATE TABLE IF NOT EXISTS camera.monitor_layout(
 id SERIAL PRIMARY KEY,
 name VARCHAR(128) NOT NULL,
 description VARCHAR(128) NOT NULL
);
ALTER TABLE camera.monitor_layout OWNER to tms_app;

CREATE TABLE IF NOT EXISTS camera.monitor(
 id SERIAL PRIMARY KEY,
 video_driver_id INTEGER NOT NULL REFERENCES camera.video_driver(id),
 monitor_group_id INTEGER NOT NULL REFERENCES camera.monitor_group(id),
 current_layout_id INTEGER REFERENCES camera.monitor_layout(id),
 friendly_name VARCHAR(128) NOT NULL,
 location_description VARCHAR(128),
 online BOOLEAN DEFAULT FALSE,
 publish_monitor BOOLEAN DEFAULT FALSE
 );
ALTER TABLE camera.monitor OWNER to tms_app;

CREATE TABLE IF NOT EXISTS camera.active_camera(
  id SERIAL PRIMARY KEY,
  position INTEGER NOT NULL,
  device_id INTEGER NOT NULL REFERENCES camera.device(id),
  device_channel INTEGER NOT NULL REFERENCES camera.channel(id)
  );
ALTER TABLE camera.active_camera OWNER to tms_app;

CREATE OR REPLACE FUNCTION camera.add_video_driver(
  "Driver Name" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.video_driver (
  driver
) VALUES (
  $1
) RETURNING TRUE;
$$ language SQL STRICT;

CREATE OR REPLACE FUNCTION camera.add_monitor_group(
  "Name" TEXT,
  "Location" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.monitor_group(
  name,
  location
) VALUES (
  $1,
  $2
) RETURNING TRUE;
$$ LANGUAGE SQL STRICT;

CREATE OR REPLACE FUNCTION camera.add_monitor_layout(
  "Name" TEXT,
  "Description" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.monitor_layout(
  name,
  description
) VALUES (
  $1,
  $2
) RETURNING TRUE;
$$ LANGUAGE SQL STRICT;

CREATE OR REPLACE FUNCTION camera.add_monitor(
  "Video Driver Name" TEXT,
  "Monitor Group Name" TEXT,
  "Current Layout Name" TEXT,
  "Friendly Name" TEXT,
  "Location Description" TEXT,
  "Online" BOOL,
  "Publish" BOOL
) RETURNS BOOLEAN AS $$
 INSERT INTO camera.monitor(
  video_driver_id,
  monitor_group_id,
  current_layout_id,
  friendly_name,
  location_description,
  online,
  publish_monitor
 ) VALUES (
  (SELECT id from camera.video_driver WHERE driver = $1),
  (SELECT id from camera.monitor_group WHERE name = $2),
  (SELECT id from camera.monitor_layout WHERE name = $3),
  $4,
  $5,
  $6,
  $7
) RETURNING TRUE;
$$ LANGUAGE SQL STRICT;

-- ToDO: create functions for adding and updating currently active camera.