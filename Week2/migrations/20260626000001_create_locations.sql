CREATE TABLE IF NOT EXISTS locations (
    location_id   SERIAL        PRIMARY KEY,
    city_name     VARCHAR(100)  NOT NULL UNIQUE
);
