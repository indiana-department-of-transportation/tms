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

CREATE TABLE IF NOT EXISTS camera.device (
  id SERIAL PRIMARY KEY,
  location_geometry public.geometry NOT NULL,
  control_id INTEGER NOT NULL REFERENCES camera.control(id),
  manufacturer_id INTEGER NOT NULL REFERENCES camera.manufacturer(id),
  model_id INTEGER  NOT NULL REFERENCES camera.model(id),
  ipv4 INET,
  ipv6 INET,
  multicast INET,
  friendly_name VARCHAR(128),
  publish_stream BOOLEAN DEFAULT FALSE,
  publish_snapshot BOOLEAN DEFAULT FALSE
);
ALTER TABLE camera.device OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS camera.channel (
  id SERIAL PRIMARY KEY,
  model_id INTEGER NOT NULL REFERENCES camera.model(id),
  channel_name VARCHAR(128),
  stillshot_url_extension VARCHAR(128),
  stillshot_protocol VARCHAR(128),
  primary_stillshot BOOLEAN DEFAULT FALSE,
  stream_url_extension VARCHAR(128),
  stream_protocol VARCHAR(128)
);
ALTER TABLE camera.channel OWNER TO tms_app;

-- Insert function for manufacturer
CREATE OR REPLACE FUNCTION camera.add_manufacturer(
  TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.manufacturer (
    manufacturer
) VALUES(
  $1
) RETURNING true;
$$ language sql STRICT;

-- Insert function for model
CREATE OR REPLACE FUNCTION camera.add_model (
  TEXT,
  TEXT
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
CREATE OR REPLACE FUNCTION camera.add_device(
  GEOMETRY,
  TEXT,
  TEXT,
  TEXT,
  INET,
  INET,
  INET,
  TEXT,
  BOOLEAN,
  BOOLEAN
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.device (
    location_geometry,
    control_id,
    manufacturer_id,
    model_id,
    ipv4,
    ipv6,
    multicast,
    friendly_name,
    publish_stream,
    publish_snapshot
) VALUES (
  POINT($1)::geometry,
  (SELECT id from camera.control WHERE control_protocol = $2),
  (SELECT id from camera.manufacturer_id WHERE manufacturer = $3),
  (SELECT id from camera.model WHERE model = $4),
  $5,
  $6,
  $7,
  $8,
  $9,
  $10
) RETURNING true;
$$ language sql STRICT;

-- Insertion function for control protocols
CREATE OR REPLACE FUNCTION camera.add_control_protocol(
  TEXT, 
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.control (
    control_protocol
) VALUES (
  $1
) RETURNING true;
$$ language sql STRICT;

-- Insertion function for channel
CREATE OR REPLACE FUNCTION camera.add_channel(
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  BOOLEAN,
  TEXT,
  TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO camera.channel (
    model_id,
    channel_name,
    stillshot_url_extension,
    stillshot_protocol,
    primary_stillshot,
    stream_url_extension,
    stream_protocol
) VALUES (
  (SELECT id from camera.model WHERE model = $1),
  $2,
  $3,
  $4,
  $5,
  $6,
  $7
) RETURNING true;
$$ language sql STRICT;