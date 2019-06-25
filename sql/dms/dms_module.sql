-- avl_module.sql
-- @author bfischer
-- @copyright INDOT, 2019
-- @license MIT
-- Sets up the required database and fuctions for the DMS schema 
\connect tms

CREATE SCHEMA IF NOT EXISTS dms;
ALTER SCHEMA dms owner TO tms_app;

CREATE TABLE IF NOT EXISTS dms.type(
	id SERIAL PRIMARY KEY,
	type VARCHAR(128) NOT NULL
);
ALTER TABLE dms.type OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS dms.manufacturer(
 id SERIAL PRIMARY KEY,
 manufacturer VARCHAR(128) NOT NULL
 );
ALTER TABLE dms.manufacturer OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS dms.model(
  id SERIAL PRIMARY KEY,
  manufacturer_id INTEGER NOT NULL REFERENCES dms.manufacturer(id),
  model VARCHAR(128) NOT NULL
);
ALTER TABLE dms.model OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS dms.authentication_type (
  id SERIAL PRIMARY KEY,
  authentication_type VARCHAR(128)
);
ALTER TABLE dms.authentication_type OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS dms.authentication_credentials (
  id SERIAL PRIMARY KEY,
  credential_name VARCHAR(128),
  username VARCHAR(128),
  password VARCHAR(128)
);
ALTER TABLE dms.authentication_type OWNER TO tms_app;

CREATE TABLE IF NOT EXISTS dms.device(
	id SERIAL PRIMARY KEY,
	location_geometry public.geometry,
	type_id INTEGER NOT NULL REFERENCES dms.type(id),
	manufacturer_id INTEGER NOT NULL REFERENCES dms.manufacturer(id),
  model_id INTEGER  NOT NULL REFERENCES dms.model(id),
  authentication_type_id INTEGER NOT NULL REFERENCES dms.authentication_type(id),
  authentication_credentials_id INTEGER REFERENCES dms.authentication_credentials(id),
  ipv4 INET,
  ipv6 INET,
  friendly_name VARCHAR(128) UNIQUE,
  description VARCHAR(128),
  publish_sign BOOLEAN DEFAULT FALSE,
  sign_online BOOLEAN DEFAULT FALSE
);
ALTER TABLE dms.device OWNER TO tms_app;


-- Insert function for manufacturer
CREATE OR REPLACE FUNCTION dms.add_manufacturer(
  "Manufacturer" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO dms.manufacturer (
    manufacturer
) VALUES(
  $1
) RETURNING true;
$$ language sql STRICT;

-- Insert function for model
CREATE OR REPLACE FUNCTION dms.add_model (
  "Manufacturer" TEXT,
  "Model" TEXT
)  RETURNS BOOLEAN AS $$
  INSERT INTO dms.model(
    manufacturer_id,
    model
) VALUES(
  (SELECT id from dms.manufacturer WHERE manufacturer = $1),
  $2
  ) RETURNING true;
$$ language sql STRICT;

-- Insert for authentication type
CREATE OR REPLACE FUNCTION dms.add_authentication_type (
  "Authentication" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO dms.authentication_type(
    authentication_type
  ) VALUES(
    $1
  ) RETURNING true;
  $$ language sql STRICT;

-- Insert for credentials
CREATE OR REPLACE FUNCTION dms.add_authentication_credentials (
  "Credential name" TEXT,
  "Username" TEXT,
  "Password" TEXT
) RETURNS BOOLEAN AS $$
  INSERT INTO dms.authentication_credentials(
    credential_name,
    username,
    password
) VALUES(
  $1,
  $2,
  $3
) RETURNING true;
$$ language sql STRICT;

CREATE OR REPLACE FUNCTION dms.add_device(
	"Longitude" FLOAT8,
	"Latitude" FLOAT8,
	"Type" Text,
	"Manufacturer" TEXT,
	"Model" TEXT,
	"Authentication Type" TEXT,
	"Authentication Credentials" TEXT,
	"IPv4 Address" INET,
	"IPv6 Address" INET,
	"Friendly Name" TEXT,
	"Description" TEXT,
	"Publish Sign" BOOL,
	"Sign Online" BOOL
	) RETURNS BOOLEAN AS $$
INSERT INTO dms.device(
	location_geometry,
	type_id,
	manufacturer_id,
	model_id,
	authentication_type_id,
	authentication_credentials_id,
	ipv4,
	ipv6,
	friendly_name,
	description,
	publish_sign,
	sign_online
) VALUES (
	(SELECT ST_SetSRID(St_Makepoint($1, $2),4326)),
	(SELECT id FROM dms.type WHERE type = $3),
	(SELECT id from dms.manufacturer WHERE manufacturer = $4),
  (SELECT id from dms.model WHERE model = $5 and manufacturer_id = (
    SELECT id from dms.manufacturer WHERE manufacturer = $4)),
  (SELECT id from dms.authentication_type WHERE authentication_type = $6),
  (SELECT id from dms.authentication_credentials WHERE credential_name = $7),
  $8,
  $9,
  $10,
  $11,
  $12,
  $13
) RETURNING true;
$$ language sql STRICT;